import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('ar')];

  /// Application title
  ///
  /// In ar, this message translates to:
  /// **''**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get login;

  /// No description provided for @username.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم'**
  String get username;

  /// No description provided for @password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// No description provided for @loginButton.
  ///
  /// In ar, this message translates to:
  /// **'دخول'**
  String get loginButton;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الخروج'**
  String get logout;

  /// No description provided for @loginError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في تسجيل الدخول'**
  String get loginError;

  /// No description provided for @invalidCredentials.
  ///
  /// In ar, this message translates to:
  /// **'اسم المستخدم أو كلمة المرور غير صحيحة'**
  String get invalidCredentials;

  /// No description provided for @showPassword.
  ///
  /// In ar, this message translates to:
  /// **'إظهار كلمة المرور'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء كلمة المرور'**
  String get hidePassword;

  /// No description provided for @restaurants.
  ///
  /// In ar, this message translates to:
  /// **'المطاعم'**
  String get restaurants;

  /// No description provided for @restaurantsList.
  ///
  /// In ar, this message translates to:
  /// **'قائمة المطاعم'**
  String get restaurantsList;

  /// No description provided for @addRestaurant.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مطعم'**
  String get addRestaurant;

  /// No description provided for @editRestaurant.
  ///
  /// In ar, this message translates to:
  /// **'تعديل مطعم'**
  String get editRestaurant;

  /// No description provided for @deleteRestaurant.
  ///
  /// In ar, this message translates to:
  /// **'حذف مطعم'**
  String get deleteRestaurant;

  /// No description provided for @restaurantName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المطعم'**
  String get restaurantName;

  /// No description provided for @restaurantDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المطعم'**
  String get restaurantDetails;

  /// No description provided for @restaurantPhoto.
  ///
  /// In ar, this message translates to:
  /// **'صورة المطعم'**
  String get restaurantPhoto;

  /// No description provided for @uploadPhoto.
  ///
  /// In ar, this message translates to:
  /// **'رفع صورة'**
  String get uploadPhoto;

  /// No description provided for @changePhoto.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الصورة'**
  String get changePhoto;

  /// No description provided for @removePhoto.
  ///
  /// In ar, this message translates to:
  /// **'إزالة الصورة'**
  String get removePhoto;

  /// No description provided for @balance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد'**
  String get balance;

  /// No description provided for @totalBalance.
  ///
  /// In ar, this message translates to:
  /// **'الرصيد الإجمالي'**
  String get totalBalance;

  /// No description provided for @positiveBalance.
  ///
  /// In ar, this message translates to:
  /// **'رصيد موجب'**
  String get positiveBalance;

  /// No description provided for @negativeBalance.
  ///
  /// In ar, this message translates to:
  /// **'رصيد سالب'**
  String get negativeBalance;

  /// No description provided for @products.
  ///
  /// In ar, this message translates to:
  /// **'المنتجات'**
  String get products;

  /// No description provided for @productsList.
  ///
  /// In ar, this message translates to:
  /// **'قائمة المنتجات'**
  String get productsList;

  /// No description provided for @addProduct.
  ///
  /// In ar, this message translates to:
  /// **'إضافة منتج'**
  String get addProduct;

  /// No description provided for @editProduct.
  ///
  /// In ar, this message translates to:
  /// **'تعديل منتج'**
  String get editProduct;

  /// No description provided for @deleteProduct.
  ///
  /// In ar, this message translates to:
  /// **'حذف منتج'**
  String get deleteProduct;

  /// No description provided for @productName.
  ///
  /// In ar, this message translates to:
  /// **'اسم المنتج'**
  String get productName;

  /// No description provided for @productPrice.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get productPrice;

  /// No description provided for @price.
  ///
  /// In ar, this message translates to:
  /// **'السعر'**
  String get price;

  /// No description provided for @pricePerJar.
  ///
  /// In ar, this message translates to:
  /// **'السعر للبرطمان'**
  String get pricePerJar;

  /// No description provided for @transactions.
  ///
  /// In ar, this message translates to:
  /// **'المعاملات'**
  String get transactions;

  /// No description provided for @transactionsList.
  ///
  /// In ar, this message translates to:
  /// **'قائمة المعاملات'**
  String get transactionsList;

  /// No description provided for @addTransaction.
  ///
  /// In ar, this message translates to:
  /// **'إضافة معاملة'**
  String get addTransaction;

  /// No description provided for @editTransaction.
  ///
  /// In ar, this message translates to:
  /// **'تعديل معاملة'**
  String get editTransaction;

  /// No description provided for @transactionDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المعاملة'**
  String get transactionDetails;

  /// No description provided for @deliveryDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ التسليم'**
  String get deliveryDate;

  /// No description provided for @returnDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الإرجاع'**
  String get returnDate;

  /// No description provided for @date.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get date;

  /// No description provided for @jarsSold.
  ///
  /// In ar, this message translates to:
  /// **'البرطمانات المباعة'**
  String get jarsSold;

  /// No description provided for @jarsDelivered.
  ///
  /// In ar, this message translates to:
  /// **'البرطمانات المسلمة'**
  String get jarsDelivered;

  /// No description provided for @jarsReturned.
  ///
  /// In ar, this message translates to:
  /// **'البرطمانات المرتجعة'**
  String get jarsReturned;

  /// No description provided for @jarsUsed.
  ///
  /// In ar, this message translates to:
  /// **'البرطمانات المستخدمة'**
  String get jarsUsed;

  /// No description provided for @selectRestaurant.
  ///
  /// In ar, this message translates to:
  /// **'اختر المطعم'**
  String get selectRestaurant;

  /// No description provided for @selectProduct.
  ///
  /// In ar, this message translates to:
  /// **'اختر المنتج'**
  String get selectProduct;

  /// No description provided for @selectDate.
  ///
  /// In ar, this message translates to:
  /// **'اختر التاريخ'**
  String get selectDate;

  /// No description provided for @addReturn.
  ///
  /// In ar, this message translates to:
  /// **'إضافة إرجاع'**
  String get addReturn;

  /// No description provided for @saveDelivery.
  ///
  /// In ar, this message translates to:
  /// **'حفظ التسليم'**
  String get saveDelivery;

  /// No description provided for @reports.
  ///
  /// In ar, this message translates to:
  /// **'التقارير'**
  String get reports;

  /// No description provided for @generateReport.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء تقرير'**
  String get generateReport;

  /// No description provided for @downloadReport.
  ///
  /// In ar, this message translates to:
  /// **'تحميل التقرير'**
  String get downloadReport;

  /// No description provided for @downloadPDF.
  ///
  /// In ar, this message translates to:
  /// **'تحميل PDF'**
  String get downloadPDF;

  /// No description provided for @reportGenerated.
  ///
  /// In ar, this message translates to:
  /// **'تم إنشاء التقرير'**
  String get reportGenerated;

  /// No description provided for @restaurantReport.
  ///
  /// In ar, this message translates to:
  /// **'تقرير المطعم'**
  String get restaurantReport;

  /// No description provided for @salesReport.
  ///
  /// In ar, this message translates to:
  /// **'تقرير المبيعات'**
  String get salesReport;

  /// No description provided for @monthlyReport.
  ///
  /// In ar, this message translates to:
  /// **'التقرير الشهري'**
  String get monthlyReport;

  /// No description provided for @analytics.
  ///
  /// In ar, this message translates to:
  /// **'التحليلات'**
  String get analytics;

  /// No description provided for @dashboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة التحكم'**
  String get dashboard;

  /// No description provided for @charts.
  ///
  /// In ar, this message translates to:
  /// **'الرسوم البيانية'**
  String get charts;

  /// No description provided for @statistics.
  ///
  /// In ar, this message translates to:
  /// **'الإحصائيات'**
  String get statistics;

  /// No description provided for @totalSales.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي المبيعات'**
  String get totalSales;

  /// No description provided for @totalRevenue.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي الإيرادات'**
  String get totalRevenue;

  /// No description provided for @topRestaurants.
  ///
  /// In ar, this message translates to:
  /// **'أفضل المطاعم'**
  String get topRestaurants;

  /// No description provided for @topProducts.
  ///
  /// In ar, this message translates to:
  /// **'أفضل المنتجات'**
  String get topProducts;

  /// No description provided for @staff.
  ///
  /// In ar, this message translates to:
  /// **'الموظفين'**
  String get staff;

  /// No description provided for @staffList.
  ///
  /// In ar, this message translates to:
  /// **'قائمة الموظفين'**
  String get staffList;

  /// No description provided for @addStaff.
  ///
  /// In ar, this message translates to:
  /// **'إضافة موظف'**
  String get addStaff;

  /// No description provided for @editStaff.
  ///
  /// In ar, this message translates to:
  /// **'تعديل موظف'**
  String get editStaff;

  /// No description provided for @deleteStaff.
  ///
  /// In ar, this message translates to:
  /// **'حذف موظف'**
  String get deleteStaff;

  /// No description provided for @staffMember.
  ///
  /// In ar, this message translates to:
  /// **'موظف'**
  String get staffMember;

  /// No description provided for @role.
  ///
  /// In ar, this message translates to:
  /// **'الدور'**
  String get role;

  /// No description provided for @admin.
  ///
  /// In ar, this message translates to:
  /// **'مدير'**
  String get admin;

  /// No description provided for @staffRole.
  ///
  /// In ar, this message translates to:
  /// **'موظف'**
  String get staffRole;

  /// No description provided for @viewPassword.
  ///
  /// In ar, this message translates to:
  /// **'عرض كلمة المرور'**
  String get viewPassword;

  /// No description provided for @changePassword.
  ///
  /// In ar, this message translates to:
  /// **'تغيير كلمة المرور'**
  String get changePassword;

  /// No description provided for @staffManagement.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الموظفين'**
  String get staffManagement;

  /// No description provided for @permissions.
  ///
  /// In ar, this message translates to:
  /// **'الصلاحيات'**
  String get permissions;

  /// No description provided for @adminOnly.
  ///
  /// In ar, this message translates to:
  /// **'للمدير فقط'**
  String get adminOnly;

  /// No description provided for @canEditPrices.
  ///
  /// In ar, this message translates to:
  /// **'يمكن تعديل الأسعار'**
  String get canEditPrices;

  /// No description provided for @canManageRestaurants.
  ///
  /// In ar, this message translates to:
  /// **'يمكن إدارة المطاعم'**
  String get canManageRestaurants;

  /// No description provided for @canViewAnalytics.
  ///
  /// In ar, this message translates to:
  /// **'يمكن عرض التحليلات'**
  String get canViewAnalytics;

  /// No description provided for @canManageStaff.
  ///
  /// In ar, this message translates to:
  /// **'يمكن إدارة الموظفين'**
  String get canManageStaff;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In ar, this message translates to:
  /// **'تعديل'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In ar, this message translates to:
  /// **'إضافة'**
  String get add;

  /// No description provided for @confirm.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد'**
  String get confirm;

  /// No description provided for @yes.
  ///
  /// In ar, this message translates to:
  /// **'نعم'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In ar, this message translates to:
  /// **'لا'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In ar, this message translates to:
  /// **'موافق'**
  String get ok;

  /// No description provided for @close.
  ///
  /// In ar, this message translates to:
  /// **'إغلاق'**
  String get close;

  /// No description provided for @back.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get back;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In ar, this message translates to:
  /// **'السابق'**
  String get previous;

  /// No description provided for @search.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In ar, this message translates to:
  /// **'تصفية'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In ar, this message translates to:
  /// **'ترتيب'**
  String get sort;

  /// No description provided for @refresh.
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get refresh;

  /// No description provided for @required.
  ///
  /// In ar, this message translates to:
  /// **'مطلوب'**
  String get required;

  /// No description provided for @requiredField.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get requiredField;

  /// No description provided for @invalidInput.
  ///
  /// In ar, this message translates to:
  /// **'إدخال غير صحيح'**
  String get invalidInput;

  /// No description provided for @mustBePositive.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن يكون رقم موجب'**
  String get mustBePositive;

  /// No description provided for @mustBeInteger.
  ///
  /// In ar, this message translates to:
  /// **'يجب أن يكون عدد صحيح'**
  String get mustBeInteger;

  /// No description provided for @invalidEmail.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني غير صحيح'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور قصيرة جداً'**
  String get passwordTooShort;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In ar, this message translates to:
  /// **'كلمات المرور غير متطابقة'**
  String get passwordsDoNotMatch;

  /// No description provided for @error.
  ///
  /// In ar, this message translates to:
  /// **'خطأ'**
  String get error;

  /// No description provided for @success.
  ///
  /// In ar, this message translates to:
  /// **'نجح'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In ar, this message translates to:
  /// **'تحذير'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In ar, this message translates to:
  /// **'معلومة'**
  String get info;

  /// No description provided for @loading.
  ///
  /// In ar, this message translates to:
  /// **'جاري التحميل...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات'**
  String get noData;

  /// No description provided for @noResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get noResults;

  /// No description provided for @networkError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الاتصال بالشبكة'**
  String get networkError;

  /// No description provided for @serverError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ في الخادم'**
  String get serverError;

  /// No description provided for @unknownError.
  ///
  /// In ar, this message translates to:
  /// **'خطأ غير معروف'**
  String get unknownError;

  /// No description provided for @deleteConfirmation.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الحذف'**
  String get deleteConfirmation;

  /// No description provided for @deleteProductMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذا المنتج؟'**
  String get deleteProductMessage;

  /// No description provided for @deleteRestaurantMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذا المطعم؟'**
  String get deleteRestaurantMessage;

  /// No description provided for @deleteStaffMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذا الموظف؟'**
  String get deleteStaffMessage;

  /// No description provided for @deleteTransactionMessage.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد من حذف هذه المعاملة؟'**
  String get deleteTransactionMessage;

  /// No description provided for @cannotUndo.
  ///
  /// In ar, this message translates to:
  /// **'لا يمكن التراجع عن هذا الإجراء'**
  String get cannotUndo;

  /// No description provided for @currency.
  ///
  /// In ar, this message translates to:
  /// **'د.أ'**
  String get currency;

  /// No description provided for @currencySymbol.
  ///
  /// In ar, this message translates to:
  /// **'د.أ'**
  String get currencySymbol;

  /// No description provided for @jod.
  ///
  /// In ar, this message translates to:
  /// **'دينار أردني'**
  String get jod;

  /// No description provided for @jars.
  ///
  /// In ar, this message translates to:
  /// **'برطمان'**
  String get jars;

  /// No description provided for @jar.
  ///
  /// In ar, this message translates to:
  /// **'برطمان'**
  String get jar;

  /// No description provided for @piece.
  ///
  /// In ar, this message translates to:
  /// **'قطعة'**
  String get piece;

  /// No description provided for @pieces.
  ///
  /// In ar, this message translates to:
  /// **'قطع'**
  String get pieces;

  /// No description provided for @home.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get home;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @profile.
  ///
  /// In ar, this message translates to:
  /// **'الملف الشخصي'**
  String get profile;

  /// No description provided for @about.
  ///
  /// In ar, this message translates to:
  /// **'حول'**
  String get about;

  /// No description provided for @help.
  ///
  /// In ar, this message translates to:
  /// **'مساعدة'**
  String get help;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'إعادة المحاولة'**
  String get retry;

  /// No description provided for @welcome.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً'**
  String get welcome;

  /// No description provided for @welcomeBack.
  ///
  /// In ar, this message translates to:
  /// **'مرحباً بعودتك'**
  String get welcomeBack;

  /// No description provided for @goodMorning.
  ///
  /// In ar, this message translates to:
  /// **'صباح الخير'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير'**
  String get goodEvening;

  /// No description provided for @today.
  ///
  /// In ar, this message translates to:
  /// **'اليوم'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In ar, this message translates to:
  /// **'أمس'**
  String get yesterday;

  /// No description provided for @thisWeek.
  ///
  /// In ar, this message translates to:
  /// **'هذا الأسبوع'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In ar, this message translates to:
  /// **'هذا الشهر'**
  String get thisMonth;

  /// No description provided for @thisYear.
  ///
  /// In ar, this message translates to:
  /// **'هذا العام'**
  String get thisYear;

  /// No description provided for @all.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get all;

  /// No description provided for @none.
  ///
  /// In ar, this message translates to:
  /// **'لا شيء'**
  String get none;

  /// No description provided for @ascending.
  ///
  /// In ar, this message translates to:
  /// **'تصاعدي'**
  String get ascending;

  /// No description provided for @descending.
  ///
  /// In ar, this message translates to:
  /// **'تنازلي'**
  String get descending;

  /// No description provided for @alphabetical.
  ///
  /// In ar, this message translates to:
  /// **'أبجدي'**
  String get alphabetical;

  /// No description provided for @byDate.
  ///
  /// In ar, this message translates to:
  /// **'حسب التاريخ'**
  String get byDate;

  /// No description provided for @byAmount.
  ///
  /// In ar, this message translates to:
  /// **'حسب المبلغ'**
  String get byAmount;

  /// No description provided for @byName.
  ///
  /// In ar, this message translates to:
  /// **'حسب الاسم'**
  String get byName;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
