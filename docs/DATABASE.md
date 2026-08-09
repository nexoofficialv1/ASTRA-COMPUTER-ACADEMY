# Database — schema version 4

SQLite stores all learner state locally. Curriculum content remains bundled JSON and is not duplicated into the database.

## `lesson_progress`
One row per stable lesson ID. Stores completion state, best score and update time.

## `practice_attempt`
Append-only history:
- `lesson_id`
- `practical_kind`
- `score`
- `metric_json`
- `created_at`

Metric JSON can store Word/Excel criteria, Typing WPM/accuracy, Data Entry speed/accuracy, File Manager task state, Internet simulator actions and Office Project answers.

## `learner_profile`
Single local learner profile with name, education, learning goal, language, optional phone and timestamps.

## `learning_activity`
Learning/practical activity dates for current streak, longest streak and active days.

## `final_exam_attempt`
Final exam score, pass/fail state and component score JSON snapshot.

## `certificate`
Offline certificate metadata:
- verification ID
- learner name
- certificate title
- final score
- immutable snapshot JSON
- issued timestamp

## `backup_restore_log` — new in v4
Stores local data portability actions:
- `action` (`export` / `restore`)
- `record_count`
- `created_at`

## Migration
v0.6 upgrades schema version 3 → 4 non-destructively by adding `backup_restore_log`. Existing profile, lesson progress, attempts, streak, exam and certificate records are preserved.

## v0.8
No schema change. Database remains version 4. New Word/Excel/Windows/Email practical attempts continue to use `practice_attempt` with their `practical_kind` and JSON metrics. Expanded final-exam component maps are stored in the existing `final_exam_attempt.component_json` field.
