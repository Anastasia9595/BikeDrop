// No hardcoded colors here — nothing should be flagged.
class NotAColor {
  const NotAColor(this.value);
  final int value;
}

void useIt() {
  const NotAColor(1);
}
