class InjectError extends Error {

  final String message;
  
  InjectError([this.message]);
  
  String toString() => this.message != null ? "InjectError: $message" : "InjectError";
  
}