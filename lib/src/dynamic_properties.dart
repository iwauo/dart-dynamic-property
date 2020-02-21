import 'symbols.dart';
import 'layered_map.dart';

typedef DynamicMethod = dynamic Function(dynamic, List<dynamic>);

mixin DynamicProperties {

  Map<String, dynamic> _properties = {};

  Map<String, Function> _methods = {};

  void defineProperties(Map<String, dynamic> properties) {
    if (properties == null) return;
    properties.keys.forEach(Symbols.of);
    this._properties.addAll(properties);
  }

  void defineMethods(Map<String, DynamicMethod> methods) {
    methods.keys.forEach(Symbols.of);
    this._methods.addAll(methods);
  }

  void clearProperties() => _properties.clear();

  Map<String, dynamic> pushLayer() {
    Map<String, dynamic> newLayer = {};
    _properties = LayeredMap(_properties, newLayer);
    return newLayer;
  }

  Map<String, dynamic> toJson() => Map.fromEntries(
    _properties
    .entries
    .where((e) => e.value != null)
    .map((e) => MapEntry(e.key, toEncodable(e.value)))
  );

  Map<String, dynamic> toMap() => {}..addAll(_properties);

  static dynamic toEncodable(dynamic v) {
    if (v is DateTime) return v.toIso8601String();
    return v;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    final name = Symbols.nameOf(invocation.memberName);
    if (name == null) throw Exception(
      "Undefined member name: ${invocation.memberName}." +
      " The all members must be declared using #defineProperties()" +
      " or #defineMethods()."
    );
    if (invocation.isMethod) {
      if (!_methods.containsKey(name)) throw Exception(
        "Unknown method name: ${name}, " +
        "which should be one of ${_methods.keys.join(", ")}."
      );
      return _methods[name].call(this, invocation.positionalArguments);
    }
    if (invocation.isAccessor && !_properties.containsKey(name)) throw Exception(
      "Unknown property name: ${name}, " +
      "which should be one of ${_properties.keys.join(", ")}."
    );
    if (invocation.isGetter) {
      return _properties[name];
    }
    if (invocation.isSetter) {
      _properties[name] = invocation.positionalArguments[0];
      return null;
    }
    return super.noSuchMethod(invocation);
  }
}
