import 'dart:mirrors';

List<T> getAllAnnotations<T>(List<InstanceMirror> metadata, [T tag]) {
  var annotations = List<T>();
  for (var metadataElement in metadata) {
    if (metadataElement.hasReflectee && metadataElement.reflectee is T && (tag == null || metadataElement.reflectee == tag)) {
      annotations.add(metadataElement.reflectee);
    }
  }
  return annotations;
}

T getAnnotation<T>(List<InstanceMirror> metadata, [T tag]) {
  var annotations = getAllAnnotations<T>(metadata, tag);
  return annotations.length == 0 ? null : annotations.first;
}

bool hasTag(List<InstanceMirror> metadata, tag) => getAllAnnotations(metadata, tag).length > 0;

MethodMirror getConstructorMirror(ClassMirror classMirror, [Symbol constructorName]) {
  DeclarationMirror declarationMirror;
  if (constructorName != null) {
    declarationMirror = classMirror.declarations.values.firstWhere((declare) => declare is MethodMirror && declare.isConstructor && constructorName == declare.constructorName, orElse: () => null);
  } else {
    declarationMirror = classMirror.declarations.values.firstWhere((declare) => declare is MethodMirror && declare.isConstructor && declare.parameters.length == 0, orElse: () => null);
  }
  if (declarationMirror == null) {
    return null;
  }
  return declarationMirror as MethodMirror;
}

