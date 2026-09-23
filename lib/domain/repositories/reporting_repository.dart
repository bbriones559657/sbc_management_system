import '../../models/reporting.dart';

abstract class ReportingRepository {
  Future<ReportingSnapshot> getSnapshot({required int days});
}
