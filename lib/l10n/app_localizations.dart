import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Symphony ERP'**
  String get appTitle;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your credentials.'**
  String get loginError;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get emailRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long'**
  String get passwordTooShort;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @warehouse.
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get warehouse;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @production.
  ///
  /// In en, this message translates to:
  /// **'Production'**
  String get production;

  /// No description provided for @tasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasks;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please check your connection.'**
  String get networkError;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get serverError;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred.'**
  String get unknownError;

  /// No description provided for @unauthorizedError.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please login again.'**
  String get unauthorizedError;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @stockItems.
  ///
  /// In en, this message translates to:
  /// **'Stock Items'**
  String get stockItems;

  /// No description provided for @stockLevel.
  ///
  /// In en, this message translates to:
  /// **'Stock Level'**
  String get stockLevel;

  /// No description provided for @lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get lowStock;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get inStock;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get productName;

  /// No description provided for @productNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Product name is required'**
  String get productNameRequired;

  /// No description provided for @productDescription.
  ///
  /// In en, this message translates to:
  /// **'Product Description'**
  String get productDescription;

  /// No description provided for @productSKU.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get productSKU;

  /// No description provided for @productCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get productCategory;

  /// No description provided for @productPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get productPrice;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @minimumStock.
  ///
  /// In en, this message translates to:
  /// **'Minimum Stock Level'**
  String get minimumStock;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @stockAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Stock Adjustment'**
  String get stockAdjustment;

  /// No description provided for @adjustmentReason.
  ///
  /// In en, this message translates to:
  /// **'Adjustment Reason'**
  String get adjustmentReason;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order Number'**
  String get orderNumber;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @orderDate.
  ///
  /// In en, this message translates to:
  /// **'Order Date'**
  String get orderDate;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @orderStatus.
  ///
  /// In en, this message translates to:
  /// **'Order Status'**
  String get orderStatus;

  /// No description provided for @shippingAddress.
  ///
  /// In en, this message translates to:
  /// **'Shipping Address'**
  String get shippingAddress;

  /// No description provided for @orderItems.
  ///
  /// In en, this message translates to:
  /// **'Order Items'**
  String get orderItems;

  /// No description provided for @confirmOrder.
  ///
  /// In en, this message translates to:
  /// **'Confirm Order'**
  String get confirmOrder;

  /// No description provided for @processOrder.
  ///
  /// In en, this message translates to:
  /// **'Process Order'**
  String get processOrder;

  /// No description provided for @shipOrder.
  ///
  /// In en, this message translates to:
  /// **'Ship Order'**
  String get shipOrder;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancelOrder;

  /// No description provided for @trackingNumber.
  ///
  /// In en, this message translates to:
  /// **'Tracking Number'**
  String get trackingNumber;

  /// No description provided for @productionOrder.
  ///
  /// In en, this message translates to:
  /// **'Production Order'**
  String get productionOrder;

  /// No description provided for @productionStage.
  ///
  /// In en, this message translates to:
  /// **'Production Stage'**
  String get productionStage;

  /// No description provided for @productionTask.
  ///
  /// In en, this message translates to:
  /// **'Production Task'**
  String get productionTask;

  /// No description provided for @startProduction.
  ///
  /// In en, this message translates to:
  /// **'Start Production'**
  String get startProduction;

  /// No description provided for @completeProduction.
  ///
  /// In en, this message translates to:
  /// **'Complete Production'**
  String get completeProduction;

  /// No description provided for @productionStatus.
  ///
  /// In en, this message translates to:
  /// **'Production Status'**
  String get productionStatus;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @assignedTo.
  ///
  /// In en, this message translates to:
  /// **'Assigned To'**
  String get assignedTo;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @requirements.
  ///
  /// In en, this message translates to:
  /// **'Requirements'**
  String get requirements;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get confirmed;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing...'**
  String get processing;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @shipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get shipped;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @returned.
  ///
  /// In en, this message translates to:
  /// **'Returned'**
  String get returned;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @onHold.
  ///
  /// In en, this message translates to:
  /// **'On Hold'**
  String get onHold;

  /// No description provided for @notStarted.
  ///
  /// In en, this message translates to:
  /// **'Not Started'**
  String get notStarted;

  /// No description provided for @priority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get priority;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @urgent.
  ///
  /// In en, this message translates to:
  /// **'Urgent'**
  String get urgent;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @zipCode.
  ///
  /// In en, this message translates to:
  /// **'ZIP Code'**
  String get zipCode;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current Password'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get passwordChangedSuccessfully;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// No description provided for @uploadAvatar.
  ///
  /// In en, this message translates to:
  /// **'Upload Avatar'**
  String get uploadAvatar;

  /// No description provided for @removeAvatar.
  ///
  /// In en, this message translates to:
  /// **'Remove Avatar'**
  String get removeAvatar;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @markAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as Read'**
  String get markAsRead;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark All as Read'**
  String get markAllAsRead;

  /// No description provided for @deleteNotification.
  ///
  /// In en, this message translates to:
  /// **'Delete Notification'**
  String get deleteNotification;

  /// No description provided for @clearAllNotifications.
  ///
  /// In en, this message translates to:
  /// **'Clear All Notifications'**
  String get clearAllNotifications;

  /// No description provided for @notificationPreferences.
  ///
  /// In en, this message translates to:
  /// **'Notification Preferences'**
  String get notificationPreferences;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get lightTheme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get darkTheme;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get systemTheme;

  /// No description provided for @todayTasks.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Tasks'**
  String get todayTasks;

  /// No description provided for @ongoingTasks.
  ///
  /// In en, this message translates to:
  /// **'Ongoing Tasks'**
  String get ongoingTasks;

  /// No description provided for @taskOverview.
  ///
  /// In en, this message translates to:
  /// **'Task Overview'**
  String get taskOverview;

  /// No description provided for @totalTasks.
  ///
  /// In en, this message translates to:
  /// **'Total Tasks'**
  String get totalTasks;

  /// No description provided for @totalDue.
  ///
  /// In en, this message translates to:
  /// **'Total Due'**
  String get totalDue;

  /// No description provided for @uniqueTasks.
  ///
  /// In en, this message translates to:
  /// **'Unique Tasks'**
  String get uniqueTasks;

  /// No description provided for @monthlyView.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthlyView;

  /// No description provided for @weeklyView.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weeklyView;

  /// No description provided for @dailyView.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get dailyView;

  /// No description provided for @allActivitiesInOnePlace.
  ///
  /// In en, this message translates to:
  /// **'All your activities in one place'**
  String get allActivitiesInOnePlace;

  /// No description provided for @theHomeScreenGivesUsers.
  ///
  /// In en, this message translates to:
  /// **'The Home Screen gives users a clear, quick overview of their day. It displays high-priority tasks, upcoming deadlines, and recent team'**
  String get theHomeScreenGivesUsers;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good Morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good Afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good Evening'**
  String get goodEvening;

  /// No description provided for @dataLoadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Data loaded successfully'**
  String get dataLoadedSuccessfully;

  /// No description provided for @noDataAvailable.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noDataAvailable;

  /// No description provided for @pullToRefresh.
  ///
  /// In en, this message translates to:
  /// **'Pull to refresh'**
  String get pullToRefresh;

  /// No description provided for @loadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get loadMore;

  /// No description provided for @warehouses.
  ///
  /// In en, this message translates to:
  /// **'Warehouses'**
  String get warehouses;

  /// No description provided for @warehousesList.
  ///
  /// In en, this message translates to:
  /// **'Warehouses List'**
  String get warehousesList;

  /// No description provided for @warehouseDetails.
  ///
  /// In en, this message translates to:
  /// **'Warehouse Details'**
  String get warehouseDetails;

  /// No description provided for @warehouseName.
  ///
  /// In en, this message translates to:
  /// **'Warehouse Name'**
  String get warehouseName;

  /// No description provided for @warehouseCode.
  ///
  /// In en, this message translates to:
  /// **'Warehouse Code'**
  String get warehouseCode;

  /// No description provided for @warehouseType.
  ///
  /// In en, this message translates to:
  /// **'Warehouse Type'**
  String get warehouseType;

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// No description provided for @capacity.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get capacity;

  /// No description provided for @currentOccupancy.
  ///
  /// In en, this message translates to:
  /// **'Current Occupancy'**
  String get currentOccupancy;

  /// No description provided for @manager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get manager;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @productList.
  ///
  /// In en, this message translates to:
  /// **'Product List'**
  String get productList;

  /// No description provided for @productDetails.
  ///
  /// In en, this message translates to:
  /// **'Product Details'**
  String get productDetails;

  /// No description provided for @sku.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get sku;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @stockQuantity.
  ///
  /// In en, this message translates to:
  /// **'Stock Quantity'**
  String get stockQuantity;

  /// No description provided for @currentStock.
  ///
  /// In en, this message translates to:
  /// **'Current Stock'**
  String get currentStock;

  /// No description provided for @minimumStockLevel.
  ///
  /// In en, this message translates to:
  /// **'Minimum Stock Level'**
  String get minimumStockLevel;

  /// No description provided for @stockStatus.
  ///
  /// In en, this message translates to:
  /// **'Stock Status'**
  String get stockStatus;

  /// No description provided for @stockTaking.
  ///
  /// In en, this message translates to:
  /// **'Stock Taking'**
  String get stockTaking;

  /// No description provided for @stockTransfer.
  ///
  /// In en, this message translates to:
  /// **'Stock Transfer'**
  String get stockTransfer;

  /// No description provided for @stockTransferList.
  ///
  /// In en, this message translates to:
  /// **'Stock Transfer List'**
  String get stockTransferList;

  /// No description provided for @newCount.
  ///
  /// In en, this message translates to:
  /// **'New Count'**
  String get newCount;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @selectLocation.
  ///
  /// In en, this message translates to:
  /// **'Select Location'**
  String get selectLocation;

  /// No description provided for @selectProduct.
  ///
  /// In en, this message translates to:
  /// **'Select Product'**
  String get selectProduct;

  /// No description provided for @chooseProduct.
  ///
  /// In en, this message translates to:
  /// **'Choose a product'**
  String get chooseProduct;

  /// No description provided for @chooseLocation.
  ///
  /// In en, this message translates to:
  /// **'Choose a location'**
  String get chooseLocation;

  /// No description provided for @countProducts.
  ///
  /// In en, this message translates to:
  /// **'Count Products'**
  String get countProducts;

  /// No description provided for @counted.
  ///
  /// In en, this message translates to:
  /// **'Counted'**
  String get counted;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @discrepancies.
  ///
  /// In en, this message translates to:
  /// **'Discrepancies'**
  String get discrepancies;

  /// No description provided for @noProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No products found for this location'**
  String get noProductsFound;

  /// No description provided for @pleaseCountAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Please count at least one product'**
  String get pleaseCountAtLeastOne;

  /// No description provided for @stockTakingCompleted.
  ///
  /// In en, this message translates to:
  /// **'Stock taking completed successfully'**
  String get stockTakingCompleted;

  /// No description provided for @noStockTakingsFound.
  ///
  /// In en, this message translates to:
  /// **'No stock takings found'**
  String get noStockTakingsFound;

  /// No description provided for @errorLoadingStockTakings.
  ///
  /// In en, this message translates to:
  /// **'Error loading stock takings'**
  String get errorLoadingStockTakings;

  /// No description provided for @submitStockCount.
  ///
  /// In en, this message translates to:
  /// **'Submit Stock Count'**
  String get submitStockCount;

  /// No description provided for @quantityChange.
  ///
  /// In en, this message translates to:
  /// **'Quantity Change'**
  String get quantityChange;

  /// No description provided for @enterQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter quantity (+ for increase, - for decrease)'**
  String get enterQuantity;

  /// No description provided for @usePositiveNumbers.
  ///
  /// In en, this message translates to:
  /// **'Use positive numbers to increase stock, negative to decrease'**
  String get usePositiveNumbers;

  /// No description provided for @selectReason.
  ///
  /// In en, this message translates to:
  /// **'Select reason for adjustment'**
  String get selectReason;

  /// No description provided for @physicalCountCorrection.
  ///
  /// In en, this message translates to:
  /// **'Physical Count Correction'**
  String get physicalCountCorrection;

  /// No description provided for @damagedGoods.
  ///
  /// In en, this message translates to:
  /// **'Damaged Goods'**
  String get damagedGoods;

  /// No description provided for @expiredProducts.
  ///
  /// In en, this message translates to:
  /// **'Expired Products'**
  String get expiredProducts;

  /// No description provided for @theftLoss.
  ///
  /// In en, this message translates to:
  /// **'Theft/Loss'**
  String get theftLoss;

  /// No description provided for @returnToSupplier.
  ///
  /// In en, this message translates to:
  /// **'Return to Supplier'**
  String get returnToSupplier;

  /// No description provided for @qualityControlRejection.
  ///
  /// In en, this message translates to:
  /// **'Quality Control Rejection'**
  String get qualityControlRejection;

  /// No description provided for @systemErrorCorrection.
  ///
  /// In en, this message translates to:
  /// **'System Error Correction'**
  String get systemErrorCorrection;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (Optional)'**
  String get notesOptional;

  /// No description provided for @addNotes.
  ///
  /// In en, this message translates to:
  /// **'Add any additional notes or comments'**
  String get addNotes;

  /// No description provided for @adjustStock.
  ///
  /// In en, this message translates to:
  /// **'Adjust Stock'**
  String get adjustStock;

  /// No description provided for @stockAdjustmentCompleted.
  ///
  /// In en, this message translates to:
  /// **'Stock adjustment completed successfully'**
  String get stockAdjustmentCompleted;

  /// No description provided for @errorAdjustingStock.
  ///
  /// In en, this message translates to:
  /// **'Error adjusting stock'**
  String get errorAdjustingStock;

  /// No description provided for @pleaseSelectProduct.
  ///
  /// In en, this message translates to:
  /// **'Please select a product'**
  String get pleaseSelectProduct;

  /// No description provided for @pleaseSelectReason.
  ///
  /// In en, this message translates to:
  /// **'Please select a reason'**
  String get pleaseSelectReason;

  /// No description provided for @pleaseEnterQuantity.
  ///
  /// In en, this message translates to:
  /// **'Please enter quantity change'**
  String get pleaseEnterQuantity;

  /// No description provided for @pleaseEnterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get pleaseEnterValidNumber;

  /// No description provided for @quantityCannotBeZero.
  ///
  /// In en, this message translates to:
  /// **'Quantity change cannot be zero'**
  String get quantityCannotBeZero;

  /// No description provided for @cannotReduceBelowZero.
  ///
  /// In en, this message translates to:
  /// **'Cannot reduce stock below zero'**
  String get cannotReduceBelowZero;

  /// No description provided for @currentStockInformation.
  ///
  /// In en, this message translates to:
  /// **'Current Stock Information'**
  String get currentStockInformation;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @minimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get minimum;

  /// No description provided for @errorLoadingProducts.
  ///
  /// In en, this message translates to:
  /// **'Error loading products'**
  String get errorLoadingProducts;

  /// No description provided for @errorLoadingLocations.
  ///
  /// In en, this message translates to:
  /// **'Error loading locations'**
  String get errorLoadingLocations;

  /// No description provided for @fromLocation.
  ///
  /// In en, this message translates to:
  /// **'From Location'**
  String get fromLocation;

  /// No description provided for @toLocation.
  ///
  /// In en, this message translates to:
  /// **'To Location'**
  String get toLocation;

  /// No description provided for @transferQuantity.
  ///
  /// In en, this message translates to:
  /// **'Transfer Quantity'**
  String get transferQuantity;

  /// No description provided for @selectFromLocation.
  ///
  /// In en, this message translates to:
  /// **'Select from location'**
  String get selectFromLocation;

  /// No description provided for @selectToLocation.
  ///
  /// In en, this message translates to:
  /// **'Select to location'**
  String get selectToLocation;

  /// No description provided for @enterTransferQuantity.
  ///
  /// In en, this message translates to:
  /// **'Enter quantity to transfer'**
  String get enterTransferQuantity;

  /// No description provided for @pleaseSelectFromLocation.
  ///
  /// In en, this message translates to:
  /// **'Please select from location'**
  String get pleaseSelectFromLocation;

  /// No description provided for @pleaseSelectToLocation.
  ///
  /// In en, this message translates to:
  /// **'Please select to location'**
  String get pleaseSelectToLocation;

  /// No description provided for @pleaseEnterTransferQuantity.
  ///
  /// In en, this message translates to:
  /// **'Please enter transfer quantity'**
  String get pleaseEnterTransferQuantity;

  /// No description provided for @locationsCannotBeSame.
  ///
  /// In en, this message translates to:
  /// **'From and To locations cannot be the same'**
  String get locationsCannotBeSame;

  /// No description provided for @insufficientStock.
  ///
  /// In en, this message translates to:
  /// **'Insufficient stock at source location'**
  String get insufficientStock;

  /// No description provided for @createTransfer.
  ///
  /// In en, this message translates to:
  /// **'Create Transfer'**
  String get createTransfer;

  /// No description provided for @stockTransferCreated.
  ///
  /// In en, this message translates to:
  /// **'Stock transfer created successfully'**
  String get stockTransferCreated;

  /// No description provided for @errorCreatingTransfer.
  ///
  /// In en, this message translates to:
  /// **'Error creating stock transfer'**
  String get errorCreatingTransfer;

  /// No description provided for @allStatuses.
  ///
  /// In en, this message translates to:
  /// **'All Statuses'**
  String get allStatuses;

  /// No description provided for @noTransfersFound.
  ///
  /// In en, this message translates to:
  /// **'No transfers found'**
  String get noTransfersFound;

  /// No description provided for @completeTransfer.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get completeTransfer;

  /// No description provided for @cancelTransfer.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelTransfer;

  /// No description provided for @transferCompleted.
  ///
  /// In en, this message translates to:
  /// **'Transfer completed successfully'**
  String get transferCompleted;

  /// No description provided for @transferCancelled.
  ///
  /// In en, this message translates to:
  /// **'Transfer cancelled successfully'**
  String get transferCancelled;

  /// No description provided for @errorCompletingTransfer.
  ///
  /// In en, this message translates to:
  /// **'Error completing transfer'**
  String get errorCompletingTransfer;

  /// No description provided for @errorCancellingTransfer.
  ///
  /// In en, this message translates to:
  /// **'Error cancelling transfer'**
  String get errorCancellingTransfer;

  /// No description provided for @cancelTransferTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel Transfer'**
  String get cancelTransferTitle;

  /// No description provided for @provideCancellationReason.
  ///
  /// In en, this message translates to:
  /// **'Please provide a reason for cancelling this transfer:'**
  String get provideCancellationReason;

  /// No description provided for @cancellationReason.
  ///
  /// In en, this message translates to:
  /// **'Cancellation reason'**
  String get cancellationReason;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @createdBy.
  ///
  /// In en, this message translates to:
  /// **'Created By'**
  String get createdBy;

  /// No description provided for @totalValue.
  ///
  /// In en, this message translates to:
  /// **'Total Value'**
  String get totalValue;

  /// No description provided for @addNotesAboutStockTaking.
  ///
  /// In en, this message translates to:
  /// **'Add any notes about the stock taking'**
  String get addNotesAboutStockTaking;

  /// No description provided for @warehousesNotFound.
  ///
  /// In en, this message translates to:
  /// **'No warehouses found'**
  String get warehousesNotFound;

  /// No description provided for @errorLoadingWarehouses.
  ///
  /// In en, this message translates to:
  /// **'Error loading warehouses'**
  String get errorLoadingWarehouses;

  /// No description provided for @searchByOrderNumberOrCustomer.
  ///
  /// In en, this message translates to:
  /// **'Search by order number or customer...'**
  String get searchByOrderNumberOrCustomer;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draft;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @noOrdersFound.
  ///
  /// In en, this message translates to:
  /// **'No orders found'**
  String get noOrdersFound;

  /// No description provided for @errorLoadingOrders.
  ///
  /// In en, this message translates to:
  /// **'Error loading orders'**
  String get errorLoadingOrders;

  /// No description provided for @orderMovedToProcessing.
  ///
  /// In en, this message translates to:
  /// **'Order moved to processing'**
  String get orderMovedToProcessing;

  /// No description provided for @errorProcessingOrder.
  ///
  /// In en, this message translates to:
  /// **'Error processing order'**
  String get errorProcessingOrder;

  /// No description provided for @enterTrackingNumberOptional.
  ///
  /// In en, this message translates to:
  /// **'Enter tracking number (optional):'**
  String get enterTrackingNumberOptional;

  /// No description provided for @ship.
  ///
  /// In en, this message translates to:
  /// **'Ship'**
  String get ship;

  /// No description provided for @orderShippedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Order shipped successfully'**
  String get orderShippedSuccessfully;

  /// No description provided for @errorShippingOrder.
  ///
  /// In en, this message translates to:
  /// **'Error shipping order'**
  String get errorShippingOrder;

  /// No description provided for @orderInformation.
  ///
  /// In en, this message translates to:
  /// **'Order Information'**
  String get orderInformation;

  /// No description provided for @totalItems.
  ///
  /// In en, this message translates to:
  /// **'Total Items'**
  String get totalItems;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @paidAmount.
  ///
  /// In en, this message translates to:
  /// **'Paid Amount'**
  String get paidAmount;

  /// No description provided for @customerInformation.
  ///
  /// In en, this message translates to:
  /// **'Customer Information'**
  String get customerInformation;

  /// No description provided for @customerId.
  ///
  /// In en, this message translates to:
  /// **'Customer ID'**
  String get customerId;

  /// No description provided for @deliveryInformation.
  ///
  /// In en, this message translates to:
  /// **'Delivery Information'**
  String get deliveryInformation;

  /// No description provided for @deliveryType.
  ///
  /// In en, this message translates to:
  /// **'Delivery Type'**
  String get deliveryType;

  /// No description provided for @deliveryStatus.
  ///
  /// In en, this message translates to:
  /// **'Delivery Status'**
  String get deliveryStatus;

  /// No description provided for @deliveryPrice.
  ///
  /// In en, this message translates to:
  /// **'Delivery Price'**
  String get deliveryPrice;

  /// No description provided for @receiver.
  ///
  /// In en, this message translates to:
  /// **'Receiver'**
  String get receiver;

  /// No description provided for @receiverPhone.
  ///
  /// In en, this message translates to:
  /// **'Receiver Phone'**
  String get receiverPhone;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Summary'**
  String get orderSummary;

  /// No description provided for @details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// No description provided for @noItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No items found'**
  String get noItemsFound;

  /// No description provided for @debugOrder.
  ///
  /// In en, this message translates to:
  /// **'Debug Order'**
  String get debugOrder;

  /// No description provided for @unitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get unitPrice;

  /// No description provided for @noHistoryAvailable.
  ///
  /// In en, this message translates to:
  /// **'No history available'**
  String get noHistoryAvailable;

  /// No description provided for @changedBy.
  ///
  /// In en, this message translates to:
  /// **'Changed by'**
  String get changedBy;

  /// No description provided for @tracking.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get tracking;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @errorRefreshingOrder.
  ///
  /// In en, this message translates to:
  /// **'Error refreshing order'**
  String get errorRefreshingOrder;

  /// No description provided for @errorLoadingOrderHistory.
  ///
  /// In en, this message translates to:
  /// **'Error loading order history'**
  String get errorLoadingOrderHistory;

  /// No description provided for @orderOperations.
  ///
  /// In en, this message translates to:
  /// **'Order Operations'**
  String get orderOperations;

  /// No description provided for @acceptAndConfirmOrder.
  ///
  /// In en, this message translates to:
  /// **'Accept and confirm this order'**
  String get acceptAndConfirmOrder;

  /// No description provided for @moveToProcessing.
  ///
  /// In en, this message translates to:
  /// **'Move order to processing status'**
  String get moveToProcessing;

  /// No description provided for @markAsReady.
  ///
  /// In en, this message translates to:
  /// **'Mark as Ready'**
  String get markAsReady;

  /// No description provided for @markOrderReadyForShipping.
  ///
  /// In en, this message translates to:
  /// **'Mark order as ready for shipping'**
  String get markOrderReadyForShipping;

  /// No description provided for @shipOrderWithTracking.
  ///
  /// In en, this message translates to:
  /// **'Ship order with tracking information'**
  String get shipOrderWithTracking;

  /// No description provided for @markAsDelivered.
  ///
  /// In en, this message translates to:
  /// **'Mark as Delivered'**
  String get markAsDelivered;

  /// No description provided for @markOrderAsDelivered.
  ///
  /// In en, this message translates to:
  /// **'Mark order as delivered'**
  String get markOrderAsDelivered;

  /// No description provided for @cancelOrderWithReason.
  ///
  /// In en, this message translates to:
  /// **'Cancel this order with reason'**
  String get cancelOrderWithReason;

  /// No description provided for @processReturnForOrder.
  ///
  /// In en, this message translates to:
  /// **'Process return for this order'**
  String get processReturnForOrder;

  /// No description provided for @noOperationsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No operations available for this order'**
  String get noOperationsAvailable;

  /// No description provided for @addConfirmationNotesOptional.
  ///
  /// In en, this message translates to:
  /// **'Add confirmation notes (optional):'**
  String get addConfirmationNotesOptional;

  /// No description provided for @addProcessingNotesOptional.
  ///
  /// In en, this message translates to:
  /// **'Add processing notes (optional):'**
  String get addProcessingNotesOptional;

  /// No description provided for @addShippingNotes.
  ///
  /// In en, this message translates to:
  /// **'Add shipping notes'**
  String get addShippingNotes;

  /// No description provided for @addDeliveryNotesOptional.
  ///
  /// In en, this message translates to:
  /// **'Add delivery notes (optional):'**
  String get addDeliveryNotesOptional;

  /// No description provided for @customerRequest.
  ///
  /// In en, this message translates to:
  /// **'Customer Request'**
  String get customerRequest;

  /// No description provided for @paymentIssues.
  ///
  /// In en, this message translates to:
  /// **'Payment Issues'**
  String get paymentIssues;

  /// No description provided for @addressIssues.
  ///
  /// In en, this message translates to:
  /// **'Address Issues'**
  String get addressIssues;

  /// No description provided for @systemError.
  ///
  /// In en, this message translates to:
  /// **'System Error'**
  String get systemError;

  /// No description provided for @duplicateOrder.
  ///
  /// In en, this message translates to:
  /// **'Duplicate Order'**
  String get duplicateOrder;

  /// No description provided for @qualityConcerns.
  ///
  /// In en, this message translates to:
  /// **'Quality Concerns'**
  String get qualityConcerns;

  /// No description provided for @additionalNotes.
  ///
  /// In en, this message translates to:
  /// **'Additional Notes'**
  String get additionalNotes;

  /// No description provided for @addCancellationDetails.
  ///
  /// In en, this message translates to:
  /// **'Add cancellation details'**
  String get addCancellationDetails;

  /// No description provided for @returnReason.
  ///
  /// In en, this message translates to:
  /// **'Return Reason'**
  String get returnReason;

  /// No description provided for @defectiveProduct.
  ///
  /// In en, this message translates to:
  /// **'Defective Product'**
  String get defectiveProduct;

  /// No description provided for @wrongItemSent.
  ///
  /// In en, this message translates to:
  /// **'Wrong Item Sent'**
  String get wrongItemSent;

  /// No description provided for @customerDissatisfaction.
  ///
  /// In en, this message translates to:
  /// **'Customer Dissatisfaction'**
  String get customerDissatisfaction;

  /// No description provided for @sizeFitIssues.
  ///
  /// In en, this message translates to:
  /// **'Size/Fit Issues'**
  String get sizeFitIssues;

  /// No description provided for @damagedDuringShipping.
  ///
  /// In en, this message translates to:
  /// **'Damaged During Shipping'**
  String get damagedDuringShipping;

  /// No description provided for @changedMind.
  ///
  /// In en, this message translates to:
  /// **'Changed Mind'**
  String get changedMind;

  /// No description provided for @qualityIssues.
  ///
  /// In en, this message translates to:
  /// **'Quality Issues'**
  String get qualityIssues;

  /// No description provided for @returnDetails.
  ///
  /// In en, this message translates to:
  /// **'Return Details'**
  String get returnDetails;

  /// No description provided for @addReturnProcessingDetails.
  ///
  /// In en, this message translates to:
  /// **'Add return processing details'**
  String get addReturnProcessingDetails;

  /// No description provided for @operationCompletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Operation completed successfully'**
  String get operationCompletedSuccessfully;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @errorLoadingTaskDetails.
  ///
  /// In en, this message translates to:
  /// **'Error loading task details'**
  String get errorLoadingTaskDetails;

  /// No description provided for @comments.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get comments;

  /// No description provided for @attachments.
  ///
  /// In en, this message translates to:
  /// **'Attachments'**
  String get attachments;

  /// No description provided for @taskInformation.
  ///
  /// In en, this message translates to:
  /// **'Task Information'**
  String get taskInformation;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @notAvailable.
  ///
  /// In en, this message translates to:
  /// **'Not available'**
  String get notAvailable;

  /// No description provided for @estimatedHours.
  ///
  /// In en, this message translates to:
  /// **'Estimated Hours'**
  String get estimatedHours;

  /// No description provided for @actualHours.
  ///
  /// In en, this message translates to:
  /// **'Actual Hours'**
  String get actualHours;

  /// No description provided for @assignment.
  ///
  /// In en, this message translates to:
  /// **'Assignment'**
  String get assignment;

  /// No description provided for @assignedUser.
  ///
  /// In en, this message translates to:
  /// **'Assigned User'**
  String get assignedUser;

  /// No description provided for @assignedRole.
  ///
  /// In en, this message translates to:
  /// **'Assigned Role'**
  String get assignedRole;

  /// No description provided for @notAssigned.
  ///
  /// In en, this message translates to:
  /// **'Not assigned'**
  String get notAssigned;

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get timeline;

  /// No description provided for @plannedStart.
  ///
  /// In en, this message translates to:
  /// **'Planned Start'**
  String get plannedStart;

  /// No description provided for @plannedEnd.
  ///
  /// In en, this message translates to:
  /// **'Planned End'**
  String get plannedEnd;

  /// No description provided for @actualStart.
  ///
  /// In en, this message translates to:
  /// **'Actual Start'**
  String get actualStart;

  /// No description provided for @actualEnd.
  ///
  /// In en, this message translates to:
  /// **'Actual End'**
  String get actualEnd;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @updated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get updated;

  /// No description provided for @taskActions.
  ///
  /// In en, this message translates to:
  /// **'Task Actions'**
  String get taskActions;

  /// No description provided for @startTask.
  ///
  /// In en, this message translates to:
  /// **'Start Task'**
  String get startTask;

  /// No description provided for @updateProgress.
  ///
  /// In en, this message translates to:
  /// **'Update Progress'**
  String get updateProgress;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get complete;

  /// No description provided for @cancelTask.
  ///
  /// In en, this message translates to:
  /// **'Cancel Task'**
  String get cancelTask;

  /// No description provided for @taskCompleted.
  ///
  /// In en, this message translates to:
  /// **'Task Completed'**
  String get taskCompleted;

  /// No description provided for @taskCancelled.
  ///
  /// In en, this message translates to:
  /// **'Task Cancelled'**
  String get taskCancelled;

  /// No description provided for @taskStartedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Task started successfully'**
  String get taskStartedSuccessfully;

  /// No description provided for @errorStartingTask.
  ///
  /// In en, this message translates to:
  /// **'Error starting task'**
  String get errorStartingTask;

  /// No description provided for @completeTask.
  ///
  /// In en, this message translates to:
  /// **'Complete Task'**
  String get completeTask;

  /// No description provided for @areYouSureCompleteTask.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to mark this task as completed?'**
  String get areYouSureCompleteTask;

  /// No description provided for @actualHoursOptional.
  ///
  /// In en, this message translates to:
  /// **'Actual Hours (optional)'**
  String get actualHoursOptional;

  /// No description provided for @completionNotesOptional.
  ///
  /// In en, this message translates to:
  /// **'Completion Notes (optional)'**
  String get completionNotesOptional;

  /// No description provided for @taskCompletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Task completed successfully'**
  String get taskCompletedSuccessfully;

  /// No description provided for @errorCompletingTask.
  ///
  /// In en, this message translates to:
  /// **'Error completing task'**
  String get errorCompletingTask;

  /// No description provided for @cancelTaskConfirm.
  ///
  /// In en, this message translates to:
  /// **'Cancel Task'**
  String get cancelTaskConfirm;

  /// No description provided for @areYouSureCancelTask.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel this task? This action cannot be undone.'**
  String get areYouSureCancelTask;

  /// No description provided for @pleaseProvideCancellationReason.
  ///
  /// In en, this message translates to:
  /// **'Please provide a cancellation reason'**
  String get pleaseProvideCancellationReason;

  /// No description provided for @taskCancelledSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Task cancelled successfully'**
  String get taskCancelledSuccessfully;

  /// No description provided for @errorCancellingTask.
  ///
  /// In en, this message translates to:
  /// **'Error cancelling task'**
  String get errorCancellingTask;

  /// No description provided for @progressPercentage.
  ///
  /// In en, this message translates to:
  /// **'Progress Percentage (0-100)'**
  String get progressPercentage;

  /// No description provided for @progressNotesOptional.
  ///
  /// In en, this message translates to:
  /// **'Progress Notes (optional)'**
  String get progressNotesOptional;

  /// No description provided for @pleaseEnterValidProgress.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid progress percentage (0-100)'**
  String get pleaseEnterValidProgress;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @progressUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Progress updated successfully'**
  String get progressUpdatedSuccessfully;

  /// No description provided for @errorUpdatingProgress.
  ///
  /// In en, this message translates to:
  /// **'Error updating progress'**
  String get errorUpdatingProgress;

  /// No description provided for @noCommentsYet.
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get noCommentsYet;

  /// No description provided for @noAttachments.
  ///
  /// In en, this message translates to:
  /// **'No attachments'**
  String get noAttachments;

  /// No description provided for @internal.
  ///
  /// In en, this message translates to:
  /// **'Internal'**
  String get internal;

  /// No description provided for @uploadedBy.
  ///
  /// In en, this message translates to:
  /// **'Uploaded by'**
  String get uploadedBy;

  /// No description provided for @fileDownloadNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'File download not implemented yet'**
  String get fileDownloadNotImplemented;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @taskIsOverdue.
  ///
  /// In en, this message translates to:
  /// **'Task is overdue'**
  String get taskIsOverdue;

  /// No description provided for @lowStockProducts.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Products'**
  String get lowStockProducts;

  /// No description provided for @searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get searchProducts;

  /// No description provided for @allCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get allCategories;

  /// No description provided for @noLowStockProductsFound.
  ///
  /// In en, this message translates to:
  /// **'No low stock products found'**
  String get noLowStockProductsFound;

  /// No description provided for @addFirstProduct.
  ///
  /// In en, this message translates to:
  /// **'Add First Product'**
  String get addFirstProduct;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data'**
  String get errorLoadingData;

  /// No description provided for @basicInformation.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInformation;

  /// No description provided for @descriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Description is required'**
  String get descriptionRequired;

  /// No description provided for @skuRequired.
  ///
  /// In en, this message translates to:
  /// **'SKU is required'**
  String get skuRequired;

  /// No description provided for @unitRequired.
  ///
  /// In en, this message translates to:
  /// **'Unit is required'**
  String get unitRequired;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get selectCategory;

  /// No description provided for @pricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get pricing;

  /// No description provided for @unitPriceLabel.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get unitPriceLabel;

  /// No description provided for @priceRequired.
  ///
  /// In en, this message translates to:
  /// **'Price is required'**
  String get priceRequired;

  /// No description provided for @pleaseEnterValidPrice.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price'**
  String get pleaseEnterValidPrice;

  /// No description provided for @stockInformation.
  ///
  /// In en, this message translates to:
  /// **'Stock Information'**
  String get stockInformation;

  /// No description provided for @initialStock.
  ///
  /// In en, this message translates to:
  /// **'Initial Stock'**
  String get initialStock;

  /// No description provided for @stockQuantityRequired.
  ///
  /// In en, this message translates to:
  /// **'Stock quantity is required'**
  String get stockQuantityRequired;

  /// No description provided for @pleaseEnterValidQuantity.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid quantity'**
  String get pleaseEnterValidQuantity;

  /// No description provided for @minimumStockRequired.
  ///
  /// In en, this message translates to:
  /// **'Minimum stock is required'**
  String get minimumStockRequired;

  /// No description provided for @pleaseEnterValidMinimumStock.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid minimum stock'**
  String get pleaseEnterValidMinimumStock;

  /// No description provided for @minimumStockAlertInfo.
  ///
  /// In en, this message translates to:
  /// **'Minimum stock level is used to trigger low stock alerts'**
  String get minimumStockAlertInfo;

  /// No description provided for @creatingProduct.
  ///
  /// In en, this message translates to:
  /// **'Creating Product...'**
  String get creatingProduct;

  /// No description provided for @createProduct.
  ///
  /// In en, this message translates to:
  /// **'Create Product'**
  String get createProduct;

  /// No description provided for @productCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product created successfully'**
  String get productCreatedSuccessfully;

  /// No description provided for @errorCreatingProduct.
  ///
  /// In en, this message translates to:
  /// **'Error creating product'**
  String get errorCreatingProduct;

  /// No description provided for @errorLoadingCategories.
  ///
  /// In en, this message translates to:
  /// **'Error loading categories'**
  String get errorLoadingCategories;

  /// No description provided for @searchWarehouses.
  ///
  /// In en, this message translates to:
  /// **'Search warehouses...'**
  String get searchWarehouses;

  /// No description provided for @noWarehousesMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No warehouses match your search'**
  String get noWarehousesMatchSearch;

  /// No description provided for @managerLabel.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get managerLabel;

  /// No description provided for @rawMaterials.
  ///
  /// In en, this message translates to:
  /// **'Raw Materials'**
  String get rawMaterials;

  /// No description provided for @searchStockItems.
  ///
  /// In en, this message translates to:
  /// **'Search stock items...'**
  String get searchStockItems;

  /// No description provided for @noStockItemsFound.
  ///
  /// In en, this message translates to:
  /// **'No stock items found'**
  String get noStockItemsFound;

  /// No description provided for @noStockItemsMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No stock items match your search'**
  String get noStockItemsMatchSearch;

  /// No description provided for @searchRawMaterials.
  ///
  /// In en, this message translates to:
  /// **'Search raw materials...'**
  String get searchRawMaterials;

  /// No description provided for @noRawMaterialsFound.
  ///
  /// In en, this message translates to:
  /// **'No raw materials found'**
  String get noRawMaterialsFound;

  /// No description provided for @noRawMaterialsMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No raw materials match your search'**
  String get noRawMaterialsMatchSearch;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @reserved.
  ///
  /// In en, this message translates to:
  /// **'Reserved'**
  String get reserved;

  /// No description provided for @expires.
  ///
  /// In en, this message translates to:
  /// **'Expires'**
  String get expires;

  /// No description provided for @supplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get supplier;

  /// No description provided for @adjust.
  ///
  /// In en, this message translates to:
  /// **'Adjust'**
  String get adjust;

  /// No description provided for @reserve.
  ///
  /// In en, this message translates to:
  /// **'Reserve'**
  String get reserve;

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @stockOperations.
  ///
  /// In en, this message translates to:
  /// **'Stock Operations'**
  String get stockOperations;

  /// No description provided for @rawMaterialOperations.
  ///
  /// In en, this message translates to:
  /// **'Raw Material Operations'**
  String get rawMaterialOperations;

  /// No description provided for @errorLoadingStockItems.
  ///
  /// In en, this message translates to:
  /// **'Error loading stock items'**
  String get errorLoadingStockItems;

  /// No description provided for @errorLoadingRawMaterials.
  ///
  /// In en, this message translates to:
  /// **'Error loading raw materials'**
  String get errorLoadingRawMaterials;

  /// No description provided for @myTasks.
  ///
  /// In en, this message translates to:
  /// **'My Tasks'**
  String get myTasks;

  /// No description provided for @searchTasks.
  ///
  /// In en, this message translates to:
  /// **'Search tasks...'**
  String get searchTasks;

  /// No description provided for @noTasksFound.
  ///
  /// In en, this message translates to:
  /// **'No tasks found'**
  String get noTasksFound;

  /// No description provided for @tryAdjustingFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters'**
  String get tryAdjustingFilters;

  /// No description provided for @showAll.
  ///
  /// In en, this message translates to:
  /// **'Show All'**
  String get showAll;

  /// No description provided for @assignToMe.
  ///
  /// In en, this message translates to:
  /// **'Assign to Me'**
  String get assignToMe;

  /// No description provided for @returnTask.
  ///
  /// In en, this message translates to:
  /// **'Return Task'**
  String get returnTask;

  /// No description provided for @reassign.
  ///
  /// In en, this message translates to:
  /// **'Reassign'**
  String get reassign;

  /// No description provided for @startProgress.
  ///
  /// In en, this message translates to:
  /// **'Start Progress'**
  String get startProgress;

  /// No description provided for @changeDueDate.
  ///
  /// In en, this message translates to:
  /// **'Change Due Date'**
  String get changeDueDate;

  /// No description provided for @changeProgress.
  ///
  /// In en, this message translates to:
  /// **'Change Progress'**
  String get changeProgress;

  /// No description provided for @statusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Status updated successfully'**
  String get statusUpdated;

  /// No description provided for @dueDateUpdated.
  ///
  /// In en, this message translates to:
  /// **'Due date updated successfully'**
  String get dueDateUpdated;

  /// No description provided for @invalidProgressValue.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid progress value (0-100)'**
  String get invalidProgressValue;

  /// No description provided for @taskAssignedToYou.
  ///
  /// In en, this message translates to:
  /// **'Task assigned to you'**
  String get taskAssignedToYou;

  /// No description provided for @errorAssigningTask.
  ///
  /// In en, this message translates to:
  /// **'Error assigning task'**
  String get errorAssigningTask;

  /// No description provided for @areYouSureReturnTask.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to return this task?'**
  String get areYouSureReturnTask;

  /// No description provided for @taskReturned.
  ///
  /// In en, this message translates to:
  /// **'Task returned successfully'**
  String get taskReturned;

  /// No description provided for @errorReturningTask.
  ///
  /// In en, this message translates to:
  /// **'Error returning task'**
  String get errorReturningTask;

  /// No description provided for @reassignTask.
  ///
  /// In en, this message translates to:
  /// **'Reassign Task'**
  String get reassignTask;

  /// No description provided for @enterUserIdToReassign.
  ///
  /// In en, this message translates to:
  /// **'Enter user ID to reassign task'**
  String get enterUserIdToReassign;

  /// No description provided for @userId.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get userId;

  /// No description provided for @enterUserId.
  ///
  /// In en, this message translates to:
  /// **'Enter user ID'**
  String get enterUserId;

  /// No description provided for @pleaseEnterUserId.
  ///
  /// In en, this message translates to:
  /// **'Please enter a user ID'**
  String get pleaseEnterUserId;

  /// No description provided for @taskReassigned.
  ///
  /// In en, this message translates to:
  /// **'Task reassigned successfully'**
  String get taskReassigned;

  /// No description provided for @errorReassigningTask.
  ///
  /// In en, this message translates to:
  /// **'Error reassigning task'**
  String get errorReassigningTask;

  /// No description provided for @addComment.
  ///
  /// In en, this message translates to:
  /// **'Add Comment'**
  String get addComment;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;

  /// No description provided for @writeComment.
  ///
  /// In en, this message translates to:
  /// **'Write a comment...'**
  String get writeComment;

  /// No description provided for @enterYourComment.
  ///
  /// In en, this message translates to:
  /// **'Enter your comment'**
  String get enterYourComment;

  /// No description provided for @internalComment.
  ///
  /// In en, this message translates to:
  /// **'Internal Comment'**
  String get internalComment;

  /// No description provided for @internalCommentDescription.
  ///
  /// In en, this message translates to:
  /// **'Only visible to internal team members'**
  String get internalCommentDescription;

  /// No description provided for @pleaseEnterComment.
  ///
  /// In en, this message translates to:
  /// **'Please enter a comment'**
  String get pleaseEnterComment;

  /// No description provided for @commentAdded.
  ///
  /// In en, this message translates to:
  /// **'Comment added successfully'**
  String get commentAdded;

  /// No description provided for @errorAddingComment.
  ///
  /// In en, this message translates to:
  /// **'Error adding comment'**
  String get errorAddingComment;

  /// No description provided for @addAttachment.
  ///
  /// In en, this message translates to:
  /// **'Add Attachment'**
  String get addAttachment;

  /// No description provided for @attachmentFeatureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Attachment feature coming soon'**
  String get attachmentFeatureComingSoon;

  /// No description provided for @typeMessage.
  ///
  /// In en, this message translates to:
  /// **'Type a message...'**
  String get typeMessage;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get sendMessage;

  /// No description provided for @startConversation.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation below'**
  String get startConversation;

  /// No description provided for @noUsersFound.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get noUsersFound;

  /// No description provided for @selectUserToReassign.
  ///
  /// In en, this message translates to:
  /// **'Select a user to reassign this task'**
  String get selectUserToReassign;

  /// No description provided for @selectUser.
  ///
  /// In en, this message translates to:
  /// **'Select User'**
  String get selectUser;

  /// No description provided for @pleaseSelectUser.
  ///
  /// In en, this message translates to:
  /// **'Please select a user'**
  String get pleaseSelectUser;

  /// No description provided for @selectFile.
  ///
  /// In en, this message translates to:
  /// **'Select File'**
  String get selectFile;

  /// No description provided for @fileDescription.
  ///
  /// In en, this message translates to:
  /// **'File Description (optional)'**
  String get fileDescription;

  /// No description provided for @enterFileDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter file description'**
  String get enterFileDescription;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @fileSelected.
  ///
  /// In en, this message translates to:
  /// **'File selected'**
  String get fileSelected;

  /// No description provided for @noFileSelected.
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get noFileSelected;

  /// No description provided for @uploadingFile.
  ///
  /// In en, this message translates to:
  /// **'Uploading file...'**
  String get uploadingFile;

  /// No description provided for @fileUploadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'File uploaded successfully'**
  String get fileUploadedSuccessfully;

  /// No description provided for @errorUploadingFile.
  ///
  /// In en, this message translates to:
  /// **'Error uploading file'**
  String get errorUploadingFile;

  /// No description provided for @downloadingFile.
  ///
  /// In en, this message translates to:
  /// **'Downloading file...'**
  String get downloadingFile;

  /// No description provided for @fileDownloadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'File downloaded successfully'**
  String get fileDownloadedSuccessfully;

  /// No description provided for @errorDownloadingFile.
  ///
  /// In en, this message translates to:
  /// **'Error downloading file'**
  String get errorDownloadingFile;

  /// No description provided for @pleaseSelectFile.
  ///
  /// In en, this message translates to:
  /// **'Please select a file to upload'**
  String get pleaseSelectFile;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @errorOpeningFile.
  ///
  /// In en, this message translates to:
  /// **'Error opening file'**
  String get errorOpeningFile;

  /// No description provided for @companyTasks.
  ///
  /// In en, this message translates to:
  /// **'Company Tasks'**
  String get companyTasks;

  /// No description provided for @filters.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get clearAll;

  /// No description provided for @showOverdueOnly.
  ///
  /// In en, this message translates to:
  /// **'Show Overdue Only'**
  String get showOverdueOnly;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply Filters'**
  String get applyFilters;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort By'**
  String get sortBy;

  /// No description provided for @createdDate.
  ///
  /// In en, this message translates to:
  /// **'Created Date'**
  String get createdDate;

  /// No description provided for @descending.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get descending;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @myResults.
  ///
  /// In en, this message translates to:
  /// **'My Results'**
  String get myResults;

  /// No description provided for @viewYourPerformance.
  ///
  /// In en, this message translates to:
  /// **'View your performance'**
  String get viewYourPerformance;

  /// No description provided for @finances.
  ///
  /// In en, this message translates to:
  /// **'Finances'**
  String get finances;

  /// No description provided for @manageYourFinances.
  ///
  /// In en, this message translates to:
  /// **'Manage your finances'**
  String get manageYourFinances;

  /// No description provided for @appPreferences.
  ///
  /// In en, this message translates to:
  /// **'App preferences'**
  String get appPreferences;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @getHelpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Get help and support'**
  String get getHelpAndSupport;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @messageAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Message and support'**
  String get messageAndSupport;

  /// No description provided for @user.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @viewCompanyTasks.
  ///
  /// In en, this message translates to:
  /// **'View Company Tasks'**
  String get viewCompanyTasks;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not Set'**
  String get notSet;

  /// No description provided for @assignee.
  ///
  /// In en, this message translates to:
  /// **'Assignee'**
  String get assignee;

  /// No description provided for @unassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get unassigned;

  /// No description provided for @editTask.
  ///
  /// In en, this message translates to:
  /// **'Edit Task'**
  String get editTask;

  /// No description provided for @markAsComplete.
  ///
  /// In en, this message translates to:
  /// **'Mark as Complete'**
  String get markAsComplete;

  /// No description provided for @uploadFile.
  ///
  /// In en, this message translates to:
  /// **'Upload File'**
  String get uploadFile;

  /// No description provided for @progressUpdated.
  ///
  /// In en, this message translates to:
  /// **'Progress updated successfully'**
  String get progressUpdated;

  /// No description provided for @reason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get reason;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
