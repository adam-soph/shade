/// Thrown when there if an avoidable problem occurs during the [Injector]'s `resolve` or
/// `resolveType` functions.
class InjectError extends Error {

  final String message;
  
  InjectError([this.message]);
  
  String toString() => this.message != null ? "InjectError: $message" : "InjectError";
  
}