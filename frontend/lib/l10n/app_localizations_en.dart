// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Auto Manager';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get logout => 'Logout';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get save => 'Save';

  @override
  String get confirm => 'Confirm';

  @override
  String get error => 'Error';

  @override
  String get required => 'Required';

  @override
  String get loginTitle => 'Login';

  @override
  String get username => 'Username';

  @override
  String get password => 'Password';

  @override
  String get loginButton => 'Sign In';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navRentals => 'Rentals';

  @override
  String get navCars => 'Cars';

  @override
  String get navClients => 'Clients';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get agencyInfo => 'Agency Information';

  @override
  String get agencyInfoSubtitle => 'Update agency details.';

  @override
  String get appLanguage => 'App Language';

  @override
  String get appLanguageSubtitle => 'Select preferred language.';

  @override
  String get subscription => 'Subscription';

  @override
  String get subscriptionPlan => 'Current Plan: Free';

  @override
  String get rentalsTitle => 'Rentals';

  @override
  String get tabOngoing => 'Ongoing';

  @override
  String get tabCompleted => 'Completed';

  @override
  String get noRentalsOngoing => 'No ongoing rentals';

  @override
  String get noRentalsCompleted => 'No completed rentals';

  @override
  String get newRental => 'New Rental';

  @override
  String get rentalDetails => 'Rental Details';

  @override
  String get renewRental => 'Renew Rental';

  @override
  String get returnCar => 'Return Car';

  @override
  String get managePayments => 'Manage Payments';

  @override
  String get viewPaymentHistory => 'Payment History';

  @override
  String get rentalSummary => 'Rental Summary';

  @override
  String get rentalPeriod => 'Rental Period';

  @override
  String get daysLeft => 'days left';

  @override
  String get daysOverdue => 'days overdue';

  @override
  String get addRentalTitle => 'New Rental';

  @override
  String get selectClient => 'Select Client';

  @override
  String get selectCar => 'Select Car';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get totalPrice => 'Total Price';

  @override
  String get saveRental => 'Save Rental';

  @override
  String get paymentsTitle => 'Payments';

  @override
  String get remainingBalance => 'Remaining Balance';

  @override
  String get totalPaid => 'Total Paid';

  @override
  String get balanceDue => 'Balance Due';

  @override
  String get addPayment => 'Add Payment';

  @override
  String get enterAmount => 'Enter Amount';

  @override
  String get pay => 'Pay';

  @override
  String get paymentHistory => 'Transaction History';

  @override
  String get analyticsTitle => 'Reports & Analytics';

  @override
  String get totalRevenue => 'Total Revenue';

  @override
  String get totalRentals => 'Total Rentals';

  @override
  String get avgDuration => 'Avg. Duration';

  @override
  String get topCars => 'Top Rented Cars';

  @override
  String get clientStats => 'Client Statistics';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get client => 'Client';

  @override
  String get car => 'Car';

  @override
  String get selectDate => 'Select Date';

  @override
  String get pleaseSelectDates => 'Please select start and end dates';

  @override
  String get pleaseSelectClient => 'Please select a client';

  @override
  String get pleaseSelectCar => 'Please select a car';

  @override
  String get pleaseEnterPrice => 'Please enter price';

  @override
  String get invalidNumber => 'Invalid number';

  @override
  String get addNewClient => 'Add New Client';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get addNewCar => 'Add New Car';

  @override
  String get carNameModel => 'Car Name (Model)';

  @override
  String get plateNumber => 'Plate Number';

  @override
  String get dailyRentPrice => 'Daily Rent Price';

  @override
  String get dateError => 'End date must be after or equal to start date';

  @override
  String pricePerDay(String price, Object value) {
    return 'Price $value';
  }

  @override
  String rentalId(String id) {
    return 'Rental ID: $id';
  }

  @override
  String get rentalNoLongerExists => 'This rental no longer exists.';

  @override
  String get upgradeToPremium => 'Upgrade to Premium';

  @override
  String get free => 'Free';

  @override
  String get zeroDA => '0DA';

  @override
  String get accessBasicFeatures => 'Access basic features';

  @override
  String get limitedRentals => 'Limited rental entries (10 max)';

  @override
  String get limitedCars => 'Limited car entries (10 max)';

  @override
  String get premium => 'Premium';

  @override
  String get premiumPrice => '5999DA / month';

  @override
  String get accessAllFeatures => 'Access all features';

  @override
  String get unlimitedRentals => 'Unlimited rental entries';

  @override
  String get unlimitedCars => 'Unlimited car entries';

  @override
  String get rentalHistoryAnalytics => 'Rental history & analytics';

  @override
  String get customReminders => 'Custom reminders for customers';

  @override
  String get recommended => 'Recommended';

  @override
  String get returnCarComplete => 'Return Car (Complete)';

  @override
  String get rentalCompleted => 'Rental Completed';

  @override
  String get extendRentalDuration => 'Extend the rental duration.';

  @override
  String get additionalDays => 'Additional Days';

  @override
  String get days => 'Days';

  @override
  String get estimatedDailyRate => 'Estimated Daily Rate:';

  @override
  String get extraCost => 'Extra Cost:';

  @override
  String get confirmRenew => 'Confirm Renew';

  @override
  String renewedSuccess(int days, String amount) {
    return 'Renewed for $days days. Added \$$amount to total.';
  }

  @override
  String errorRenewing(String error) {
    return 'Error renewing rental: $error';
  }

  @override
  String get statusOngoing => 'Ongoing';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusOverdue => 'OVERDUE';

  @override
  String rentalIdLabel(String id) {
    return 'Rental ID: $id';
  }

  @override
  String clientNumber(String id) {
    return 'Client #$id';
  }

  @override
  String carNumber(String id) {
    return 'Car #$id';
  }

  @override
  String get viewClient => 'View Client';

  @override
  String get viewCar => 'View Car';

  @override
  String get noPhoneInfo => 'No phone info';

  @override
  String get unknownPlate => 'Unknown Plate';

  @override
  String rentalIdColon(int id) {
    return 'Rental ID: $id';
  }

  @override
  String daysLabel(int days) {
    return '$days days';
  }

  @override
  String get start => 'Start';

  @override
  String get end => 'End';

  @override
  String get ongoingRentals => 'Ongoing Rentals';

  @override
  String get availableCars => 'Available Cars';

  @override
  String get dueToday => 'Due Today';

  @override
  String get recentActivities => 'Recent Activities';

  @override
  String carRentedBy(String plate, String client) {
    return 'Car $plate rented by $client';
  }

  @override
  String get revenue => 'Revenue';

  @override
  String get thisWeek => 'This Week';

  @override
  String get thisMonth => 'This Month';

  @override
  String get allTime => 'All Time';

  @override
  String get custom => 'Custom';

  @override
  String get totalClients => 'Total Clients';

  @override
  String get newClients => 'New Clients';

  @override
  String get repeatClients => 'Repeat Clients';

  @override
  String get generatingPdf => 'Generating PDF Report...';

  @override
  String errorGeneratingPdf(String error) {
    return 'Error generating PDF: $error';
  }

  @override
  String get pleaseWaitForData => 'Please wait for data to load.';

  @override
  String get clientsTitle => 'Clients';

  @override
  String get noClientFound => 'No Client Found';

  @override
  String get searchClientHint => 'Search by name or phone number';

  @override
  String get clientProfileTitle => 'Client Profile';

  @override
  String get noRecentActivities => 'No recent activities';

  @override
  String get ninLabel => 'NIN';

  @override
  String get statusActive => 'ACTIVE';

  @override
  String get statusIdle => 'IDLE';

  @override
  String get totalRents => 'TOTAL RENTS';

  @override
  String get rentHistory => 'Rent History';

  @override
  String get from => 'from';

  @override
  String get to => 'to';

  @override
  String get totalIs => 'Total is';

  @override
  String get unknown => 'Unknown';

  @override
  String get noPhone => 'No phone';

  @override
  String get delete => 'Delete';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get atTime => 'at';

  @override
  String get myVehicles => 'My Vehicles';

  @override
  String get searchCarPlaceholder => 'Search for a car or plate...';

  @override
  String get failedToLoadData => 'Failed to load data';

  @override
  String get noVehiclesMatchFilter => 'No vehicles match the filter';

  @override
  String get addFirstVehicle => 'Add Your First Vehicle';

  @override
  String get tapPlusToBegin => 'Tap the \"+\" button to begin.';

  @override
  String get vehicleDetails => 'Vehicle Details';

  @override
  String get unknownName => 'Unknown Name';

  @override
  String get returnDate => 'Return Date';

  @override
  String get availableOn => 'Available On';

  @override
  String get nextMaintenance => 'Next Maintenance';

  @override
  String get deleteVehicleTitle => 'Delete vehicle';

  @override
  String deleteVehicleConfirm(String name) {
    return 'Are you sure you want to delete \"$name\"? This action cannot be undone.';
  }

  @override
  String get editVehicle => 'Edit Vehicle';

  @override
  String get carName => 'Car Name';

  @override
  String get nextMaintenanceOptional => 'Next Maintenance Date (optional)';

  @override
  String get rentPricePerDay => 'Rent Price (per Day)';

  @override
  String get availabilityDate => 'Availability Date';

  @override
  String deletedVehicle(String name) {
    return 'Deleted \"$name\"';
  }

  @override
  String get statusAvailable => 'Available';

  @override
  String get statusRented => 'Rented';

  @override
  String get statusMaintenance => 'Maintenance';

  @override
  String get filterAll => 'All';

  @override
  String get labelClient => 'Client';

  @override
  String get labelCar => 'Car';

  @override
  String get labelStartDate => 'Start Date';

  @override
  String get labelEndDate => 'End Date';

  @override
  String get labelTotalPrice => 'Total Price';

  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';
}
