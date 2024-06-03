class Project {
  final String project;
  final String author;
  // Tambahkan properti lainnya sesuai kebutuhan

  Project({required this.project, required this.author});

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      project: json['project'],
      author: json['author'],
      // Inisialisasi properti lainnya dari JSON
    );
  }
}
