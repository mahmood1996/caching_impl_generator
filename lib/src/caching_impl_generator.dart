import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:caching_impl_annotation/caching_impl_annotation.dart';
import 'package:caching_impl_generator/src/code_generators/box_method_generator.dart';
import 'package:caching_impl_generator/src/code_generators/get_methods_generator.dart';
import 'package:caching_impl_generator/src/code_generators/mixin_declaration_generator.dart';
import 'package:caching_impl_generator/src/code_generators/save_methods_generator.dart';
import 'package:source_gen/source_gen.dart';

final class CachingImplGenerator
    extends GeneratorForAnnotation<GenerateForCaching> {
  const CachingImplGenerator();

  @override
  String generateForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (annotation.isNull) {
      throw InvalidGenerationSource(
        'Source must be annotated with $GenerateForCaching',
        element: element,
      );
    }
    if (element is! ClassElement) {
      throw InvalidGenerationSource(
        'Classes only can be annotated with $GenerateForCaching',
        element: element,
      );
    }

    return MixinDeclarationGenerator([
      GetMethodsGenerator(),
      SaveMethodsGenerator(),
      BoxMethodGenerator(),
    ]).generateFor(element);
  }
}
