import 'package:shade/shade.dart';

void main() {
  var appBuilder = ApplicationBuilder()
    ..addPreware(JsonBodyParser)
    ..addAllInjections({"PersonService": PrimaryPersonService})
    ..addAllControllers([PersonController]);

  var app = appBuilder.build();
  app.listen(8000, () => print("Listening on port 8000"));
}

// Controller
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
    this
        .service
        .createPerson(json["id"], json["name"], json["age"], json["likeToCode"])
        .then((_) {
      res.sendJson({"message": "success!"});
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
    this
        .service
        .patchPerson(id,
            name: json["name"],
            age: json["age"],
            likesToCode: json["likesToCode"])
        .then((person) {
      res.sendJson({"message": "success!"});
      step();
    });
  }

  @Put("/:personId")
  void putPerson(Request req, Response res, Step step) {
    var json = res.state["json"];
    var id = int.parse(req.pathParameters["personId"]);
    this
        .service
        .putPerson(id, json["name"], json["age"], json["likesToCode"])
        .then((_) {
      res.sendJson({"message": "success!"});
      step();
    });
  }

  @Delete("/:personId")
  void deletePerson(Request req, Response res, Step step) {
    var id = int.parse(req.pathParameters["personId"]);
    this.service.deletePerson(id).then((_) {
      res.sendJson({"message": "success!"});
      step();
    });
  }
}

// Dependencies
abstract class PersonService {
  Future<void> createPerson(int id, String name, int age, bool likesToCode);

  Future<void> deletePerson(int id);

  Future<List<Map<String, dynamic>>> getAllPeople();

  Future<Map<String, dynamic>> getPerson(int id);

  Future<void> patchPerson(int id, {String name, int age, bool likesToCode});

  Future<void> putPerson(int id, String name, int age, bool likesToCode);
}

class PrimaryPersonService implements PersonService {
  Future<void> createPerson(
      int id, String name, int age, bool likesToCode) async {
    people
        .add({"id": id, "name": name, "age": age, "likesToCode": likesToCode});
  }

  Future<List<Map<String, dynamic>>> getAllPeople() {
    return Future.value(people);
  }

  Future<void> deletePerson(int id) async {
    people.removeWhere((person) => person["id"] == id);
  }

  Future<Map<String, dynamic>> getPerson(int id) async {
    return Future.value(people.firstWhere((person) => person["id"] == id));
  }

  Future<void> patchPerson(int id,
      {String name, int age, bool likesToCode}) async {
    var personIndex = people.indexWhere((person) => person["id"] == id);
    if (name != null) {
      people[personIndex]["name"] = name;
    }
    if (age != null) {
      people[personIndex]["age"] = age;
    }
    if (likesToCode != null) {
      people[personIndex]["likesToCode"] = likesToCode;
    }
  }

  Future<void> putPerson(int id, String name, int age, bool likesToCode) async {
    var personIndex = people.indexWhere((person) => person["id"] == id);
    people[personIndex]["name"] = name;
    people[personIndex]["age"] = age;
    people[personIndex]["likesToCode"] = likesToCode;
  }
}

// Logging middleware
void LogRequest(Request req, Response res, Step step) {
  print("----- Logging Request -----");
  print("Path: ${req.path}");
  print("HttpMethod: ${req.method}");
  print("Json Body: ${res.state["json"]}");
  step();
}

// Emulated database
List<Map<String, dynamic>> people = [
  {"id": 1, "name": "Adam Soph", "age": 23, "likesToCode": true},
  {"id": 2, "name": "Joe John", "age": 45, "likesToCode": false},
  {"id": 3, "name": "Emilee Zenko", "age": 21, "likesToCode": true},
  {"id": 4, "name": "Ryan Fitz", "age": 37, "likesToCode": false},
  {"id": 5, "name": "Carmella Zenko", "age": 12, "likesToCode": true}
];
