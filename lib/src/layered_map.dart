import 'dart:collection';

class LayeredMap<K, V> extends MapBase<K, V> {

  final Map<K, V> _baseMap;
  final Map<K, V> _updates;

  LayeredMap([Map<K, V> baseMap, Map<K, V> updates]):
    _baseMap = baseMap ?? {},
    _updates = updates ?? {};

  V _getValueFor(K key) =>
    _updates.containsKey(key) ? _updates[key]
                              : _baseMap[key];

  void _setValueFor(K key, V value) =>
    _updates[key] = value;

  @override
  V operator [](Object key) => _getValueFor(key);

  @override
  void operator []=(K key, V value) => _setValueFor(key, value);

  @override
  void clear() => _updates.clear();

  @override
  Iterable<K> get keys => _baseMap.keys.toSet()..addAll(_updates.keys);

  @override
  V remove(Object key) => _updates.remove(key);
}
