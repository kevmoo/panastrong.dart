// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:retry/retry.dart';

import '../logging.dart';
import '../utils.dart' show runProc, withTempDir, PanaProcessResult;

final _acceptedBranchNameRegExp = RegExp(r'^[a-z0-9]+$');

/// Detects the name of the default git branch on the given [baseUrl],
/// using the metadata returned by `git remote show`.
///
/// Returns `null` when no branch name can be detected, or the implied
/// branch name does not conform of the allowed patterns.
Future<String?> tryDetectDefaultGitBranch(String baseUrl) async {
  return await withTempDir((dir) async {
    GitLocalRepository? repo;
    try {
      repo = await GitLocalRepository.createLocalRepository(baseUrl);
      return await repo.detectDefaultBranch();
    } on GitToolException catch (e, st) {
      log.warning(e.toString(), st);
      return null;
    } finally {
      await repo?.delete();
    }
  });
}

class GitLocalRepository {
  final String localPath;
  final String origin;

  GitLocalRepository({
    required this.localPath,
    required this.origin,
  });

  static Future<GitLocalRepository> createLocalRepository(String origin) async {
    final tempDir = await Directory.systemTemp.createTemp('git-repo');
    final repo = GitLocalRepository(
      localPath: tempDir.path,
      origin: origin,
    );
    try {
      await repo._init();
      return repo;
    } on Exception catch (_) {
      await tempDir.delete(recursive: true);
      rethrow;
    }
  }

  Future<PanaProcessResult> _runGit(
    List<String> args, {
    GitToolException Function(PanaProcessResult pr)? createException,
  }) async {
    final pr = await runProc(
      ['git', ...args],
      workingDirectory: localPath,
    );
    if (pr.exitCode != 0) {
      final ex = createException == null
          ? GitToolException.failedToRun(args.join(' '), pr)
          : createException(pr);
      throw ex;
    }
    return pr;
  }

  Future<PanaProcessResult> _runGitWithRetry(
    List<String> args, {
    int maxAttempts = 3,
    GitToolException Function(PanaProcessResult pr)? createException,
  }) async {
    return await retry(
      () => _runGit(
        args,
        createException: createException,
      ),
      maxAttempts: maxAttempts,
      retryIf: (e) => e is GitToolException,
    );
  }

  Future<void> _init() async {
    await _runGit(['init']);
    await _runGit(['remote', 'add', 'origin', origin]);
  }

  /// Detects the default branch name by querying the origin and
  /// matching `HEAD branch` in the output.
  ///
  /// Throws [GitToolException] if the git command fails, if the
  /// branch name is missing, or if the default branch name has
  /// unexpected pattern.
  Future<String> detectDefaultBranch() async {
    final pr = await _runGitWithRetry(['remote', 'show', 'origin']);
    final output = pr.stdout.toString();
    final lines = output.split('\n');
    for (final line in lines) {
      final parts = line.trim().split(':');
      if (parts.length == 2 && parts[0].trim() == 'HEAD branch') {
        final branch = parts[1].trim();
        if (_acceptedBranchNameRegExp.matchAsPrefix(branch) != null) {
          return branch;
        } else {
          throw GitToolException('Could not accept branch name: `$branch`.');
        }
      }
    }
    throw GitToolException('Could not find HEAD branch.', output);
  }

  /// Checkout [branch] into the local working directory.
  ///
  /// Throws [GitToolException] if the git command fails.
  Future<void> checkoutFiles(String branch, Iterable<String> files) async {
    final fileList = files.toList();
    if (fileList.isEmpty) return;
    await _fetch(branch, 1);
    await _runGitWithRetry([
      'checkout',
      'origin/$branch',
      '--',
      ...fileList,
    ], createException: (pr) {
      final andMore =
          fileList.length == 1 ? '' : ' and ${fileList.length - 1} more';
      return GitToolException(
          'Could not checkout `${fileList.first}`$andMore.');
    });
  }

  /// Deletes the local directory.
  Future<void> delete() async {
    await Directory(localPath).delete(recursive: true);
  }

  Future<void> _fetch(String branch, int depth) async {
    // TODO: cache if the branch has been already fetched to the requested level
    await _runGitWithRetry([
      'fetch',
      '--depth',
      '$depth',
      'origin',
      branch,
    ]);
  }
}

class GitToolException implements Exception {
  final String message;
  final String? output;

  GitToolException(this.message, [this.output]);

  factory GitToolException.failedToRun(String command, PanaProcessResult pr) =>
      GitToolException('Failed to run `$command`.', pr.asJoinedOutput);

  @override
  String toString() => [message, output].whereType<String>().join('\n');
}
