import 'dart:convert';

import 'route_step.dart';
import 'state.dart';
import 'request.dart';
import 'response.dart';

abstract class Middleware {

  void step(State state, Request req, Response res, Step step);

}

void JsonBodyParser(State state, Request req, Response res, Step step) {
  utf8.decoder.bind(req.stream).join().then((content) {
    print(content);
    var jsonBody = json.decode(content);
    state.putLocal("json", jsonBody);
  }).catchError((err) {
    state.putLocal("json", {});
  }).then((_) => step());
}