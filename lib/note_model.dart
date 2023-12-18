class Note {
  String title;
  String content;
  DateTime timestamp;

  Note({
    required this.title,
    required this.content,
    required this.timestamp,
  });

  // Factory constructor to create a Note from a map (e.g., when loading from storage)
  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      title: map['title'],
      content: map['content'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  // Method to convert a Note to a map (e.g., for saving to storage)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
