
import 'exceptions.dart';
import 'context.dart';

/// The defintion of an [Application]'s error handler.
/// 
/// This class is meant to be used as an interface.
abstract class ErrorHandler {

  /// Called when an error occured in a request context.
  void handle(Request req, Response res, dynamic err);

}

/// The default error handler if another error handler is not specified in the [ApplicationBuilder].
class DefaultErrorHandler implements ErrorHandler {

  /// The default handle function will send a 404 for [RouteNotFoundException]s and a 500 for anything else.
  @override
  void handle(Request req, Response res, err) {
    if (!res.sent) {
      if (err is RouteNotFoundException) {
        res..statusCode = 404..sendText(err.toString());
      } else {
        res..statusCode = 500..sendText(err.toString());
      }
    }
    print(err.toString());
  }

}