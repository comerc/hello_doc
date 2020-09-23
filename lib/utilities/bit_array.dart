class BitArray {
  int _value;
  BitArray({int value = 0})
      : _value = value,
        assert(value != null);

  bool operator [](int index) {
    if (index >= 64) throw Exception('Wrong index...');
    final res = _value & 1 << index;
    if (res == 0) {
      return false;
    } else {
      return true;
    }
  }

  void operator []=(int index, bool value) {
    if (value) {
      setBit(index);
    } else {
      clearBit(index);
    }
  }

  void setBit(int index) {
    if (index >= 64) throw Exception('Wrong index...');
    _value = _value | 1 << index;
  }

  void clearBit(int index) {
    if (index >= 64) throw Exception('Wrong index...');
    _value = _value & ~(1 << index);
  }

  int get value => _value;
}
