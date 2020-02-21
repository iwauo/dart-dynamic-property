/// A small utility which helps to use [Symbol]s.
class Symbols {

  static Symbol of(String name) {
    final getter = Symbol(name);
    if (!_nameOf.containsKey(getter)) {
      final setter = Symbol(name+"=");
      _nameOf[getter] = name;
      _nameOf[setter] = name;
    }
    return getter;
  }

  static String nameOf(Symbol symbol) => _nameOf[symbol];

  static Map<Symbol, String> _nameOf = {};
}
