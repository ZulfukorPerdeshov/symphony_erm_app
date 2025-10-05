import '../utils/constants.dart';
import '../models/company.dart';
import 'api_service.dart';
import 'storage_service.dart';

class CompanyService {
  static String? _currentCompanyId;
  static const String _companyIdKey = 'current_company_id';

  static String? get currentCompanyId => _currentCompanyId;

  static Future<void> init() async {
    _currentCompanyId = StorageService.get(_companyIdKey);
  }

  static Future<void> setCurrentCompany(String companyId) async {
    _currentCompanyId = companyId;
    await StorageService.store(_companyIdKey, companyId);
  }

  static Future<List<String>> getMyCompanies() async {
    final response = await ApiService.get<dynamic>(
      ApiConstants.companyServiceBaseUrl,
      ApiConstants.myCompaniesEndpoint,
    );

    // Handle both single company object and array of companies
    if (response is Map<String, dynamic>) {
      // Single company object
      final companyId = response['id'] as String?;
      final companyName = response['name'] as String?;
      if (companyId != null && companyName != null) {
        return [companyId]; // Return company ID for internal use
      }
      return [];
    } else if (response is List) {
      // Array of companies
      return response.map((e) {
        if (e is Map<String, dynamic>) {
          return e['id'] as String? ?? e.toString();
        }
        return e.toString();
      }).toList();
    }

    return [];
  }

  static Future<Map<String, dynamic>?> getMyCompanyDetails() async {
    final response = await ApiService.get<dynamic>(
      ApiConstants.companyServiceBaseUrl,
      ApiConstants.myCompaniesEndpoint,
    );

    if (response is Map<String, dynamic>) {
      return response;
    }
    return null;
  }

  static String getCurrentCompanyIdOrThrow() {
    if (_currentCompanyId == null || _currentCompanyId!.isEmpty) {
      throw Exception('No company selected. Please select a company first.');
    }
    return _currentCompanyId!;
  }

  static String? getCurrentCompanyId() {
    return _currentCompanyId;
  }

  /// Fetches a paginated list of companies with filtering and sorting options
  /// Mirrors the TypeScript version with the same parameters
  static Future<CompaniesResponse> getCompanies([GetCompaniesParams? params]) async {
    print('CompanyService.getCompanies: Called with params: ${params?.toQueryParameters()}');

    try {
      final queryParams = params?.toQueryParameters() ?? {};

      final response = await ApiService.get<Map<String, dynamic>>(
        ApiConstants.companyServiceBaseUrl,
        ApiConstants.companiesEndpoint,
        queryParameters: queryParams,
      );

      print('CompanyService.getCompanies: API response received');
      print('CompanyService.getCompanies: Response keys: ${response.keys}');

      if (response.containsKey('companies')) {
        final companiesCount = (response['companies'] as List?)?.length ?? 0;
        print('CompanyService.getCompanies: Found $companiesCount companies in response');
      }

      return CompaniesResponse.fromJson(response);
    } catch (error) {
      print('CompanyService.getCompanies: API error: $error');
      rethrow;
    }
  }

  /// Convenience method to get companies as a simple list of Company objects
  static Future<List<Company>> getCompaniesList([GetCompaniesParams? params]) async {
    final response = await getCompanies(params);
    return response.data;
  }
}