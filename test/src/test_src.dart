import 'dart:async';

import 'package:caching_impl_annotation/caching_impl_annotation.dart';
import 'package:source_gen_test/annotations.dart';

@ShouldThrow('Source must be annotated with GenerateForCaching')
final class AClassNotAnnotatedWithGenerateForCaching {}

@ShouldThrow('Classes only can be annotated with GenerateForCaching')
@GenerateForCaching()
const int aVariableAnnotatedWithGenerateForCaching = 0;

@ShouldThrow('Classes only can be annotated with GenerateForCaching')
@GenerateForCaching()
void aFunctionAnnotatedWithGenerateForCaching() {}

final class Product {
  Product({
    required this.id,
    required this.name,
  });

  final int id;
  final String name;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}

@ShouldGenerate(
  'mixin _\$GenerateMixinMixin {\n'
  '  Future<dynamic> getDartDefinedType() async {\n'
  '    final box = await _box(\'key\');\n'
  '    if (!box.containsKey(0)) throw CacheException();\n'
  '    final storedData = json.decode(box.get(0)!);\n'
  '    return storedData;\n'
  '  }\n'
  '\n'
  '  Future<Product> getNonDartDefinedType() async {\n'
  '    final box = await _box(\'key\');\n'
  '    if (!box.containsKey(0)) throw CacheException();\n'
  '    final storedData = json.decode(box.get(0)!);\n'
  '    return Product.fromJson(storedData);\n'
  '  }\n'
  '\n'
  '  Future<Product> getObjectWithFromJson() async {\n'
  '    final box = await _box(\'key\');\n'
  '    if (!box.containsKey(0)) throw CacheException();\n'
  '    final storedData = json.decode(box.get(0)!);\n'
  '    return GenerateMixin._fromJson(storedData);\n'
  '  }\n'
  '\n'
  '  Future<void> saveDartDefinedType(int param) async {\n'
  '    await (await _box(\'key\')).put(0, json.encode(param));\n'
  '  }\n'
  '\n'
  '  Future<void> saveNonDartDefinedType(Product param) async {\n'
  '    await (await _box(\'key\')).put(0, json.encode(param.toJson()));\n'
  '  }\n'
  '\n'
  '  Future<void> saveObjectWithToJson(Product param) async {\n'
  '    await (await _box(\'key\')).put(0, GenerateMixin._toJson(param));\n'
  '  }\n'
  '\n'
  '  Future<Box<String>> _box(String storageKey) =>\n'
  '      Hive.openBox<String>(storageKey);\n'
  '}\n',
  contains: true,
)
@GenerateForCaching()
abstract class GenerateMixin {
  @Get(storageKey: 'key')
  Future<dynamic> getDartDefinedType();

  @Get<Product>(storageKey: 'key')
  Future<Product> getNonDartDefinedType();

  @Get<Product>(storageKey: 'key', fromJson: _fromJson)
  Future<Product> getObjectWithFromJson();

  @Save(storageKey: 'key')
  Future<void> saveDartDefinedType(int param);

  @Save(storageKey: 'key')
  Future<void> saveNonDartDefinedType(Product param);

  @Save<Product>(storageKey: 'key', toJson: _toJson)
  Future<void> saveObjectWithToJson(Product param);

  static FutureOr<Product> _fromJson(dynamic json) => Product.fromJson(json);

  static dynamic _toJson(Product product) => product.toJson();
}

@ShouldThrow("Get.storageKey must be non empty string")
@GenerateForCaching()
abstract class AMethodAnnotatedWithGetWithEmptyStorageKey {
  @Get(storageKey: '')
  Future<dynamic> aMethodAnnotatedWithGetWithEmptyStorageKey();
}

@ShouldThrow("Methods annotated with Get must not have parameters")
@GenerateForCaching()
abstract class AMethodAnnotatedWithGetThatHasParams {
  @Get(storageKey: 'key')
  Future<dynamic> aMethodAnnotatedWithGetThatHasParams(dynamic param);
}

@ShouldThrow("Methods annotated with Get must return Future, or FutureOr")
@GenerateForCaching()
abstract class AMethodAnnotatedWithGetReturnsSyncType {
  @Get(storageKey: 'key')
  dynamic aMethodAnnotatedWithGetReturnsSyncType();
}

@ShouldThrow("Methods annotated with Get must return a value not void")
@GenerateForCaching()
abstract class AMethodAnnotatedWithGetReturnsAsyncVoid {
  @Get(storageKey: 'key')
  Future<void> aMethodAnnotatedWithGetReturnsFutureOfVoid();
}

@ShouldThrow("Save.storageKey must be non empty string")
@GenerateForCaching()
abstract class AMethodAnnotatedWithSaveWithEmptyStorageKey {
  @Save(storageKey: '')
  Future<void> aMethodAnnotatedWithSaveWithEmptyStorageKey();
}

@ShouldThrow("Methods annotated with Save must have one parameter for input")
@GenerateForCaching()
abstract class AMethodAnnotatedWithSaveThatHasNotParams {
  @Save(storageKey: 'key')
  Future<void> aMethodAnnotatedWithSaveThatHasNotParams();
}

@ShouldThrow("Methods annotated with Save must have one parameter for input")
@GenerateForCaching()
abstract class AMethodAnnotatedWithSaveThatHasMoreThanOneParam {
  @Save(storageKey: 'key')
  Future<void> aMethodAnnotatedWithSaveThatHasMoreThanOneParam(
    dynamic param1,
    dynamic param2,
  );
}

@ShouldThrow(
  "Methods annotated with Save must be void, Future<void>, or FutureOr<void>",
)
@GenerateForCaching()
abstract class AMethodAnnotatedWithSaveThatReturnsValue {
  @Save(storageKey: 'key')
  dynamic aMethodAnnotatedWithSaveThatReturnsDynamic(
    dynamic param1,
  );

  @Save(storageKey: 'key')
  Future<int> aMethodAnnotatedWithSaveThatReturnsFutureOfInt(
    dynamic param1,
  );

  @Save(storageKey: 'key')
  FutureOr<int> aMethodAnnotatedWithSaveThatReturnsFutureOrOfInt(
    dynamic param1,
  );
}
