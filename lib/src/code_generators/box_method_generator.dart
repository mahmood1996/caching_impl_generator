import 'package:analyzer/dart/element/element.dart';

import 'code_generator.dart';

final class BoxMethodGenerator implements CodeGenerator {
  @override
  String generateFor(Element _) =>
      'Future<Box<String>> _box(String storageKey) =>\n'
      '    Hive.openBox<String>(storageKey);';
}
