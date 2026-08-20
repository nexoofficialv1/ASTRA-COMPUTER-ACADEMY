import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../services/progress_repository.dart';
import 'data_entry_lab_screen.dart';
import 'concept_sort_lab_screen.dart';
import 'excel_lab_screen.dart';
import 'excel_workflow_lab_screen.dart';
import 'file_manager_lab_screen.dart';
import 'email_lab_screen.dart';
import 'internet_lab_screen.dart';
import 'office_project_lab_screen.dart';
import 'powerpoint_lab_screen.dart';
import 'shortcut_lab_screen.dart';
import 'word_workflow_lab_screen.dart';
import 'quiz_screen.dart';
import 'typing_lab_screen.dart';
import 'word_lab_screen.dart';
import 'word_page_elements_lab_screen.dart';
import 'windows_desktop_lab_screen.dart';
import 'windows_personalization_lab_screen.dart';
import 'word_advanced_lab_screen.dart';
import 'paint3d_lab_screen.dart';
import 'scratch_lab_screen.dart';
import 'ai_decision_lab_screen.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen({
    super.key,
    required this.lesson,
    required this.progressRepository,
  });

  final Lesson lesson;
  final ProgressRepository progressRepository;

  Future<void> _openNext(BuildContext context) async {
    if (lesson.practicalKind == 'concept_sort') {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ConceptSortLabScreen(
            lesson: lesson,
            progressRepository: progressRepository,
          ),
        ),
      );
      return;
    }

    if (lesson.practicalKind == 'typing') {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TypingLabScreen(
            lesson: lesson,
            progressRepository: progressRepository,
          ),
        ),
      );
      return;
    }

    if (lesson.practicalKind == 'data_entry') {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DataEntryLabScreen(
            lesson: lesson,
            progressRepository: progressRepository,
          ),
        ),
      );
      return;
    }

    if (lesson.practicalKind == 'excel_workflow') {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ExcelWorkflowLabScreen(
            lesson: lesson,
            progressRepository: progressRepository,
          ),
        ),
      );
      return;
    }

    if (lesson.practicalKind?.startsWith('excel_') == true) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ExcelLabScreen(
            lesson: lesson,
            progressRepository: progressRepository,
          ),
        ),
      );
      return;
    }

    if (lesson.practicalKind == 'word_workflow') {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => WordWorkflowLabScreen(
            lesson: lesson,
            progressRepository: progressRepository,
          ),
        ),
      );
      return;
    }

    if (lesson.practicalKind == 'word_page_elements') {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => WordPageElementsLabScreen(
            lesson: lesson,
            progressRepository: progressRepository,
          ),
        ),
      );
      return;
    }

    if (lesson.practicalKind?.startsWith('word_') == true) {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => WordLabScreen(
            lesson: lesson,
            progressRepository: progressRepository,
          ),
        ),
      );
      return;
    }

    if (lesson.practicalKind == 'windows_file_manager') {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => FileManagerLabScreen(
            lesson: lesson,
            progressRepository: progressRepository,
          ),
        ),
      );
      return;
    }

    if (lesson.practicalKind == 'windows_desktop') {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => WindowsDesktopLabScreen(
            lesson: lesson,
            progressRepository: progressRepository,
          ),
        ),
      );
      return;
    }

    if (lesson.practicalKind == 'internet_browser') {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => InternetLabScreen(
            lesson: lesson,
            progressRepository: progressRepository,
          ),
        ),
      );
      return;
    }

    if (lesson.practicalKind == 'email_compose') {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => EmailLabScreen(
            lesson: lesson,
            progressRepository: progressRepository,
          ),
        ),
      );
      return;
    }

    if (lesson.practicalKind == 'office_project') {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OfficeProjectLabScreen(
            lesson: lesson,
            progressRepository: progressRepository,
          ),
        ),
      );
      return;
    }

    if (lesson.practicalKind == 'powerpoint') {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PowerPointLabScreen(
            lesson: lesson,
            progressRepository: progressRepository,
          ),
        ),
      );
      return;
    }

    if (lesson.practicalKind == 'keyboard_shortcuts') {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ShortcutLabScreen(
            lesson: lesson,
            progressRepository: progressRepository,
          ),
        ),
      );
      return;
    }

    if (lesson.practicalKind == 'windows_personalization') {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => WindowsPersonalizationLabScreen(
            lesson: lesson,
            progressRepository: progressRepository,
          ),
        ),
      );
      return;
    }

    if (lesson.practicalKind == 'word_advanced') {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => WordAdvancedLabScreen(
            lesson: lesson,
            progressRepository: progressRepository,
          ),
        ),
      );
      return;
    }

    if (lesson.practicalKind == 'paint3d') {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => Paint3DLabScreen(
            lesson: lesson,
            progressRepository: progressRepository,
          ),
        ),
      );
      return;
    }

    if (lesson.practicalKind == 'scratch') {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ScratchLabScreen(
            lesson: lesson,
            progressRepository: progressRepository,
          ),
        ),
      );
      return;
    }

    if (lesson.practicalKind == 'ai_decision') {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AiDecisionLabScreen(
            lesson: lesson,
            progressRepository: progressRepository,
          ),
        ),
      );
      return;
    }

    if (lesson.quiz.isEmpty) {
      await progressRepository.markCompleted(lesson.id);
      if (context.mounted) Navigator.of(context).pop();
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizScreen(
          lesson: lesson,
          progressRepository: progressRepository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final actionLabel = lesson.hasInteractivePractical
        ? 'Practical Lab শুরু করুন'
        : lesson.quiz.isEmpty
            ? 'লেসন সম্পন্ন করুন'
            : 'Quiz শুরু করুন';

    return Scaffold(
      appBar: AppBar(title: Text(lesson.titleBn)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 120),
        children: [
          Text(
            lesson.summaryBn,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 18),
          for (final paragraph in lesson.contentBn) ...[
            Text(paragraph, style: const TextStyle(fontSize: 16, height: 1.6)),
            const SizedBox(height: 14),
          ],
          if (lesson.hasEnglishExplanation) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.translate_rounded, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'English Explanation',
                          style: TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    if (lesson.titleEn.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        lesson.titleEn,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                    if (lesson.summaryEn.trim().isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        lesson.summaryEn,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                        ),
                      ),
                    ],
                    for (final paragraph in lesson.contentEn) ...[
                      const SizedBox(height: 10),
                      Text(
                        paragraph,
                        style: const TextStyle(fontSize: 15, height: 1.55),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          if (lesson.steps.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              lesson.isPractical ? 'Practice Steps' : 'মনে রাখুন',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < lesson.steps.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(radius: 13, child: Text('${i + 1}')),
                    const SizedBox(width: 10),
                    Expanded(child: Text(lesson.steps[i])),
                  ],
                ),
              ),
            if (lesson.stepsEn.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                lesson.isPractical
                    ? 'Practice Steps — English'
                    : 'Key Points — English',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              for (var i = 0; i < lesson.stepsEn.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(radius: 12, child: Text('${i + 1}')),
                      const SizedBox(width: 10),
                      Expanded(child: Text(lesson.stepsEn[i])),
                    ],
                  ),
                ),
            ],
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: () => _openNext(context),
          icon: Icon(lesson.hasInteractivePractical ? Icons.science_rounded : Icons.task_alt_rounded),
          label: Text(actionLabel),
        ),
      ),
    );
  }
}
