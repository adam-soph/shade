
/// Annotates a class as injectable.
/// 
/// The parameter [constructorName] is optional and is the name of the constructor that the
/// [Injector] will work with. If not specified it will assume the default constructor.
/// 
/// If this annotation is missing from class that is being injected, the [Injector] will use
/// an constructor with no parameters is one exists. Otherwise a [InjectError] will be thrown.
class Injectable {
  final String constructorName;
  const Injectable([this.constructorName = ""]);
}

/// Annotates the parameters within a constructor and gives them a [token].
/// 
/// This [token] is exchanged in the [Injector] for a value to be injected for this parameter.
class Inject {
  final String token;
  const Inject(this.token);
}
