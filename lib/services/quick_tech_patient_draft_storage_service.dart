import 'package:get_storage/get_storage.dart';

class QuickTechPatientDraft {
  final String name;
  final String phone;
  final String age;
  final String gender;

  const QuickTechPatientDraft({
    required this.name,
    required this.phone,
    this.age = '',
    this.gender = '',
  });
}

class QuickTechPatientDraftStorageService {
  static final GetStorage _box = GetStorage();

  static const String _keyName = 'patientDraft.name';
  static const String _keyPhone = 'patientDraft.phone';
  static const String _keyAge = 'patientDraft.age';
  static const String _keyGender = 'patientDraft.gender';

  static Future<void> saveDraft({
    required String name,
    required String phone,
    String age = '',
    String gender = '',
  }) async {
    await _box.write(_keyName, name.trim());
    await _box.write(_keyPhone, phone.trim());
    await _box.write(_keyAge, age.trim());
    await _box.write(_keyGender, gender.trim());
  }

  static QuickTechPatientDraft? readDraft() {
    final name = _box.read<String>(_keyName);
    final phone = _box.read<String>(_keyPhone);
    final age = _box.read<String>(_keyAge);
    final gender = _box.read<String>(_keyGender);

    if (name == null || name.trim().isEmpty) return null;
    if (phone == null || phone.trim().isEmpty) return null;

    return QuickTechPatientDraft(
      name: name.trim(),
      phone: phone.trim(),
      age: (age ?? '').trim(),
      gender: (gender ?? '').trim(),
    );
  }

  static Future<void> clearDraft() async {
    await _box.remove(_keyName);
    await _box.remove(_keyPhone);
    await _box.remove(_keyAge);
    await _box.remove(_keyGender);
  }
}
