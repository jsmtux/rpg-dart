library directions;

class Directions
{
  final _value;
  const Directions._internal(this._value);
  toString() => 'Enum.$_value';

  static const UP = const Directions._internal('UP');
  static const DOWN = const Directions._internal('DOWN');
  static const LEFT = const Directions._internal('LEFT');
  static const RIGHT = const Directions._internal('RIGHT');
}