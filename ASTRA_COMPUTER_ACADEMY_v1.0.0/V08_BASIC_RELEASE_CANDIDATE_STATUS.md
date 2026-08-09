# v0.8 Basic Computer Release Candidate Source Status

## Completed
- 60 lessons across 9 course areas.
- 40 interactive practicals.
- Word Header/Footer/Page Number simulator.
- Excel Percentage formula task.
- Excel Sort/Filter workflow simulator.
- Excel Chart selection/preview simulator.
- Excel Print Setup simulator.
- Windows Desktop/Start/Taskbar/window-control simulator.
- Email compose/attachment simulator.
- Email phishing/suspicious attachment safety lesson.
- Final Practical Exam expanded to 9 skill components.
- Certificate printable PDF export using Flutter-rendered certificate image.
- Existing SQLite schema v4 retained.
- v0.8 source-level self-test added.

## Validation boundary
The source-level test validates content/schema/routing/import consistency and approximate lexical delimiter balance. It does not replace `flutter analyze`, `flutter test`, Android emulator/device tests or an actual release APK build.

## Next
v0.9 moved to the approved UI implementation milestone; Android build hardening is completed at source level in v1.0.0.
