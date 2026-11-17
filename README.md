# Learning App

An offline-first Flutter app for learning, interview practice and mock tests.
The interface uses Material 3 and the royal-blue visual identity of the
original app.

## Current functionality

- Five-tab navigation for Home, Learn, Interview, Projects and Profile.
- Splash and welcome screens with local sign-up/sign-in and remembered sessions.
- A course catalogue covering Python, SQL, Machine Learning, Data Science, AI,
  Data Structures and Algorithms, Technical Fundamentals, Databricks, PySpark,
  Azure DevOps and Git/GitHub.
- An 18-module Python course with beginner-to-advanced lessons, code examples,
  exercises, NumPy, Pandas, Matplotlib, and a capstone.
- Structured 10-module Databricks and PySpark curricula and an 11-module Azure
  DevOps curriculum, with examples, expected outputs or exercises where
  applicable. Lessons and progress are stored locally.
- Searchable interview questions with category/difficulty filters and local
  bookmarks.
- Subject mock interviews with timers, reference answers and deterministic
  keyword checklists (no generative AI).
- Practice and exam mock-test modes with countdowns, answer navigation,
  review flags, scoring, explanations and saved history. Course assessments
  require lesson completion and a passing exam result.
- Performance summaries calculated from saved test attempts.
- Create, edit, view and delete project records, stored on the device.
- Editable local learner name.

## Storage and service configuration

Course progress, bookmarks, test attempts, project metadata and the profile
name use `shared_preferences` on the current device. They are not synced,
encrypted as account data, or shared between devices.

This project did not include Supabase configuration or an existing backend.
Authentication, cloud database synchronization, owner-based server
authorization, and project file upload/download are therefore not enabled.
Configure a Supabase project and its URL/public key, authentication redirect
settings, Storage bucket and Row Level Security policies before enabling those
features. Do not put a service-role key in the mobile application.

The interview bank remains a small curated starter set. Quiz setup now draws
from a subject/topic-tagged bank for 25 subjects, with 150 generated question
records per subject plus the original curated questions where available.
Question records are formed from ten core concepts per subject and alternate
question formats; they are not 150 independently authored facts per subject.
The bank provides at least 50 records at each difficulty and enables the
10-, 20-, 30- and 50-question options. Each test samples questions without
repeating an ID within that test.

Course completion is a local Learning App progress record; assignments and
PDF certificates are not implemented. Leaderboards are not enabled because
there is no authenticated multi-user backend, and the app does not fabricate
other students or rankings. Local authentication is for offline use and is
not a substitute for Firebase or another trusted authentication service.

## Run and build

```shell
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

The app label is `Learning App`. A release APK is written to
`build/app/outputs/flutter-apk/app-release.apk` when the Android release build
succeeds. The current Android release configuration uses the default debug
signing setup; configure a production keystore before distribution.
