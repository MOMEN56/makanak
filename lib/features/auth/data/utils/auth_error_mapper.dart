import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

abstract final class AuthErrorMapper {
  static String mapAuthError(
    supa.AuthException error, {
    bool isSignUp = false,
  }) {
    final message = error.message.toLowerCase();
    final code = error.code?.toLowerCase();

    if (code == 'over_email_send_rate_limit') {
      return 'تم إرسال محاولات كثيرة خلال وقت قصير. انتظري قليلًا ثم حاولي مرة أخرى.';
    }

    if (message.contains('invalid login credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
    }

    if (message.contains('email not confirmed')) {
      return 'فعّلي بريدك الإلكتروني أولًا ثم حاولي مرة أخرى.';
    }

    if (message.contains('user already registered') ||
        message.contains('already been registered')) {
      return 'يوجد حساب مسجل بهذا البريد الإلكتروني بالفعل.';
    }

    if (message.contains('password should be at least') ||
        message.contains('weak password')) {
      return 'كلمة المرور ضعيفة. استخدمي 8 أحرف على الأقل.';
    }

    if (message.contains('network') || message.contains('socket')) {
      return 'تحققي من اتصال الإنترنت ثم حاولي مرة أخرى.';
    }

    if (message.contains('signup') &&
        (message.contains('disabled') || message.contains('not allowed'))) {
      return 'إنشاء الحساب غير متاح الآن. حاولي مرة أخرى لاحقًا.';
    }

    if (message.contains('email') &&
        (message.contains('invalid') || message.contains('not valid'))) {
      return 'صيغة البريد الإلكتروني غير مقبولة. جرّبي بريدًا آخر.';
    }

    if (message.contains('rate limit') ||
        message.contains('too many') ||
        message.contains('security purposes')) {
      return 'تمت محاولات كثيرة خلال وقت قصير. انتظري دقيقة ثم جرّبي مرة أخرى ببريد جديد.';
    }

    if (message.contains('database') ||
        message.contains('saving') ||
        message.contains('trigger')) {
      return 'تعذر تجهيز بيانات الحساب الآن. حاول مرة أخرى بعد قليل.';
    }

    if (isSignUp) {
      return 'تعذر إنشاء الحساب الآن. راجعي البيانات وحاولي مرة أخرى.';
    }

    return 'تعذر تنفيذ الطلب الآن. حاول مرة أخرى بعد قليل.';
  }

  static String mapGooglePlatformError(PlatformException error) {
    final code = error.code.toLowerCase();
    final message = (error.message ?? '').toLowerCase();
    final details = '${error.details ?? ''}'.toLowerCase();
    final combined = '$code $message $details';

    if (combined.contains('10') || combined.contains('developer_error')) {
      return 'تعذر بدء تسجيل الدخول بحساب Google الآن. حاول مرة أخرى لاحقًا.';
    }

    if (combined.contains('12500') ||
        combined.contains('sign_in_failed') ||
        combined.contains('sign in failed')) {
      return 'تعذر بدء تسجيل الدخول بحساب Google الآن. حاول مرة أخرى لاحقًا.';
    }

    if (combined.contains('network')) {
      return 'تعذر تسجيل Google الآن بسبب مشكلة اتصال. تحققي من الإنترنت ثم حاولي مرة أخرى.';
    }

    return 'تعذر بدء تسجيل الدخول بحساب Google الآن. حاول مرة أخرى لاحقًا.';
  }
}
