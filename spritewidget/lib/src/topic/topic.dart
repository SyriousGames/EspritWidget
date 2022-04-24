import 'dart:collection';

/// Manages subscribers who want to be notified about topics.
///
/// This does not expose the ability to notify subscribers, so you can
/// safely give this interface to subscribers.
///
/// This can be used
/// to decouple the game state from game UI.
/// It is similar to, but more flexible than, Flutter [Listenable], [ChangeNotifier],
/// and [ValueNotifier]. All notifications to subscribers are synchronous and
/// performed in the order in which the subscriber subscribed, from earliest
/// to latest.
abstract class Topic<T> {
  void subscribe(void Function(T) listener);
  void unsubscribe(void Function(T) listener);
}

/// A [Topic] which notifies subscribers about events.
class EventTopic<T> extends Topic<T> {
  Queue<void Function(T)> _subscribers = DoubleLinkedQueue();

  void subscribe(void Function(T) listener) {
    _subscribers.add(listener);
  }

  void unsubscribe(void Function(T) listener) {
    _subscribers.remove(listener);
  }

  void notify(T eventValue) {
    final subscribersCopy = List.from(_subscribers);
    for (final subscriber in subscribersCopy) {
      subscriber(eventValue);
    }
  }
}

/// An [EventTopic] which also holds a value.
///
/// If the value changes, as determined by the == operator, this topic
/// notifies its subscribers.
class ValueTopic<T> extends EventTopic<T> {
  T _value;

  ValueTopic(this._value);

  T get value => _value;
  void set value(T value) {
    final prev = _value;
    _value = value;
    if (value != prev) {
      notify(value);
    }
  }
}
