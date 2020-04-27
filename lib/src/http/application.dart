import 'dart:io';

import 'router.dart';
import 'route_step.dart';
import 'request_context.dart';

class Application {
  
  Router _router;
  ErrorRouteStep _errorRouteFunction;
  SecurityContext _securityContext;

  Application(Router router, ErrorRouteStep errorRouteFunction, [SecurityContext securityContext]) {
    this._router = router;
    this._errorRouteFunction = errorRouteFunction;
    this._securityContext = securityContext;
  }

  void listen(int port, [Function callback]) async {
    HttpServer server;
    if (this._securityContext != null) {
      server = await HttpServer.bindSecure(InternetAddress.loopbackIPv4, port, this._securityContext);
    } else {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    }
    callback();
    await for (HttpRequest httpRequest in server) {
      RequestContext.create(httpRequest, this._router, this._errorRouteFunction);
    }
  }

}
