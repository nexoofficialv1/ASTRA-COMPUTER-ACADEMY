import 'package:flutter/material.dart';
import '../models/learner_profile.dart';
import '../services/learner_profile_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.profileRepository,
  });

  final LearnerProfileRepository profileRepository;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _education = TextEditingController();
  final _goal = TextEditingController();
  String _language = 'bn';
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await widget.profileRepository.getProfile();
    if (!mounted) return;
    if (profile != null) {
      _name.text = profile.name;
      _phone.text = profile.phone ?? '';
      _education.text = profile.education;
      _goal.text = profile.goal;
      _language = profile.preferredLanguage;
    }
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await widget.profileRepository.saveProfile(
      LearnerProfile(
        name: _name.text,
        phone: _phone.text.trim().isEmpty ? null : _phone.text,
        education: _education.text,
        goal: _goal.text,
        preferredLanguage: _language,
      ),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Student profile সংরক্ষণ হয়েছে')),
    );
    Navigator.of(context).pop(true);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _education.dispose();
    _goal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Profile')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  Text(
                    'আপনার শেখার প্রোফাইল',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'এই তথ্য শুধুমাত্র আপনার ডিভাইসে offline সংরক্ষিত থাকবে। Certificate-এ নামটি ব্যবহার হবে।',
                  ),
                  const SizedBox(height: 22),
                  TextFormField(
                    controller: _name,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Student Name *',
                      prefixIcon: Icon(Icons.person_rounded),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'নাম লিখুন'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Mobile (optional)',
                      prefixIcon: Icon(Icons.phone_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _education,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Education',
                      prefixIcon: Icon(Icons.school_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _goal,
                    minLines: 2,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Learning Goal',
                      hintText: 'যেমন: Office job / Data Entry / Advanced coding',
                      prefixIcon: Icon(Icons.flag_rounded),
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: _language,
                    decoration: const InputDecoration(
                      labelText: 'Preferred Language',
                      prefixIcon: Icon(Icons.language_rounded),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'bn', child: Text('বাংলা')),
                      DropdownMenuItem(value: 'en', child: Text('English')),
                    ],
                    onChanged: (value) => setState(() => _language = value ?? 'bn'),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: const Icon(Icons.save_rounded),
                    label: Text(_saving ? 'সংরক্ষণ হচ্ছে...' : 'Profile Save করুন'),
                  ),
                ],
              ),
            ),
    );
  }
}
