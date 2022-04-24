part of flint_particles;

/// A collection of values that are weighted. When
/// a random value is required from the collection, the value returned
/// is randomly selected based on the weightings.
class WeightedList<T> {
  List<_Pair<T>> _values = [];
  double _totalWeights = 0;

  WeightedList();

  /// Adds a value to the WeightedList.
  ///
  /// @param value the value to add
  /// @param weight the weighting to place on the item
  void add(T value, double weight) {
    _totalWeights += weight;
    _values.add(_Pair(_totalWeights, value));
  }

  /// Empties the WeightedList. After calling this method the WeightedList
  /// contains no items.
  void clear() {
    _values.clear();
    _totalWeights = 0;
  }

  /// The number of items in the WeightedList
  int get length {
    return _values.length;
  }

  /// The sum of the weights of all the values.
  double get totalWeights {
    return _totalWeights;
  }

  /// Returns a random value from the WeightedList. The weighting of the values is
  /// used when selecting the random value, so items with a higher weighting are
  /// more likely to be selected.
  ///
  /// @return A randomly selected item from the array, based on the probability distribution of items.
  T getRandomValue() {
    return getValue(Random().nextDouble());
  }

  /// Returns a value from the WeightedList based on the probability distribution of items driven by
  /// [value] whose range is 0..1.
  T getValue(double value) {
    double position = value * _totalWeights;
    // Note: Cannot use dart binarySearch here because we need to find the closest match. Dart's tries to find an
    // exact match.
    int min = 0;
    int max = _values.length;
    while (min < max) {
      int mid = min + ((max - min) >> 1);
      var element = _values[mid];
      int comp = element.topWeight.compareTo(position);
      if (comp == 0) return element.value;
      if (comp < 0) {
        min = mid + 1;
      } else {
        max = mid;
      }
    }

    // Return closest match
    return _values[min].value;
  }
}

class _Pair<T> {
  double topWeight;
  T value;

  _Pair(this.topWeight, this.value);
}
