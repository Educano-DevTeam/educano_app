class DashboardRepository {
  DashboardRepository._();

  static final DashboardRepository instance =
      DashboardRepository._();

  Future<DashboardSummary> getSummary() async {
    return const DashboardSummary(
      users: 1770,
      bronzeUsers: 236,
      silverUsers: -19,
      goldUsers: 0,
    );
  }
}

class DashboardSummary {
  final int users;
  final int bronzeUsers;
  final int silverUsers;
  final int goldUsers;

  const DashboardSummary({
    required this.users,
    required this.bronzeUsers,
    required this.silverUsers,
    required this.goldUsers,
  });
}