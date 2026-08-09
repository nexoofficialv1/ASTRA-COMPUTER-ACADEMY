# Development Status

Version: 0.8.0
Status: Basic Computer Release Candidate source completed; Flutter/Android runtime validation pending

### Working source modules
- Home / Course / Lesson / Quiz / Progress
- Student Profile / Mastery / Streak / Badges
- 9-component Final Practical Exam / Offline Certificate
- SQLite lesson progress and append-only practical attempts
- Typing Lab with WPM + accuracy targets
- Data Entry Lab with accuracy + timing + entries/minute
- Word formatting/table/document Lab + deterministic evaluator
- Word Save As / Page Setup / Print workflow simulation
- Word Header/Footer/Page Number practical
- Excel worksheet grid + arithmetic/aggregate/conditional/criteria/lookup formula engine
- Excel Percentage / Sort / Filter / Chart / Print workflow practicals
- Windows/File Manager offline sandbox
- Virtual keyboard shortcut lab
- Windows Desktop/Start/Taskbar/window-control sandbox
- Internet Browser offline sandbox
- Email compose/attachment sandbox + safety lessons
- PowerPoint slide practical simulator
- Integrated Office Project Lab
- Offline JSON Backup/Restore
- Certificate text/HTML/PDF export

### Seed curriculum
- Computer Fundamentals: 2 lessons
- MS Word: 11 lessons
- MS Excel: 16 lessons
- Data Entry: 5 lessons
- Typing: 4 lessons
- Windows & File Management: 8 lessons
- Internet Basics: 7 lessons
- MS PowerPoint: 4 lessons
- Real Office Projects: 3 lessons

Total seed lessons: 60
Total interactive practicals: 40
Database schema: v4 (unchanged in v0.8; no migration required)

### Validation boundary
Source-level consistency checks pass. Flutter SDK/Dart SDK are not available in this packaging environment, so compile, widget, emulator/device and APK tests are still pending.
