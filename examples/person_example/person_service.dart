abstract class PersonService {

  Future<void> createPerson(int id, String name, int age, bool likesToCode);

  Future<void> deletePerson(int id);

  Future<List<Map<String, dynamic>>> getAllPeople();

  Future<Map<String, dynamic>> getPerson(int id);

  Future<void> patchPerson(int id, { String name, int age, bool likesToCode });

  Future<void> putPerson(int id, String name, int age, bool likesToCode);

}


class PrimaryPersonService implements PersonService {

  Future<void> createPerson(int id, String name, int age, bool likesToCode) async {
    people.add({
      "id": id,
      "name": name,
      "age": age,
      "likesToCode": likesToCode
    });
  }

  Future<List<Map<String, dynamic>>> getAllPeople() {  
    return Future.value(people);
  }

  Future<void> deletePerson(int id) async {
    people.removeWhere((person) => person["id"] == id);
  }

  Future<Map<String, dynamic>> getPerson(int id) async {
    return Future.value(people.firstWhere((person) => person["id"]== id));
  }

  Future<void> patchPerson(int id, { String name, int age, bool likesToCode }) async {
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


List<Map<String, dynamic>> people = [
  {
    "id": 1,
    "name": "Adam Soph",
    "age": 23,
    "likesToCode": true
  },{
    "id": 2,
    "name": "Joe John",
    "age": 45,
    "likesToCode": false
  },{
    "id": 3,
    "name": "Emilee Zenko",
    "age": 21,
    "likesToCode": true
  },{
    "id": 4,
    "name": "Ryan Fitz",
    "age": 37,
    "likesToCode": false
  },{
    "id": 5,
    "name": "armella Zenko",
    "age": 13,
    "likesToCode": true
  }
];