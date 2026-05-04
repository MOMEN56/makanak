class AppStrings {
  const AppStrings._();

  static const appTitle = 'مكانك';
  static const cartTitle = 'سلة المشتريات';
  static const cartEmpty = 'السلة فارغة';
  static const product = 'منتج';
  static const continueText = 'متابعة';
  static const addAddress = 'إضافة عنوان';
  static const addressNameHint = 'شارع النصر سموحة';
  static const addressName = 'اسم العنوان';
  static const street = 'الشارع';
  static const phoneNumber = 'رقم التليفون';
  static const floor = 'الدور';
  static const buildingNumber = 'رقم العمارة';
  static const apartmentNumber = 'رقم الشقة';
  static const deliveryNotesHint = 'أي ملاحظات للتوصيل';
  static const notes = 'ملاحظات';
  static const saving = 'جاري الحفظ...';
  static const saveAddressAndContinue = 'حفظ العنوان والمتابعة';
  static const confirmOrder = 'تأكيد الطلب';
  static const confirmingOrder = 'جاري تأكيد الطلب...';
  static const noSavedAddresses = 'لا توجد عناوين محفوظة';
  static const addressSaveError = 'حدث خطأ أثناء حفظ العنوان';
  static const addressLoadError = 'حدث خطأ أثناء تحميل العناوين';
  static const defaultAddressError = 'حدث خطأ أثناء تحديد العنوان الرئيسي';
  static const orderConfirmError = 'حدث خطأ أثناء تأكيد الطلب';
  static const invalidProduct = 'بيانات المنتج غير صالحة';
  static const invalidAddress = 'بيانات العنوان غير صالحة';
  static const deliveryAddress = 'عنوان التوصيل';
  static const chooseDeliveryAddress = 'اختيار عنوان التوصيل';
  static const useThisAddress = 'استخدام هذا العنوان';
  static const change = 'تغيير';
  static const defaultAddress = 'العنوان الأساسي';
  static const makeDefault = 'خليه اساسي';
  static const cart = 'السلة';
  static const address = 'العنوان';
  static const confirmation = 'التأكيد';
  static const productsTotal = 'إجمالي المنتجات';
  static const deliveryPrice = 'سعر التوصيل';
  static const orderTotal = 'إجمالي الطلب';
  static const currency = 'ج.م';
  static const trackOrder = 'تتبع طلبي';
  static const shopDataUnavailable = 'بيانات المحل غير متاحة';
  static const requiredFieldMessage = 'هذا الحقل مطلوب';
  static const phoneRequired = 'رقم الهاتف مطلوب';
  static const phoneDigitsOnly = 'رقم الهاتف يجب أن يحتوي على أرقام فقط';
  static const phoneLength = 'رقم الهاتف يجب أن يكون 11 رقم';
  static const phonePrefix =
      'رقم الهاتف يجب أن يبدأ بـ 010 أو 011 أو 012 أو 015';
  static const addToCart = 'اضف للسلة';
  static const productSearchHint = 'نفسك تجيب ايه؟';

  static String requiredField(String fieldName) => '$fieldName مطلوب';

  static String maxWords(String fieldName, int maxWords) =>
      '$fieldName يجب ألا يزيد عن $maxWords كلمات';

  static String feminineMaxWords(String fieldName, int maxWords) =>
      '$fieldName يجب ألا تزيد عن $maxWords كلمات';

  static String productAddedToCart(String productName, String quantityText) =>
      'تمت إضافة$quantityText $productName إلى';
}
