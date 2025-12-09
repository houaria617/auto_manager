import 'package:auto_manager/databases/repo/Client/client_abstract.dart';
import 'package:bloc/bloc.dart';
import '../databases/repo/Rental/rental_abstract.dart';
import '../databases/repo/Car/car_abstract.dart';
import '../databases/repo/Activity/activity_abstract.dart';

class DashboardStatistics {
  final int ongoingRentals;
  final int availableCars;
  final int dueToday;
  final List<Map<String, dynamic>> recentActivities;

  DashboardStatistics(
    this.ongoingRentals,
    this.availableCars,
    this.dueToday,
    this.recentActivities,
  );
}

class DashboardCubit extends Cubit<DashboardStatistics> {
  DateTime? _lastDueNotification;

  DashboardCubit()
    : super(DashboardStatistics(0, 0, 0, <Map<String, dynamic>>[]));

  final _rentalRepo = AbstractRentalRepo.getInstance();
  final _carRepo = AbstractCarRepo.getInstance();
  final _activityRepo = AbstractActivityRepo.getInstance();
  final _clientRepo = AbstractClientRepo.getInstance();

  // ✅ NEW: Helper method to specifically load activities from DB
  void loadActivities() async {
    final recentActivities = await _activityRepo.getActivities();
    emit(
      DashboardStatistics(
        state.ongoingRentals,
        state.availableCars,
        state.dueToday,
        recentActivities,
      ),
    );
  }

  // ✅ UPDATED: Inserts activity, then refreshes the list
  void addActivity(Map<String, dynamic> activity) async {
    // If description is empty or null, just reload existing data
    if (activity['description'] == null || activity['description'] == '') {
      loadActivities();
      return;
    }

    // Insert into database
    await _activityRepo.insertActivity(activity);

    // Fetch the updated list from DB to ensure correct order/IDs
    loadActivities();
  }

  void countOngoingRentals() async {
    int ongRentalsCount = await _rentalRepo.countOngoingRentals();
    emit(
      DashboardStatistics(
        ongRentalsCount,
        state.availableCars,
        state.dueToday,
        state.recentActivities,
      ),
    );
  }

  void countAvailableCars() async {
    int avCarsCount = await _carRepo.countAvailableCars();
    emit(
      DashboardStatistics(
        state.ongoingRentals,
        avCarsCount,
        state.dueToday,
        state.recentActivities,
      ),
    );
  }

  void countDueToday() async {
    int dueTodayCount = await _rentalRepo.countDueToday();
    emit(
      DashboardStatistics(
        state.ongoingRentals,
        state.availableCars,
        dueTodayCount,
        state.recentActivities,
      ),
    );
  }

  void checkDueToday(String carModel, int clientID) async {
    final int dueTodayCount = await _rentalRepo.countDueToday();

    bool isSameDay(DateTime instanceDate, DateTime today) {
      return instanceDate.year == today.year &&
          instanceDate.month == today.month &&
          instanceDate.day == today.day;
    }

    if (dueTodayCount > 0) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final client = await _clientRepo.getClient(clientID);
      final lastNotified = _lastDueNotification;

      if (lastNotified == null || !isSameDay(lastNotified, today)) {
        addActivity({
          'description': '${client?['full_name']} Returns $carModel Today',
          'date': DateTime.now(),
        });
        _lastDueNotification = today;
      }
    }
  }
}
