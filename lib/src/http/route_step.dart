import 'response.dart';
import 'request.dart';
import 'state.dart';

typedef Step = void Function([dynamic error]);

typedef RouteStep = void Function(State state, Request req, Response res, Step step);

typedef ErrorRouteStep = void Function(State state, Request req, Response res, dynamic err);

