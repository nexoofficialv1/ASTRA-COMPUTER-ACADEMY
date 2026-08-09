class LearnerProfile {
  const LearnerProfile({
    required this.name,
    required this.education,
    required this.goal,
    required this.preferredLanguage,
    this.phone,
  });

  final String name;
  final String education;
  final String goal;
  final String preferredLanguage;
  final String? phone;

  bool get isComplete => name.trim().isNotEmpty;
}
