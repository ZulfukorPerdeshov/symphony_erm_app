class WorkingHoursDay {
  final String? openTime;
  final String? closeTime;
  final bool isClosed;

  WorkingHoursDay({
    this.openTime,
    this.closeTime,
    required this.isClosed,
  });

  factory WorkingHoursDay.fromJson(Map<String, dynamic> json) {
    return WorkingHoursDay(
      openTime: json['openTime'],
      closeTime: json['closeTime'],
      isClosed: json['isClosed'] ?? true, // Default to closed if not specified
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'openTime': openTime,
      'closeTime': closeTime,
      'isClosed': isClosed,
    };
  }
}

class WorkingHours {
  final WorkingHoursDay monday;
  final WorkingHoursDay tuesday;
  final WorkingHoursDay wednesday;
  final WorkingHoursDay thursday;
  final WorkingHoursDay friday;
  final WorkingHoursDay saturday;
  final WorkingHoursDay sunday;

  WorkingHours({
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
  });

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    return WorkingHours(
      monday: WorkingHoursDay.fromJson(json['monday'] ?? {}),
      tuesday: WorkingHoursDay.fromJson(json['tuesday'] ?? {}),
      wednesday: WorkingHoursDay.fromJson(json['wednesday'] ?? {}),
      thursday: WorkingHoursDay.fromJson(json['thursday'] ?? {}),
      friday: WorkingHoursDay.fromJson(json['friday'] ?? {}),
      saturday: WorkingHoursDay.fromJson(json['saturday'] ?? {}),
      sunday: WorkingHoursDay.fromJson(json['sunday'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monday': monday.toJson(),
      'tuesday': tuesday.toJson(),
      'wednesday': wednesday.toJson(),
      'thursday': thursday.toJson(),
      'friday': friday.toJson(),
      'saturday': saturday.toJson(),
      'sunday': sunday.toJson(),
    };
  }
}

class Contact {
  final String? phone;
  final String? mobile;
  final String? email;
  final String? website;
  final String? telegram;
  final String? instagram;
  final String? facebook;
  final Map<String, String>? workingHours;

  Contact({
    this.phone,
    this.mobile,
    this.email,
    this.website,
    this.telegram,
    this.instagram,
    this.facebook,
    this.workingHours,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      phone: json['phone'],
      mobile: json['mobile'],
      email: json['email'],
      website: json['website'],
      telegram: json['telegram'],
      instagram: json['instagram'],
      facebook: json['facebook'],
      workingHours: json['workingHours'] != null
          ? Map<String, String>.from(json['workingHours'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'mobile': mobile,
      'email': email,
      'website': website,
      'telegram': telegram,
      'instagram': instagram,
      'facebook': facebook,
      'workingHours': workingHours,
    };
  }
}

class Address {
  final int? countryId;
  final int? regionId;
  final int? districtId;
  final String? country;
  final String? region;
  final String? district;
  final String? street;
  final String? postalCode;
  final double? latitude;
  final double? longitude;
  final String? fullAddress;

  Address({
    this.countryId,
    this.regionId,
    this.districtId,
    this.country,
    this.region,
    this.district,
    this.street,
    this.postalCode,
    this.latitude,
    this.longitude,
    this.fullAddress,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      countryId: json['countryId'],
      regionId: json['regionId'],
      districtId: json['districtId'],
      country: json['country'],
      region: json['region'],
      district: json['district'],
      street: json['street'],
      postalCode: json['postalCode'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      fullAddress: json['fullAddress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'countryId': countryId,
      'regionId': regionId,
      'districtId': districtId,
      'country': country,
      'region': region,
      'district': district,
      'street': street,
      'postalCode': postalCode,
      'latitude': latitude,
      'longitude': longitude,
      'fullAddress': fullAddress,
    };
  }
}

class CompanyImage {
  final String id;
  final String? fileName;
  final String? url;
  final int type;
  final bool isMain;
  final int displayOrder;
  final DateTime uploadedAt;

  CompanyImage({
    required this.id,
    this.fileName,
    this.url,
    required this.type,
    required this.isMain,
    required this.displayOrder,
    required this.uploadedAt,
  });

  factory CompanyImage.fromJson(Map<String, dynamic> json) {
    return CompanyImage(
      id: json['id'],
      fileName: json['fileName'],
      url: json['url'],
      type: json['type'] ?? 1,
      isMain: json['isMain'] ?? false,
      displayOrder: json['displayOrder'] ?? 0,
      uploadedAt: DateTime.parse(json['uploadedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'url': url,
      'type': type,
      'isMain': isMain,
      'displayOrder': displayOrder,
      'uploadedAt': uploadedAt.toIso8601String(),
    };
  }
}

class Currency {
  final String id;
  final String code;
  final String name;
  final String symbol;
  final bool isActive;
  final bool isDefault;
  final int decimalPlaces;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  Currency({
    required this.id,
    required this.code,
    required this.name,
    required this.symbol,
    required this.isActive,
    required this.isDefault,
    required this.decimalPlaces,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      id: json['id'] ?? '',
      code: json['code'] ?? 'USD',
      name: json['name'] ?? 'US Dollar',
      symbol: json['symbol'] ?? '\$',
      isActive: json['isActive'] ?? true,
      isDefault: json['isDefault'] ?? false,
      decimalPlaces: json['decimalPlaces'] ?? 2,
      description: json['description'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'symbol': symbol,
      'isActive': isActive,
      'isDefault': isDefault,
      'decimalPlaces': decimalPlaces,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Category {
  final String id;
  final String name;
  final String? nameRu;
  final String? nameEn;
  final String? description;
  final String? parentId;
  final String? iconUrl;
  final List<String> children;
  final String? parentName;
  final String? parentCategory;
  final int companiesCount;
  final int depth;
  final bool hasChildren;
  final int childrenCount;

  Category({
    required this.id,
    required this.name,
    this.nameRu,
    this.nameEn,
    this.description,
    this.parentId,
    this.iconUrl,
    required this.children,
    this.parentName,
    this.parentCategory,
    required this.companiesCount,
    required this.depth,
    required this.hasChildren,
    required this.childrenCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      nameRu: json['nameRu'],
      nameEn: json['nameEn'],
      description: json['description'],
      parentId: json['parentId'],
      iconUrl: json['iconUrl'],
      children: List<String>.from(json['children'] ?? []),
      parentName: json['parentName'],
      parentCategory: json['parentCategory'],
      companiesCount: json['companiesCount'] ?? 0,
      depth: json['depth'] ?? 0,
      hasChildren: json['hasChildren'] ?? false,
      childrenCount: json['childrenCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameRu': nameRu,
      'nameEn': nameEn,
      'description': description,
      'parentId': parentId,
      'iconUrl': iconUrl,
      'children': children,
      'parentName': parentName,
      'parentCategory': parentCategory,
      'companiesCount': companiesCount,
      'depth': depth,
      'hasChildren': hasChildren,
      'childrenCount': childrenCount,
    };
  }
}

class Company {
  final String id;
  final String ownerId;
  final String name;
  final String? description;
  final int type;
  final String typeName;
  final String? taxNumber;
  final String? legalName;
  final String currencyId;
  final WorkingHours workingHours;
  final bool isActive;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Contact? contact;
  final Address? address;
  final List<CompanyImage> images;
  final CompanyImage? logo;
  final Currency currency;
  final List<Category> categories;

  Company({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description,
    required this.type,
    required this.typeName,
    this.taxNumber,
    this.legalName,
    required this.currencyId,
    required this.workingHours,
    required this.isActive,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
    this.contact,
    this.address,
    required this.images,
    this.logo,
    required this.currency,
    required this.categories,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] ?? '',
      ownerId: json['ownerId'] ?? '',
      name: json['name'] ?? 'Unknown Company',
      description: json['description'],
      type: json['type'] ?? 1,
      typeName: json['typeName'] ?? 'Unknown',
      taxNumber: json['taxNumber'],
      legalName: json['legalName'],
      currencyId: json['currencyId'] ?? '',
      workingHours: WorkingHours.fromJson(json['workingHours'] ?? {}),
      isActive: json['isActive'] ?? true,
      isVerified: json['isVerified'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      contact: json['contact'] != null ? Contact.fromJson(json['contact']) : null,
      address: json['address'] != null ? Address.fromJson(json['address']) : null,
      images: (json['images'] as List<dynamic>?)
          ?.map((item) => CompanyImage.fromJson(item))
          .toList() ?? [],
      logo: json['logo'] != null ? CompanyImage.fromJson(json['logo']) : null,
      currency: json['currency'] != null
          ? Currency.fromJson(json['currency'])
          : Currency(
              id: '',
              code: 'USD',
              name: 'US Dollar',
              symbol: '\$',
              isActive: true,
              isDefault: true,
              decimalPlaces: 2,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ),
      categories: (json['categories'] as List<dynamic>?)
          ?.map((item) => Category.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'description': description,
      'type': type,
      'typeName': typeName,
      'taxNumber': taxNumber,
      'legalName': legalName,
      'currencyId': currencyId,
      'workingHours': workingHours.toJson(),
      'isActive': isActive,
      'isVerified': isVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'contact': contact?.toJson(),
      'address': address?.toJson(),
      'images': images.map((image) => image.toJson()).toList(),
      'logo': logo?.toJson(),
      'currency': currency.toJson(),
      'categories': categories.map((category) => category.toJson()).toList(),
    };
  }
}

class CompaniesResponse {
  final List<Company> data;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  CompaniesResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory CompaniesResponse.fromJson(Map<String, dynamic> json) {
    // Handle the actual API response format: {"companies": [...]}
    if (json.containsKey('companies')) {
      final companiesList = (json['companies'] as List<dynamic>)
          .map((item) => Company.fromJson(item))
          .toList();

      return CompaniesResponse(
        data: companiesList,
        total: json['total'] ?? companiesList.length,
        page: json['page'] ?? 1,
        pageSize: json['pageSize'] ?? companiesList.length,
        totalPages: json['totalPages'] ?? 1,
      );
    }

    // Handle pagination format: {"data": [...], "total": ..., etc}
    return CompaniesResponse(
      data: (json['data'] as List<dynamic>)
          .map((item) => Company.fromJson(item))
          .toList(),
      total: json['total'],
      page: json['page'],
      pageSize: json['pageSize'],
      totalPages: json['totalPages'],
    );
  }

  Map<String, dynamic> toJson() => {
        'data': data.map((company) => company.toJson()).toList(),
        'total': total,
        'page': page,
        'pageSize': pageSize,
        'totalPages': totalPages,
      };
}

class GetCompaniesParams {
  final int? page;
  final int? pageSize;
  final String? search;
  final String? status;
  final String? type;
  final String? location;
  final String? sortBy;
  final String? sortOrder;

  GetCompaniesParams({
    this.page,
    this.pageSize,
    this.search,
    this.status,
    this.type,
    this.location,
    this.sortBy,
    this.sortOrder,
  });

  Map<String, dynamic> toQueryParameters() {
    final params = <String, dynamic>{};
    if (page != null) params['page'] = page;
    if (pageSize != null) params['pageSize'] = pageSize;
    if (search != null && search!.isNotEmpty) params['search'] = search;
    if (status != null && status!.isNotEmpty) params['status'] = status;
    if (type != null && type!.isNotEmpty) params['type'] = type;
    if (location != null && location!.isNotEmpty) params['location'] = location;
    if (sortBy != null && sortBy!.isNotEmpty) params['sortBy'] = sortBy;
    if (sortOrder != null && sortOrder!.isNotEmpty) params['sortOrder'] = sortOrder;
    return params;
  }
}