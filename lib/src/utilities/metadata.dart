import 'dart:mirrors';

List<T> getAllAnnotations<T>(List<InstanceMirror> metadata, [T tag]) {
  var annotations = List<T>();
  for (var metadataElement in metadata) {
    if (metadataElement.hasReflectee &&
        metadataElement.reflectee is T &&
        (tag == null || metadataElement.reflectee == tag)) {
      annotations.add(metadataElement.reflectee);
    }
  }
  return annotations;
}

T getAnnotation<T>(List<InstanceMirror> metadata, [T tag]) {
  var annotations = getAllAnnotations<T>(metadata, tag);
  return annotations.isEmpty ? null : annotations.first;
}

bool hasTag(List<InstanceMirror> metadata, tag) =>
    getAllAnnotations(metadata, tag).isNotEmpty;

MethodMirror getConstructorMirror(ClassMirror classMirror,
    [String constructorName]) {
  DeclarationMirror declarationMirror;
  if (constructorName != null) {
    var constructorNameSymbol = Symbol(constructorName);
    declarationMirror = classMirror.declarations.values.firstWhere(
        (declare) =>
            declare is MethodMirror &&
            declare.isConstructor &&
            constructorNameSymbol == declare.constructorName,
        orElse: () => null);
  } else {
    declarationMirror = classMirror.declarations.values.firstWhere(
        (declare) =>
            declare is MethodMirror &&
            declare.isConstructor &&
            declare.parameters.isEmpty,
        orElse: () => null);
  }
  if (declarationMirror == null) {
    return null;
  }
  return declarationMirror as MethodMirror;
}
