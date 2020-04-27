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
  void getAllPeople(State state, Request req, Response res, Step step) {
    this.service.getAllPeople().then((people) {
      res.sendJson(people);
      step();
    });
  }

  @Post()
  void createPerson(State state, Request req, Response res, Step step) {
    var json = state.getLocal("json");
    this.service.createPerson(json["id"], json["name"], json["age"], json["likeToCode"]).then((_) {
      res.sendJson({
        "message": "success!"
      });
      step();
    }).catchError(step);
  }

  @Get("/:personId")
  void getPerson(State state, Request req, Response res, Step step) {
    var id = int.parse(req.getPathParameter("personId"));
    this.service.getPerson(id).then((person) {
      res.sendJson(person);
      step();
    });
  }

  @Patch("/:personId")
  void patchPerson(State state, Request req, Response res, Step step) {
    var id = int.parse(req.getPathParameter("personId"));
    var json = state.getLocal("json");
    this.service.patchPerson(id, name: json["name"], age: json["age"], likesToCode: json["likesToCode"]).then((person) {
      res.sendJson({
        "message": "success!"
      });
      step();
    });
  }

  @Put("/:personId")
  void putPerson(State state, Request req, Response res, Step step) {
    var json = state.getLocal("json");
    var id = int.parse(req.getPathParameter("personId"));
    this.service.putPerson(id, json["name"], json["age"], json["likesToCode"]).then((_) {
      res.sendJson({
        "message": "success!"
      });
      step();
    });
  }

  @Delete("/:personId")
  void deletePerson(State state, Request req, Response res, Step step) { 
    var id = int.parse(req.getPathParameter("personId"));
    this.service.deletePerson(id).then((_) {
      res.sendJson({
        "message": "success!"
      });
      step();
    });
  }

}



