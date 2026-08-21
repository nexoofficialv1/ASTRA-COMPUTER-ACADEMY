## 1.1.0+21 - Class V Visual Zoom & Guided Mockups
- Rebuilt the 12 Class V learning visuals in a portrait, mobile-first layout with larger labels.
- Learning images are now tappable and open in a full-screen InteractiveViewer with pinch zoom, pan, zoom-in, zoom-out and reset controls.
- Visual mockup cards are now tappable and open a larger guided concept view.
- Every Class V mockup now explains: what the learner is seeing, what they should understand, and what they should remember, in Bengali and English.
- Enlarged the in-lesson image preview to a 4:5 portrait learning area for better readability on phones.
- Preserved all existing practical routes, progress behavior and bilingual lesson content.

## 1.1.0+20 - Class V Real Visual Learning Pack
- Added 12 child-friendly educational visual assets for Class V lessons.
- Attached a real visual learning image to all 27 Class V lessons.
- Added Bengali and English visual captions inside the lesson screen.
- Preserved Phase 7 deep content, bilingual content and all existing practical routes.
- Added visual-pack integrity tests.

## 1.1.0+19 - Class V Deep Child-Friendly Content
- Deep-enriched all 27 Class V lessons with simpler Bengali explanations and supporting English explanations.
- Added "What you will learn", examples, important words, quick recap and common mistakes to every lesson.
- Added visual mockup cards so children can understand key ideas more easily without relying only on long text.
- Added bilingual quiz support with English question, options and answer explanation.
- Upgraded the lesson screen to a study-friendly structure designed for Class V children.
- Added deep-content integrity tests for all 27 lessons.

## 1.1.0+18 - Class V Bengali + English Learning Content
- Added English explanations directly below Bengali explanations for all 27 Class V lessons.
- Added English lesson titles, summaries, explanations and practice/key-point steps.
- Added bilingual quiz questions, options and answer explanations.
- Bengali remains primary; English is a direct supporting explanation underneath.
- English fields remain optional for the existing Foundation curriculum.
- Added bilingual integrity tests for all Class V lessons and quizzes.

## 1.1.0+17 - Class V Full Syllabus Completion Audit
- Added a machine-checkable Class V coverage manifest covering all 9 chapters and 80+ required syllabus topics.
- Closed previously non-interactive practical gaps in Chapters 1 and 2 with a Concept Sort lab.
- Completed Paint 3D project Save/Open workflow.
- Completed Scratch project workflow: Duplicate Sprite, Save, Open and Exit.
- Added interactive Sprite Library, Costume and Backdrop scene setup.
- Added original SDG, Healthy Living, Art Integration, Cyber Ethics, Cross-Curricular, Computational Thinking and higher-order reasoning activities.
- Added full coverage audit tests that fail CI if a required topic or practical mapping is missing.
- No database migration is required.

## 1.1.0+16 - Class V Assessment & Progress
- Added a Chapter Test for every Class V chapter using the chapter's own ASTRA quiz bank.
- Chapter Tests persist best score in the existing progress store; pass mark is 60%.
- Added a gated Class V Final Exam with one representative question from each of the 9 chapters; pass mark is 70%.
- Added a dedicated Class V School Progress Dashboard with lesson completion, practical average, chapter-test status and final-exam score.
- Added school assessment service tests.
- No database schema migration is required; assessment scores use stable synthetic progress IDs.

## 1.1.0+15 - Class V Windows Word Internet Integration
- Connected Class V Files/Folders to the existing offline File Manager simulator.
- Added an interactive Windows 10 personalization lab for Settings, Control Panel, Wallpaper, Theme and Browser launch.
- Added an advanced Word 2019 learning lab covering Find/Replace, spelling check, Thesaurus, formatting, page orientation, graphics, Text Wrapping, Draw, WordArt and Save.
- Connected Class V safe-search practice to the existing offline Internet Browser simulator.
- Added integration tests for all six mapped Class V lessons.
- Existing Basic Computer certification and final-exam scope remains unchanged.

## 1.1.0+14 - Class V Interactive Learning Labs
- Added the full Class V school-course foundation: 9 syllabus-aligned chapters and 27 original Bengali-first ASTRA lessons.
- Added Paint 3D simulator practicals for tools practice and Healthy Food Poster activity.
- Added Scratch 3 drag/drop block-programming simulator for colourful shapes, events/sound and mini quiz-game tasks.
- Added an offline AI pattern-prediction activity using Rock-Paper-Scissors to teach prediction, uncertainty and verification.
- Added Class V practical routing and integrity tests.
- Kept the existing Basic Computer Foundation certification/final-exam scope unchanged.
- No copyrighted book text or artwork is bundled; content is original ASTRA material aligned to the supplied syllabus structure.


## v1.0.1 - Flutter 3.44 analyze hotfix
- Migrated progress indicator theme to `ThemeData.progressIndicatorTheme` / `ProgressIndicatorThemeData`.
- Prevented `flutter create` from leaving the template `MyApp` widget test in ASTRA builds.
- Migrated deprecated color opacity calls to `withValues(alpha:)`.
- Migrated `DropdownButtonFormField.value` to `initialValue` with a keyed dependent filter field.
- Migrated quiz radio controls to `RadioGroup`.
- Fixed flow-control brace lints in the Excel formula parser.
# Changelog

## 0.9.0 - UI Implementation / Android Release Hardening Part 1
- Applied approved ASTRA navy/blue mobile visual system.
- Added branded splash screen and reusable brand mark.
- Rebuilt dashboard around welcome, streak, offline-ready status, progress ring and continue-learning flow.
- Added bottom navigation entry points for Home, Courses, Practical, Progress and Profile.
- Added Course Library and Practical Hub screens.
- Redesigned Course Detail with progress header and Lessons/Practicals tabs.
- Added global light theme and system dark-theme foundation.
- Preserved all v0.8 curriculum, practical engines, certification and database schema v4.
- Retained approved UI mockup under docs for implementation consistency.
- Flutter compile/runtime validation remains pending because Flutter/Dart SDK is unavailable in this packaging environment.

## 0.8.0 - Basic Computer Release Candidate Source
- Added Word Header/Footer/Page Number practical.
- Added Excel Percentage, Sort/Filter, Chart and Print Setup practicals.
- Added Windows Desktop/Start/Taskbar/window-control simulator.
- Added Email compose/attachment simulator and email safety lessons.
- Expanded curriculum from 48 to 60 lessons and 33 to 40 interactive practicals.
- Expanded Final Practical Exam from 5 to 9 core components.
- Added printable offline certificate PDF export using rendered certificate imagery.
- Added `pdf` and `path_provider` dependencies for local certificate file generation.
- Database remains schema v4; no migration required.
- Flutter compile/runtime remains pending because Flutter/Dart SDK is unavailable in the packaging environment.

## 0.7.0 - Basic Computer Completion Part 1
- Added MS PowerPoint course and offline slide simulator.
- Added slide/theme/title/content/bullet assessment.
- Added IF, COUNTIF, SUMIF and exact-match VLOOKUP to the local Excel formula engine.
- Added Result Sheet, Expense Analysis and Product Lookup Excel practicals.
- Added Word Page Setup / Save As / PDF-format / Print Preview workflow simulation.
- Added Windows virtual keyboard shortcut practical.
- Expanded curriculum from 36 to 48 lessons and from 26 to 33 interactive practicals.
- Database remains schema v4; no migration required.

## 0.6.0 - Windows, Internet & Data Portability
- Added Windows/File Manager course and offline sandbox practicals.
- Added create-folder, move-file, rename-file and delete-file evaluation.
- Added Internet Basics course covering browser/search/URL/HTTPS/download/upload/phishing safety.
- Added offline mock Browser practical with search, secure-site identification and simulated transfer actions.
- Added integrated Monthly Office Report project across file naming, Word, Excel, Data Entry and Typing.
- Added dependency-free JSON backup/restore using clipboard transfer.
- Added DB schema v4 with backup/restore audit log.
- Added certificate plain-text and HTML export foundation.
- Expanded curriculum from 26 to 36 lessons and from 21 to 26 interactive practicals.

## 0.4.0
- Added four MS Word office-document practicals: Leave Application, Official Letter, Notice and Resume.
- Added four Excel office practicals: Mark Sheet, Attendance, Stock Register and Billing.
- Generalized practical routing for all `word_*` and `excel_*` practical kinds.
- Upgraded Typing Lab with target WPM, target accuracy and combined skill scoring.
- Added English office, Bengali and mixed-record typing drills.
- Upgraded Data Entry Lab with elapsed time, entries/minute, target time and richer result metrics.
- Added registration, invoice and office master-record data-entry tasks.
- Added practical content integrity test and updated documentation.

## 0.3.0
- Added interactive Excel worksheet simulator with cell selection and formula bar.
- Added offline formula engine for cell arithmetic and SUM/AVERAGE/MIN/MAX/COUNT.
- Added range evaluation and common spreadsheet error handling.
- Added deterministic Excel practical evaluator that checks result plus formula usage/pattern.
- Added Formula Task 01, Function Task 02 and Office Sheet Task 03.
- Added Excel formula/evaluator unit tests.
- Updated curriculum, routing and architecture documentation.


## 0.2.0
- Added interactive MS Word Practical Lab.
- Added independent Heading and Paragraph formatting state.
- Added Bold, Italic and Underline controls.
- Added 10–24 pt font-size selector.
- Added Left, Center, Right and Justify alignment.
- Added editable table insertion (1–6 rows × 1–6 columns).
- Added deterministic curriculum-driven Word practical evaluator.
- Added criterion-level result feedback and offline score history.
- Added Formatting Task 01 and Table Task 02.
- Added Word evaluator tests.
- Updated architecture, database notes, roadmap and status documentation.

## 0.5.0 - Student Progress & Certification
- Added offline learner profile with name, phone, education, goal and language preference.
- Added DB v3 migration preserving existing lesson/practical progress.
- Added controlled sequential lesson progression/unlock behavior.
- Added course mastery scoring: 40% completion + 60% practical performance where interactive practicals exist.
- Added daily learning activity, current/longest streak calculation and active-day tracking.
- Added seven dynamic skill badges.
- Added five-component Final Practical Exam using Word, Excel, Typing and Data Entry core tasks.
- Added pass policy: each final component >=60% and overall final score >=70%.
- Added offline certificate eligibility, issuance, immutable snapshot and local Verification ID.

## 1.0.0+10 — Android build-ready hardening
- Added reproducible Android scaffold bootstrap using the active Flutter SDK.
- Added GitHub Actions analyze/test/release-APK workflow.
- Added ASTRA launcher icon and native splash overlay resources.
- Added offline-oriented Android manifest hardening.
- Added local Android build script and build guide.
- Added narrow-phone dashboard adaptations.
- Preserved 9 courses, 60 lessons, 40 interactive practicals, 9-part final exam and SQLite schema v4.
