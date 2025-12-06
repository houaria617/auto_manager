import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Auto Manager'**
  String get appName;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get loginTitle;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginButton;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navRentals.
  ///
  /// In en, this message translates to:
  /// **'Rentals'**
  String get navRentals;

  /// No description provided for @navCars.
  ///
  /// In en, this message translates to:
  /// **'Cars'**
  String get navCars;

  /// No description provided for @navClients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get navClients;

  /// No description provided for @navAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get navAnalytics;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @agencyInfo.
  ///
  /// In en, this message translates to:
  /// **'Agency Information'**
  String get agencyInfo;

  /// No description provided for @agencyInfoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update agency details.'**
  String get agencyInfoSubtitle;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @appLanguageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Select preferred language.'**
  String get appLanguageSubtitle;

  /// No description provided for @subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get subscription;

  /// No description provided for @subscriptionPlan.
  ///
  /// In en, this message translates to:
  /// **'Current Plan: Free'**
  String get subscriptionPlan;

  /// No description provided for @rentalsTitle.
  ///
  /// In en, this message translates to:
  /// **'Rentals'**
  String get rentalsTitle;

  /// No description provided for @tabOngoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get tabOngoing;

  /// No description provided for @tabCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get tabCompleted;

  /// No description provided for @noRentalsOngoing.
  ///
  /// In en, this message translates to:
  /// **'No ongoing rentals'**
  String get noRentalsOngoing;

  /// No description provided for @noRentalsCompleted.
  ///
  /// In en, this message translates to:
  /// **'No completed rentals'**
  String get noRentalsCompleted;

  /// No description provided for @newRental.
  ///
  /// In en, this message translates to:
  /// **'New Rental'**
  String get newRental;

  /// No description provided for @rentalDetails.
  ///
  /// In en, this message translates to:
  /// **'Rental Details'**
  String get rentalDetails;

  /// No description provided for @renewRental.
  ///
  /// In en, this message translates to:
  /// **'Renew Rental'**
  String get renewRental;

  /// No description provided for @returnCar.
  ///
  /// In en, this message translates to:
  /// **'Return Car'**
  String get returnCar;

  /// No description provided for @managePayments.
  ///
  /// In en, this message translates to:
  /// **'Manage Payments'**
  String get managePayments;

  /// No description provided for @viewPaymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Payment History'**
  String get viewPaymentHistory;

  /// No description provided for @rentalSummary.
  ///
  /// In en, this message translates to:
  /// **'Rental Summary'**
  String get rentalSummary;

  /// No description provided for @rentalPeriod.
  ///
  /// In en, this message translates to:
  /// **'Rental Period'**
  String get rentalPeriod;

  /// No description provided for @daysLeft.
  ///
  /// In en, this message translates to:
  /// **'days left'**
  String get daysLeft;

  /// No description provided for @daysOverdue.
  ///
  /// In en, this message translates to:
  /// **'days overdue'**
  String get daysOverdue;

  /// No description provided for @addRentalTitle.
  ///
  /// In en, this message translates to:
  /// **'New Rental'**
  String get addRentalTitle;

  /// No description provided for @selectClient.
  ///
  /// In en, this message translates to:
  /// **'Select Client'**
  String get selectClient;

  /// No description provided for @selectCar.
  ///
  /// In en, this message translates to:
  /// **'Select Car'**
  String get selectCar;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @totalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total Price'**
  String get totalPrice;

  /// No description provided for @saveRental.
  ///
  /// In en, this message translates to:
  /// **'Save Rental'**
  String get saveRental;

  /// No description provided for @paymentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get paymentsTitle;

  /// No description provided for @remainingBalance.
  ///
  /// In en, this message translates to:
  /// **'Remaining Balance'**
  String get remainingBalance;

  /// No description provided for @totalPaid.
  ///
  /// In en, this message translates to:
  /// **'Total Paid'**
  String get totalPaid;

  /// No description provided for @balanceDue.
  ///
  /// In en, this message translates to:
  /// **'Balance Due'**
  String get balanceDue;

  /// No description provided for @addPayment.
  ///
  /// In en, this message translates to:
  /// **'Add Payment'**
  String get addPayment;

  /// No description provided for @enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter Amount'**
  String get enterAmount;

  /// No description provided for @pay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get pay;

  /// No description provided for @paymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get paymentHistory;

  /// No description provided for @analyticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports & Analytics'**
  String get analyticsTitle;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// No description provided for @totalRentals.
  ///
  /// In en, this message translates to:
  /// **'Total Rentals'**
  String get totalRentals;

  /// No description provided for @avgDuration.
  ///
  /// In en, this message translates to:
  /// **'Avg. Duration'**
  String get avgDuration;

  /// No description provided for @topCars.
  ///
  /// In en, this message translates to:
  /// **'Top Rented Cars'**
  String get topCars;

  /// No description provided for @clientStats.
  ///
  /// In en, this message translates to:
  /// **'Client Statistics'**
  String get clientStats;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @client.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get client;

  /// No description provided for @car.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get car;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @pleaseSelectDates.
  ///
  /// In en, this message translates to:
  /// **'Please select start and end dates'**
  String get pleaseSelectDates;

  /// No description provided for @pleaseSelectClient.
  ///
  /// In en, this message translates to:
  /// **'Please select a client'**
  String get pleaseSelectClient;

  /// No description provided for @pleaseSelectCar.
  ///
  /// In en, this message translates to:
  /// **'Please select a car'**
  String get pleaseSelectCar;

  /// No description provided for @pleaseEnterPrice.
  ///
  /// In en, this message translates to:
  /// **'Please enter price'**
  String get pleaseEnterPrice;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get invalidNumber;

  /// No description provided for @addNewClient.
  ///
  /// In en, this message translates to:
  /// **'Add New Client'**
  String get addNewClient;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @addNewCar.
  ///
  /// In en, this message translates to:
  /// **'Add New Car'**
  String get addNewCar;

  /// No description provided for @carNameModel.
  ///
  /// In en, this message translates to:
  /// **'Car Name (Model)'**
  String get carNameModel;

  /// No description provided for @plateNumber.
  ///
  /// In en, this message translates to:
  /// **'Plate Number'**
  String get plateNumber;

  /// No description provided for @dailyRentPrice.
  ///
  /// In en, this message translates to:
  /// **'Daily Rent Price'**
  String get dailyRentPrice;

  /// No description provided for @dateError.
  ///
  /// In en, this message translates to:
  /// **'End date must be after or equal to start date'**
  String get dateError;

  /// No description provided for @pricePerDay.
  ///
  /// In en, this message translates to:
  /// **'Price {value}'**
  String pricePerDay(String price, Object value);

  /// No description provided for @rentalId.
  ///
  /// In en, this message translates to:
  /// **'Rental ID: {id}'**
  String rentalId(String id);

  /// No description provided for @rentalNoLongerExists.
  ///
  /// In en, this message translates to:
  /// **'This rental no longer exists.'**
  String get rentalNoLongerExists;

  /// No description provided for @upgradeToPremium.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Premium'**
  String get upgradeToPremium;

  /// No description provided for @free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get free;

  /// No description provided for @zeroDA.
  ///
  /// In en, this message translates to:
  /// **'0DA'**
  String get zeroDA;

  /// No description provided for @accessBasicFeatures.
  ///
  /// In en, this message translates to:
  /// **'Access basic features'**
  String get accessBasicFeatures;

  /// No description provided for @limitedRentals.
  ///
  /// In en, this message translates to:
  /// **'Limited rental entries (10 max)'**
  String get limitedRentals;

  /// No description provided for @limitedCars.
  ///
  /// In en, this message translates to:
  /// **'Limited car entries (10 max)'**
  String get limitedCars;

  /// No description provided for @premium.
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get premium;

  /// No description provided for @premiumPrice.
  ///
  /// In en, this message translates to:
  /// **'5999DA / month'**
  String get premiumPrice;

  /// No description provided for @accessAllFeatures.
  ///
  /// In en, this message translates to:
  /// **'Access all features'**
  String get accessAllFeatures;

  /// No description provided for @unlimitedRentals.
  ///
  /// In en, this message translates to:
  /// **'Unlimited rental entries'**
  String get unlimitedRentals;

  /// No description provided for @unlimitedCars.
  ///
  /// In en, this message translates to:
  /// **'Unlimited car entries'**
  String get unlimitedCars;

  /// No description provided for @rentalHistoryAnalytics.
  ///
  /// In en, this message translates to:
  /// **'Rental history & analytics'**
  String get rentalHistoryAnalytics;

  /// No description provided for @customReminders.
  ///
  /// In en, this message translates to:
  /// **'Custom reminders for customers'**
  String get customReminders;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @returnCarComplete.
  ///
  /// In en, this message translates to:
  /// **'Return Car (Complete)'**
  String get returnCarComplete;

  /// No description provided for @rentalCompleted.
  ///
  /// In en, this message translates to:
  /// **'Rental Completed'**
  String get rentalCompleted;

  /// No description provided for @extendRentalDuration.
  ///
  /// In en, this message translates to:
  /// **'Extend the rental duration.'**
  String get extendRentalDuration;

  /// No description provided for @additionalDays.
  ///
  /// In en, this message translates to:
  /// **'Additional Days'**
  String get additionalDays;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'Days'**
  String get days;

  /// No description provided for @estimatedDailyRate.
  ///
  /// In en, this message translates to:
  /// **'Estimated Daily Rate:'**
  String get estimatedDailyRate;

  /// No description provided for @extraCost.
  ///
  /// In en, this message translates to:
  /// **'Extra Cost:'**
  String get extraCost;

  /// No description provided for @confirmRenew.
  ///
  /// In en, this message translates to:
  /// **'Confirm Renew'**
  String get confirmRenew;

  /// No description provided for @renewedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Renewed for {days} days. Added \${amount} to total.'**
  String renewedSuccess(int days, String amount);

  /// No description provided for @errorRenewing.
  ///
  /// In en, this message translates to:
  /// **'Error renewing rental: {error}'**
  String errorRenewing(String error);

  /// No description provided for @statusOngoing.
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get statusOngoing;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get statusCompleted;

  /// No description provided for @statusOverdue.
  ///
  /// In en, this message translates to:
  /// **'OVERDUE'**
  String get statusOverdue;

  /// No description provided for @rentalIdLabel.
  ///
  /// In en, this message translates to:
  /// **'Rental ID: {id}'**
  String rentalIdLabel(String id);

  /// No description provided for @clientNumber.
  ///
  /// In en, this message translates to:
  /// **'Client #{id}'**
  String clientNumber(String id);

  /// No description provided for @carNumber.
  ///
  /// In en, this message translates to:
  /// **'Car #{id}'**
  String carNumber(String id);

  /// No description provided for @viewClient.
  ///
  /// In en, this message translates to:
  /// **'View Client'**
  String get viewClient;

  /// No description provided for @viewCar.
  ///
  /// In en, this message translates to:
  /// **'View Car'**
  String get viewCar;

  /// No description provided for @noPhoneInfo.
  ///
  /// In en, this message translates to:
  /// **'No phone info'**
  String get noPhoneInfo;

  /// No description provided for @unknownPlate.
  ///
  /// In en, this message translates to:
  /// **'Unknown Plate'**
  String get unknownPlate;

  /// No description provided for @rentalIdColon.
  ///
  /// In en, this message translates to:
  /// **'Rental ID: {id}'**
  String rentalIdColon(int id);

  /// No description provided for @daysLabel.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String daysLabel(int days);

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @end.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get end;

  /// No description provided for @ongoingRentals.
  ///
  /// In en, this message translates to:
  /// **'Ongoing Rentals'**
  String get ongoingRentals;

  /// No description provided for @availableCars.
  ///
  /// In en, this message translates to:
  /// **'Available Cars'**
  String get availableCars;

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'Due Today'**
  String get dueToday;

  /// No description provided for @recentActivities.
  ///
  /// In en, this message translates to:
  /// **'Recent Activities'**
  String get recentActivities;

  /// No description provided for @carRentedBy.
  ///
  /// In en, this message translates to:
  /// **'Car {plate} rented by {client}'**
  String carRentedBy(String plate, String client);

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @totalClients.
  ///
  /// In en, this message translates to:
  /// **'Total Clients'**
  String get totalClients;

  /// No description provided for @newClients.
  ///
  /// In en, this message translates to:
  /// **'New Clients'**
  String get newClients;

  /// No description provided for @repeatClients.
  ///
  /// In en, this message translates to:
  /// **'Repeat Clients'**
  String get repeatClients;

  /// No description provided for @generatingPdf.
  ///
  /// In en, this message translates to:
  /// **'Generating PDF Report...'**
  String get generatingPdf;

  /// No description provided for @errorGeneratingPdf.
  ///
  /// In en, this message translates to:
  /// **'Error generating PDF: {error}'**
  String errorGeneratingPdf(String error);

  /// No description provided for @pleaseWaitForData.
  ///
  /// In en, this message translates to:
  /// **'Please wait for data to load.'**
  String get pleaseWaitForData;

  /// No description provided for @clientsTitle.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get clientsTitle;

  /// No description provided for @noClientFound.
  ///
  /// In en, this message translates to:
  /// **'No Client Found'**
  String get noClientFound;

  /// No description provided for @searchClientHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or phone number'**
  String get searchClientHint;

  /// No description provided for @clientProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Client Profile'**
  String get clientProfileTitle;

  /// No description provided for @noRecentActivities.
  ///
  /// In en, this message translates to:
  /// **'No recent activities'**
  String get noRecentActivities;

  /// No description provided for @ninLabel.
  ///
  /// In en, this message translates to:
  /// **'NIN'**
  String get ninLabel;

  /// No description provided for @statusActive.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get statusActive;

  /// No description provided for @statusIdle.
  ///
  /// In en, this message translates to:
  /// **'IDLE'**
  String get statusIdle;

  /// No description provided for @totalRents.
  ///
  /// In en, this message translates to:
  /// **'TOTAL RENTS'**
  String get totalRents;

  /// No description provided for @rentHistory.
  ///
  /// In en, this message translates to:
  /// **'Rent History'**
  String get rentHistory;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'from'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'to'**
  String get to;

  /// No description provided for @totalIs.
  ///
  /// In en, this message translates to:
  /// **'Total is'**
  String get totalIs;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @noPhone.
  ///
  /// In en, this message translates to:
  /// **'No phone'**
  String get noPhone;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @atTime.
  ///
  /// In en, this message translates to:
  /// **'at'**
  String get atTime;

  /// No description provided for @myVehicles.
  ///
  /// In en, this message translates to:
  /// **'My Vehicles'**
  String get myVehicles;

  /// No description provided for @searchCarPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Search for a car or plate...'**
  String get searchCarPlaceholder;

  /// No description provided for @failedToLoadData.
  ///
  /// In en, this message translates to:
  /// **'Failed to load data'**
  String get failedToLoadData;

  /// No description provided for @noVehiclesMatchFilter.
  ///
  /// In en, this message translates to:
  /// **'No vehicles match the filter'**
  String get noVehiclesMatchFilter;

  /// No description provided for @addFirstVehicle.
  ///
  /// In en, this message translates to:
  /// **'Add Your First Vehicle'**
  String get addFirstVehicle;

  /// No description provided for @tapPlusToBegin.
  ///
  /// In en, this message translates to:
  /// **'Tap the \"+\" button to begin.'**
  String get tapPlusToBegin;

  /// No description provided for @vehicleDetails.
  ///
  /// In en, this message translates to:
  /// **'Vehicle Details'**
  String get vehicleDetails;

  /// No description provided for @unknownName.
  ///
  /// In en, this message translates to:
  /// **'Unknown Name'**
  String get unknownName;

  /// No description provided for @returnDate.
  ///
  /// In en, this message translates to:
  /// **'Return Date'**
  String get returnDate;

  /// No description provided for @availableOn.
  ///
  /// In en, this message translates to:
  /// **'Available On'**
  String get availableOn;

  /// No description provided for @nextMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Next Maintenance'**
  String get nextMaintenance;

  /// No description provided for @deleteVehicleTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete vehicle'**
  String get deleteVehicleTitle;

  /// No description provided for @deleteVehicleConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{name}\"? This action cannot be undone.'**
  String deleteVehicleConfirm(String name);

  /// No description provided for @editVehicle.
  ///
  /// In en, this message translates to:
  /// **'Edit Vehicle'**
  String get editVehicle;

  /// No description provided for @carName.
  ///
  /// In en, this message translates to:
  /// **'Car Name'**
  String get carName;

  /// No description provided for @nextMaintenanceOptional.
  ///
  /// In en, this message translates to:
  /// **'Next Maintenance Date (optional)'**
  String get nextMaintenanceOptional;

  /// No description provided for @rentPricePerDay.
  ///
  /// In en, this message translates to:
  /// **'Rent Price (per Day)'**
  String get rentPricePerDay;

  /// No description provided for @availabilityDate.
  ///
  /// In en, this message translates to:
  /// **'Availability Date'**
  String get availabilityDate;

  /// No description provided for @deletedVehicle.
  ///
  /// In en, this message translates to:
  /// **'Deleted \"{name}\"'**
  String deletedVehicle(String name);

  /// No description provided for @statusAvailable.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get statusAvailable;

  /// No description provided for @statusRented.
  ///
  /// In en, this message translates to:
  /// **'Rented'**
  String get statusRented;

  /// No description provided for @statusMaintenance.
  ///
  /// In en, this message translates to:
  /// **'Maintenance'**
  String get statusMaintenance;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @labelClient.
  ///
  /// In en, this message translates to:
  /// **'Client'**
  String get labelClient;

  /// No description provided for @labelCar.
  ///
  /// In en, this message translates to:
  /// **'Car'**
  String get labelCar;

  /// No description provided for @labelStartDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get labelStartDate;

  /// No description provided for @labelEndDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get labelEndDate;

  /// No description provided for @labelTotalPrice.
  ///
  /// In en, this message translates to:
  /// **'Total Price'**
  String get labelTotalPrice;
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
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
