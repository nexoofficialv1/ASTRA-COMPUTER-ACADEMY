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
import 'visual_zoom_screen.dart';
import 'visual_concept_screen.dart';

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
          if (lesson.learningGoalsBn.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'এই lesson-এ কী শিখবে',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final item in lesson.learningGoalsBn)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 7),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('✓  '),
                            Expanded(child: Text(item)),
                          ],
                        ),
                      ),
                    if (lesson.learningGoalsEn.isNotEmpty) ...[
                      const Divider(height: 22),
                      const Text(
                        'What you will learn',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      for (final item in lesson.learningGoalsEn)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text('• $item'),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
          if (lesson.hasVisualAsset) ...[
            const Text(
              'ছবি দেখে শুরু করি',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => VisualZoomScreen(
                            assetPath: lesson.visualAsset,
                            title: lesson.titleBn,
                            captionBn: lesson.visualCaptionBn,
                            captionEn: lesson.visualCaptionEn,
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 4 / 5,
                          child: Container(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerLowest,
                            child: Image.asset(
                              lesson.visualAsset,
                              width: double.infinity,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 10,
                          bottom: 10,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 7,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.zoom_in_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Tap to zoom',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (lesson.visualCaptionBn.trim().isNotEmpty)
                          Text(
                            lesson.visualCaptionBn,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        if (lesson.visualCaptionEn.trim().isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            lesson.visualCaptionEn,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                        const SizedBox(height: 9),
                        const Row(
                          children: [
                            Icon(Icons.touch_app_rounded, size: 18),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'ছবিতে ট্যাপ করুন → Full screen → Pinch করে zoom করুন',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          const SizedBox(height: 18),
          const Text(
            'সহজ ব্যাখ্যা',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
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
          if (lesson.examplesBn.isNotEmpty) ...[
            const Text(
              'উদাহরণ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final item in lesson.examplesBn)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text('• $item'),
                      ),
                    if (lesson.examplesEn.isNotEmpty) ...[
                      const Divider(height: 22),
                      const Text(
                        'Examples in English',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      for (final item in lesson.examplesEn)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text('• $item'),
                        ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          if (lesson.mockupCards.isNotEmpty) ...[
            const Text(
              'ভিজ্যুয়াল mockup',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            for (final card in lesson.mockupCards) ...[
              Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => VisualConceptScreen(card: card),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          card['icon']?.toString() ?? '🧩',
                          style: const TextStyle(fontSize: 30),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              card['titleBn']?.toString() ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(card['descriptionBn']?.toString() ?? ''),
                            if ((card['understandBn']?.toString() ?? '')
                                .trim()
                                .isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                '💡 ${card['understandBn']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  height: 1.4,
                                ),
                              ),
                            ],
                            if ((card['rememberBn']?.toString() ?? '')
                                .trim()
                                .isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                '⭐ ${card['rememberBn']}',
                                style: const TextStyle(height: 1.4),
                              ),
                            ],
                            if ((card['descriptionEn']?.toString() ?? '')
                                .trim()
                                .isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'English: ${card['descriptionEn']}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                            const SizedBox(height: 10),
                            const Row(
                              children: [
                                Icon(Icons.open_in_full_rounded, size: 17),
                                SizedBox(width: 5),
                                Expanded(
                                  child: Text(
                                    'ট্যাপ করলে বড় করে step-by-step explanation দেখাবে',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 6),
          ],
          if (lesson.importantWords.isNotEmpty) ...[
            const Text(
              'গুরুত্বপূর্ণ শব্দ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    for (final item in lesson.importantWords)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                item['word']?.toString() ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              flex: 3,
                              child: Text(
                                item['meaningBn']?.toString() ?? '',
                              ),
                            ),
                          ],
                        ),
                      ),
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
          if (lesson.recapBn.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Quick Recap',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final item in lesson.recapBn)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 7),
                        child: Text('✓ $item'),
                      ),
                    if (lesson.recapEn.isNotEmpty) ...[
                      const Divider(height: 22),
                      const Text(
                        'Quick Recap in English',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      for (final item in lesson.recapEn)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 7),
                          child: Text('• $item'),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
          if (lesson.commonMistakesBn.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'Common Mistakes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final item in lesson.commonMistakesBn)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 7),
                        child: Text('⚠ $item'),
                      ),
                    if (lesson.commonMistakesEn.isNotEmpty) ...[
                      const Divider(height: 22),
                      const Text(
                        'Common Mistakes in English',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      for (final item in lesson.commonMistakesEn)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 7),
                          child: Text('• $item'),
                        ),
                    ],
                  ],
                ),
              ),
            ),
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
