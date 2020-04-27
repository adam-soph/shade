class RouteConfigurationError extends Error {
  
  final String message;
  
  RouteConfigurationError([this.message]);
  
  String toString() => this.message != null ? "RouteConfigurationError: $message" : "RouteConfigurationError";

}



