// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test/test.dart';
import 'package:pana/src/version.dart';

import 'shared.dart';

final data = new E2EData('http', '0.11.3+13', _data, {
  'pkg': 'undefined',
  'package:http/browser_client.dart': 'web',
  'package:http/http.dart': 'everywhere',
  'package:http/testing.dart': 'flutter, server'
});

final _data = {
  "panaVersion": panaPkgVersion.toString(),
  "sdkVersion": startsWith("Dart VM version: "),
  "packageName": "http",
  "packageVersion": "0.11.3+13",
  "pubSummary": {
    "pubspecContent": {
      "author": "Dart Team <misc@dartlang.org>",
      "dependencies": {
        "async": "^1.10.0",
        "collection": "^1.5.0",
        "http_parser": ">=0.0.1 <4.0.0",
        "path": ">=0.9.0 <2.0.0",
        "stack_trace": ">=0.9.1 <2.0.0"
      },
      "description": "A composable, Future-based API for making HTTP requests.",
      "dev_dependencies": {"unittest": ">=0.9.0 <0.12.0"},
      "environment": {"sdk": ">=1.23.0-dev.0.0 <2.0.0"},
      "homepage": "https://github.com/dart-lang/http",
      "name": "http",
      "version": "0.11.3+13"
    },
    "packages": isMap,
    "availablePackages": {"unittest": "0.12.4+1"}
  },
  "dartFiles": {
    "lib/browser_client.dart": {
      "uri": "package:http/browser_client.dart",
      "size": 3688,
      "isFormatted": false,
      "analyzerItems": [],
      "directLibs": ["dart:html", "dart:web_safe_io"],
      "transitiveLibs": ['dart:html', 'dart:web_safe_io'],
      'platform': {
        'uses': ['dart:html', 'dart:web_safe_io']
      }
    },
    "lib/http.dart": {
      "uri": "package:http/http.dart",
      "size": 7234,
      "isFormatted": false,
      "analyzerItems": [],
      "directLibs": ["dart:web_safe_io"],
      "transitiveLibs": ["dart:web_safe_io"],
      "platform": {
        "uses": ['dart:web_safe_io']
      }
    },
    "lib/src/base_client.dart": {
      "uri": "package:http/src/base_client.dart",
      "size": 7821,
      "isFormatted": false,
      "analyzerItems": [],
    },
    "lib/src/base_request.dart": {
      "uri": "package:http/src/base_request.dart",
      "size": 4739,
      "isFormatted": false,
      "analyzerItems": [],
    },
    "lib/src/base_response.dart": {
      "uri": "package:http/src/base_response.dart",
      "size": 1727,
      "isFormatted": false,
      "analyzerItems": [],
    },
    "lib/src/boundary_characters.dart": {
      "uri": "package:http/src/boundary_characters.dart",
      "size": 957,
      "isFormatted": false,
      "analyzerItems": [],
    },
    "lib/src/byte_stream.dart": {
      "uri": "package:http/src/byte_stream.dart",
      "size": 1391,
      "isFormatted": false,
      "analyzerItems": [],
    },
    "lib/src/client.dart": {
      "uri": "package:http/src/client.dart",
      "size": 6152,
      "isFormatted": false,
      "analyzerItems": [],
    },
    "lib/src/exception.dart": {
      "uri": "package:http/src/exception.dart",
      "size": 502,
      "isFormatted": true,
      "analyzerItems": [],
    },
    "lib/src/io_client.dart": {
      "uri": "package:http/src/io_client.dart",
      "size": 2530,
      "isFormatted": false,
      "analyzerItems": [],
    },
    "lib/src/mock_client.dart": {
      "uri": "package:http/src/mock_client.dart",
      "size": 3320,
      "isFormatted": false,
      "analyzerItems": [],
    },
    "lib/src/multipart_file.dart": {
      "uri": "package:http/src/multipart_file.dart",
      "size": 4431,
      "isFormatted": false,
      "analyzerItems": [],
    },
    "lib/src/multipart_request.dart": {
      "uri": "package:http/src/multipart_request.dart",
      "size": 5905,
      "isFormatted": false,
      "analyzerItems": [],
    },
    "lib/src/request.dart": {
      "uri": "package:http/src/request.dart",
      "size": 5952,
      "isFormatted": false,
      "analyzerItems": [],
    },
    "lib/src/response.dart": {
      "uri": "package:http/src/response.dart",
      "size": 3431,
      "isFormatted": false,
      "analyzerItems": [],
    },
    "lib/src/streamed_request.dart": {
      "uri": "package:http/src/streamed_request.dart",
      "size": 1650,
      "isFormatted": false,
      "analyzerItems": [],
    },
    "lib/src/streamed_response.dart": {
      "uri": "package:http/src/streamed_response.dart",
      "size": 1326,
      "isFormatted": false,
      "analyzerItems": [],
    },
    "lib/src/utils.dart": {
      "uri": "package:http/src/utils.dart",
      "size": 4843,
      "isFormatted": false,
      "analyzerItems": [],
    },
    "lib/testing.dart": {
      "uri": "package:http/testing.dart",
      "size": 966,
      "isFormatted": true,
      "analyzerItems": [],
      "directLibs": ["package:http/src/mock_client.dart"],
      "transitiveLibs": [
        "dart:async",
        "dart:collection",
        "dart:convert",
        "dart:io",
        "dart:math",
        "dart:typed_data",
        "package:async/async.dart",
        "package:async/src/async_cache.dart",
        "package:async/src/async_memoizer.dart",
        "package:async/src/byte_collector.dart",
        "package:async/src/cancelable_operation.dart",
        "package:async/src/delegate/event_sink.dart",
        "package:async/src/delegate/future.dart",
        "package:async/src/delegate/sink.dart",
        "package:async/src/delegate/stream.dart",
        "package:async/src/delegate/stream_consumer.dart",
        "package:async/src/delegate/stream_sink.dart",
        "package:async/src/delegate/stream_subscription.dart",
        "package:async/src/future_group.dart",
        "package:async/src/lazy_stream.dart",
        "package:async/src/null_stream_sink.dart",
        "package:async/src/restartable_timer.dart",
        "package:async/src/result.dart",
        "package:async/src/result/capture_sink.dart",
        "package:async/src/result/capture_transformer.dart",
        "package:async/src/result/error.dart",
        "package:async/src/result/future.dart",
        "package:async/src/result/release_sink.dart",
        "package:async/src/result/release_transformer.dart",
        "package:async/src/result/value.dart",
        "package:async/src/single_subscription_transformer.dart",
        "package:async/src/stream_completer.dart",
        "package:async/src/stream_group.dart",
        "package:async/src/stream_queue.dart",
        "package:async/src/stream_sink_completer.dart",
        "package:async/src/stream_sink_transformer.dart",
        "package:async/src/stream_sink_transformer/handler_transformer.dart",
        "package:async/src/stream_sink_transformer/stream_transformer_wrapper.dart",
        "package:async/src/stream_sink_transformer/typed.dart",
        "package:async/src/stream_splitter.dart",
        "package:async/src/stream_subscription_transformer.dart",
        "package:async/src/stream_zip.dart",
        "package:async/src/subscription_stream.dart",
        "package:async/src/typed/future.dart",
        "package:async/src/typed/stream.dart",
        "package:async/src/typed/stream_subscription.dart",
        "package:async/src/typed_stream_transformer.dart",
        "package:async/src/utils.dart",
        "package:charcode/ascii.dart",
        "package:charcode/charcode.dart",
        "package:charcode/html_entity.dart",
        "package:collection/collection.dart",
        "package:collection/src/algorithms.dart",
        "package:collection/src/canonicalized_map.dart",
        "package:collection/src/combined_wrappers/combined_iterable.dart",
        "package:collection/src/combined_wrappers/combined_list.dart",
        "package:collection/src/combined_wrappers/combined_map.dart",
        "package:collection/src/comparators.dart",
        "package:collection/src/empty_unmodifiable_set.dart",
        "package:collection/src/equality.dart",
        "package:collection/src/equality_map.dart",
        "package:collection/src/equality_set.dart",
        "package:collection/src/functions.dart",
        "package:collection/src/iterable_zip.dart",
        "package:collection/src/priority_queue.dart",
        "package:collection/src/queue_list.dart",
        "package:collection/src/typed_wrappers.dart",
        "package:collection/src/union_set.dart",
        "package:collection/src/union_set_controller.dart",
        "package:collection/src/unmodifiable_wrappers.dart",
        "package:collection/src/utils.dart",
        "package:collection/src/wrappers.dart",
        "package:http/src/base_client.dart",
        "package:http/src/base_request.dart",
        "package:http/src/base_response.dart",
        "package:http/src/byte_stream.dart",
        "package:http/src/client.dart",
        "package:http/src/exception.dart",
        "package:http/src/io_client.dart",
        "package:http/src/mock_client.dart",
        "package:http/src/request.dart",
        "package:http/src/response.dart",
        "package:http/src/streamed_response.dart",
        "package:http/src/utils.dart",
        "package:http_parser/http_parser.dart",
        "package:http_parser/src/authentication_challenge.dart",
        "package:http_parser/src/case_insensitive_map.dart",
        "package:http_parser/src/chunked_coding.dart",
        "package:http_parser/src/chunked_coding/decoder.dart",
        "package:http_parser/src/chunked_coding/encoder.dart",
        "package:http_parser/src/http_date.dart",
        "package:http_parser/src/media_type.dart",
        "package:http_parser/src/scan.dart",
        "package:http_parser/src/utils.dart",
        "package:path/path.dart",
        "package:path/src/characters.dart",
        "package:path/src/context.dart",
        "package:path/src/internal_style.dart",
        "package:path/src/parsed_path.dart",
        "package:path/src/path_exception.dart",
        "package:path/src/style.dart",
        "package:path/src/style/posix.dart",
        "package:path/src/style/url.dart",
        "package:path/src/style/windows.dart",
        "package:path/src/utils.dart",
        "package:source_span/source_span.dart",
        "package:source_span/src/colors.dart",
        "package:source_span/src/file.dart",
        "package:source_span/src/location.dart",
        "package:source_span/src/location_mixin.dart",
        "package:source_span/src/span.dart",
        "package:source_span/src/span_exception.dart",
        "package:source_span/src/span_mixin.dart",
        "package:source_span/src/span_with_context.dart",
        "package:source_span/src/utils.dart",
        "package:string_scanner/src/eager_span_scanner.dart",
        "package:string_scanner/src/exception.dart",
        "package:string_scanner/src/line_scanner.dart",
        "package:string_scanner/src/relative_span_scanner.dart",
        "package:string_scanner/src/span_scanner.dart",
        "package:string_scanner/src/string_scanner.dart",
        "package:string_scanner/src/utils.dart",
        "package:string_scanner/string_scanner.dart",
        "package:typed_data/typed_buffers.dart",
        "package:typed_data/typed_data.dart"
      ],
      "platform": {
        "uses": [
          'dart:async',
          'dart:collection',
          'dart:convert',
          'dart:io',
          'dart:math',
          'dart:typed_data'
        ]
      }
    },
    "test/html/client_test.dart": {
      "uri": "asset:http/test/html/client_test.dart",
      "size": 1144,
      "isFormatted": false,
      "analyzerItems": [],
    },
    "test/html/streamed_request_test.dart": {
      "uri": "asset:http/test/html/streamed_request_test.dart",
      "size": 1210,
      "isFormatted": true,
      "analyzerItems": [],
    },
    "test/html/utils.dart": {
      "uri": "asset:http/test/html/utils.dart",
      "size": 391,
      "isFormatted": false,
      "analyzerItems": [],
    },
    "test/io/client_test.dart": {
      "uri": "asset:http/test/io/client_test.dart",
      "size": 3502,
      "isFormatted": false,
      "analyzerItems": [],
    },
    "test/io/http_test.dart": {
      "uri": "asset:http/test/io/http_test.dart",
      "size": 14300,
      "isFormatted": false,
      "analyzerItems": [],
    },
    "test/io/multipart_test.dart": {
      "uri": "asset:http/test/io/multipart_test.dart",
      "size": 1195,
      "isFormatted": false,
      "analyzerItems": [],
    },
    "test/io/request_test.dart": {
      "uri": "asset:http/test/io/request_test.dart",
      "size": 1952,
      "isFormatted": false,
      "analyzerItems": [],
    },
    "test/io/streamed_request_test.dart": {
      "uri": "asset:http/test/io/streamed_request_test.dart",
      "size": 1883,
      "isFormatted": false,
      "analyzerItems": [],
    },
    "test/io/utils.dart": {
      "uri": "asset:http/test/io/utils.dart",
      "size": 4568,
      "isFormatted": false,
      "analyzerItems": [],
    },
    "test/mock_client_test.dart": {
      "uri": "asset:http/test/mock_client_test.dart",
      "size": 2033,
      "isFormatted": false,
      "analyzerItems": [
        {
          "type": "INFO|HINT|UNUSED_IMPORT",
          "file": "test/mock_client_test.dart",
          "line": 9,
          "col": 8,
          "error": "Unused import."
        }
      ],
    },
    "test/multipart_test.dart": {
      "uri": "asset:http/test/multipart_test.dart",
      "size": 7313,
      "isFormatted": false,
      "analyzerItems": [],
    },
    "test/request_test.dart": {
      "uri": "asset:http/test/request_test.dart",
      "size": 12436,
      "isFormatted": false,
      "analyzerItems": [],
    },
    "test/response_test.dart": {
      "uri": "asset:http/test/response_test.dart",
      "size": 2641,
      "isFormatted": false,
      "analyzerItems": [],
    },
    "test/streamed_request_test.dart": {
      "uri": "asset:http/test/streamed_request_test.dart",
      "size": 916,
      "isFormatted": true,
      "analyzerItems": [],
    },
    "test/utils.dart": {
      "uri": "asset:http/test/utils.dart",
      "size": 3632,
      "isFormatted": false,
      "analyzerItems": [],
    }
  },
  "license": {"name": "BSD"}
};
