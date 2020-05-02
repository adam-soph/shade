import 'package:shade/shade.dart';

import 'person_service.dart';
import 'person_middleware.dart';

@Injectable()
@Controller("/person")
@Postware(LogRequest)
class PersonController {

  final PersonService service;

  PersonController(@Inject("PersonService") this.service);

  @Get()
  void getAllPeople(Request req, Response res, Step step) {
    this.service.getAllPeople().then((people) {
      res.sendJson(people);
      step();
    });
  }

  @Post()
  void createPerson(Request req, Response res, Step step) {
    var json = res.state["json"];
    this.service.createPerson(json["id"], json["name"], json["age"], json["likeToCode"]).then((_) {
      res.sendJson({
        "message": "success!"
      });
      step();
    }).catchError(step);
  }

  @Get("/:personId")
  void getPerson(Request req, Response res, Step step) {
    var id = int.parse(req.pathParameters["personId"]);
    this.service.getPerson(id).then((person) {
      res.sendJson(person);
      step();
    });
  }

  @Patch("/:personId")
  void patchPerson(Request req, Response res, Step step) {
    var id = int.parse(req.pathParameters["personId"]);
    var json = res.state["json"];
    this.service.patchPerson(id, name: json["name"], age: json["age"], likesToCode: json["likesToCode"]).then((person) {
      res.sendJson({
        "message": "success!"
      });
      step();
    });
  }

  @Put("/:personId")
  void putPerson(Request req, Response res, Step step) {
    var json = res.state["json"];
    var id = int.parse(req.pathParameters["personId"]);
    this.service.putPerson(id, json["name"], json["age"], json["likesToCode"]).then((_) {
      res.sendJson({
        "message": "success!"
      });
      step();
    });
  }

  @Delete("/:personId")
  void deletePerson(Request req, Response res, Step step) { 
    var id = int.parse(req.pathParameters["personId"]);
    this.service.deletePerson(id).then((_) {
      res.sendJson({
        "message": "success!"
      });
      step();
    });
  }

}



