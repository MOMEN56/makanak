String? validateAuthFullName(String? value) {
  final fullName = value?.trim() ?? '';
  if (fullName.isEmpty) {
    return 'من فضلك أدخلي الاسم الكامل.';
  }

  if (fullName.length < 3) {
    return 'الاسم الكامل يجب أن يكون 3 أحرف على الأقل.';
  }

  return null;
}

String? validateAuthEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) {
    return 'من فضلك أدخلي البريد الإلكتروني.';
  }

  const emailPattern = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';
  if (!RegExp(emailPattern).hasMatch(email)) {
    return 'صيغة البريد الإلكتروني غير صحيحة.';
  }

  return null;
}

String? validateAuthPassword(String? value) {
  if ((value ?? '').isEmpty) {
    return 'من فضلك أدخلي كلمة المرور.';
  }

  if ((value ?? '').length < 8) {
    return 'كلمة المرور يجب ألا تقل عن 8 أحرف.';
  }

  return null;
}

String? validateAuthConfirmPassword(String? value, String password) {
  if ((value ?? '').isEmpty) {
    return 'من فضلك أكدي كلمة المرور.';
  }

  if (value != password) {
    return 'كلمتا المرور غير متطابقتين.';
  }

  return null;
}
