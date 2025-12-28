import 'package:auto_manager/databases/repo/Client/client_abstract.dart';
import 'package:bloc/bloc.dart';
import '../databases/repo/Rental/rental_abstract.dart';
import '../databases/repo/Car/car_abstract.dart';
import '../databases/repo/Activity/activity_abstract.dart';

// class Activity {
//   final String description;
//   final DateTime date;

//   Activity(this.description, this.date);
// }

class DashboardStatistics {
  final int ongoingRentals;
  final int availableCars;
  final int dueToday;
  final List<Map<String, dynamic>> recentActivities;
  final bool isLoading;

  DashboardStatistics(
    this.ongoingRentals,
    this.availableCars,
    this.dueToday,
    this.recentActivities,
    this.isLoading,
  );
}

class DashboardCubit extends Cubit<DashboardStatistics> {
  DateTime? _lastDueNotification;
  DashboardCubit()
    : super(DashboardStatistics(0, 0, 0, <Map<String, dynamic>>[], false));

  final _rentalRepo = AbstractRentalRepo.getInstance();
  final _carRepo = AbstractCarRepo.getInstance();
  final _activityRepo = AbstractActivityRepo.getInstance();
  final _clientRepo = AbstractClientRepo.getInstance();

  void countOngoingRentals() async {
    int ongRentalsCount = await _rentalRepo.countOngoingRentals();
    emit(
      DashboardStatistics(
        ongRentalsCount,
        state.availableCars,
        state.dueToday,
        state.recentActivities,
        true,
      ),
    );
    print('Counted Ongoing Rentals Successfully');
  }

  void checkDueToday(Map<String, dynamic>? car, int clientID) async {
    final int dueTodayCount = await _rentalRepo.countDueToday();

    bool isSameDay(DateTime instanceDate, DateTime today) {
      return instanceDate.year == today.year &&
          instanceDate.month == today.month &&
          instanceDate.day == today.day;
    }

    if (dueTodayCount > 0) {
      // Check if we already notified today
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final client = await _clientRepo.getClient(clientID);

      // Store last notification date
      final lastNotified = _lastDueNotification;
      if (lastNotified == null || !isSameDay(lastNotified, today)) {
        addActivity({
          'description': '${client['full_name']} Returns ${car?['name']} Today',
          'date': DateTime.now(),
        });
        _lastDueNotification = today;
      }
    }
  }

  void countAvailableCars() async {
    int avCarsCount = await _carRepo.countAvailableCars();
    emit(
      DashboardStatistics(
        state.ongoingRentals,
        avCarsCount,
        state.dueToday,
        state.recentActivities,
        false,
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
        false,
      ),
    );
  }

  void getRecentActivities() async {
    emit(
      DashboardStatistics(
        state.ongoingRentals,
        state.availableCars,
        state.dueToday,
        [],
        true,
      ),
    );
    final recentActivities = await _activityRepo.getRecentActivities();

    emit(
      DashboardStatistics(
        state.ongoingRentals,
        state.availableCars,
        state.dueToday,
        recentActivities,
        false,
      ),
    );
  }

  void addActivity(Map<String, dynamic> activity) async {
    emit(
      DashboardStatistics(
        state.ongoingRentals,
        state.availableCars,
        state.dueToday,
        state.recentActivities,
        true,
      ),
    );
    final recentActivities = await _activityRepo.getRecentActivities();
    print('recent activities fetched from DB: $recentActivities');
    await _activityRepo.insertActivity(activity);
    List<Map<String, dynamic>> updated = [activity, ...recentActivities];
    if (updated.length > 3) {
      updated = updated.sublist(0, 3);
    }
    emit(
      DashboardStatistics(
        state.ongoingRentals,
        state.availableCars,
        state.dueToday,
        updated,
        false,
      ),
    );
  }
}
