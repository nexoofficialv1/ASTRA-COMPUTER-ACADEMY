# Student Progress & Certification — v0.5.0

## Implemented
- Student Profile stored locally in SQLite.
- Sequential lesson unlock inside each course.
- Course mastery model and overall mastery dashboard.
- Daily activity streak (current, longest, active days).
- Badges: First Step, 3 Day Streak, Accuracy Hero, Word Pro, Excel Pro, Course Finisher, Office Ready.
- Final Practical Exam with 5 core components:
  1. Word Resume Practical (`word_007`)
  2. Excel Mark Sheet (`excel_005`)
  3. Excel Billing Sheet (`excel_008`)
  4. English Office Typing (`typing_002`)
  5. Office Master Record Data Entry (`de_005`)
- Final exam requires >=60% in each component and >=70% average.
- Certificate requires profile, all lessons complete and a passed Final Practical Exam.
- Offline certificate stores a verification ID and issuance snapshot locally.

## Deliberate v0.5 limitation
The verification ID is local/offline only. Public online verification, QR validation, cloud account sync and signed PDF certificate are reserved for the later backend/web phase.
