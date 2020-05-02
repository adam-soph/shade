
import 'package:shade/shade.dart';

void LogRequest(Request req, Response res, Step step) {

  print("----- Logging Request -----");
  print("Path: ${req.path}");
  print("HttpMethod: ${req.method}");
  print("Json Body: ${res.state["json"]}");
  step();

}


