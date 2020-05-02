import 'dart:convert';

import 'route_step.dart';
import 'context.dart';

/// The definition of a middleware object.
/// 
/// This is meant to be used as an interface.
/// 
/// If your middleware doesn't require dependencies or parameters it is recommended that you just use a [RouteStep].
abstract class Middleware {

  void step(Request req, Response res, Step step);

}

void JsonBodyParser(Request req, Response res, Step step) {
  utf8.decoder.bind(req.data).join().then((content) {
    print(content);
    var jsonBody = json.decode(content);
    res.state["json"] = jsonBody;
  }).catchError((err) {
    res.state["json"] = Map<String, dynamic>();
  }).then((_) => step());
}