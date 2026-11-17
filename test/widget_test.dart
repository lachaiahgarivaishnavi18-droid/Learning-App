import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:learning_app/data/app_content.dart';
import 'package:learning_app/data/quiz_bank.dart';
import 'package:learning_app/main.dart';
import 'package:learning_app/services/app_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('new learners see splash, welcome, and sign-up choices', (
    tester,
  ) async {
    final store = await AppStore.create();
    await tester.pumpWidget(LearningApp(store: store));
    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();
    expect(find.byType(WelcomePage), findsOneWidget);
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
  });

  test('local account sign-in survives app-store reload and logout', () async {
    final store = await AppStore.create();
    await store.signUp(
      fullName: 'Taylor',
      email: 'taylor@example.com',
      mobile: '1234567890',
      password: 'secure-pass',
      confirmPassword: 'secure-pass',
    );
    expect(store.isAuthenticated, isTrue);

    final reloaded = await AppStore.create();
    expect(reloaded.isAuthenticated, isTrue);
    expect(reloaded.displayName, 'Taylor');
    await reloaded.logout();
    expect(reloaded.isAuthenticated, isFalse);
    await reloaded.signIn(
      email: 'taylor@example.com',
      password: 'secure-pass',
      rememberMe: true,
    );
    expect(reloaded.isAuthenticated, isTrue);
  });

  testWidgets('shows the dashboard and all five main destinations', (
    tester,
  ) async {
    final store = await AppStore.create();
    await _pumpAuthenticatedApp(tester, store);

    expect(find.text('Hello, Learner!'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Learn'), findsOneWidget);
    expect(find.text('Interview'), findsOneWidget);
    expect(find.text('Projects'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('course lessons and interview practice are reachable', (
    tester,
  ) async {
    final store = await AppStore.create();
    await _pumpAuthenticatedApp(tester, store);

    await tester.tap(find.text('Learn'));
    await tester.pumpAndSettle();
    expect(find.text('Learning courses'), findsOneWidget);
    expect(find.text('Python'), findsOneWidget);

    await tester.tap(find.text('Interview'));
    await tester.pumpAndSettle();
    expect(find.text('Interview practice'), findsOneWidget);
    expect(find.text('Mock tests'), findsOneWidget);
  });

  testWidgets('courses opened from Profile have Material ancestors', (
    tester,
  ) async {
    final store = await AppStore.create();
    await _pumpAuthenticatedApp(tester, store);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('My courses'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Learning courses'), findsOneWidget);

    await tester.tap(find.text('Python').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.scrollUntilVisible(
      find.text('Modules and lessons'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Modules and lessons'), findsOneWidget);
  });

  testWidgets('Databricks modules open their lesson content', (tester) async {
    final store = await AppStore.create();
    await _pumpAuthenticatedApp(tester, store);
    await tester.tap(find.text('Learn'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Databricks'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Databricks'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('1. Databricks and the Lakehouse'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('1. Databricks and the Lakehouse'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('What Databricks provides'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('What Databricks provides'), findsOneWidget);
    await tester.tap(find.text('What Databricks provides'));
    await tester.pumpAndSettle();
    expect(find.text('Topics'), findsOneWidget);
    expect(find.text('Account vs workspace'), findsOneWidget);
  });

  test('bookmarks, lesson progress, profile and attempts persist', () async {
    final store = await AppStore.create();
    await store.toggleBookmark(interviewQuestions.first.id);
    for (final lesson in courses.first.allLessons) {
      await store.markLessonComplete(lesson.id);
    }
    await store.markCourseAssessmentPassed(courses.first.id);
    await store.updateDisplayName('Taylor');
    await store.saveAttempt(
      TestAttempt(
        id: 'attempt-1',
        subject: 'Python',
        completedAt: DateTime(2026, 1, 1),
        selections: const {'py-1': 1},
        questionIds: const ['py-1'],
        durationSeconds: 30,
      ),
    );

    final reloaded = await AppStore.create();
    expect(reloaded.bookmarks, contains(interviewQuestions.first.id));
    expect(
      reloaded.completedLessons,
      contains(courses.first.allLessons.first.id),
    );
    expect(reloaded.displayName, 'Taylor');
    expect(reloaded.attempts.single.id, 'attempt-1');
    expect(reloaded.isCourseComplete(courses.first), isTrue);
  });

  test(
    'priority courses have structured modules and usable assessment banks',
    () {
      for (final subject in ['Databricks', 'PySpark', 'Azure DevOps']) {
        final course = courses.singleWhere((course) => course.title == subject);
        expect(course.modules.length, greaterThanOrEqualTo(10));
        expect(course.allLessons.length, greaterThan(course.modules.length));
        expect(
          quizQuestions.where((question) => question.subject == subject).length,
          greaterThanOrEqualTo(100),
        );
      }
    },
  );

  test('Python course includes its beginner-to-advanced syllabus', () {
    final python = courses.singleWhere((course) => course.title == 'Python');
    expect(python.modules.length, greaterThanOrEqualTo(15));
    expect(python.allLessons.length, greaterThanOrEqualTo(30));
    expect(
      python.allLessons.map((lesson) => lesson.title),
      containsAll([
        'Introduction to Python',
        'Virtual environments and pip',
        'Variables and assignment',
        'Creating and updating lists',
        'Defining functions and returning values',
        'Recursion and base cases',
        'Classes, objects, and constructors',
        'Inheritance and composition',
        'NumPy arrays and vectorization',
        'Pandas Series and DataFrames',
        'Plotting with Matplotlib',
        'Python interview questions and review',
      ]),
    );
    expect(
      python.allLessons.every(
        (lesson) =>
            lesson.summary.isNotEmpty &&
            lesson.example.isNotEmpty &&
            lesson.exercise != null,
      ),
      isTrue,
    );
  });

  test(
    'all major question banks have unique tagged questions per difficulty',
    () {
      for (final subject in quizBankSubjects) {
        final questions = quizQuestions
            .where((question) => question.subject == subject)
            .toList();
        expect(questions.length, greaterThanOrEqualTo(100), reason: subject);
        expect(
          questions.map((question) => question.prompt).toSet().length,
          greaterThanOrEqualTo(100),
          reason: subject,
        );
        expect(
          questions.every((question) => question.topic.isNotEmpty),
          isTrue,
        );
        expect(
          questions.every((question) => question.options.length == 4),
          isTrue,
        );
        expect(
          questions.every(
            (question) =>
                question.options.toSet().length == 4 &&
                question.answerIndex >= 0 &&
                question.answerIndex < question.options.length,
          ),
          isTrue,
        );
        for (final difficulty in ['Basic', 'Intermediate', 'Advanced']) {
          expect(
            questions
                .where((question) => question.difficulty == difficulty)
                .length,
            greaterThanOrEqualTo(50),
            reason: '$subject / $difficulty',
          );
        }
      }
    },
  );

  testWidgets('50-question test setup selects unique questions', (
    tester,
  ) async {
    final store = await AppStore.create();
    await tester.pumpWidget(
      MaterialApp(
        home: TestSetupPage(subject: 'Machine Learning', store: store),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('unique questions available for all levels'),
      findsOneWidget,
    );
    for (final count in [10, 20, 30, 50]) {
      final countLabel = find.text('$count Questions');
      await tester.scrollUntilVisible(
        countLabel,
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(countLabel);
      await tester.pumpAndSettle();
      final chip = tester.widget<ChoiceChip>(
        find.ancestor(of: countLabel, matching: find.byType(ChoiceChip)),
      );
      expect(chip.selected, isTrue);
    }
    await tester.scrollUntilVisible(
      find.text('Start exam'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Start exam'));
    await tester.pumpAndSettle();

    final testPage = tester.widget<MockTestPage>(find.byType(MockTestPage));
    expect(testPage.questions, hasLength(50));
    expect(
      testPage.questions.map((question) => question.id).toSet(),
      hasLength(50),
    );
  });

  testWidgets('practice mode reveals feedback after an answer is submitted', (
    tester,
  ) async {
    final store = await AppStore.create();
    final questions = quizQuestions
        .where((question) => question.subject == 'Databricks')
        .take(10)
        .toList();
    await tester.pumpWidget(
      MaterialApp(
        home: MockTestPage(
          subject: 'Databricks',
          questions: questions,
          store: store,
          mode: TestMode.practice,
        ),
      ),
    );

    await tester.tap(find.text(questions.first.options.first).first);
    await tester.pump();
    await tester.tap(find.text('Submit answer / Reveal answer'));
    await tester.pump();

    expect(find.text('Correct'), findsOneWidget);
    expect(find.text(questions.first.explanation), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('exam mode defers answers until confirmed submission', (
    tester,
  ) async {
    final store = await AppStore.create();
    final questions = quizQuestions
        .where((question) => question.subject == 'Databricks')
        .take(10)
        .toList();
    await tester.pumpWidget(
      MaterialApp(
        home: MockTestPage(
          subject: 'Databricks',
          questions: questions,
          store: store,
          mode: TestMode.exam,
        ),
      ),
    );

    await tester.tap(find.text(questions.first.options.first).first);
    await tester.pump();
    expect(find.text(questions.first.explanation), findsNothing);

    for (var index = 0; index < questions.length - 1; index++) {
      await tester.ensureVisible(find.text('Next'));
      await tester.tap(find.text('Next'));
      await tester.pump();
    }
    await tester.ensureVisible(find.text('Submit exam'));
    await tester.tap(find.text('Submit exam'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit').last);
    await tester.pumpAndSettle();

    expect(find.text('10%'), findsOneWidget);
    expect(find.text(questions.first.explanation), findsOneWidget);
    expect(store.attempts.single.mode, 'exam');
    expect(store.attempts.single.questionIds, hasLength(10));
  });
}

Future<void> _pumpAuthenticatedApp(WidgetTester tester, AppStore store) async {
  await store.signUp(
    fullName: 'Learner',
    email: 'learner@example.com',
    mobile: '',
    password: 'learner-pass',
    confirmPassword: 'learner-pass',
  );
  await tester.pumpWidget(LearningApp(store: store));
  await tester.pump(const Duration(milliseconds: 800));
  await tester.pumpAndSettle();
}
