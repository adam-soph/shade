
import 'exceptions.dart';
import 'response.dart';
import 'request.dart';
import 'state.dart';

abstract class ErrorHandler {

  void handle(State state, Request req, Response res, dynamic err);

}

class DefaultErrorHandler implements ErrorHandler {

  @override
  void handle(State state, Request req, Response res, err) {
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