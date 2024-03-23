import 'package:analyzer/dart/element/element.dart';
import 'package:caching_impl_annotation/caching_impl_annotation.dart';
import 'package:caching_impl_generator/src/code_generators/code_generator.dart';
import 'package:source_gen/source_gen.dart';

import '../utils.dart';

final class SaveMethodsGenerator implements CodeGenerator<ClassElement> {
  @override
  String generateFor(ClassElement element) {
    return Utils.getElementsAnnotatedWith<Save>(element.methods)
        .whereType<MethodElement>()
        .map((e) => '${_buildSaveMethod(e)}\n')
        .join();
  }

  String _buildSaveMethod(MethodElement element) {
    final methodDeclaration = element.declaration;
    _validateSaveStorageKey(element);
    _validateSaveMethodParams(methodDeclaration);
    _validateSaveMethodReturn(element);

    return (StringBuffer('$methodDeclaration async {\n')
          ..write(_buildSaveMethodBody(element))
          ..write('}\n'))
        .toString();
  }

  String _buildSaveMethodBody(MethodElement element) {
    final storageKey = Utils.getFieldOfAnnotation<Save>(element, 'storageKey')!
        .toStringValue();

    return (StringBuffer('await (await _box(\'$storageKey\'))'
            '.put(0, ')
          ..write(_buildJsonEncodingImplForSaveMethod(element))
          ..write(');\n'))
        .toString();
  }

  String _buildJsonEncodingImplForSaveMethod(MethodElement element) {
    final methodParam = element.declaration.children.first as VariableElement;

    final toJson =
        Utils.getFieldOfAnnotation<Save>(element, 'toJson')?.toFunctionValue();

    return switch (toJson) {
      (null) => [
          'json.encode(${methodParam.displayName}',
          if (!Utils.isDartDefinedType(methodParam.type))
            '${Utils.isNullable(methodParam.type) ? '?' : ''}.toJson()',
          ')',
        ].join(),
      (_) => [
          Utils.getFunctionReferenceAsString(toJson),
          '(${methodParam.displayName})',
        ].join(),
    };
  }

  void _validateSaveMethodReturn(MethodElement element) {
    if (Utils.canReturnValue(element.returnType)) {
      throw InvalidGenerationSource(
        'Methods annotated with ${Utils.getAnnotationName<Save>()}'
        ' must be void, Future<void>, or FutureOr<void>',
        element: element,
      );
    }
  }

  void _validateSaveStorageKey(MethodElement element) {
    if (Utils.getFieldOfAnnotation<Save>(element, 'storageKey')!
        .toStringValue()!
        .isEmpty) {
      final annotationName = Utils.getAnnotationName<Save>();
      throw InvalidGenerationSource(
        '$annotationName.storageKey must be non empty string',
        element: element,
      );
    }
  }

  void _validateSaveMethodParams(MethodElement methodDeclaration) {
    if (methodDeclaration.children.length != 1) {
      throw InvalidGenerationSource(
        'Methods annotated with ${Utils.getAnnotationName<Save>()} must have one parameter for input',
        element: methodDeclaration,
      );
    }
  }
}
