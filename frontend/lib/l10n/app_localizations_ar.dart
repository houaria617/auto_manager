// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'مدير السيارات';

  @override
  String get comingSoon => 'قريباً';

  @override
  String get logout => 'خروج';

  @override
  String get cancel => 'إلغاء';

  @override
  String get add => 'إضافة';

  @override
  String get save => 'حفظ';

  @override
  String get confirm => 'تأكيد';

  @override
  String get error => 'خطأ';

  @override
  String get required => 'مطلوب';

  @override
  String get loginTitle => 'تسجيل الدخول';

  @override
  String get username => 'اسم المستخدم';

  @override
  String get password => 'كلمة المرور';

  @override
  String get loginButton => 'دخول';

  @override
  String get navDashboard => 'الرئيسية';

  @override
  String get navRentals => 'تأجير';

  @override
  String get navCars => 'سيارات';

  @override
  String get navClients => 'عملاء';

  @override
  String get navAnalytics => 'تحليلات';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get agencyInfo => 'معلومات الوكالة';

  @override
  String get agencyInfoSubtitle => 'تحديث المعلومات.';

  @override
  String get appLanguage => 'اللغة';

  @override
  String get appLanguageSubtitle => 'تغيير اللغة.';

  @override
  String get subscription => 'الاشتراك';

  @override
  String get subscriptionPlan => 'الخطة الحالية: مجانية';

  @override
  String get rentalsTitle => 'التأجيرات';

  @override
  String get tabOngoing => 'جاري';

  @override
  String get tabCompleted => 'مكتمل';

  @override
  String get noRentalsOngoing => 'لا يوجد تأجير جاري';

  @override
  String get noRentalsCompleted => 'لا يوجد تأجير مكتمل';

  @override
  String get newRental => 'تأجير جديد';

  @override
  String get rentalDetails => 'التفاصيل';

  @override
  String get renewRental => 'تجديد';

  @override
  String get returnCar => 'إرجاع';

  @override
  String get managePayments => 'المدفوعات';

  @override
  String get viewPaymentHistory => 'السجل';

  @override
  String get rentalSummary => 'ملخص';

  @override
  String get rentalPeriod => 'المدة';

  @override
  String get daysLeft => 'أيام متبقية';

  @override
  String get daysOverdue => 'أيام تأخير';

  @override
  String get addRentalTitle => 'إضافة تأجير';

  @override
  String get selectClient => 'اختر عميل';

  @override
  String get selectCar => 'اختر سيارة';

  @override
  String get startDate => 'تاريخ البدء';

  @override
  String get endDate => 'تاريخ النهاية';

  @override
  String get totalPrice => 'الإجمالي';

  @override
  String get saveRental => 'حفظ التأجير';

  @override
  String get paymentsTitle => 'المدفوعات';

  @override
  String get remainingBalance => 'المبلغ المتبقي';

  @override
  String get totalPaid => 'المدفوع';

  @override
  String get balanceDue => 'المستحق';

  @override
  String get addPayment => 'إضافة دفعة';

  @override
  String get enterAmount => 'أدخل المبلغ';

  @override
  String get pay => 'دفع';

  @override
  String get paymentHistory => 'سجل المعاملات';

  @override
  String get analyticsTitle => 'التقارير';

  @override
  String get totalRevenue => 'الإيرادات';

  @override
  String get totalRentals => 'عدد التأجيرات';

  @override
  String get avgDuration => 'متوسط المدة';

  @override
  String get topCars => 'أفضل السيارات';

  @override
  String get clientStats => 'إحصائيات العملاء';

  @override
  String get exportPdf => 'تصدير PDF';

  @override
  String get client => 'عميل';

  @override
  String get car => 'سيارة';

  @override
  String get selectDate => 'اختر التاريخ';

  @override
  String get pleaseSelectDates => 'يرجى اختيار تاريخي البدء والنهاية';

  @override
  String get pleaseSelectClient => 'يرجى اختيار عميل';

  @override
  String get pleaseSelectCar => 'يرجى اختيار سيارة';

  @override
  String get pleaseEnterPrice => 'يرجى إدخال السعر';

  @override
  String get invalidNumber => 'رقم غير صحيح';

  @override
  String get addNewClient => 'إضافة عميل جديد';

  @override
  String get firstName => 'الاسم الأول';

  @override
  String get lastName => 'اسم العائلة';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get addNewCar => 'إضافة سيارة جديدة';

  @override
  String get carNameModel => 'اسم السيارة (الموديل)';

  @override
  String get plateNumber => 'رقم اللوحة';

  @override
  String get dailyRentPrice => 'سعر الإيجار اليومي';

  @override
  String get dateError => 'يجب أن يكون تاريخ النهاية بعد أو يساوي تاريخ البدء';

  @override
  String pricePerDay(String price) {
    return '$price/يوم';
  }

  @override
  String rentalId(String id) {
    return 'رقم التأجير: $id';
  }

  @override
  String get rentalNoLongerExists => 'هذا التأجير لم يعد موجوداً.';

  @override
  String get upgradeToPremium => 'الترقية إلى المميز';

  @override
  String get free => 'مجاني';

  @override
  String get zeroDA => '0 دج';

  @override
  String get accessBasicFeatures => 'الوصول إلى الميزات الأساسية';

  @override
  String get limitedRentals => 'إدخالات تأجير محدودة (10 كحد أقصى)';

  @override
  String get limitedCars => 'إدخالات سيارات محدودة (10 كحد أقصى)';

  @override
  String get premium => 'مميز';

  @override
  String get premiumPrice => '5999 دج / شهر';

  @override
  String get accessAllFeatures => 'الوصول إلى جميع الميزات';

  @override
  String get unlimitedRentals => 'إدخالات تأجير غير محدودة';

  @override
  String get unlimitedCars => 'إدخالات سيارات غير محدودة';

  @override
  String get rentalHistoryAnalytics => 'سجل التأجير والتحليلات';

  @override
  String get customReminders => 'تذكيرات مخصصة للعملاء';

  @override
  String get recommended => 'موصى به';

  @override
  String get returnCarComplete => 'إرجاع السيارة (إكمال)';

  @override
  String get rentalCompleted => 'تم إكمال التأجير';

  @override
  String get extendRentalDuration => 'تمديد مدة التأجير.';

  @override
  String get additionalDays => 'أيام إضافية';

  @override
  String get days => 'أيام';

  @override
  String get estimatedDailyRate => 'السعر اليومي المقدر:';

  @override
  String get extraCost => 'التكلفة الإضافية:';

  @override
  String get confirmRenew => 'تأكيد التجديد';

  @override
  String renewedSuccess(int days, String amount) {
    return 'تم التجديد لمدة $days أيام. تمت إضافة \$$amount إلى الإجمالي.';
  }

  @override
  String errorRenewing(String error) {
    return 'خطأ في تجديد التأجير: $error';
  }

  @override
  String get statusOngoing => 'جاري';

  @override
  String get statusCompleted => 'مكتمل';

  @override
  String get statusOverdue => 'متأخر';

  @override
  String rentalIdLabel(String id) {
    return 'رقم التأجير: $id';
  }

  @override
  String clientNumber(String id) {
    return 'عميل #$id';
  }

  @override
  String carNumber(String id) {
    return 'سيارة #$id';
  }

  @override
  String get viewClient => 'عرض العميل';

  @override
  String get viewCar => 'عرض السيارة';

  @override
  String get noPhoneInfo => 'لا توجد معلومات هاتف';

  @override
  String get unknownPlate => 'لوحة غير معروفة';

  @override
  String rentalIdColon(int id) {
    return 'رقم التأجير: $id';
  }

  @override
  String daysLabel(int days) {
    return '$days أيام';
  }

  @override
  String get start => 'البدء';

  @override
  String get end => 'النهاية';

  @override
  String get ongoingRentals => 'التأجيرات الجارية';

  @override
  String get availableCars => 'السيارات المتاحة';

  @override
  String get dueToday => 'المستحقة اليوم';

  @override
  String get recentActivities => 'الأنشطة الأخيرة';

  @override
  String carRentedBy(String plate, String client) {
    return 'تم تأجير السيارة $plate من قبل $client';
  }

  @override
  String get revenue => 'الإيرادات';

  @override
  String get thisWeek => 'هذا الأسبوع';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get allTime => 'كل الوقت';

  @override
  String get custom => 'مخصص';

  @override
  String get totalClients => 'إجمالي العملاء';

  @override
  String get newClients => 'عملاء جدد';

  @override
  String get repeatClients => 'عملاء متكررون';

  @override
  String get generatingPdf => 'جارٍ إنشاء تقرير PDF...';

  @override
  String errorGeneratingPdf(String error) {
    return 'خطأ في إنشاء PDF: $error';
  }

  @override
  String get pleaseWaitForData => 'يرجى الانتظار حتى يتم تحميل البيانات.';
}
