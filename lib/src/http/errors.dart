/// Thrown during [ApplicationBuilder]'s `build` function if the routes are misconfigured.
class RouteConfigurationError extends Error {
  
  final String message;
  
  RouteConfigurationError([this.message]);
  
  String toString() => this.message != null ? "RouteConfigurationError: $message" : "RouteConfigurationError";

}
