class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.summary,
    required this.example,
    this.topics = const [],
    this.expectedOutput,
    this.exercise,
  });

  final String id;
  final String title;
  final String summary;
  final String example;
  final List<String> topics;
  final String? expectedOutput;
  final String? exercise;
}

class CourseModule {
  const CourseModule({
    required this.title,
    required this.summary,
    required this.lessons,
  });

  final String title;
  final String summary;
  final List<Lesson> lessons;
}

class Course {
  const Course({
    required this.title,
    this.lessons = const [],
    this.modules = const [],
    this.description = '',
    this.objectives = const [],
    this.prerequisites = const [],
    this.level = 'Beginner',
    this.duration = 'Self-paced',
    this.tools = const [],
    this.capstoneProject = '',
    this.quizSubject,
  });

  final String title;
  final List<Lesson> lessons;
  final List<CourseModule> modules;
  final String description;
  final List<String> objectives;
  final List<String> prerequisites;
  final String level;
  final String duration;
  final List<String> tools;
  final String capstoneProject;
  final String? quizSubject;

  String get id => title.toLowerCase().replaceAll(' ', '-');

  List<Lesson> get allLessons => lessons.isNotEmpty
      ? lessons
      : modules.expand((module) => module.lessons).toList(growable: false);

  List<String> get allTopics => allLessons
      .expand((lesson) => lesson.topics)
      .toSet()
      .toList(growable: false);

  int get topicCount => allTopics.length;

  List<CourseModule> get learningModules {
    if (modules.isNotEmpty) return modules;
    final details = switch (title) {
      'Python' => (
        'Python foundations',
        'Reusable Python code',
        'Learn values, variables and core language behavior.',
        'Apply functions and collections to small programs.',
      ),
      'SQL' => (
        'Queries and relationships',
        'Aggregation and analysis',
        'Select and combine relational data.',
        'Summarize records and reason about grouped results.',
      ),
      'Machine Learning' => (
        'Model development',
        'Model evaluation',
        'Prepare data and validate model behavior.',
        'Select metrics and avoid misleading evaluations.',
      ),
      'Data Science' => (
        'Data quality and exploration',
        'Communicating findings',
        'Inspect, validate and explore source data.',
        'Explain evidence, uncertainty and next steps.',
      ),
      'Artificial Intelligence' => (
        'Search and AI concepts',
        'Responsible evaluation',
        'Represent states, actions and possible solutions.',
        'Evaluate system behavior, safety and limitations.',
      ),
      'Data Structures and Algorithms' => (
        'Core data structures',
        'Complexity and application',
        'Choose structures for the operations a problem needs.',
        'Compare algorithmic growth and practical trade-offs.',
      ),
      _ => (
        'Systems fundamentals',
        'Engineering practice',
        'Understand protocols and common system concepts.',
        'Apply collaboration and security principles.',
      ),
    };
    final splitAt = lessons.length > 1 ? lessons.length - 1 : lessons.length;
    return [
      CourseModule(
        title: details.$1,
        summary: details.$3,
        lessons: lessons.take(splitAt).toList(growable: false),
      ),
      if (lessons.length > splitAt)
        CourseModule(
          title: details.$2,
          summary: details.$4,
          lessons: lessons.skip(splitAt).toList(growable: false),
        ),
    ];
  }
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.subject,
    required this.prompt,
    required this.options,
    required this.answerIndex,
    required this.explanation,
    this.difficulty = 'Basic',
    this.topic = 'Fundamentals',
  });

  final String id;
  final String subject;
  final String prompt;
  final List<String> options;
  final int answerIndex;
  final String explanation;
  final String difficulty;
  final String topic;
}
