import 'package:flutter/cupertino.dart';
import 'model/company_model.dart';
import 'model/personal_details_screen.dart';

class DashboardState extends ChangeNotifier {
  bool _isLoading = false;
  BuildContext? _context;
  int _selectedTabIndex =0;
  int _currentIndex = 0;
  int _previousIndex = 0;
  String _selectedCompanyId = '1';
  PersonalDetailsModel? _personalDetailsModel;

  final List<CompanyModel> _companyList = [
    CompanyModel(
      id: '1',
      name: 'Edwin Trading LLC',
      gstId: 'GSTINI2345',
      avatarColor: const Color(0xFF2E7D32),
      avatarLetter: 'E',
      companyName: 'Edwin Trading LLC',
      websiteUrl: 'https://www.edwintrading.ae',
      tradeLicenseNumber: 'GST-IN12345',
      incorporationDate: '14 / 03 / 2021',
      expiryDate: '14 / 03 / 2026',
    ),
    CompanyModel(
      id: '2',
      name: 'ZhongFin Retail Trading LLC',
      gstId: '10293847',
      avatarColor: const Color(0xFFBF360C),
      avatarLetter: '夏',
      companyName: 'ZhongFin Retail Trading LLC',
      websiteUrl: 'https://www.zhongfin.ae',
      tradeLicenseNumber: 'LIC-10293847',
      incorporationDate: '01 / 06 / 2019',
      expiryDate: '01 / 06 / 2027',
    ),
  ];
  bool get isLoading => _isLoading;
  BuildContext get context => _context!;
  int get selectedTabIndex =>_selectedTabIndex;
  int get currentIndex => _currentIndex;
  int get previousIndex => _previousIndex;
  String get selectedCompanyId => _selectedCompanyId;
  PersonalDetailsModel? get personalDetailsModel => _personalDetailsModel;
  List<CompanyModel> get companyList => List.unmodifiable(_companyList);
  CompanyModel get selectedCompany =>
      _companyList.firstWhere((c) => c.id == _selectedCompanyId);

void setLoading(bool loading){
  _isLoading = loading;
  notifyListeners();
}
  void setContext(BuildContext context) {
    _context = context;
    notifyListeners();
  }
  void setTabIndex(int index){
    _selectedTabIndex = index;
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    _previousIndex = _currentIndex;
    _currentIndex = index;
    notifyListeners();
  }

  void setPreviousIndex(int index) {
    _previousIndex = index;
    notifyListeners();
  }

  void setSelectedCompanyId(String id) {
    _selectedCompanyId = id;
    notifyListeners();
  }
void setPersonalDetails(PersonalDetailsModel data){
  _personalDetailsModel = data;
  notifyListeners();
}


  // ── Company Actions ──────────────────────────────────────────────────────────
  void addCompany(CompanyModel company) {
    _companyList.add(company);
    notifyListeners();
  }

  /// Called after a real file pick — stores name, size AND local path
  void uploadFileToCompany(
      String companyId,
      String fileName,
      double sizeMB,
      String filePath,          // ← NEW param
      ) {
    final index = _companyList.indexWhere((c) => c.id == companyId);
    if (index != -1) {
      _companyList[index].uploadedFileName  = fileName;
      _companyList[index].uploadedFileSizeMB = sizeMB;
      _companyList[index].uploadedFilePath  = filePath;
      notifyListeners();
    }
  }

  void removeFileFromCompany(String companyId) {
    final index = _companyList.indexWhere((c) => c.id == companyId);
    if (index != -1) {
      _companyList[index].uploadedFileName  = null;
      _companyList[index].uploadedFileSizeMB = null;
      _companyList[index].uploadedFilePath  = null;
      notifyListeners();
    }
  }
}