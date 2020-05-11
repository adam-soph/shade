import 'dart:io';
import 'dart:convert';

import 'package:shade/src/http/http.dart';

/// Middleware to used parse the request body to json.
///
/// Stores the Json into the response [State] with key `json`.
///
/// Not be parsed if request `mimeType` is not `application/json`, the request body is not valid json, and/or the request body is not `UTF-8`.
void JsonBodyParser(Request req, Response res, Step step) {
  if (req.headers.contentType.mimeType == ContentType.json.mimeType) {
    utf8.decoder
        .bind(req.data)
        .join()
        .then((content) => res.state["json"] = json.decode(content))
        .catchError((_) => null)
        .then((_) => step());
  } else {
    step();
  }
}

class CORS implements Middleware {
  final List<String> allowOrigins;
  final List<String> allowMethods;
  final List<String> allowHeaders;
  final List<String> exposeHeaders;
  final int maxAge;
  final bool allowCredentials;

  const CORS(
      {this.allowOrigins = const ["*"],
      this.allowMethods = const ["*"],
      this.allowHeaders = const ["*"],
      this.maxAge = 86400,
      this.exposeHeaders,
      this.allowCredentials});

  @override
  void step(Request req, Response res, step) {
    res.headers.add("Access-Control-Allow-Origin", this.allowOrigins.join(","));
    res.headers
        .add("Access-Control-Allow-Headers", this.allowHeaders.join(","));
    res.headers
        .add("Access-Control-Allow-Methods", this.allowMethods.join(","));

    if (this.exposeHeaders != null) {
      res.headers
          .add("Access-Control-Expose-Headers", this.exposeHeaders.join(","));
    }
    if (this.maxAge != null) {
      res.headers.add("Access-Control-Max-Age", this.maxAge);
    }
    if (this.allowCredentials != null) {
      res.headers
          .add("Access-Control-Allow-Credentials", this.allowCredentials);
    }
    if (req.method == "OPTIONS") {
      res.send();
      step(ApplicationCommand.BREAK);
    } else {
      step();
    }
  }
}
