class Project {
  final int id;
  final String content;
  final String author;

  Project({required this.id, required this.content, required this.author});

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'],
      content: json['content'],
      author: json['author'],
    );
  }
}
