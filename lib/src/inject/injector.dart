import 'dart:mirrors';

import 'package:shade/src/utilities/metadata.dart';

import 'errors.dart';
import 'annotations.dart';

class Injector {
  
  Map<String, dynamic> _injections;
  Map<Type, dynamic> _instanceCache;

  Injector(Map<String, dynamic> injections) : _injections = injections {
    this._instanceCache = {};
  }

  T resolve<T>() {
    return this.resolveType(T);
  }

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
      var tokenvalue = this._injections[inject.token];
      var resolvedToken;
      if (!(tokenvalue is Type)) {
        resolvedToken = tokenvalue;
      } else if (this._instanceCache.containsKey(tokenvalue)) {
        resolvedToken = this._instanceCache[resolvedToken];
      } else {
        resolvedToken = this.resolveType(tokenvalue);
        this._instanceCache[tokenvalue] = resolvedToken;
      }
      if (!param.isNamed) {
        positionalTokens.add(resolvedToken);
      } else {
        namedTokens[param.simpleName] = resolvedToken;
      }
    }
    return mirror.newInstance(constructor.constructorName, positionalTokens, namedTokens).reflectee;
  }

}