class Pair<L, R> {
  final L left;
  final R right;

  const Pair(this.left, this.right);

  bool operator ==(Object o) {
    print(o is Pair<L, R> && o.left == this.left && o.right == this.right);
    return o is Pair<L, R> && o.left == this.left && o.right == this.right;
  }

  @override
  int get hashCode => this.right.hashCode ^ this.left.hashCode;
}
