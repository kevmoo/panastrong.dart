import 'package:pana/src/platform.dart';
import 'package:test/test.dart';

import 'pubspec_test.dart';

void main() {
  group('Platform', () {
    test('no libraries', () {
      Platform p = classifyPlatform([]);
      expect(p.hasConflict, isFalse);
      expect(p.worksAnywhere, isTrue);
      expect(p.worksEverywhere, isTrue);
      expect(p.worksInBrowser, isTrue);
      expect(p.worksInConsole, isTrue);
      expect(p.worksInFlutter, isTrue);
    });

    test('unknown library', () {
      Platform p = classifyPlatform(['package:_unknown/_unknown.dart']);
      expect(p.hasConflict, isFalse);
      expect(p.worksAnywhere, isTrue);
      expect(p.worksEverywhere, isTrue);
      expect(p.worksInBrowser, isTrue);
      expect(p.worksInConsole, isTrue);
      expect(p.worksInFlutter, isTrue);
    });

    test('dart:io', () {
      Platform p = classifyPlatform(['dart:io']);
      expect(p.hasConflict, isFalse);
      expect(p.worksAnywhere, isTrue);
      expect(p.worksEverywhere, isFalse);
      expect(p.worksInBrowser, isFalse);
      expect(p.worksInConsole, isTrue);
      expect(p.worksInFlutter, isTrue);
    });

    test('dart:html', () {
      Platform p = classifyPlatform(['dart:html']);
      expect(p.hasConflict, isFalse);
      expect(p.worksAnywhere, isTrue);
      expect(p.worksEverywhere, isFalse);
      expect(p.worksInBrowser, isTrue);
      expect(p.worksInConsole, isFalse);
      expect(p.worksInFlutter, isFalse);

      p = classifyPlatform(['dart:svg']);
      expect(p.hasConflict, isFalse);
      expect(p.worksAnywhere, isTrue);
      expect(p.worksEverywhere, isFalse);
      expect(p.worksInBrowser, isTrue);
      expect(p.worksInConsole, isFalse);
      expect(p.worksInFlutter, isFalse);
    });

    test('dart:ui', () {
      Platform p = classifyPlatform(['dart:ui']);
      expect(p.hasConflict, isFalse);
      expect(p.worksAnywhere, isTrue);
      expect(p.worksEverywhere, isFalse);
      expect(p.worksInBrowser, isFalse);
      expect(p.worksInConsole, isFalse);
      expect(p.worksInFlutter, isTrue);
    });

    test('dart:mirrors', () {
      Platform p = classifyPlatform(['dart:mirrors']);
      expect(p.hasConflict, isFalse);
      expect(p.worksAnywhere, isTrue);
      expect(p.worksEverywhere, isFalse);
      expect(p.worksInBrowser, isTrue);
      expect(p.worksInConsole, isTrue);
      expect(p.worksInFlutter, isFalse);
    });

    test('http package: both html and io', () {
      Platform p = classifyPlatform(['dart:html', 'dart:io']);
      expect(p.hasConflict, isFalse);
      expect(p.worksAnywhere, isTrue);
      expect(p.worksEverywhere, isFalse);
      expect(p.worksInBrowser, isTrue);
      expect(p.worksInConsole, isFalse);
      expect(p.worksInFlutter, isFalse);
    });

    test('detect angular', () {
      Platform p =
          classifyPlatform(['dart:html', 'package:angular2/angular2.dart']);
      expect(p.hasConflict, isFalse);
      expect(p.worksAnywhere, isTrue);
      expect(p.worksEverywhere, isFalse);
      expect(p.worksInBrowser, isTrue);
      expect(p.worksInConsole, isFalse);
      expect(p.worksInFlutter, isFalse);
      expect(p.uses, [KnownPlatforms.angular, KnownPlatforms.browser]);
    });
  });

  group('Conflicting Platform', () {
    test('dart:html + dart:ui', () {
      Platform p = classifyPlatform(['dart:html', 'dart:ui']);
      expect(p.hasConflict, isTrue);
      expect(p.worksAnywhere, isFalse);
      expect(p.worksEverywhere, isFalse);
      expect(p.worksInBrowser, isFalse);
      expect(p.worksInConsole, isFalse);
      expect(p.worksInFlutter, isFalse);
    });

    test('dart:mirrors + dart:ui', () {
      Platform p = classifyPlatform(['dart:mirrors', 'dart:ui']);
      expect(p.hasConflict, isTrue);
      expect(p.worksAnywhere, isFalse);
      expect(p.worksEverywhere, isFalse);
      expect(p.worksInBrowser, isFalse);
      expect(p.worksInConsole, isFalse);
      expect(p.worksInFlutter, isFalse);
    });
  });

  group('PlatformSummary', () {
    test('handles multiple libraries', () {
      PlatformSummary sum = classifyPlatforms(emptyPubspec, {
        'package:_example/a.dart': ['dart:html'],
        'package:_example/b.dart': ['dart:io'],
      });
      expect(sum.hasConflict, isFalse);
      expect(sum.package.worksEverywhere, isTrue);
      expect(sum.libraries.length, 2);
      Platform pa = sum.libraries['package:_example/a.dart'];
      Platform pb = sum.libraries['package:_example/b.dart'];
      expect(pa.worksInBrowser, isTrue);
      expect(pa.worksInConsole, isFalse);
      expect(pb.worksInBrowser, isFalse);
      expect(pb.worksInConsole, isTrue);
    });

    test('detects flutter in pubspec', () {
      PlatformSummary sum = classifyPlatforms(flutterPluginPubspec, {});
      expect(sum.hasConflict, isFalse);
      expect(sum.package.worksInFlutter, isTrue);
      expect(sum.package.worksInConsole, isFalse);
      expect(sum.package.worksInBrowser, isFalse);
    });

    test('detects flutter in dependencies', () {
      PlatformSummary sum = classifyPlatforms(flutterSdkPubspec, {});
      expect(sum.hasConflict, isFalse);
      expect(sum.package.worksInFlutter, isTrue);
      expect(sum.package.worksInConsole, isFalse);
      expect(sum.package.worksInBrowser, isFalse);
    });
  });

  group('Conflicting PlatformSummary', () {
    test('Flutter package with mirrors', () {
      PlatformSummary sum = classifyPlatforms(flutterPluginPubspec, {
        'package:_example/lib.dart': ['dart:mirrors'],
      });
      expect(sum.hasConflict, isTrue);
    });
  });
}
