class PostModel {
  final int id;
  final String title;
  final String body;
  final int userId;
  final List<String> tags;
  final PostReactions reactions;

  const PostModel({
    required this.id,
    required this.title,
    required this.body,
    required this.userId,
    required this.tags,
    required this.reactions,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: (json['id'] as int?) ?? 0,
      title: (json['title'] as String?) ?? '',
      body: (json['body'] as String?) ?? '',
      userId: (json['userId'] as int?) ?? 0,
      tags: List<String>.from((json['tags'] as List<dynamic>?) ?? []),
      reactions: json['reactions'] != null
          ? PostReactions.fromJson(json['reactions'] as Map<String, dynamic>)
          : const PostReactions(likes: 0, dislikes: 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'userId': userId,
      'tags': tags,
      'reactions': reactions.toJson(),
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PostModel &&
        other.id == id &&
        other.title == title &&
        other.body == body &&
        other.userId == userId &&
        other.tags == tags &&
        other.reactions == reactions;
  }

  @override
  int get hashCode {
    return id.hashCode ^
    title.hashCode ^
    body.hashCode ^
    userId.hashCode ^
    tags.hashCode ^
    reactions.hashCode;
  }
}

class PostReactions {
  final int likes;
  final int dislikes;

  const PostReactions({
    required this.likes,
    required this.dislikes,
  });

  factory PostReactions.fromJson(Map<String, dynamic> json) {
    return PostReactions(
      likes: (json['likes'] as int?) ?? 0,
      dislikes: (json['dislikes'] as int?) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'likes': likes,
      'dislikes': dislikes,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PostReactions &&
        other.likes == likes &&
        other.dislikes == dislikes;
  }

  @override
  int get hashCode {
    return likes.hashCode ^ dislikes.hashCode;
  }
}