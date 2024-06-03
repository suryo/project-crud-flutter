class Project {
  final String content;
  final String author;
  // Tambahkan properti lainnya sesuai kebutuhan

  Project({required this.content, required this.author});

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      content: json['content'],
      author: json['author'],
      // Inisialisasi properti lainnya dari JSON
    );
  }
}
