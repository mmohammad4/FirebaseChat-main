class SearchModel {
  final String id;
  final String title;
  final String desc;
  final String profilePic;
  final int isGroup;

  SearchModel({required this.id, required this.title, required this.desc, required this.profilePic, required this.isGroup});

  factory SearchModel.fromJson(String id, Map<String, dynamic> data) {
    return SearchModel(id: data["id"]??id, title: data["title"], desc: data["desc"], isGroup: data["isGroup"], profilePic: data["profilePic"]);
  }

  Map<String, dynamic> toJSON() {
    return {"id": id, "title": title, "desc": desc, "profilePic": profilePic, "isGroup": isGroup};
  }
}