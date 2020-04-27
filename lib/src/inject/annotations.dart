class Injectable {
  final Symbol constructorName;
  const Injectable([this.constructorName = Symbol.empty]);
}

class Inject {
  final String token;
  const Inject(this.token);
}
