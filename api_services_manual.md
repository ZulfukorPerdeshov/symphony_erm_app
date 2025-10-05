# CloudShopMgr Flutter App Development Manual

## Table of Contents
1. [Authentication](#authentication)
2. [Warehouse Management](#warehouse-management)
3. [Order Management](#order-management)
4. [Production Management](#production-management)
5. [Production Tasks Management](#production-tasks-management)
6. [User Profile Management](#user-profile-management)
7. [Notifications Management](#notifications-management)
8. [API Integration](#api-integration)
9. [Technical Implementation](#technical-implementation)

---

## Authentication

### Login Functionality
The mobile app should implement secure authentication using JWT tokens.

#### Required Features:
- **Login Screen**: Email/username and password fields
- **JWT Token Management**: Store and refresh access tokens
- **Automatic Login**: Remember user credentials (optional)
- **Logout**: Clear tokens and redirect to login

#### API Endpoints:
```
POST /api/auth/login
POST /api/auth/refresh-token
POST /api/auth/logout
```

#### Implementation Notes:
- Use secure storage (flutter_secure_storage) for token storage
- Implement token refresh mechanism
- Handle authentication errors gracefully
- Support biometric authentication (optional)

---

## Warehouse Management

### Stock Items Management

#### Core Features:
1. **View Stock Items**
   - List all inventory items with pagination
   - Search and filter functionality
   - Show current stock levels, locations, and status

2. **Stock Item Details**
   - View detailed information about specific items
   - Show stock history and movements
   - Display item images and specifications

3. **Add New Stock Items**
   - Create new inventory items
   - Upload item images
   - Set initial stock quantities and locations

4. **Update Stock Items**
   - Edit item information
   - Update stock quantities
   - Change item status (active/inactive)

### Stock Operations

#### Key Operations:
1. **Stock Adjustment**
   - Increase/decrease stock quantities
   - Record adjustment reasons
   - Track adjustment history

2. **Stock Transfer**
   - Move items between locations/warehouses
   - Track transfer status and completion
   - Generate transfer documentation

3. **Stock Taking**
   - Conduct physical inventory counts
   - Compare actual vs system quantities
   - Generate discrepancy reports

#### API Endpoints:
```
GET /api/inventory/products
GET /api/inventory/products/{id}
POST /api/inventory/products
PUT /api/inventory/products/{id}
DELETE /api/inventory/products/{id}
POST /api/inventory/stock-adjustments
POST /api/inventory/stock-transfers
GET /api/inventory/stock-movements
```

---

## Order Management

### Order Overview
Mobile users can view and manage customer orders with complete operational control.

#### Core Features:
1. **View Orders**
   - List all orders with status indicators
   - Filter by date, status, customer, or priority
   - Search orders by order number or customer name

2. **Order Details**
   - View complete order information
   - Show customer details and shipping information
   - Display ordered items with quantities and prices
   - Track order status and history

3. **Order Operations**
   - **Confirm Orders**: Accept new orders
   - **Process Orders**: Move to processing status
   - **Prepare for Shipping**: Mark as ready for dispatch
   - **Ship Orders**: Update with tracking information
   - **Cancel Orders**: Cancel with reason codes
   - **Return Processing**: Handle returns and refunds

#### Order Status Flow:
```
Pending → Confirmed → Processing → Ready → Shipped → Delivered
                ↓
              Cancelled
                ↓
              Returned
```

#### API Endpoints:
```
GET /api/orders
GET /api/orders/{id}
PUT /api/orders/{id}/status
POST /api/orders/{id}/confirm
POST /api/orders/{id}/process
POST /api/orders/{id}/ship
POST /api/orders/{id}/cancel
POST /api/orders/{id}/return
```

---

## Production Management

### Production Overview
Manage complete production lifecycle from planning to completion.

#### Core Features:
1. **Production Orders**
   - View all production orders
   - Create new production orders
   - Update production schedules
   - Track production progress

2. **Production Stages**
   - **Start Production**: Initialize production process
   - **Stage Management**: Move through production stages
   - **Quality Control**: Record quality checks
   - **Complete Production**: Finalize and move to inventory

3. **Production Monitoring**
   - Real-time production status
   - Resource allocation tracking
   - Production efficiency metrics
   - Equipment utilization

#### Production Stages:
1. **Planning**: Define requirements and resources
2. **Material Preparation**: Allocate raw materials
3. **Production**: Execute manufacturing process
4. **Quality Control**: Inspect and test products
5. **Packaging**: Prepare finished goods
6. **Completion**: Move to finished goods inventory

#### API Endpoints:
```
GET /api/production/orders
GET /api/production/orders/{id}
POST /api/production/orders
PUT /api/production/orders/{id}
POST /api/production/orders/{id}/start
PUT /api/production/orders/{id}/stage
POST /api/production/orders/{id}/complete
GET /api/production/stages
```

---

## Production Tasks Management

### Task Operations
Manage individual production tasks and assignments.

#### Core Features:
1. **View Tasks**
   - List assigned production tasks
   - Filter by priority, status, or due date
   - Show task details and requirements

2. **Task Management**
   - **Start Tasks**: Begin task execution
   - **Update Progress**: Record completion percentage
   - **Complete Tasks**: Mark as finished
   - **Report Issues**: Log problems or delays

3. **Task Assignment**
   - Assign tasks to workers
   - Set priorities and deadlines
   - Track task dependencies

#### Task Status:
- **Not Started**: Task is created but not begun
- **In Progress**: Task is actively being worked on
- **On Hold**: Task is paused or blocked
- **Completed**: Task is finished
- **Cancelled**: Task is cancelled

#### API Endpoints:
```
GET /api/production/tasks
GET /api/production/tasks/{id}
POST /api/production/tasks
PUT /api/production/tasks/{id}
POST /api/production/tasks/{id}/start
PUT /api/production/tasks/{id}/progress
POST /api/production/tasks/{id}/complete
POST /api/production/tasks/{id}/issues
```

---

## User Profile Management

### Profile Features
Allow users to manage their account information and preferences.

#### Core Features:
1. **Change Password**
   - Current password verification
   - New password with confirmation
   - Password strength validation
   - Security notifications

2. **Avatar Management**
   - Upload profile pictures
   - Crop and resize images
   - Set default avatars
   - Remove current avatar

3. **Profile Information**
   - Update personal details
   - Change contact information
   - Set preferences and settings
   - View account activity

#### API Endpoints:
```
GET /api/users/profile
PUT /api/users/profile
POST /api/users/change-password
POST /api/users/avatar
DELETE /api/users/avatar
```

---

## Notifications Management

### Notification System
Comprehensive notification system for real-time updates and alerts.

#### Core Features:
1. **View Notifications**
   - List all notifications with timestamps
   - Show read/unread status
   - Categorize by type (orders, production, system)
   - Support pagination for large lists

2. **Manage Notifications**
   - Mark as read/unread
   - Delete individual notifications
   - Clear all notifications
   - Archive old notifications

3. **Notification Types**
   - **Order Notifications**: New orders, status changes
   - **Production Alerts**: Task assignments, completions
   - **Inventory Alerts**: Low stock, stock movements
   - **System Notifications**: Updates, maintenance

4. **Push Notifications**
   - Real-time mobile notifications
   - Configurable notification preferences
   - Sound and vibration settings

#### API Endpoints:
```
GET /api/notifications
GET /api/notifications/{id}
PUT /api/notifications/{id}/read
DELETE /api/notifications/{id}
POST /api/notifications/mark-all-read
GET /api/notifications/preferences
PUT /api/notifications/preferences
```

---

## API Integration

### Base Configuration
All API calls should use the following base configuration:

#### Base URL:
```
IdentityService: http://localhost:8091
InventoryService: http://localhost:8092
OrderService: http://localhost:8093
ProductionService: http://localhost:8094
PayrollService: http://localhost:5115
```

#### Authentication:
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

#### Error Handling:
```dart
// Standard error response format
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human readable error message",
    "details": "Additional error details"
  }
}
```

### HTTP Status Codes:
- **200**: Success
- **201**: Created
- **400**: Bad Request
- **401**: Unauthorized
- **403**: Forbidden
- **404**: Not Found
- **500**: Internal Server Error

---

## API Endpoints & DTOs

### Authentication Service

#### Login
```
POST /api/auth/login
```

**Request DTO:**
```dart
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {
    'email': email,
    'password': password,
  };
}
```

**Response DTO:**
```dart
class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final UserDto user;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    accessToken: json['accessToken'],
    refreshToken: json['refreshToken'],
    user: UserDto.fromJson(json['user']),
  );
}
```

#### Refresh Token
```
POST /api/auth/refresh-token
```

**Request DTO:**
```dart
class RefreshTokenRequest {
  final String refreshToken;

  RefreshTokenRequest({required this.refreshToken});

  Map<String, dynamic> toJson() => {
    'refreshToken': refreshToken,
  };
}
```

#### User Profile
```
GET /api/users/profile
PUT /api/users/profile
```

**User DTO:**
```dart
class UserDto {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final DateTime createdAt;

  UserDto({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    required this.createdAt,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) => UserDto(
    id: json['id'],
    email: json['email'],
    firstName: json['firstName'],
    lastName: json['lastName'],
    avatarUrl: json['avatarUrl'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}
```

#### Change Password
```
POST /api/users/change-password
```

**Request DTO:**
```dart
class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() => {
    'currentPassword': currentPassword,
    'newPassword': newPassword,
  };
}
```

---

### Inventory Service

#### Get Products
```
GET /api/inventory/products?skip=0&take=50&search=term
```

**Product DTO:**
```dart
class ProductDto {
  final String id;
  final String name;
  final String description;
  final String sku;
  final String category;
  final double price;
  final int stockQuantity;
  final int minimumStockLevel;
  final String unit;
  final bool isActive;
  final List<String> imageUrls;
  final DateTime createdAt;

  ProductDto({
    required this.id,
    required this.name,
    required this.description,
    required this.sku,
    required this.category,
    required this.price,
    required this.stockQuantity,
    required this.minimumStockLevel,
    required this.unit,
    required this.isActive,
    required this.imageUrls,
    required this.createdAt,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) => ProductDto(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    sku: json['sku'],
    category: json['category'],
    price: json['price'].toDouble(),
    stockQuantity: json['stockQuantity'],
    minimumStockLevel: json['minimumStockLevel'],
    unit: json['unit'],
    isActive: json['isActive'],
    imageUrls: List<String>.from(json['imageUrls'] ?? []),
    createdAt: DateTime.parse(json['createdAt']),
  );
}
```

#### Create/Update Product
```
POST /api/inventory/products
PUT /api/inventory/products/{id}
```

**Request DTO:**
```dart
class CreateProductRequest {
  final String name;
  final String description;
  final String sku;
  final String category;
  final double price;
  final int stockQuantity;
  final int minimumStockLevel;
  final String unit;
  final List<String> imageUrls;

  CreateProductRequest({
    required this.name,
    required this.description,
    required this.sku,
    required this.category,
    required this.price,
    required this.stockQuantity,
    required this.minimumStockLevel,
    required this.unit,
    required this.imageUrls,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'sku': sku,
    'category': category,
    'price': price,
    'stockQuantity': stockQuantity,
    'minimumStockLevel': minimumStockLevel,
    'unit': unit,
    'imageUrls': imageUrls,
  };
}
```

#### Stock Adjustment
```
POST /api/inventory/stock-adjustments
```

**Request DTO:**
```dart
class StockAdjustmentRequest {
  final String productId;
  final int quantityChange;
  final String reason;
  final String? notes;

  StockAdjustmentRequest({
    required this.productId,
    required this.quantityChange,
    required this.reason,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'quantityChange': quantityChange,
    'reason': reason,
    'notes': notes,
  };
}
```

---

### Order Service

#### Get Orders
```
GET /api/orders?status=pending&skip=0&take=50
```

**Order DTO:**
```dart
class OrderDto {
  final String id;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final OrderStatus status;
  final double totalAmount;
  final DateTime orderDate;
  final DateTime? shippingDate;
  final List<OrderItemDto> items;
  final ShippingAddressDto shippingAddress;

  OrderDto({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.status,
    required this.totalAmount,
    required this.orderDate,
    this.shippingDate,
    required this.items,
    required this.shippingAddress,
  });

  factory OrderDto.fromJson(Map<String, dynamic> json) => OrderDto(
    id: json['id'],
    orderNumber: json['orderNumber'],
    customerId: json['customerId'],
    customerName: json['customerName'],
    status: OrderStatus.values.firstWhere((e) => e.name == json['status']),
    totalAmount: json['totalAmount'].toDouble(),
    orderDate: DateTime.parse(json['orderDate']),
    shippingDate: json['shippingDate'] != null ? DateTime.parse(json['shippingDate']) : null,
    items: (json['items'] as List).map((e) => OrderItemDto.fromJson(e)).toList(),
    shippingAddress: ShippingAddressDto.fromJson(json['shippingAddress']),
  );
}

enum OrderStatus { pending, confirmed, processing, ready, shipped, delivered, cancelled, returned }

class OrderItemDto {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  OrderItemDto({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory OrderItemDto.fromJson(Map<String, dynamic> json) => OrderItemDto(
    id: json['id'],
    productId: json['productId'],
    productName: json['productName'],
    quantity: json['quantity'],
    unitPrice: json['unitPrice'].toDouble(),
    totalPrice: json['totalPrice'].toDouble(),
  );
}

class ShippingAddressDto {
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final String country;

  ShippingAddressDto({
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.country,
  });

  factory ShippingAddressDto.fromJson(Map<String, dynamic> json) => ShippingAddressDto(
    street: json['street'],
    city: json['city'],
    state: json['state'],
    zipCode: json['zipCode'],
    country: json['country'],
  );
}
```

#### Update Order Status
```
PUT /api/orders/{id}/status
```

**Request DTO:**
```dart
class UpdateOrderStatusRequest {
  final OrderStatus status;
  final String? notes;
  final String? trackingNumber;

  UpdateOrderStatusRequest({
    required this.status,
    this.notes,
    this.trackingNumber,
  });

  Map<String, dynamic> toJson() => {
    'status': status.name,
    'notes': notes,
    'trackingNumber': trackingNumber,
  };
}
```

---

### Production Service

#### Get Production Orders
```
GET /api/production/orders?status=active&skip=0&take=50
```

**Production Order DTO:**
```dart
class ProductionOrderDto {
  final String id;
  final String orderNumber;
  final String productId;
  final String productName;
  final int quantity;
  final ProductionStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? dueDate;
  final List<ProductionStageDto> stages;

  ProductionOrderDto({
    required this.id,
    required this.orderNumber,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.status,
    required this.startDate,
    this.endDate,
    this.dueDate,
    required this.stages,
  });

  factory ProductionOrderDto.fromJson(Map<String, dynamic> json) => ProductionOrderDto(
    id: json['id'],
    orderNumber: json['orderNumber'],
    productId: json['productId'],
    productName: json['productName'],
    quantity: json['quantity'],
    status: ProductionStatus.values.firstWhere((e) => e.name == json['status']),
    startDate: DateTime.parse(json['startDate']),
    endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    stages: (json['stages'] as List).map((e) => ProductionStageDto.fromJson(e)).toList(),
  );
}

enum ProductionStatus { planning, inProgress, qualityControl, completed, cancelled }

class ProductionStageDto {
  final String id;
  final String name;
  final String description;
  final int order;
  final StageStatus status;
  final DateTime? startTime;
  final DateTime? endTime;

  ProductionStageDto({
    required this.id,
    required this.name,
    required this.description,
    required this.order,
    required this.status,
    this.startTime,
    this.endTime,
  });

  factory ProductionStageDto.fromJson(Map<String, dynamic> json) => ProductionStageDto(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    order: json['order'],
    status: StageStatus.values.firstWhere((e) => e.name == json['status']),
    startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
    endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
  );
}

enum StageStatus { notStarted, inProgress, completed, onHold }
```

#### Start/Complete Production Stage
```
POST /api/production/orders/{id}/stages/{stageId}/start
POST /api/production/orders/{id}/stages/{stageId}/complete
```

**Request DTO:**
```dart
class UpdateStageRequest {
  final String? notes;
  final Map<String, dynamic>? data;

  UpdateStageRequest({this.notes, this.data});

  Map<String, dynamic> toJson() => {
    'notes': notes,
    'data': data,
  };
}
```

---

### Production Tasks

#### Get Tasks
```
GET /api/production/tasks?assignedTo=userId&status=inProgress
```

**Production Task DTO:**
```dart
class ProductionTaskDto {
  final String id;
  final String name;
  final String description;
  final String productionOrderId;
  final String? assignedTo;
  final String? assignedToName;
  final TaskStatus status;
  final TaskPriority priority;
  final int progressPercentage;
  final DateTime? startTime;
  final DateTime? endTime;
  final DateTime? dueDate;
  final List<String> requirements;

  ProductionTaskDto({
    required this.id,
    required this.name,
    required this.description,
    required this.productionOrderId,
    this.assignedTo,
    this.assignedToName,
    required this.status,
    required this.priority,
    required this.progressPercentage,
    this.startTime,
    this.endTime,
    this.dueDate,
    required this.requirements,
  });

  factory ProductionTaskDto.fromJson(Map<String, dynamic> json) => ProductionTaskDto(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    productionOrderId: json['productionOrderId'],
    assignedTo: json['assignedTo'],
    assignedToName: json['assignedToName'],
    status: TaskStatus.values.firstWhere((e) => e.name == json['status']),
    priority: TaskPriority.values.firstWhere((e) => e.name == json['priority']),
    progressPercentage: json['progressPercentage'],
    startTime: json['startTime'] != null ? DateTime.parse(json['startTime']) : null,
    endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    requirements: List<String>.from(json['requirements'] ?? []),
  );
}

enum TaskStatus { notStarted, inProgress, onHold, completed, cancelled }
enum TaskPriority { low, medium, high, urgent }
```

#### Update Task Progress
```
PUT /api/production/tasks/{id}/progress
```

**Request DTO:**
```dart
class UpdateTaskProgressRequest {
  final int progressPercentage;
  final String? notes;

  UpdateTaskProgressRequest({
    required this.progressPercentage,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'progressPercentage': progressPercentage,
    'notes': notes,
  };
}
```

---

### Notifications

#### Get Notifications
```
GET /api/notifications?unreadOnly=true&skip=0&take=50
```

**Notification DTO:**
```dart
class NotificationDto {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  NotificationDto({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) => NotificationDto(
    id: json['id'],
    title: json['title'],
    message: json['message'],
    type: NotificationType.values.firstWhere((e) => e.name == json['type']),
    isRead: json['isRead'],
    createdAt: DateTime.parse(json['createdAt']),
    data: json['data'],
  );
}

enum NotificationType { order, production, inventory, system, task }
```

#### Mark as Read
```
PUT /api/notifications/{id}/read
POST /api/notifications/mark-all-read
```

---

### File Upload

#### Upload Avatar
```
POST /api/files/avatar
Content-Type: multipart/form-data
```

**Response DTO:**
```dart
class FileUploadResponse {
  final String url;
  final String fileName;
  final int fileSize;

  FileUploadResponse({
    required this.url,
    required this.fileName,
    required this.fileSize,
  });

  factory FileUploadResponse.fromJson(Map<String, dynamic> json) => FileUploadResponse(
    url: json['url'],
    fileName: json['fileName'],
    fileSize: json['fileSize'],
  );
}
```

#### Upload Product Images
```
POST /api/files/products
Content-Type: multipart/form-data
```

---

## Technical Implementation

### Required Flutter Packages:
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^0.13.5
  flutter_secure_storage: ^9.0.0
  provider: ^6.0.5
  dio: ^5.3.2
  flutter_local_notifications: ^15.1.1
  image_picker: ^1.0.4
  cached_network_image: ^3.3.0
  pull_to_refresh: ^2.0.0
  flutter_barcode_scanner: ^2.0.0
```

### Folder Structure:
```
lib/
├── main.dart
├── models/
│   ├── user.dart
│   ├── order.dart
│   ├── product.dart
│   ├── production.dart
│   └── notification.dart
├── services/
│   ├── auth_service.dart
│   ├── api_service.dart
│   ├── notification_service.dart
│   └── storage_service.dart
├── screens/
│   ├── auth/
│   ├── warehouse/
│   ├── orders/
│   ├── production/
│   ├── profile/
│   └── notifications/
├── widgets/
│   ├── common/
│   ├── forms/
│   └── lists/
└── utils/
    ├── constants.dart
    ├── helpers.dart
    └── validators.dart
```

### State Management:
Use Provider or Riverpod for state management:

```dart
// Example Provider setup
class AppState extends ChangeNotifier {
  User? _currentUser;
  List<Order> _orders = [];
  List<Notification> _notifications = [];

  // Getters and methods
}
```

### Network Layer:
```dart
class ApiService {
  static const baseUrl = 'http://localhost:8080/api';

  Future<Response> get(String endpoint) async {
    // Implementation with error handling
  }

  Future<Response> post(String endpoint, Map<String, dynamic> data) async {
    // Implementation with error handling
  }
}
```

### Data Models:
```dart
class Order {
  final String id;
  final String customerId;
  final String status;
  final DateTime createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.customerId,
    required this.status,
    required this.createdAt,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // JSON parsing implementation
  }
}
```

### Security Considerations:
1. **Token Storage**: Use flutter_secure_storage for JWT tokens
2. **Network Security**: Implement certificate pinning
3. **Data Validation**: Validate all user inputs
4. **Error Handling**: Don't expose sensitive error information
5. **Biometric Auth**: Support fingerprint/face authentication

### Testing Strategy:
1. **Unit Tests**: Test business logic and models
2. **Widget Tests**: Test UI components
3. **Integration Tests**: Test complete user flows
4. **API Tests**: Mock API responses for testing

---

## Development Guidelines

### Code Standards:
- Follow Dart/Flutter naming conventions
- Use meaningful variable and function names
- Implement proper error handling
- Add comprehensive comments
- Follow SOLID principles

### Performance Optimization:
- Implement lazy loading for large lists
- Use pagination for data retrieval
- Cache frequently accessed data
- Optimize image loading and caching
- Implement proper disposal of resources

### User Experience:
- Implement loading states and progress indicators
- Provide clear error messages
- Use consistent UI patterns
- Support offline functionality where possible
- Implement pull-to-refresh functionality

### Deployment:
- Configure different environments (dev, staging, prod)
- Implement proper app signing
- Set up CI/CD pipelines
- Configure app store releases
- Implement crash reporting and analytics

---

This manual provides a comprehensive guide for developing the CloudShopMgr Flutter mobile application with all the specified functionalities. Each section includes detailed requirements, API endpoints, and implementation guidelines to ensure a robust and user-friendly mobile application.