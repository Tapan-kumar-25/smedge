abstract class DashboardRepository {
  Future<dynamic> fetchPersonalDetails();
  Future<dynamic> editPersonalDetails(Map<String, dynamic> body);
  Future<dynamic> fetchBusinessDetails();
  Future<dynamic> addCompany(Map<String, dynamic> body);
}