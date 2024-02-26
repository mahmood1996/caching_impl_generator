import 'package:analyzer/dart/element/element.dart';

import 'code_generator.dart';

final class MixinDeclarationGenerator implements CodeGenerator<ClassElement> {
  MixinDeclarationGenerator(this.implGenerators);

  final List<CodeGenerator<Element>> implGenerators;

  @override
  String generateFor(ClassElement element) {
    return [
      'mixin _\$${element.name}Mixin {\n',
      ...implGenerators.map((e) => e.generateFor(element)),
      '}\n',
    ].join();
  }
}
