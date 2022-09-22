// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:typed_data';

import 'package:pana/pana.dart';
import 'package:pana/src/utils.dart';
import 'package:path/path.dart' as path;
import 'package:pubspec_parse/pubspec_parse.dart' as p;

final maxFileSizeInBytes = 4194304; // 4MB
final maxFileSizeInMegaBytes = maxFileSizeInBytes / (1024 * 1024);
final maxNumberOfScreenshots = 10;

/// [ScreenshotResult] holds either a [ProcessedScreenshot] or a list of
/// problems describing what went wrong when trying to generate thumbnails and
/// screenshot.
class ScreenshotResult {
  ProcessedScreenshot? processedScreenshot;
  Uint8List? webpImageBytes;
  Uint8List? webp100ThumbnailBytes;
  Uint8List? png100ThumbnailBytes;
  Uint8List? webp190ThumbnailBytes;
  Uint8List? png190ThumbnailBytes;
  List<String> problems;

  ScreenshotResult._(
    this.processedScreenshot,
    this.webpImageBytes,
    this.webp100ThumbnailBytes,
    this.png100ThumbnailBytes,
    this.webp190ThumbnailBytes,
    this.png190ThumbnailBytes,
    this.problems,
  );

  factory ScreenshotResult.success(
    ProcessedScreenshot processedScreenshot,
    Uint8List webpImageBytes,
    Uint8List webp100ThumbnailBytes,
    Uint8List png100ThumbnailBytes,
    Uint8List webp190ThumbnailBytes,
    Uint8List png190ThumbnailBytes,
  ) {
    return ScreenshotResult._(
        processedScreenshot,
        webpImageBytes,
        webp100ThumbnailBytes,
        png100ThumbnailBytes,
        webp190ThumbnailBytes,
        png190ThumbnailBytes, []);
  }

  factory ScreenshotResult.failed(List<String> problems) {
    return ScreenshotResult._(null, null, null, null, null, null, problems);
  }
}

Future<List<ScreenshotResult>> processAllScreenshots(
    List<p.Screenshot> screenshots, String pkgDir) async {
  final tempDir = Directory.systemTemp.createTempSync();
  try {
    final results = <ScreenshotResult>[];
    var processedScreenshots = 0;
    for (final screenshot in screenshots) {
      final problems = <String>[];
      if (processedScreenshots == maxNumberOfScreenshots) {
        results.add(ScreenshotResult.failed(
          [
            '${screenshot.path}: Not processed. pub.dev shows at most $maxNumberOfScreenshots screenshots.'
          ],
        ));
        continue;
      }

      problems.addAll(_validateScreenshot(screenshot, pkgDir));
      if (problems.isNotEmpty) {
        results.add(ScreenshotResult.failed(problems));
        continue;
      }

      final result = await _processScreenshot(pkgDir, screenshot, tempDir.path);
      if (result.problems.isEmpty) {
        processedScreenshots++;
      }
      results.add(result);
    }
    return results;
  } finally {
    tempDir.deleteSync(recursive: true);
  }
}

List<String> _validateScreenshot(p.Screenshot screenshot, String pkgDir) {
  final problems = <String>[];
  if (screenshot.description.isEmpty) {
    problems.add(
        '${screenshot.path}: Screenshot `description` property is missing.');
  } else if (screenshot.description.length > 160) {
    problems.add(
        '${screenshot.path}: Screenshot `description` is too long. Description length must be less '
        'than 160 characters.');
  }
  if (screenshot.path.isEmpty) {
    problems.add('${screenshot.path}: Screenshot `path` property is missing.');
  }

  final fullPath = path.join(pkgDir, screenshot.path);
  if (!path.isWithin(pkgDir, fullPath)) {
    problems.add(
        '${screenshot.path}: Screenshot file path should be within the package.');
  }

  final origImage = File(fullPath);
  if (!origImage.existsSync()) {
    problems.add(
        '${screenshot.path}: No file found at specified screenshot `path` ${screenshot.path}');
  } else if (origImage.lengthSync() > maxFileSizeInBytes) {
    problems.add(
        '${screenshot.path}: Screenshot file size exceeds limit of $maxFileSizeInMegaBytes MB');
  }
  return problems;
}

Future<ScreenshotResult> _processScreenshot(
    String pkgDir, p.Screenshot e, String tempDir) async {
  final basename = path.basenameWithoutExtension(e.path);
  final webpName = '$basename.webp';
  final genDir = 'gen';
  final thumbnail100Dir = path.join(genDir, '100x100');
  final thumbnail190Dir = path.join(genDir, '190x190');
  final webpPath = path.join(genDir, webpName);
  final webp100ThumbnailPath = path.join(thumbnail100Dir, webpName);
  final webp190ThumbnailPath = path.join(thumbnail190Dir, webpName);
  final pngName = '$basename.png';
  final png100ThumbnailPath = path.join(thumbnail100Dir, pngName);
  final png190ThumbnailPath = path.join(thumbnail190Dir, pngName);
  final originalPath = path.join(pkgDir, e.path);

  Directory(path.join(tempDir, thumbnail100Dir)).createSync(recursive: true);
  Directory(path.join(tempDir, thumbnail190Dir)).createSync(recursive: true);

  final webpScreenshotProblems =
      await _generateWebpScreenshot(originalPath, path.join(tempDir, webpPath));
  if (webpScreenshotProblems.isNotEmpty) {
    return ScreenshotResult.failed(webpScreenshotProblems);
  }

  final thumbnailProblems = await _generateThumbnails(
    originalPath,
    path.join(tempDir, webpPath),
    path.join(tempDir, webp100ThumbnailPath),
    path.join(tempDir, png100ThumbnailPath),
    path.join(tempDir, webp190ThumbnailPath),
    path.join(tempDir, png190ThumbnailPath),
    tempDir,
  );
  if (thumbnailProblems.isNotEmpty) {
    return ScreenshotResult.failed(thumbnailProblems);
  }

  return ScreenshotResult.success(
    ProcessedScreenshot(e.path, e.description,
        webpImage: webpPath,
        webp100Thumbnail: webp100ThumbnailPath,
        png100Thumbnail: png100ThumbnailPath,
        webp190Thumbnail: webp190ThumbnailPath,
        png190Thumbnail: png190ThumbnailPath),
    File(path.join(tempDir, webpPath)).readAsBytesSync(),
    File(path.join(tempDir, webp100ThumbnailPath)).readAsBytesSync(),
    File(path.join(tempDir, png100ThumbnailPath)).readAsBytesSync(),
    File(path.join(tempDir, webp190ThumbnailPath)).readAsBytesSync(),
    File(path.join(tempDir, png190ThumbnailPath)).readAsBytesSync(),
  );
}

/// Generates a WebP screenshot given the original image at [originalPath] and
/// writes it to [targetWebpPath].
///
/// Returns a list of problems if generating the screenshot did not succeed.
/// On success, an empty list is returned.
///
/// The WebP screenshot can be either static or animated.
///
/// If the original image format is already WebP, the screenshot will simply be
/// copied over. The `webpinfo` tool is used for determining this.
/// Otherwise, a conversion is tried, using the `cwebp` tool which can handle
/// PNG, JPEG, and TIFF as input. For GIF files the `gif2webp` conversion tool
/// is used.
///
/// For any other input format the screenshot generation will fail. It will also
/// fail if any of the mentioned tools are not available on the command line and
/// an error message will be written to stderr.
Future<List<String>> _generateWebpScreenshot(
  String originalPath,
  String targetWebpPath,
) async {
  final problems = <String>[];
  final copyIfWebpProblems =
      await _copyIfAlreadyWebp(originalPath, targetWebpPath);
  if (copyIfWebpProblems.isEmpty) {
    return [];
  }
  problems.addAll(copyIfWebpProblems);

  final convertWithCwebpProblems =
      await _convertWithCWebp(originalPath, targetWebpPath);
  if (convertWithCwebpProblems.isEmpty) {
    return [];
  }
  problems.addAll(convertWithCwebpProblems);

  final gif2webpProblems =
      await _convertGifToWebp(originalPath, targetWebpPath);
  if (gif2webpProblems.isEmpty) {
    return [];
  }
  problems.addAll(gif2webpProblems);
  problems.add(
      'Generating webp image for $originalPath failed due to invalid input');
  return problems;
}

Future<List<String>> _copyIfAlreadyWebp(
    String originalPath, String webpPath) async {
  final infoResult = await _checkedRunProc(['webpinfo', originalPath]);
  if (infoResult.exitCode == 0) {
    await File(originalPath).copy(webpPath);
    return [];
  }
  return [
    '`$originalPath`: Tried interpreting screenshot as WebP with `webpinfo "$originalPath"` failed with _exit code_ `${infoResult.exitCode}`.'
  ];
}

Future<List<String>> _convertWithCWebp(
    String originalPath, String webpPath) async {
  final cwebpResult =
      await _checkedRunProc(['cwebp', originalPath, '-o', webpPath]);
  if (cwebpResult.exitCode == 0) {
    return [];
  }
  return [
    '`$originalPath`: Converting screenshot with `cwebp "$originalPath" -o "$webpPath"` failed with _exit code_ `${cwebpResult.exitCode}`.'
  ];
}

Future<List<String>> _convertGifToWebp(
    String originalPath, String webpPath) async {
  final gif2webpResult =
      await _checkedRunProc(['gif2webp', originalPath, '-o', webpPath]);

  if (gif2webpResult.exitCode == 0) {
    return [];
  }
  return [
    '`$originalPath`: Tried interpreting screenshot as GIF with `gif2webp "$originalPath" -o "$webpPath"` failed with _exit code_ `${gif2webpResult.exitCode}`.'
  ];
}

/// Generates PNG and a WebP thumbnails from the WebP screenshot found at
/// [webpPath] and writes them to [png100ThumbnailPath], [webp100ThumbnailPath]
/// [png190ThumbnailPath], and [webp190ThumbnailPath] respectively.
///
/// Returns a list of problems if generating the thumbnails did not succeed.
/// On success, an empty list is returned.
//
/// If the WebP screenshot is animated, the `webpmux` tool is used to extract
/// the first frame for the thumbnail.
///
/// The `webpinfo` tool is used to determine the original height and width. The
/// `cwebp` converter is used for resizing the screenshot. The `dwebp` converter
/// is used for generating the thumbnail in PNG.
///
/// Thumbnail generation will fail if any of the mentioned tools are not
/// available on the command line and an error message will be written to stderr.
Future<List<String>> _generateThumbnails(
    String originalPath,
    String webpPath,
    String webp100ThumbnailPath,
    String png100ThumbnailPath,
    String webp190ThumbnailPath,
    String png190ThumbnailPath,
    String tempDir) async {
  late String staticWebpPath;
  final infoResult = await _checkedRunProc(['webpinfo', webpPath]);
  if (infoResult.exitCode != 0) {
    return [
      '`$originalPath`: Running `webpinfo "$webpPath"` failed with _exit code_ ${infoResult.exitCode}.'
    ];
  }

  if ((infoResult.stdout.asString).contains('Animation: 1')) {
    staticWebpPath = path.join(
      tempDir,
      '${path.basenameWithoutExtension(webpPath)}_static.webp',
    );
    // input file is animated, extract the first frame.
    final webpmuxResult = await _checkedRunProc(
        ['webpmux', '-get', 'frame', '1', webpPath, '-o', staticWebpPath]);

    if (webpmuxResult.exitCode != 0) {
      return [
        '`$originalPath`: Extracting frame from $webpPath with `webpmux -get frame 1 "$webpPath" -o "$staticWebpPath"` failed with _exit code_ `${webpmuxResult.exitCode}`.'
      ];
    }
  } else {
    staticWebpPath = webpPath;
  }

  final stdout = infoResult.stdout.asString;
  final lines = stdout.split('\n');
  final widthString =
      lines.firstWhere((String line) => line.contains('Width:'));
  final heightString =
      lines.firstWhere((String line) => line.contains('Height:'));
  final width = int.parse(widthString.split(':').last.trim());
  final height = int.parse(heightString.split(':').last.trim());

  final int width100Argument;
  final int height100Argument;
  final int width190Argument;
  final int height190Argument;

  if (width > height) {
    width100Argument = 100;
    width190Argument = 190;
    height100Argument = 0;
    height190Argument = 0;
  } else {
    width100Argument = 0;
    width190Argument = 0;
    height100Argument = 100;
    height190Argument = 190;
  }

  var resizeResult = await _checkedRunProc([
    'cwebp',
    '-resize',
    '$width100Argument',
    '$height100Argument',
    staticWebpPath,
    '-o',
    webp100ThumbnailPath
  ]);

  if (resizeResult.exitCode != 0) {
    return [
      '`$originalPath`: Resizing to WebP thumbnail with `cwebp -resize $width100Argument $height100Argument "$staticWebpPath" -o "$webp100ThumbnailPath"` failed with exitcode ${resizeResult.exitCode}'
    ];
  }

  final resizeResult1 = await _checkedRunProc([
    'cwebp',
    '-resize',
    '$width190Argument',
    '$height190Argument',
    staticWebpPath,
    '-o',
    webp190ThumbnailPath
  ]);

  if (resizeResult1.exitCode != 0) {
    return [
      '`$originalPath`: Resizing to WebP thumbnail with `cwebp -resize $width190Argument $height190Argument "$staticWebpPath" -o "$webp190ThumbnailPath"` failed with exitcode ${resizeResult1.exitCode}'
    ];
  }

  final pngResult = await _checkedRunProc(
      ['dwebp', webp100ThumbnailPath, '-o', png100ThumbnailPath]);
  if (pngResult.exitCode != 0) {
    return [
      '`$originalPath`: Generating PNG thumbnail with `dwebp "$webp100ThumbnailPath" -o "$png100ThumbnailPath"` failed with _exit code_ `${pngResult.exitCode}`.'
    ];
  }

  final pngResult1 = await _checkedRunProc(
      ['dwebp', webp190ThumbnailPath, '-o', png190ThumbnailPath]);
  if (pngResult1.exitCode != 0) {
    return [
      '`$originalPath`: Generating PNG thumbnail with `dwebp "$webp190ThumbnailPath" -o "$png190ThumbnailPath"` failed with _exit code_ `${pngResult.exitCode}`.'
    ];
  }

  return [];
}

Future<PanaProcessResult> _checkedRunProc(List<String> cmdAndArgs) async {
  PanaProcessResult result;
  try {
    result = await runProc(cmdAndArgs);
  } on ProcessException catch (e) {
    stderr.write("'${cmdAndArgs[0]}' tool not found.");
    return PanaProcessResult(-1, e.errorCode, e.message, e.message,
        wasError: true);
  }
  return result;
}
