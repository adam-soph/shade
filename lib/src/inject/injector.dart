import 'dart:mirrors';

import 'package:shade/src/utilities/metadata.dart';

import 'errors.dart';
import 'annotations.dart';

/// Resolves types with given injections.
class Injector {
  Map<String, dynamic> _injections;
  Map<Type, dynamic> _instanceCache;

  /// Creates a new Injector.
  ///
  /// [injections] is map of `token: tokenValue`. `tokenValue` can be an instance of an object, or a type to be resolved.
  ///
  /// Example:
  /// ```dart
  /// @Injectable()
  /// class SomeClass {
  ///
  ///   OtherClass other;
  ///   String someString;
  ///
  ///   SomeClass(@Inject("OtherToken") this.other, @Inject("SomeStringToken") this.someString);
  ///
  /// }
  ///
  /// void main() {
  ///
  ///   var injector = Injector({
  ///     "OtherToken": OtherClass,
  ///     "SomeStringToken": "Some String"
  ///   });
  ///
  /// }
  /// ```
  Injector(Map<String, dynamic> injections)
      : this._injections = injections,
        this._instanceCache = {};

  /// Resolved an instacne of type [T].
  ///
  /// All injections used during resolution are singletons.
  T resolve<T>() {
    return this.resolveType(T);
  }

  /// Resolved an instacne of type [type].
  ///
  /// All injections used during resolution are singletons.
  dynamic resolveType(Type type) {
    var mirror = reflectClass(type);
    var injectable = getAnnotation<Injectable>(mirror.metadata);
    var constructor = getConstructorMirror(mirror, injectable?.constructorName);

    if (constructor == null) {
      throw InjectError();
    }

    List<dynamic> positionalTokens = [];
    Map<Symbol, dynamic> namedTokens = {};

    for (ParameterMirror param in constructor.parameters) {
      var inject = getAnnotation<Inject>(param.metadata);
      if (inject == null || !this._injections.containsKey(inject.token)) {
        throw InjectError("Invalid token.");
      }
      var tokenValue = this._injections[inject.token];
      var resolvedToken;
      if (!(tokenValue is Type)) {
        resolvedToken = tokenValue;
      } else if (this._instanceCache.containsKey(tokenValue)) {
        resolvedToken = this._instanceCache[resolvedToken];
      } else {
        resolvedToken = this.resolveType(tokenValue);
        this._instanceCache[tokenValue] = resolvedToken;
      }
      if (!param.isNamed) {
        positionalTokens.add(resolvedToken);
      } else {
        namedTokens[param.simpleName] = resolvedToken;
      }
    }
    return mirror
        .newInstance(constructor.constructorName, positionalTokens, namedTokens)
        .reflectee;
  }
}
