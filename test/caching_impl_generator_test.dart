import 'dart:async';

import 'package:caching_impl_annotation/caching_impl_annotation.dart';
import 'package:caching_impl_generator/src/caching_impl_generator.dart';
import 'package:source_gen_test/src/build_log_tracking.dart';
import 'package:source_gen_test/src/init_library_reader.dart';
import 'package:source_gen_test/src/test_annotated_classes.dart';

Future<void> main() async {
  final reader = await initializeLibraryReaderForDirectory(
    'test/src',
    'test_src.dart',
  );

  initializeBuildLogTracking();
  testAnnotatedElements<GenerateForCaching>(
    reader,
    const CachingImplGenerator(),
  );
}
