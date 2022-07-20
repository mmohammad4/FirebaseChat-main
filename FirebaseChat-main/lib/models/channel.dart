class Channel {
  Channel({
    required this.channel,
    required this.isGroup,
    required this.groupName,
    required this.users,
  });

  final String channel;
  final int isGroup;
  final String groupName;
  final Map<String, dynamic> users;

  factory Channel.fromJson(String channelId, Map<dynamic, dynamic> json) => Channel(
    channel: json["channel"] ?? channelId,
    groupName: json["groupName"] ?? "",
    isGroup: json["isGroup"],
    users: json["users"],
  );

  Map<String, dynamic> toJson() => {
    "channel": channel,
    "isGroup": isGroup,
    "groupName": groupName,
    "users": users,
  };
}