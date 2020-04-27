
import 'package:shade/shade.dart';

void LogRequest(State state, Request req, Response res, Step step) {

  print("----- Logging Request -----");
  print("Path: ${req.path}");
  print("HttpMethod: ${req.httpMethod}");
  print("Json Body: ${state.getLocal("json")}");
  step();

}


