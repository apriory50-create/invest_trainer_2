class Lesson {
  final int id;
  final int moduleId;
  final String moduleTitle;
  final String title;
  final String category;
  final int readingTimeMinutes;
  final String content;
  final List<String> keyRules;
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;

  const Lesson({
    required this.id,
    this.moduleId = 1,
    required this.moduleTitle,
    required this.title,
    this.category = 'База',
    this.readingTimeMinutes = 5,
    required this.content,
    this.keyRules = const [],
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
  });
}

