import '../../../core/data/repositories/dashboard_repository.dart';

class DashboardController {
  final DashboardRepository repository;

  DashboardController({
    DashboardRepository? repository,
  }) : repository =
            repository ?? DashboardRepository.instance;

  Future<DashboardSummary> loadSummary() {
    return repository.getSummary();
  }
}