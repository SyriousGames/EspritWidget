class HslColor {
  double h;
  double s;
  double l;
  double a;

  HslColor({this.h = 0, this.s = 0, this.l = 0, this.a = 0.0});

  String toString() {
    return "HSL(h: $h, s: $s, l: $l, a: $a)";
  }
}
