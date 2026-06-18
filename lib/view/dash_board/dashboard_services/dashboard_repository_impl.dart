import 'package:smedge/common_files/error_handler.dart';
import 'package:smedge/view/auth/auth_api_service/auth_api_service.dart';
import 'package:smedge/view/dash_board/dashboard_services/dashboard_repository.dart';

class DashboardRepositoryImpl extends DashboardRepository {
  final AuthApiService _apiService;
  DashboardRepositoryImpl(this._apiService);
  @override
  Future<dynamic> fetchPersonalDetails()async {
    try{
      final response = await _apiService.fetchPersonalDetails();
      return response;
    }catch(e){
      throw ErrorHandler.handle(e);
    }
  }
  @override
  Future<dynamic> editPersonalDetails(Map<String, dynamic> body)async {
    try{
      final response = await _apiService.editPersonalDetails(body);
      return response;
    }catch(e){
      throw ErrorHandler.handle(e);
    }
  }
  @override
  Future<dynamic> fetchBusinessDetails()async {
    try{
      final response = await _apiService.fetchBusinessDetails();
      return response;
    }catch(e){
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<dynamic> addCompany(Map<String, dynamic> body)async {
    try{
      final response = await _apiService.saveCompany(body);
      return response;
    }catch(e){
      throw ErrorHandler.handle(e);
    }
  }

}