import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

abstract final class Utils {
  static bool canReturnValue(DartType type) {
    return ![isVoid(type), isFutureOfVoid(type), isFutureOrOfVoid(type)]
        .reduce((value, element) => value || element);
  }

  static bool isVoid(DartType type) => type is VoidType;

  static bool isFutureOfVoid(DartType type) {
    if (!type.isDartAsyncFuture) return false;
    return _isAllArgumentsOfVoidType(type as InterfaceType);
  }

  static bool isFutureOrOfVoid(DartType type) {
    if (!type.isDartAsyncFutureOr) return false;
    return _isAllArgumentsOfVoidType(type as InterfaceType);
  }

  static bool _isAllArgumentsOfVoidType(InterfaceType type) {
    if (type.typeArguments.isEmpty) return false;
    return !type.typeArguments.any((e) => e is! VoidType);
  }

  static DartObject? getFirstAnnotationOf<AnnotationType>(Element element) {
    return TypeChecker.fromRuntime(AnnotationType).firstAnnotationOf(element);
  }

  static Iterable<Element> getElementsAnnotatedWith<AnnotationType>(
    Iterable<Element> elements,
  ) {
    return elements.where((e) => TypeChecker.fromRuntime(AnnotationType)
        .hasAnnotationOf(e, throwOnUnresolved: false));
  }

  static DartObject? getFieldOfAnnotation<AnnotationType>(
    Element element,
    String fieldName,
  ) =>
      getFirstAnnotationOf<AnnotationType>(element)?.getField(fieldName);

  static dynamic getLiteralValueFrom(DartObject? object) {
    final value = ConstantReader(object).literalValue;

    return switch (value) {
      (String value) => '\'$value\'',
      (List<DartObject?> value) => value.map(getLiteralValueFrom).toList(),
      (Set<DartObject?> value) => value.map(getLiteralValueFrom).toSet(),
      (Map<DartObject?, DartObject?> value) => {
          for (var e in value.entries)
            getLiteralValueFrom(e.key): getLiteralValueFrom(e.value)
        },
      (_) => value,
    };
  }

  static bool isDartDefinedType(DartType type) {
    return type.isDartCoreInt ||
        type.isDartCoreString ||
        type.isDartCoreDouble ||
        type.isDartCoreList ||
        type.isDartCoreMap ||
        type.isDartCoreObject ||
        type.isDartCoreBool ||
        type.isDartCoreEnum ||
        type.isDartCoreIterable ||
        type.isDartCoreRecord ||
        type.isDartCoreNum ||
        type.isDartCoreNull ||
        type.isDartCoreSet ||
        type.isDartAsyncFuture ||
        type.isDartAsyncFutureOr ||
        type.isDartAsyncStream ||
        type.isDartCoreFunction ||
        type.isDartCoreType ||
        type.isDartCoreSymbol ||
        type is DynamicType ||
        type is VoidType;
  }

  static String getFunctionReferenceAsString(ExecutableElement element) {
    return (StringBuffer()
          ..writeAll([
            if (element.enclosingElement is ClassElement)
              '${element.enclosingElement.displayName}.',
            element.displayName,
          ]))
        .toString();
  }

  static String getAnnotationName<AnnotationType>() {
    return AnnotationType.toString().replaceAll(RegExp(r'<.+>'), '');
  }

  static String getTypeName(DartType type) => '$type'.replaceAll('?', '');

  static bool isNullable(DartType type) => '$type'.contains('?');
}
