import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:caching_impl_annotation/caching_impl_annotation.dart';
import 'package:source_gen/source_gen.dart';

import '../utils.dart';
import 'code_generator.dart';

final class GetMethodsGenerator implements CodeGenerator<ClassElement> {
  @override
  String generateFor(ClassElement element) {
    return Utils.getElementsAnnotatedWith<Get>(element.methods)
        .whereType<MethodElement>()
        .map((e) => '${_buildGetMethod(e)}\n')
        .join();
  }

  String _buildGetMethod(MethodElement element) {
    _validateGetStorageKey(element);
    _validateGetMethodReturn(element);
    _validateGetMethodParams(element.declaration);
    return [
      '${element.declaration} async {\n',
      __buildGetMethodBody(element),
      '}\n'
    ].join();
  }

  String __buildGetMethodBody(MethodElement element) {
    final fromJson =
        Utils.getFieldOfAnnotation<Get>(element, 'fromJson')?.toFunctionValue();

    final futureArgumentType =
        (element.declaration.returnType as InterfaceType).typeArguments.first;

    return [
      'final box = await _box(\'${_getStorageKeyValueOn(element)}\');\n',
      'if (!box.containsKey(0)) throw CacheException();\n',
      'final storedData = json.decode(box.get(0)!);\n',
      'return ${switch ((
        fromJson,
        Utils.isDartDefinedType(futureArgumentType)
      )) {
        (null, true) => 'storedData',
        (null, false) => '$futureArgumentType.fromJson(storedData)',
        (ExecutableElement e, _) =>
          '${Utils.getFunctionReferenceAsString(e)}(storedData)',
      }};\n',
    ].join();
  }

  void _validateGetMethodReturn(MethodElement element) {
    final returnType = element.returnType;
    if (!(returnType.isDartAsyncFuture || returnType.isDartAsyncFutureOr)) {
      throw InvalidGenerationSource(
        'Methods annotated with ${Utils.getAnnotationName<Get>()} must return Future, or FutureOr',
        element: element,
      );
    }
    if ((returnType as InterfaceType).typeArguments.firstOrNull is VoidType) {
      throw InvalidGenerationSource(
        'Methods annotated with ${Utils.getAnnotationName<Get>()} must return a value not void',
        element: element,
      );
    }
  }

  void _validateGetMethodParams(MethodElement methodDeclaration) {
    if (methodDeclaration.children.isNotEmpty) {
      throw InvalidGenerationSource(
        'Methods annotated with ${Utils.getAnnotationName<Get>()} must not have parameters',
        element: methodDeclaration,
      );
    }
  }

  void _validateGetStorageKey(MethodElement element) {
    if (_getStorageKeyValueOn(element).isEmpty) {
      final annotationName = Utils.getAnnotationName<Get>();
      throw InvalidGenerationSource(
        '$annotationName.storageKey must be non empty string',
        element: element,
      );
    }
  }

  String _getStorageKeyValueOn(MethodElement element) {
    return Utils.getFieldOfAnnotation<Get>(element, 'storageKey')!
        .toStringValue()!;
  }
}
