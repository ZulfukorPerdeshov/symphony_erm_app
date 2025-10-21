import 'package:flutter/material.dart';
import '../services/company_service.dart';
import '../models/company.dart';
import '../utils/constants.dart';

class CompanySelector extends StatefulWidget {
  final Function(String)? onCompanyChanged;

  const CompanySelector({super.key, this.onCompanyChanged});

  @override
  State<CompanySelector> createState() => _CompanySelectorState();
}

class _CompanySelectorState extends State<CompanySelector> {
  List<Company> _companies = [];
  String? _selectedCompany;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCompanies();
    _selectedCompany = CompanyService.currentCompanyId;
  }

  Future<void> _loadCompanies() async {
    setState(() => _isLoading = true);

    try {
      // Try to get companies list first
      List<Company> companies = [];
      try {
        companies = await CompanyService.getCompaniesList();
      } catch (e) {
        print('Failed to get companies list, trying my company: $e');
        // Fallback to getMyCompanyDetails if getCompanies fails
        final myCompanyDetails = await CompanyService.getMyCompanyDetails();
        if (myCompanyDetails != null) {
          companies = [Company.fromJson(myCompanyDetails)];
        }
      }

      setState(() {
        // Remove duplicates by company ID to prevent dropdown errors
        final Map<String, Company> uniqueCompanies = {};
        for (var company in companies) {
          if (!uniqueCompanies.containsKey(company.id)) {
            uniqueCompanies[company.id] = company;
          }
        }
        _companies = uniqueCompanies.values.toList();
        _isLoading = false;

        print('companies loaded: ${_companies.length} companies (${companies.length} before deduplication)');
        print('companies: ${_companies.map((c) => '${c.name} (${c.id})').toList()}');
        print('current selected company: $_selectedCompany');

        // Validate the selected company exists in the loaded list
        final companyIds = _companies.map((c) => c.id).toSet();
        if (_selectedCompany != null && !companyIds.contains(_selectedCompany)) {
          print('Warning: Selected company $_selectedCompany not found in loaded companies');
          _selectedCompany = null;
        }

        // If no company is selected and we have companies, select the first one
        if ((_selectedCompany == null || _selectedCompany == 'default-company-id') && _companies.isNotEmpty) {
          _selectCompany(_companies.first.id);
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading companies: $e')),
        );
      }
    }
  }

  void _selectCompany(String companyId) {
    setState(() => _selectedCompany = companyId);
    CompanyService.setCurrentCompany(companyId);
    widget.onCompanyChanged?.call(companyId);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      // margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _isLoading
          ? _buildLoadingWidget(theme)
          : _buildCompanySelector(theme),
    );
  }

  Widget _buildLoadingWidget(ThemeData theme) {
    return Row(
      children: [
        Icon(
          Icons.business,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Text(
          'Loading companies...',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const Spacer(),
        SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildCompanySelector(ThemeData theme) {
    if (_companies.isEmpty) {
      return Row(
        children: [
          Icon(
            Icons.business_outlined,
            color: theme.colorScheme.error,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No companies available',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
          TextButton(
            onPressed: _loadCompanies,
            child: Text('Retry'),
          ),
        ],
      );
    }

    // Validate that the selected company exists in the companies list
    // If not, default to null or the first company
    final companyIds = _companies.map((c) => c.id).toList();
    final validSelectedCompany = _selectedCompany != null && companyIds.contains(_selectedCompany)
        ? _selectedCompany
        : (companyIds.isNotEmpty ? companyIds.first : null);

    // Update the selected company if it changed
    if (validSelectedCompany != _selectedCompany) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (validSelectedCompany != null) {
          _selectCompany(validSelectedCompany);
        }
      });
    }

    return Row(
      children: [
        // Icon(
        //   Icons.business,
        //   color: theme.colorScheme.primary,
        //   size: 20,
        // ),
        // const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: validSelectedCompany,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  selectedItemBuilder: (BuildContext context) {
                    return _companies.map((Company company) {
                      return Container(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          company.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList();
                  },
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      _selectCompany(newValue);
                    }
                  },
                  items: _companies.map<DropdownMenuItem<String>>((Company company) {
                    return DropdownMenuItem<String>(
                      value: company.id,
                      child: Text(
                        company.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _companies.length > 1
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${_companies.length}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: _companies.length > 1
                  ? theme.colorScheme.onPrimaryContainer
                  : theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}