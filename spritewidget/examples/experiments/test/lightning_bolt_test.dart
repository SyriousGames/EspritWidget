import 'package:experiments/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:spritewidget/spritewidget.dart';

void main() {
  final texture = _MockSpriteTexture();
  test('getPointAlongALine - horizontal', () {
    final bolt = LightningBolt(Offset(10, 16), Offset(20, 16), texture);
    expect(bolt.getPointAlongLine(0), equals(Offset(10, 16)));
    expect(bolt.getPointAlongLine(0.5), equals(Offset(15, 16)));
    expect(bolt.getPointAlongLine(1), equals(Offset(20, 16)));
  });

  test('getPointAlongALine - vertical', () {
    final bolt = LightningBolt(Offset(16, 10), Offset(16, 20), texture);
    expect(bolt.getPointAlongLine(0), equals(Offset(16, 10)));
    expect(bolt.getPointAlongLine(0.5), equals(Offset(16, 15)));
    expect(bolt.getPointAlongLine(1), equals(Offset(16, 20)));
  });

  test('getPointAlongALine - diagonal down to right', () {
    final bolt = LightningBolt(Offset(10, 10), Offset(20, 20), texture);
    expect(bolt.getPointAlongLine(0), equals(Offset(10, 10)));
    expect(bolt.getPointAlongLine(0.5), equals(Offset(15, 15)));
    expect(bolt.getPointAlongLine(1), equals(Offset(20, 20)));
  });

  test('getPointAlongALine - diagonal up to left', () {
    final bolt = LightningBolt(Offset(20, 20), Offset(10, 10), texture);
    expect(bolt.getPointAlongLine(0), equals(Offset(20, 20)));
    expect(bolt.getPointAlongLine(0.5), equals(Offset(15, 15)));
    expect(bolt.getPointAlongLine(1), equals(Offset(10, 10)));
  });

  test('getPointAlongALine - non-45 slope', () {
    final bolt = LightningBolt(Offset(2, 4), Offset(11, 7), texture);
    final result = bolt.getPointAlongLine(0.6666666666666666667);
    expect(result, equals(Offset(8.0, 6.0)));
  });
}

class _MockSpriteTexture extends Mock implements SpriteTexture {}
