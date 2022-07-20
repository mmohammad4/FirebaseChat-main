class Users {
  String id;
  String name;
  String bio;
  String profilePic;
  double latitude;
  double longitude;
  String address;
  DateTime? date;

  Users({
    required this.id,
    required this.name,
    required this.bio,
    this.date,
    this.profilePic = "",
    this.latitude = 0,
    this.longitude = 0,
    this.address = "",});

  factory Users.fromJson(String id, Map<String, dynamic> data) {
    return Users(
      id: data["id"]??id,
      name: data["name"],
      bio: data["bio"],
      profilePic: data["profilePic"]??"",
      latitude: data["latitude"]??0,
      longitude: data["longitude"]??0,
      address: data["address"]??"",
    );
  }

  Map<String, dynamic> toJSON() {
    return {
      "id": id,
      "name": name,
      "bio": bio,
      "date": date,
      "profilePic": profilePic,
      "latitude": latitude,
      "longitude": longitude,
      "address": address,};
  }
}
