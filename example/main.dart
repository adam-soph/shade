import 'package:shade/shade.dart';

import 'person_service.dart';
import 'person_controller.dart';

void main() {

  var appBuilder = 
  ApplicationBuilder()
    ..addPreware(JsonBodyParser)
    ..addAllInjections({
      "PersonService": PrimaryPersonService
    })
    ..addAllControllers([
      PersonController
    ]);

  var app = appBuilder.build();
  app.listen(8000, () => print("Listening on port 8000"));
}
