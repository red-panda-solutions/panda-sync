class TypeRegistryEntry<T> {
  final String boxName;
  final Function toJson;
  final Function fromJson;

  TypeRegistryEntry({
    required this.boxName,
    required this.toJson,
    required this.fromJson,
  });
}

class TypeRegistry {
  static final Map<Type, TypeRegistryEntry> _registry = {};

  static void register<T>(String boxName, Function toJson, Function fromJson) {
    _registry[T] = TypeRegistryEntry<T>(
      boxName: boxName,
      toJson: toJson,
      fromJson: fromJson,
    );
  }

  static TypeRegistryEntry<T>? get<T>() {
    return _registry[T] as TypeRegistryEntry<T>?;
  }

  static TypeRegistryEntry<dynamic>? getByName(String boxName) {
    return _registry.values.firstWhere((entry) => entry.boxName == boxName);
  }
}
