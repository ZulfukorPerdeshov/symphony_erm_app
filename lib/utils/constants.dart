class ApiConstants {  
  static const String baseApiUrl = 'http://192.168.100.106';
  
  static const String identityServiceBaseUrl = '${baseApiUrl}:8080';
  static const String companyServiceBaseUrl = '${baseApiUrl}:8082';
  static const String inventoryServiceBaseUrl = '${baseApiUrl}:8084';
  static const String orderServiceBaseUrl = '${baseApiUrl}:8090';
  static const String productionServiceBaseUrl = '${baseApiUrl}:8084';
  static const String payrollServiceBaseUrl = '${baseApiUrl}:8096';

  // Authentication endpoints
  static const String loginEndpoint = '/api/auth/login';
  static const String refreshTokenEndpoint = '/api/auth/refresh-token';
  static const String logoutEndpoint = '/api/auth/logout';
  static const String changePasswordEndpoint = '/api/Auth/change-password';

  // User endpoints
  static const String userProfileEndpoint = '/api/users/profile';
  static const String avatarEndpoint = '/api/users/avatar';
  static const String usersByIdsEndpoint = '/api/Users/by-Ids';

// Company endpoints
  static const String myCompaniesEndpoint = '/api/Companies/my';
  static const String companiesEndpoint = '/api/Companies';
  static String companyUsersEndpoint(String companyId) => '/api/companies/$companyId/users';

  // Inventory endpoints (company-scoped)
  static String productsEndpoint(String companyId) => '/api/Companies/$companyId/Products';

  // Inventory transaction endpoints (from docs: /api/companies/{companyId}/inventory-transactions)
  static String inventoryTransactionsEndpoint(String companyId) => '/api/companies/$companyId/inventory-transactions';
  static String inventoryTransactionReceiptEndpoint(String companyId) => '/api/companies/$companyId/inventory-transactions/receipt';
  static String inventoryTransactionConsumptionEndpoint(String companyId) => '/api/companies/$companyId/inventory-transactions/consumption';
  static String inventoryTransactionMoveEndpoint(String companyId) => '/api/companies/$companyId/inventory-transactions/move';
  static String inventoryTransactionWriteoffEndpoint(String companyId) => '/api/companies/$companyId/inventory-transactions/writeoff';
  static String inventoryTransactionAdjustmentEndpoint(String companyId) => '/api/companies/$companyId/inventory-transactions/adjustment';
  static String inventoryTransactionHistoryEndpoint(String companyId) => '/api/companies/$companyId/inventory-transactions/history';
  static String inventoryWarehouseSummaryEndpoint(String companyId) => '/api/companies/$companyId/inventory-transactions/warehouse-summary';

  // Raw material stock items endpoints
  static String rawMaterialStockItemsEndpoint(String companyId) => '/api/Companies/$companyId/raw-material-stock-items';
  static String rawMaterialStockItemAdjustEndpoint(String companyId) => '/api/Companies/$companyId/raw-material-stock-items/adjust';
  static String rawMaterialStockItemReserveEndpoint(String companyId) => '/api/Companies/$companyId/raw-material-stock-items/reserve';

  // Stock items endpoints
  static String stockItemsEndpoint(String companyId) => '/api/Companies/$companyId/stock-items';
  static String stockItemByIdEndpoint(String companyId, String stockItemId) => '/api/Companies/$companyId/stock-items/$stockItemId';
  static String stockItemsByWarehouseEndpoint(String companyId, String warehouseId) => '/api/Companies/$companyId/stock-items/by-warehouse/$warehouseId';
  static String stockItemsByProductEndpoint(String companyId, String productId) => '/api/Companies/$companyId/stock-items/by-product/$productId';
  static String stockItemSummaryEndpoint(String companyId, String productId) => '/api/Companies/$companyId/stock-items/summary/product/$productId';
  static String stockItemSearchEndpoint(String companyId) => '/api/Companies/$companyId/stock-items/search';
  static String stockItemAdjustEndpoint(String companyId, String stockItemId) => '/api/Companies/$companyId/stock-items/$stockItemId/adjust';
  static String stockItemReserveEndpoint(String companyId, String stockItemId) => '/api/Companies/$companyId/stock-items/$stockItemId/reserve';
  static String stockItemReleaseEndpoint(String companyId, String stockItemId) => '/api/Companies/$companyId/stock-items/$stockItemId/release';
  static String stockItemTransferEndpoint(String companyId, String stockItemId) => '/api/Companies/$companyId/stock-items/$stockItemId/transfer';
  static String stockItemsLowStockReportEndpoint(String companyId) => '/api/Companies/$companyId/stock-items/reports/low-stock';
  static String stockItemsExpiringReportEndpoint(String companyId) => '/api/Companies/$companyId/stock-items/reports/expiring';
  static String stockItemsAvailableQuantityEndpoint(String companyId) => '/api/Companies/$companyId/stock-items/available-quantity';
  static String stockItemsTotalQuantityEndpoint(String companyId) => '/api/Companies/$companyId/stock-items/total-quantity';
  static String stockItemsBulkEndpoint(String companyId) => '/api/Companies/$companyId/stock-items/bulk';
  static String stockItemsBulkMinLevelsEndpoint(String companyId) => '/api/Companies/$companyId/stock-items/bulk/min-levels';

  // Warehouses endpoints (from docs: /api/companies/{companyId}/Warehouses)
  static String warehousesEndpoint(String companyId) => '/api/companies/$companyId/Warehouses';
  static String warehouseByIdEndpoint(String companyId, String warehouseId) => '/api/companies/$companyId/Warehouses/$warehouseId';
  static String warehousesByTypeEndpoint(String companyId, String type) => '/api/companies/$companyId/Warehouses/by-type/$type';

  // Categories are NOT company-scoped (from docs: /api/Categories)
  static const String categoriesEndpoint = '/api/Categories';
  static const String categoriesSearchEndpoint = '/api/Categories/search';
  static String categoriesByTypeEndpoint(String type) => '/api/Categories/by-type/$type';
  static String categoriesHierarchyEndpoint(String type) => '/api/Categories/hierarchy/$type';

  // Additional inventory endpoints
  static String inventoryBulkUpdateEndpoint(String companyId) => '/api/companies/$companyId/inventory-transactions/bulk-update';
  static String inventoryStockTakingEndpoint(String companyId) => '/api/companies/$companyId/inventory-transactions/stock-taking';
  static String inventoryExpiringEndpoint(String companyId) => '/api/companies/$companyId/inventory-transactions/expiring';
  static String inventoryOverstockedEndpoint(String companyId) => '/api/companies/$companyId/inventory-transactions/overstocked';

  // Order endpoints
  static const String ordersEndpoint = '/api/Orders';

  // Production endpoints
  static const String productionOrdersEndpoint = '/api/production/orders';
  static const String productionStagesEndpoint = '/api/production/stages';
  static const String productionTasksEndpoint = '/api/production/tasks';

  // Production tasks endpoints (company-scoped)
  static String productionTasksListEndpoint(String companyId) => '/api/companies/$companyId/production-tasks';
  static String productionTasksMyTasksEndpoint(String companyId) => '/api/companies/$companyId/production-tasks/my-tasks';
  static String productionTaskByIdEndpoint(String companyId, String taskId) => '/api/companies/$companyId/production-tasks/$taskId';

  // Production task actions
  static String productionTaskStartEndpoint(String companyId, String taskId) => '/api/companies/$companyId/production-tasks/$taskId/start';
  static String productionTaskCompleteEndpoint(String companyId, String taskId) => '/api/companies/$companyId/production-tasks/$taskId/complete';
  static String productionTaskCancelEndpoint(String companyId, String taskId) => '/api/companies/$companyId/production-tasks/$taskId/cancel';
  static String productionTaskProgressEndpoint(String companyId, String taskId) => '/api/companies/$companyId/production-tasks/$taskId/progress';
  static String productionTaskAssignToSelfEndpoint(String companyId, String taskId) => '/api/companies/$companyId/production-tasks/$taskId/assign-to-self';
  static String productionTaskReassignEndpoint(String companyId, String taskId) => '/api/companies/$companyId/production-tasks/$taskId/reassign';
  static String productionTaskUnassignEndpoint(String companyId, String taskId) => '/api/companies/$companyId/production-tasks/$taskId/unassign';
  static String productionTaskUpdateStatusEndpoint(String companyId, String taskId) => '/api/companies/$companyId/production-tasks/$taskId/status';
  static String productionTaskUpdateDueDateEndpoint(String companyId, String taskId) => '/api/companies/$companyId/production-tasks/$taskId/due-date';
  static String productionTaskUpdateProgressEndpoint(String companyId, String taskId) => '/api/companies/$companyId/production-tasks/$taskId/update-progress';

  // Production task comments
  static String productionTaskCommentsEndpoint(String companyId, String taskId) => '/api/companies/$companyId/production-tasks/$taskId/comments';
  static String productionTaskCommentByIdEndpoint(String companyId, String commentId) => '/api/companies/$companyId/production-tasks/comments/$commentId';

  // Production task attachments
  static String productionTaskAttachmentsEndpoint(String companyId, String taskId) => '/api/companies/$companyId/production-tasks/$taskId/attachments';
  static String productionTaskAttachmentDownloadEndpoint(String companyId, String attachmentId) => '/api/companies/$companyId/production-tasks/attachments/$attachmentId/download';
  static String productionTaskAttachmentByIdEndpoint(String companyId, String attachmentId) => '/api/companies/$companyId/production-tasks/attachments/$attachmentId';

  // Notification endpoints
  static const String notificationsEndpoint = '/api/notifications';

  // File upload endpoints
  static const String filesAvatarEndpoint = '/api/files/avatar';
  static const String filesProductsEndpoint = '/api/files/products';
}

class AppConstants {
  static const String appName = 'Symphony ERP';
  static const String appVersion = '1.0.0';

  // Storage keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String settingsKey = 'app_settings';
  static const String firstNameKey = 'first_name';
  static const String lastNameKey = 'last_name';
  static const String emailKey = 'email';
  static const String phoneNumberKey = 'phone_number';
  static const String avatarKey = 'avatar';

  // Pagination
  static const int defaultPageSize = 50;
  static const int maxPageSize = 100;

  // Timeouts
  static const int connectTimeoutMs = 30000;
  static const int receiveTimeoutMs = 30000;
  static const int sendTimeoutMs = 30000;
}

class AppColors {
  // Modern primary colors - Vibrant Purple-Blue gradient
  static const primaryPurple = 0xFF6366F1;
  static const primaryBlue = 0xFF3B82F6;
  static const primaryIndigo = 0xFF4F46E5;
  static const primaryLight = 0xFF818CF8;
  static const primaryDark = 0xFF4338CA;

  // Accent colors - Energetic and modern
  static const accentCyan = 0xFF06B6D4;
  static const accentPink = 0xFFEC4899;
  static const accentEmerald = 0xFF10B981;
  static const accentAmber = 0xFFF59E0B;
  static const accentViolet = 0xFF8B5CF6;

  // Neutral colors - Softer modern palette
  static const backgroundLight = 0xFFF8FAFC;
  static const backgroundDark = 0xFF0F172A;
  static const surfaceLight = 0xFFFFFFFF;
  static const surfaceDark = 0xFF1E293B;
  static const cardLight = 0xFFFCFCFC;
  static const cardDark = 0xFF334155;

  // Text colors
  static const textPrimary = 0xFF0F172A;
  static const textSecondary = 0xFF64748B;
  static const textHint = 0xFF94A3B8;
  static const textOnDark = 0xFFF1F5F9;

  // Status colors - Modern and vibrant
  static const success = 0xFF10B981;
  static const successLight = 0xFF6EE7B7;
  static const warning = 0xFFF59E0B;
  static const warningLight = 0xFFFBBF24;
  static const error = 0xFFEF4444;
  static const errorLight = 0xFFFCA5A5;
  static const info = 0xFF3B82F6;
  static const infoLight = 0xFF93C5FD;

  // Gradient colors
  static const gradientStart = 0xFF6366F1;
  static const gradientMiddle = 0xFF8B5CF6;
  static const gradientEnd = 0xFFEC4899;

  // Border and divider
  static const borderLight = 0xFFE2E8F0;
  static const borderDark = 0xFF334155;
  static const dividerLight = 0xFFF1F5F9;
  static const dividerDark = 0xFF475569;
}

class AppStrings {
  // App
  static const String appTitle = 'Symphony ERP';
  static const String loading = 'Loading...';
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String add = 'Add';
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String refresh = 'Refresh';

  // Authentication
  static const String login = 'Login';
  static const String logout = 'Logout';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String forgotPassword = 'Forgot Password?';
  static const String loginError = 'Login failed. Please check your credentials.';
  static const String logoutConfirm = 'Are you sure you want to logout?';

  // Navigation
  static const String home = 'Home';
  static const String warehouse = 'Warehouse';
  static const String orders = 'Orders';
  static const String production = 'Production';
  static const String tasks = 'Tasks';
  static const String profile = 'Profile';
  static const String notifications = 'Notifications';
  static const String analytics = 'Analytics';

  // Common errors
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unknownError = 'An unknown error occurred.';
  static const String unauthorizedError = 'Session expired. Please login again.';

  // Warehouse
  static const String inventory = 'Inventory';
  static const String stockItems = 'Stock Items';
  static const String stockLevel = 'Stock Level';
  static const String lowStock = 'Low Stock';
  static const String outOfStock = 'Out of Stock';

  // Orders
  static const String orderNumber = 'Order Number';
  static const String customer = 'Customer';
  static const String orderDate = 'Order Date';
  static const String totalAmount = 'Total Amount';
  static const String orderStatus = 'Order Status';

  // Production
  static const String productionOrder = 'Production Order';
  static const String productionStage = 'Production Stage';
  static const String productionTask = 'Production Task';
  static const String startProduction = 'Start Production';
  static const String completeProduction = 'Complete Production';

  // Status
  static const String pending = 'Pending';
  static const String confirmed = 'Confirmed';
  static const String processing = 'Processing';
  static const String ready = 'Ready';
  static const String shipped = 'Shipped';
  static const String delivered = 'Delivered';
  static const String cancelled = 'Cancelled';
  static const String returned = 'Returned';
  static const String inProgress = 'In Progress';
  static const String completed = 'Completed';
  static const String onHold = 'On Hold';
}