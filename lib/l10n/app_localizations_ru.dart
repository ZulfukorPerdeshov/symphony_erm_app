// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Symphony ERP';

  @override
  String get loading => 'Загрузка...';

  @override
  String get retry => 'Повторить';

  @override
  String get cancel => 'Отмена';

  @override
  String get save => 'Сохранить';

  @override
  String get delete => 'Удалить';

  @override
  String get edit => 'Редактировать';

  @override
  String get add => 'Добавить';

  @override
  String get search => 'Поиск';

  @override
  String get filter => 'Фильтр';

  @override
  String get refresh => 'Обновить';

  @override
  String get ok => 'ОК';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get close => 'Закрыть';

  @override
  String get login => 'Войти';

  @override
  String get logout => 'Выйти';

  @override
  String get email => 'Электронная почта';

  @override
  String get password => 'Пароль';

  @override
  String get forgotPassword => 'Забыли пароль?';

  @override
  String get loginError => 'Ошибка входа. Проверьте ваши данные.';

  @override
  String get logoutConfirm => 'Вы уверены, что хотите выйти?';

  @override
  String get emailRequired => 'Электронная почта обязательна';

  @override
  String get passwordRequired => 'Пароль обязателен';

  @override
  String get invalidEmail => 'Введите действительный адрес электронной почты';

  @override
  String get passwordTooShort => 'Пароль должен содержать не менее 6 символов';

  @override
  String get home => 'Главная';

  @override
  String get warehouse => 'Склад';

  @override
  String get orders => 'Заказы';

  @override
  String get production => 'Производство';

  @override
  String get tasks => 'Задачи';

  @override
  String get profile => 'Профиль';

  @override
  String get notifications => 'Уведомления';

  @override
  String get analytics => 'Аналитика';

  @override
  String get settings => 'Настройки';

  @override
  String get networkError => 'Ошибка сети. Проверьте подключение к интернету.';

  @override
  String get serverError => 'Ошибка сервера. Попробуйте позже.';

  @override
  String get unknownError => 'Произошла неизвестная ошибка.';

  @override
  String get unauthorizedError => 'Сессия истекла. Войдите снова.';

  @override
  String get inventory => 'Инвентарь';

  @override
  String get stockItems => 'Товары на складе';

  @override
  String get stockLevel => 'Уровень запасов';

  @override
  String get lowStock => 'Низкий запас';

  @override
  String get outOfStock => 'Нет в наличии';

  @override
  String get inStock => 'В наличии';

  @override
  String get addProduct => 'Добавить товар';

  @override
  String get editProduct => 'Редактировать товар';

  @override
  String get productName => 'Название товара';

  @override
  String get productNameRequired => 'Название товара обязательно';

  @override
  String get productDescription => 'Описание товара';

  @override
  String get productSKU => 'Артикул';

  @override
  String get productCategory => 'Категория';

  @override
  String get productPrice => 'Цена';

  @override
  String get quantity => 'Количество';

  @override
  String get minimumStock => 'Минимальный уровень запасов';

  @override
  String get unit => 'Единица измерения';

  @override
  String get stockAdjustment => 'Корректировка запасов';

  @override
  String get adjustmentReason => 'Причина корректировки';

  @override
  String get notes => 'Примечания';

  @override
  String get orderNumber => 'Номер заказа';

  @override
  String get customer => 'Клиент';

  @override
  String get orderDate => 'Дата заказа';

  @override
  String get totalAmount => 'Общая сумма';

  @override
  String get orderStatus => 'Статус заказа';

  @override
  String get shippingAddress => 'Адрес доставки';

  @override
  String get orderItems => 'Товары в заказе';

  @override
  String get confirmOrder => 'Подтвердить заказ';

  @override
  String get processOrder => 'Обработать заказ';

  @override
  String get shipOrder => 'Отправить заказ';

  @override
  String get cancelOrder => 'Отменить заказ';

  @override
  String get trackingNumber => 'Номер отслеживания';

  @override
  String get productionOrder => 'Производственный заказ';

  @override
  String get productionStage => 'Стадия производства';

  @override
  String get productionTask => 'Производственная задача';

  @override
  String get startProduction => 'Начать производство';

  @override
  String get completeProduction => 'Завершить производство';

  @override
  String get productionStatus => 'Статус производства';

  @override
  String get dueDate => 'Срок выполнения';

  @override
  String get assignedTo => 'Назначено';

  @override
  String get progress => 'Прогресс';

  @override
  String get requirements => 'Требования';

  @override
  String get pending => 'Ожидание';

  @override
  String get confirmed => 'Подтверждено';

  @override
  String get processing => 'Обработка...';

  @override
  String get ready => 'Готово';

  @override
  String get shipped => 'Отправлено';

  @override
  String get delivered => 'Доставлено';

  @override
  String get cancelled => 'Отменено';

  @override
  String get returned => 'Возвращено';

  @override
  String get inProgress => 'В процессе';

  @override
  String get completed => 'Завершено';

  @override
  String get onHold => 'Приостановлено';

  @override
  String get notStarted => 'Не начато';

  @override
  String get priority => 'Приоритет';

  @override
  String get low => 'Низкий';

  @override
  String get medium => 'Средний';

  @override
  String get high => 'Высокий';

  @override
  String get urgent => 'Срочный';

  @override
  String get plannedPeriod => 'Плановый период';

  @override
  String get actualPeriod => 'Фактический период';

  @override
  String get product => 'Продукт';

  @override
  String get productionBatch => 'Производственная партия';

  @override
  String get units => 'шт';

  @override
  String get selectedCompany => 'Выбранная компания';

  @override
  String get firstName => 'Имя';

  @override
  String get lastName => 'Фамилия';

  @override
  String get fullName => 'Полное имя';

  @override
  String get phoneNumber => 'Номер телефона';

  @override
  String get address => 'Адрес';

  @override
  String get city => 'Город';

  @override
  String get state => 'Регион';

  @override
  String get zipCode => 'Почтовый индекс';

  @override
  String get country => 'Страна';

  @override
  String get changePassword => 'Изменить пароль';

  @override
  String get currentPassword => 'Текущий пароль';

  @override
  String get newPassword => 'Новый пароль';

  @override
  String get confirmPassword => 'Подтвердите пароль';

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get passwordChangedSuccessfully => 'Пароль успешно изменен';

  @override
  String get updateProfile => 'Обновить профиль';

  @override
  String get uploadAvatar => 'Загрузить аватар';

  @override
  String get removeAvatar => 'Удалить аватар';

  @override
  String get profileUpdatedSuccessfully => 'Профиль успешно обновлен';

  @override
  String get markAsRead => 'Отметить как прочитанное';

  @override
  String get markAllAsRead => 'Отметить все как прочитанные';

  @override
  String get deleteNotification => 'Удалить уведомление';

  @override
  String get clearAllNotifications => 'Очистить все уведомления';

  @override
  String get notificationPreferences => 'Настройки уведомлений';

  @override
  String get language => 'Язык';

  @override
  String get theme => 'Тема';

  @override
  String get lightTheme => 'Светлая';

  @override
  String get darkTheme => 'Темная';

  @override
  String get systemTheme => 'Системная';

  @override
  String get todayTasks => 'Задачи на сегодня';

  @override
  String get ongoingTasks => 'Текущие задачи';

  @override
  String get taskOverview => 'Обзор задач';

  @override
  String get totalTasks => 'Всего задач';

  @override
  String get totalDue => 'Всего к выполнению';

  @override
  String get uniqueTasks => 'Уникальные задачи';

  @override
  String get monthlyView => 'За месяц';

  @override
  String get weeklyView => 'За неделю';

  @override
  String get dailyView => 'За день';

  @override
  String get allActivitiesInOnePlace => 'Все ваши активности в одном месте';

  @override
  String get theHomeScreenGivesUsers =>
      'Главный экран дает пользователям четкий, быстрый обзор их дня. Он отображает высокоприоритетные задачи, предстоящие дедлайны и недавнюю активность команды';

  @override
  String get hello => 'Привет';

  @override
  String get welcome => 'Добро пожаловать';

  @override
  String get goodMorning => 'Доброе утро';

  @override
  String get goodAfternoon => 'Добрый день';

  @override
  String get goodEvening => 'Добрый вечер';

  @override
  String get dataLoadedSuccessfully => 'Данные успешно загружены';

  @override
  String get noDataAvailable => 'Нет доступных данных';

  @override
  String get pullToRefresh => 'Потяните для обновления';

  @override
  String get loadMore => 'Загрузить еще';

  @override
  String get warehouses => 'Склады';

  @override
  String get warehousesList => 'Список складов';

  @override
  String get warehouseDetails => 'Детали склада';

  @override
  String get warehouseName => 'Название склада';

  @override
  String get warehouseCode => 'Код склада';

  @override
  String get warehouseType => 'Тип склада';

  @override
  String get location => 'Местоположение';

  @override
  String get capacity => 'Вместимость';

  @override
  String get currentOccupancy => 'Текущая заполненность';

  @override
  String get manager => 'Менеджер';

  @override
  String get status => 'Статус';

  @override
  String get active => 'Активный';

  @override
  String get inactive => 'Неактивный';

  @override
  String get description => 'Описание';

  @override
  String get products => 'Товары';

  @override
  String get productList => 'Список товаров';

  @override
  String get productDetails => 'Детали товара';

  @override
  String get sku => 'Артикул';

  @override
  String get category => 'Категория';

  @override
  String get price => 'Цена';

  @override
  String get stock => 'Запас';

  @override
  String get stockQuantity => 'Количество запасов';

  @override
  String get currentStock => 'Текущий запас';

  @override
  String get minimumStockLevel => 'Минимальный уровень запасов';

  @override
  String get stockStatus => 'Статус запасов';

  @override
  String get stockTaking => 'Инвентаризация';

  @override
  String get stockTransfer => 'Перемещение запасов';

  @override
  String get stockTransferList => 'Список перемещений запасов';

  @override
  String get newCount => 'Новый подсчет';

  @override
  String get history => 'История';

  @override
  String get selectLocation => 'Выберите место';

  @override
  String get selectProduct => 'Выберите товар';

  @override
  String get chooseProduct => 'Выберите товар';

  @override
  String get chooseLocation => 'Выберите место';

  @override
  String get countProducts => 'Подсчет товаров';

  @override
  String get counted => 'Подсчитано';

  @override
  String get system => 'Система';

  @override
  String get discrepancies => 'Расхождения';

  @override
  String get noProductsFound => 'Товары для этого места не найдены';

  @override
  String get pleaseCountAtLeastOne => 'Подсчитайте хотя бы один товар';

  @override
  String get stockTakingCompleted => 'Инвентаризация успешно завершена';

  @override
  String get noStockTakingsFound => 'Инвентаризации не найдены';

  @override
  String get errorLoadingStockTakings => 'Ошибка загрузки инвентаризаций';

  @override
  String get submitStockCount => 'Отправить подсчет';

  @override
  String get quantityChange => 'Изменение количества';

  @override
  String get enterQuantity =>
      'Введите количество (+ для увеличения, - для уменьшения)';

  @override
  String get usePositiveNumbers =>
      'Используйте положительные числа для увеличения запасов, отрицательные для уменьшения';

  @override
  String get selectReason => 'Выберите причину корректировки';

  @override
  String get physicalCountCorrection => 'Корректировка физического подсчета';

  @override
  String get damagedGoods => 'Поврежденные товары';

  @override
  String get expiredProducts => 'Просроченные товары';

  @override
  String get theftLoss => 'Кража/Потеря';

  @override
  String get returnToSupplier => 'Возврат поставщику';

  @override
  String get qualityControlRejection => 'Отбраковка контролем качества';

  @override
  String get systemErrorCorrection => 'Исправление системной ошибки';

  @override
  String get other => 'Другое';

  @override
  String get notesOptional => 'Примечания (Необязательно)';

  @override
  String get addNotes => 'Добавьте дополнительные примечания или комментарии';

  @override
  String get adjustStock => 'Корректировать запас';

  @override
  String get stockAdjustmentCompleted =>
      'Корректировка запасов успешно завершена';

  @override
  String get errorAdjustingStock => 'Ошибка корректировки запасов';

  @override
  String get pleaseSelectProduct => 'Выберите товар';

  @override
  String get pleaseSelectReason => 'Выберите причину';

  @override
  String get pleaseEnterQuantity => 'Введите изменение количества';

  @override
  String get pleaseEnterValidNumber => 'Введите корректное число';

  @override
  String get quantityCannotBeZero =>
      'Изменение количества не может быть нулевым';

  @override
  String get cannotReduceBelowZero => 'Невозможно уменьшить запас ниже нуля';

  @override
  String get currentStockInformation => 'Информация о текущих запасах';

  @override
  String get current => 'Текущий';

  @override
  String get minimum => 'Минимум';

  @override
  String get errorLoadingProducts => 'Ошибка загрузки товаров';

  @override
  String get errorLoadingLocations => 'Ошибка загрузки мест';

  @override
  String get fromLocation => 'Откуда';

  @override
  String get toLocation => 'Куда';

  @override
  String get transferQuantity => 'Количество для перемещения';

  @override
  String get selectFromLocation => 'Выберите место отправления';

  @override
  String get selectToLocation => 'Выберите место назначения';

  @override
  String get enterTransferQuantity => 'Введите количество для перемещения';

  @override
  String get pleaseSelectFromLocation => 'Выберите место отправления';

  @override
  String get pleaseSelectToLocation => 'Выберите место назначения';

  @override
  String get pleaseEnterTransferQuantity =>
      'Введите количество для перемещения';

  @override
  String get locationsCannotBeSame =>
      'Места отправления и назначения не могут совпадать';

  @override
  String get insufficientStock => 'Недостаточно запасов в исходном месте';

  @override
  String get createTransfer => 'Создать перемещение';

  @override
  String get stockTransferCreated => 'Перемещение запасов успешно создано';

  @override
  String get errorCreatingTransfer => 'Ошибка создания перемещения запасов';

  @override
  String get allStatuses => 'Все статусы';

  @override
  String get noTransfersFound => 'Перемещения не найдены';

  @override
  String get completeTransfer => 'Завершить';

  @override
  String get cancelTransfer => 'Отменить';

  @override
  String get transferCompleted => 'Перемещение успешно завершено';

  @override
  String get transferCancelled => 'Перемещение успешно отменено';

  @override
  String get errorCompletingTransfer => 'Ошибка завершения перемещения';

  @override
  String get errorCancellingTransfer => 'Ошибка отмены перемещения';

  @override
  String get cancelTransferTitle => 'Отменить перемещение';

  @override
  String get provideCancellationReason =>
      'Укажите причину отмены этого перемещения:';

  @override
  String get cancellationReason => 'Причина отмены';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get date => 'Дата';

  @override
  String get createdBy => 'Создано';

  @override
  String get totalValue => 'Общая стоимость';

  @override
  String get addNotesAboutStockTaking =>
      'Добавьте примечания об инвентаризации';

  @override
  String get warehousesNotFound => 'Склады не найдены';

  @override
  String get errorLoadingWarehouses => 'Ошибка загрузки складов';

  @override
  String get searchByOrderNumberOrCustomer =>
      'Поиск по номеру заказа или клиенту...';

  @override
  String get all => 'Все';

  @override
  String get draft => 'Черновик';

  @override
  String get total => 'Всего';

  @override
  String get revenue => 'Выручка';

  @override
  String get items => 'Товары';

  @override
  String get noOrdersFound => 'Заказы не найдены';

  @override
  String get errorLoadingOrders => 'Ошибка загрузки заказов';

  @override
  String get orderMovedToProcessing => 'Заказ перемещен в обработку';

  @override
  String get errorProcessingOrder => 'Ошибка обработки заказа';

  @override
  String get enterTrackingNumberOptional =>
      'Введите номер отслеживания (необязательно):';

  @override
  String get ship => 'Отправить';

  @override
  String get orderShippedSuccessfully => 'Заказ успешно отправлен';

  @override
  String get errorShippingOrder => 'Ошибка отправки заказа';

  @override
  String get orderInformation => 'Информация о заказе';

  @override
  String get totalItems => 'Всего товаров';

  @override
  String get subtotal => 'Промежуточный итог';

  @override
  String get discount => 'Скидка';

  @override
  String get paidAmount => 'Оплаченная сумма';

  @override
  String get customerInformation => 'Информация о клиенте';

  @override
  String get customerId => 'ID клиента';

  @override
  String get deliveryInformation => 'Информация о доставке';

  @override
  String get deliveryType => 'Тип доставки';

  @override
  String get deliveryStatus => 'Статус доставки';

  @override
  String get deliveryPrice => 'Стоимость доставки';

  @override
  String get receiver => 'Получатель';

  @override
  String get receiverPhone => 'Телефон получателя';

  @override
  String get orderSummary => 'Сводка заказа';

  @override
  String get details => 'Детали';

  @override
  String get noItemsFound => 'Товары не найдены';

  @override
  String get debugOrder => 'Отладка заказа';

  @override
  String get unitPrice => 'Цена за единицу';

  @override
  String get noHistoryAvailable => 'История недоступна';

  @override
  String get changedBy => 'Изменено';

  @override
  String get tracking => 'Отслеживание';

  @override
  String get actions => 'Действия';

  @override
  String get errorRefreshingOrder => 'Ошибка обновления заказа';

  @override
  String get errorLoadingOrderHistory => 'Ошибка загрузки истории заказа';

  @override
  String get orderOperations => 'Операции с заказом';

  @override
  String get acceptAndConfirmOrder => 'Принять и подтвердить этот заказ';

  @override
  String get moveToProcessing => 'Переместить заказ в статус обработки';

  @override
  String get markAsReady => 'Отметить как готово';

  @override
  String get markOrderReadyForShipping =>
      'Отметить заказ как готовый к отправке';

  @override
  String get shipOrderWithTracking =>
      'Отправить заказ с информацией об отслеживании';

  @override
  String get markAsDelivered => 'Отметить как доставлено';

  @override
  String get markOrderAsDelivered => 'Отметить заказ как доставленный';

  @override
  String get cancelOrderWithReason => 'Отменить этот заказ с указанием причины';

  @override
  String get processReturnForOrder => 'Обработать возврат для этого заказа';

  @override
  String get noOperationsAvailable => 'Нет доступных операций для этого заказа';

  @override
  String get addConfirmationNotesOptional =>
      'Добавить примечания к подтверждению (необязательно):';

  @override
  String get addProcessingNotesOptional =>
      'Добавить примечания к обработке (необязательно):';

  @override
  String get addShippingNotes => 'Добавить примечания к отправке';

  @override
  String get addDeliveryNotesOptional =>
      'Добавить примечания к доставке (необязательно):';

  @override
  String get customerRequest => 'Запрос клиента';

  @override
  String get paymentIssues => 'Проблемы с оплатой';

  @override
  String get addressIssues => 'Проблемы с адресом';

  @override
  String get systemError => 'Системная ошибка';

  @override
  String get duplicateOrder => 'Дубликат заказа';

  @override
  String get qualityConcerns => 'Проблемы с качеством';

  @override
  String get additionalNotes => 'Дополнительные примечания';

  @override
  String get addCancellationDetails => 'Добавить детали отмены';

  @override
  String get returnReason => 'Причина возврата';

  @override
  String get defectiveProduct => 'Дефектный товар';

  @override
  String get wrongItemSent => 'Отправлен неправильный товар';

  @override
  String get customerDissatisfaction => 'Недовольство клиента';

  @override
  String get sizeFitIssues => 'Проблемы с размером/посадкой';

  @override
  String get damagedDuringShipping => 'Повреждено при доставке';

  @override
  String get changedMind => 'Передумал';

  @override
  String get qualityIssues => 'Проблемы с качеством';

  @override
  String get returnDetails => 'Детали возврата';

  @override
  String get addReturnProcessingDetails => 'Добавить детали обработки возврата';

  @override
  String get operationCompletedSuccessfully => 'Операция успешно завершена';

  @override
  String get continueButton => 'Продолжить';

  @override
  String get errorLoadingTaskDetails => 'Ошибка загрузки деталей задачи';

  @override
  String get comments => 'Комментарии';

  @override
  String get attachments => 'Вложения';

  @override
  String get taskInformation => 'Информация о задаче';

  @override
  String get duration => 'Длительность';

  @override
  String get notAvailable => 'Недоступно';

  @override
  String get estimatedHours => 'Ожидаемые часы';

  @override
  String get actualHours => 'Фактические часы';

  @override
  String get assignment => 'Назначение';

  @override
  String get assignedUser => 'Назначенный пользователь';

  @override
  String get assignedRole => 'Назначенная роль';

  @override
  String get notAssigned => 'Не назначено';

  @override
  String get timeline => 'Временная шкала';

  @override
  String get plannedStart => 'Запланированное начало';

  @override
  String get plannedEnd => 'Запланированное окончание';

  @override
  String get actualStart => 'Фактическое начало';

  @override
  String get actualEnd => 'Фактическое окончание';

  @override
  String get created => 'Создано';

  @override
  String get updated => 'Обновлено';

  @override
  String get taskActions => 'Действия с задачей';

  @override
  String get startTask => 'Начать задачу';

  @override
  String get updateProgress => 'Обновить прогресс';

  @override
  String get complete => 'Завершить';

  @override
  String get cancelTask => 'Отменить задачу';

  @override
  String get taskCompleted => 'Задача завершена';

  @override
  String get taskCancelled => 'Задача отменена';

  @override
  String get taskStartedSuccessfully => 'Задача успешно начата';

  @override
  String get errorStartingTask => 'Ошибка начала задачи';

  @override
  String get completeTask => 'Завершить задачу';

  @override
  String get areYouSureCompleteTask =>
      'Вы уверены, что хотите отметить эту задачу как завершенную?';

  @override
  String get actualHoursOptional => 'Фактические часы (необязательно)';

  @override
  String get completionNotesOptional =>
      'Примечания к завершению (необязательно)';

  @override
  String get taskCompletedSuccessfully => 'Задача успешно завершена';

  @override
  String get errorCompletingTask => 'Ошибка завершения задачи';

  @override
  String get cancelTaskConfirm => 'Отменить задачу';

  @override
  String get areYouSureCancelTask =>
      'Вы уверены, что хотите отменить эту задачу? Это действие нельзя отменить.';

  @override
  String get pleaseProvideCancellationReason =>
      'Пожалуйста, укажите причину отмены';

  @override
  String get taskCancelledSuccessfully => 'Задача успешно отменена';

  @override
  String get errorCancellingTask => 'Ошибка отмены задачи';

  @override
  String get progressPercentage => 'Процент прогресса (0-100)';

  @override
  String get progressNotesOptional => 'Примечания к прогрессу (необязательно)';

  @override
  String get pleaseEnterValidProgress =>
      'Пожалуйста, введите корректный процент прогресса (0-100)';

  @override
  String get update => 'Обновить';

  @override
  String get progressUpdatedSuccessfully => 'Прогресс успешно обновлен';

  @override
  String get errorUpdatingProgress => 'Ошибка обновления прогресса';

  @override
  String get noCommentsYet => 'Пока нет комментариев';

  @override
  String get noAttachments => 'Нет вложений';

  @override
  String get internal => 'Внутренний';

  @override
  String get uploadedBy => 'Загружено';

  @override
  String get fileDownloadNotImplemented => 'Загрузка файла еще не реализована';

  @override
  String get unknown => 'Неизвестно';

  @override
  String get taskIsOverdue => 'Задача просрочена';

  @override
  String get lowStockProducts => 'Товары с низким запасом';

  @override
  String get searchProducts => 'Поиск товаров...';

  @override
  String get allCategories => 'Все категории';

  @override
  String get noLowStockProductsFound => 'Товары с низким запасом не найдены';

  @override
  String get addFirstProduct => 'Добавить первый товар';

  @override
  String get errorLoadingData => 'Ошибка загрузки данных';

  @override
  String get basicInformation => 'Основная информация';

  @override
  String get descriptionRequired => 'Описание обязательно';

  @override
  String get skuRequired => 'Артикул обязателен';

  @override
  String get unitRequired => 'Единица измерения обязательна';

  @override
  String get selectCategory => 'Выберите категорию';

  @override
  String get pricing => 'Ценообразование';

  @override
  String get unitPriceLabel => 'Цена за единицу';

  @override
  String get priceRequired => 'Цена обязательна';

  @override
  String get pleaseEnterValidPrice => 'Введите корректную цену';

  @override
  String get stockInformation => 'Информация о запасах';

  @override
  String get initialStock => 'Начальный запас';

  @override
  String get stockQuantityRequired => 'Количество запасов обязательно';

  @override
  String get pleaseEnterValidQuantity => 'Введите корректное количество';

  @override
  String get minimumStockRequired => 'Минимальный запас обязателен';

  @override
  String get pleaseEnterValidMinimumStock =>
      'Введите корректный минимальный запас';

  @override
  String get minimumStockAlertInfo =>
      'Минимальный уровень запасов используется для запуска оповещений о низком запасе';

  @override
  String get creatingProduct => 'Создание товара...';

  @override
  String get createProduct => 'Создать товар';

  @override
  String get productCreatedSuccessfully => 'Товар успешно создан';

  @override
  String get errorCreatingProduct => 'Ошибка создания товара';

  @override
  String get errorLoadingCategories => 'Ошибка загрузки категорий';

  @override
  String get searchWarehouses => 'Поиск складов...';

  @override
  String get noWarehousesMatchSearch => 'Нет складов, соответствующих поиску';

  @override
  String get managerLabel => 'Менеджер';

  @override
  String get rawMaterials => 'Сырье';

  @override
  String get searchStockItems => 'Поиск товарных запасов...';

  @override
  String get noStockItemsFound => 'Товарные запасы не найдены';

  @override
  String get noStockItemsMatchSearch =>
      'Нет товарных запасов, соответствующих поиску';

  @override
  String get searchRawMaterials => 'Поиск сырья...';

  @override
  String get noRawMaterialsFound => 'Сырье не найдено';

  @override
  String get noRawMaterialsMatchSearch => 'Нет сырья, соответствующего поиску';

  @override
  String get available => 'Доступно';

  @override
  String get reserved => 'Зарезервировано';

  @override
  String get expires => 'Истекает';

  @override
  String get supplier => 'Поставщик';

  @override
  String get adjust => 'Корректировать';

  @override
  String get reserve => 'Зарезервировать';

  @override
  String get transfer => 'Переместить';

  @override
  String get stockOperations => 'Операции с запасами';

  @override
  String get rawMaterialOperations => 'Операции с сырьем';

  @override
  String get errorLoadingStockItems => 'Ошибка загрузки товарных запасов';

  @override
  String get errorLoadingRawMaterials => 'Ошибка загрузки сырья';

  @override
  String get myTasks => 'Мои задачи';

  @override
  String get searchTasks => 'Поиск задач...';

  @override
  String get noTasksFound => 'Задачи не найдены';

  @override
  String get tryAdjustingFilters => 'Попробуйте изменить фильтры';

  @override
  String get showAll => 'Показать все';

  @override
  String get assignToMe => 'Назначить мне';

  @override
  String get returnTask => 'Вернуть задачу';

  @override
  String get reassign => 'Переназначить';

  @override
  String get startProgress => 'Начать выполнение';

  @override
  String get changeDueDate => 'Изменить срок';

  @override
  String get changeProgress => 'Изменить прогресс';

  @override
  String get statusUpdated => 'Статус успешно обновлен';

  @override
  String get dueDateUpdated => 'Срок успешно обновлен';

  @override
  String get invalidProgressValue =>
      'Введите корректное значение прогресса (0-100)';

  @override
  String get taskAssignedToYou => 'Задача назначена вам';

  @override
  String get errorAssigningTask => 'Ошибка назначения задачи';

  @override
  String get areYouSureReturnTask =>
      'Вы уверены, что хотите вернуть эту задачу?';

  @override
  String get taskReturned => 'Задача успешно возвращена';

  @override
  String get errorReturningTask => 'Ошибка возврата задачи';

  @override
  String get reassignTask => 'Переназначить задачу';

  @override
  String get enterUserIdToReassign =>
      'Введите ID пользователя для переназначения';

  @override
  String get userId => 'ID пользователя';

  @override
  String get enterUserId => 'Введите ID пользователя';

  @override
  String get pleaseEnterUserId => 'Пожалуйста, введите ID пользователя';

  @override
  String get taskReassigned => 'Задача успешно переназначена';

  @override
  String get errorReassigningTask => 'Ошибка переназначения задачи';

  @override
  String get addComment => 'Добавить комментарий';

  @override
  String get comment => 'Комментарий';

  @override
  String get writeComment => 'Написать комментарий...';

  @override
  String get enterYourComment => 'Введите ваш комментарий';

  @override
  String get internalComment => 'Внутренний комментарий';

  @override
  String get internalCommentDescription =>
      'Виден только внутренним членам команды';

  @override
  String get pleaseEnterComment => 'Пожалуйста, введите комментарий';

  @override
  String get commentAdded => 'Комментарий успешно добавлен';

  @override
  String get errorAddingComment => 'Ошибка добавления комментария';

  @override
  String get addAttachment => 'Добавить вложение';

  @override
  String get attachmentFeatureComingSoon => 'Функция вложений скоро появится';

  @override
  String get typeMessage => 'Введите сообщение...';

  @override
  String get sendMessage => 'Отправить';

  @override
  String get startConversation => 'Начните разговор ниже';

  @override
  String get noUsersFound => 'Пользователи не найдены';

  @override
  String get selectUserToReassign =>
      'Выберите пользователя для переназначения задачи';

  @override
  String get selectUser => 'Выберите пользователя';

  @override
  String get pleaseSelectUser => 'Пожалуйста, выберите пользователя';

  @override
  String get selectFile => 'Выбрать файл';

  @override
  String get fileDescription => 'Описание файла (необязательно)';

  @override
  String get enterFileDescription => 'Введите описание файла';

  @override
  String get upload => 'Загрузить';

  @override
  String get fileSelected => 'Файл выбран';

  @override
  String get noFileSelected => 'Файл не выбран';

  @override
  String get uploadingFile => 'Загрузка файла...';

  @override
  String get fileUploadedSuccessfully => 'Файл успешно загружен';

  @override
  String get errorUploadingFile => 'Ошибка загрузки файла';

  @override
  String get downloadingFile => 'Скачивание файла...';

  @override
  String get fileDownloadedSuccessfully => 'Файл успешно скачан';

  @override
  String get errorDownloadingFile => 'Ошибка скачивания файла';

  @override
  String get pleaseSelectFile => 'Пожалуйста, выберите файл для загрузки';

  @override
  String get open => 'Открыть';

  @override
  String get errorOpeningFile => 'Ошибка открытия файла';

  @override
  String get companyTasks => 'Задачи компании';

  @override
  String get filters => 'Фильтры';

  @override
  String get clearAll => 'Очистить все';

  @override
  String get showOverdueOnly => 'Показать только просроченные';

  @override
  String get applyFilters => 'Применить фильтры';

  @override
  String get sortBy => 'Сортировать по';

  @override
  String get createdDate => 'Дата создания';

  @override
  String get descending => 'По убыванию';

  @override
  String get apply => 'Применить';

  @override
  String get myResults => 'Мои результаты';

  @override
  String get viewYourPerformance => 'Просмотр ваших результатов';

  @override
  String get finances => 'Финансы';

  @override
  String get manageYourFinances => 'Управление финансами';

  @override
  String get appPreferences => 'Настройки приложения';

  @override
  String get support => 'Поддержка';

  @override
  String get getHelpAndSupport => 'Получить помощь и поддержку';

  @override
  String get chat => 'Чат';

  @override
  String get messageAndSupport => 'Сообщения и поддержка';

  @override
  String get user => 'Пользователь';

  @override
  String get comingSoon => 'Скоро будет';

  @override
  String get viewCompanyTasks => 'Посмотреть задачи компании';

  @override
  String get notSet => 'Не установлено';

  @override
  String get assignee => 'Исполнитель';

  @override
  String get unassigned => 'Не назначено';

  @override
  String get editTask => 'Редактировать задачу';

  @override
  String get markAsComplete => 'Отметить как выполненную';

  @override
  String get uploadFile => 'Загрузить файл';

  @override
  String get progressUpdated => 'Прогресс успешно обновлен';

  @override
  String get reason => 'Причина';
}
