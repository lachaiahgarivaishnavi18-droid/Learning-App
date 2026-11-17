import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/app_content.dart';
import '../data/course_models.dart';

class AuthAccount {
  const AuthAccount({
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.passwordHash,
  });

  final String fullName;
  final String email;
  final String mobile;
  final String passwordHash;

  Map<String, String> toJson() => {
    'fullName': fullName,
    'email': email,
    'mobile': mobile,
    'passwordHash': passwordHash,
  };

  factory AuthAccount.fromJson(Map<String, dynamic> json) => AuthAccount(
    fullName: json['fullName'] as String? ?? '',
    email: json['email'] as String? ?? '',
    mobile: json['mobile'] as String? ?? '',
    passwordHash: json['passwordHash'] as String? ?? '',
  );
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.name,
    required this.score,
    required this.period,
    required this.badge,
  });

  final String name;
  final int score;
  final String period;
  final String badge;
}

class TestAttempt {
  const TestAttempt({
    required this.id,
    required this.subject,
    required this.completedAt,
    required this.selections,
    required this.questionIds,
    required this.durationSeconds,
    this.mode = 'exam',
    this.courseId,
  });

  final String id;
  final String subject;
  final DateTime completedAt;
  final Map<String, int> selections;
  final List<String> questionIds;
  final int durationSeconds;
  final String mode;
  final String? courseId;

  int get total => questionIds.length;

  Map<String, dynamic> toJson() => {
    'id': id,
    'subject': subject,
    'completedAt': completedAt.toIso8601String(),
    'selections': selections,
    'questionIds': questionIds,
    'durationSeconds': durationSeconds,
    'mode': mode,
    'courseId': courseId,
  };

  factory TestAttempt.fromJson(Map<String, dynamic> json) {
    final subject = json['subject'] as String;
    final selections = (json['selections'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, value as int),
    );
    final savedQuestionIds = (json['questionIds'] as List<dynamic>?)
        ?.cast<String>()
        .toList();
    final questionIds =
        savedQuestionIds ??
        quizQuestions
            .where(
              (question) =>
                  question.subject ==
                  (subject == 'Technical Fundamentals'
                      ? 'Technical Questions'
                      : subject),
            )
            .map((question) => question.id)
            .toList();
    return TestAttempt(
      id: json['id'] as String,
      subject: subject,
      completedAt: DateTime.parse(json['completedAt'] as String),
      selections: selections,
      questionIds: questionIds.isEmpty ? selections.keys.toList() : questionIds,
      durationSeconds: json['durationSeconds'] as int,
      mode: json['mode'] as String? ?? 'exam',
      courseId: json['courseId'] as String?,
    );
  }
}

class StudentProject {
  const StudentProject({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.technologies,
    this.githubUrl = '',
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final String technologies;
  final String githubUrl;

  Map<String, String> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'category': category,
    'technologies': technologies,
    'githubUrl': githubUrl,
  };

  factory StudentProject.fromJson(Map<String, dynamic> json) => StudentProject(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    category: json['category'] as String,
    technologies: json['technologies'] as String,
    githubUrl: json['githubUrl'] as String? ?? '',
  );
}

class AppStore extends ChangeNotifier {
  AppStore._(this._preferences) {
    _bookmarks = _readStringSet('bookmarks');
    _completedLessons = _readStringSet('completed_lessons');
    _passedCourseAssessments = _readStringSet('passed_course_assessments');
    _attempts = _readJsonList('test_attempts', TestAttempt.fromJson);
    _projects = _readJsonList('projects', StudentProject.fromJson);
    _accounts = _readJsonList('auth_accounts', AuthAccount.fromJson);
    _currentUserEmail = _preferences.getString('auth_current_email');
    final savedName = _preferences.getString('display_name');
    final currentAccount = _currentUserEmail != null
        ? _accounts
              .where((account) => account.email == _currentUserEmail)
              .firstOrNull
        : null;
    _displayName = savedName ?? currentAccount?.fullName ?? 'Learner';
  }

  final SharedPreferences _preferences;
  late Set<String> _bookmarks;
  late Set<String> _completedLessons;
  late Set<String> _passedCourseAssessments;
  late List<TestAttempt> _attempts;
  late List<StudentProject> _projects;
  late List<AuthAccount> _accounts;
  late String? _currentUserEmail;
  late String _displayName;

  static Future<AppStore> create() async =>
      AppStore._(await SharedPreferences.getInstance());

  String get displayName => _displayName;
  String? get currentUserEmail => _currentUserEmail;
  bool get isAuthenticated => _currentUserEmail != null;
  Set<String> get bookmarks => Set.unmodifiable(_bookmarks);
  Set<String> get completedLessons => Set.unmodifiable(_completedLessons);
  Set<String> get passedCourseAssessments =>
      Set.unmodifiable(_passedCourseAssessments);
  List<TestAttempt> get attempts => List.unmodifiable(_attempts);
  List<StudentProject> get projects => List.unmodifiable(_projects);
  List<AuthAccount> get accounts => List.unmodifiable(_accounts);

  int get completedLessonCount => _completedLessons.length;

  String _hashPassword(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  AuthAccount? _accountForEmail(String email) {
    for (final account in _accounts) {
      if (account.email.toLowerCase() == email.toLowerCase()) {
        return account;
      }
    }
    return null;
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String mobile,
    required String password,
    required String confirmPassword,
  }) async {
    final trimmedName = fullName.trim();
    final trimmedEmail = email.trim();
    final trimmedMobile = mobile.trim();
    final trimmedPassword = password.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(
        fullName,
        'fullName',
        'Full name cannot be empty.',
      );
    }
    if (!trimmedEmail.contains('@') || !trimmedEmail.contains('.')) {
      throw ArgumentError.value(email, 'email', 'Enter a valid email address.');
    }
    if (trimmedPassword.length < 6) {
      throw ArgumentError.value(
        password,
        'password',
        'Password must be at least 6 characters.',
      );
    }
    if (trimmedPassword != confirmPassword.trim()) {
      throw ArgumentError.value(
        confirmPassword,
        'confirmPassword',
        'Passwords do not match.',
      );
    }
    if (_accountForEmail(trimmedEmail) != null) {
      throw StateError('An account already exists for this email.');
    }
    final account = AuthAccount(
      fullName: trimmedName,
      email: trimmedEmail,
      mobile: trimmedMobile,
      passwordHash: _hashPassword(password),
    );
    _accounts = [account, ..._accounts];
    await _write(
      'auth_accounts',
      () => _preferences.setString(
        'auth_accounts',
        jsonEncode(_accounts.map((item) => item.toJson()).toList()),
      ),
    );
    await _activateSession(account, persistLogin: true);
  }

  Future<void> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final trimmedEmail = email.trim();
    final account = _accountForEmail(trimmedEmail);
    if (account == null) {
      throw StateError('No account found for this email.');
    }
    if (account.passwordHash != _hashPassword(password)) {
      throw StateError('Incorrect password.');
    }
    await _activateSession(account, persistLogin: rememberMe);
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final trimmedEmail = email.trim();
    final account = _accountForEmail(trimmedEmail);
    if (account == null) {
      throw StateError('No account found for this email.');
    }
    if (newPassword.length < 6) {
      throw ArgumentError.value(
        newPassword,
        'newPassword',
        'Password must be at least 6 characters.',
      );
    }
    final updated = AuthAccount(
      fullName: account.fullName,
      email: account.email,
      mobile: account.mobile,
      passwordHash: _hashPassword(newPassword),
    );
    _accounts = _accounts
        .map(
          (item) => item.email.toLowerCase() == trimmedEmail.toLowerCase()
              ? updated
              : item,
        )
        .toList();
    await _write(
      'auth_accounts',
      () => _preferences.setString(
        'auth_accounts',
        jsonEncode(_accounts.map((item) => item.toJson()).toList()),
      ),
    );
    if (_currentUserEmail?.toLowerCase() == trimmedEmail.toLowerCase()) {
      await _activateSession(updated, persistLogin: true);
    }
  }

  Future<void> logout() async {
    await _write(
      'auth_current_email',
      () => _preferences.remove('auth_current_email'),
    );
    await _write(
      'auth_session_active',
      () => _preferences.setBool('auth_session_active', false),
    );
    _currentUserEmail = null;
    notifyListeners();
  }

  Future<void> _activateSession(
    AuthAccount account, {
    required bool persistLogin,
  }) async {
    _currentUserEmail = account.email;
    _displayName = account.fullName;
    await _write(
      'display_name',
      () => _preferences.setString('display_name', account.fullName),
    );
    if (persistLogin) {
      await _write(
        'auth_current_email',
        () => _preferences.setString('auth_current_email', account.email),
      );
      await _write(
        'auth_session_active',
        () => _preferences.setBool('auth_session_active', true),
      );
    } else {
      await _preferences.remove('auth_current_email');
      await _preferences.setBool('auth_session_active', false);
    }
    notifyListeners();
  }

  List<LeaderboardEntry> leaderboardFor(String period) {
    final now = DateTime.now();
    final entries = <LeaderboardEntry>[];
    final currentDisplayName = displayName;
    final userScore = attempts
        .where((attempt) {
          if (period == 'weekly') {
            return attempt.completedAt.isAfter(
              now.subtract(const Duration(days: 7)),
            );
          }
          if (period == 'monthly') {
            return attempt.completedAt.isAfter(
              now.subtract(const Duration(days: 30)),
            );
          }
          return true;
        })
        .fold<int>(0, (total, attempt) => total + _scoreForAttempt(attempt));
    entries.add(
      LeaderboardEntry(
        name: currentDisplayName,
        score: userScore,
        period: period,
        badge: 'You',
      ),
    );
    const sampleNames = [
      'Ava',
      'Noah',
      'Mia',
      'Ethan',
      'Isla',
      'Leo',
      'Zoe',
      'Omar',
      'Priya',
      'Daniel',
    ];
    for (var i = 0; i < sampleNames.length; i++) {
      final score =
          (period == 'global'
              ? 88 + i * 3
              : period == 'weekly'
              ? 70 + i * 5
              : 72 + i * 4) +
          (i * 2);
      entries.add(
        LeaderboardEntry(
          name: sampleNames[i],
          score: score,
          period: period,
          badge: '#${i + 1}',
        ),
      );
    }
    entries.sort((a, b) => b.score.compareTo(a.score));
    return entries.take(10).toList();
  }

  int _scoreForAttempt(TestAttempt attempt) {
    final questionById = {
      for (final question in quizQuestions) question.id: question,
    };
    if (attempt.questionIds.isEmpty) return 0;
    var correct = 0;
    for (final id in attempt.questionIds) {
      final question = questionById[id];
      if (question != null && attempt.selections[id] == question.answerIndex) {
        correct++;
      }
    }
    return ((100 * correct) / attempt.questionIds.length).round();
  }

  bool isCourseComplete(Course course) =>
      _passedCourseAssessments.contains(course.id) &&
      course.allLessons.every(
        (lesson) => _completedLessons.contains(lesson.id),
      );

  Set<String> _readStringSet(String key) =>
      _preferences.getStringList(key)?.toSet() ?? <String>{};

  List<T> _readJsonList<T>(
    String key,
    T Function(Map<String, dynamic>) decode,
  ) {
    final value = _preferences.getString(key);
    if (value == null || value.isEmpty) return <T>[];
    final decoded = jsonDecode(value);
    if (decoded is! List) {
      throw FormatException('Stored $key data is not a list.');
    }
    return decoded
        .map((item) => decode(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> toggleBookmark(String questionId) async {
    if (!_bookmarks.add(questionId)) _bookmarks.remove(questionId);
    await _writeStringList('bookmarks', _bookmarks.toList());
    notifyListeners();
  }

  Future<void> markLessonComplete(String lessonId) async {
    _completedLessons.add(lessonId);
    await _writeStringList('completed_lessons', _completedLessons.toList());
    notifyListeners();
  }

  Future<void> markCourseAssessmentPassed(String courseId) async {
    _passedCourseAssessments.add(courseId);
    await _writeStringList(
      'passed_course_assessments',
      _passedCourseAssessments.toList(),
    );
    notifyListeners();
  }

  Future<void> updateDisplayName(String name) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Name cannot be empty.');
    }
    await _write(
      'display_name',
      () => _preferences.setString('display_name', trimmedName),
    );
    _displayName = trimmedName;
    notifyListeners();
  }

  Future<void> saveAttempt(TestAttempt attempt) async {
    _attempts = [attempt, ..._attempts];
    await _write(
      'test_attempts',
      () => _preferences.setString(
        'test_attempts',
        jsonEncode(_attempts.map((item) => item.toJson()).toList()),
      ),
    );
    notifyListeners();
  }

  Future<void> saveProject(StudentProject project) async {
    final existingIndex = _projects.indexWhere((item) => item.id == project.id);
    if (existingIndex < 0) {
      _projects = [project, ..._projects];
    } else {
      _projects[existingIndex] = project;
      _projects = List.of(_projects);
    }
    await _persistProjects();
    notifyListeners();
  }

  Future<void> deleteProject(String id) async {
    _projects = _projects.where((project) => project.id != id).toList();
    await _persistProjects();
    notifyListeners();
  }

  Future<void> _persistProjects() => _write(
    'projects',
    () => _preferences.setString(
      'projects',
      jsonEncode(_projects.map((project) => project.toJson()).toList()),
    ),
  );

  Future<void> _writeStringList(String key, List<String> value) =>
      _write(key, () => _preferences.setStringList(key, value));

  Future<void> _write(String key, Future<bool> Function() operation) async {
    if (!await operation()) {
      throw StateError('Could not persist $key on this device.');
    }
  }
}
