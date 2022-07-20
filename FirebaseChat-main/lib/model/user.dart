            // model class for User

class User {
  final String id;
  final String name;
  final String bio;
  final DateTime? date;

  User({required this.id, required this.name, required this.bio, this.date});

  factory User.fromJson(String id, Map<String, dynamic> data) {
    return User(id: id, name: data["name"]??'', bio: data["bio"]??"");
  }

  Map<String, dynamic> toJson() {
    return {"id":id,"name": name, "bio": bio, "date": date};
  }


}
