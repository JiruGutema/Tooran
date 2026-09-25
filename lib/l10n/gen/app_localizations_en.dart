// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tooran';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonUndo => 'Undo';

  @override
  String get commonDone => 'Done';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonShare => 'Share';

  @override
  String get commonClose => 'Close';

  @override
  String get commonCreate => 'Create';

  @override
  String get commonRestore => 'Restore';

  @override
  String get commonShow => 'Show';

  @override
  String get commonHide => 'Hide';

  @override
  String get commonApply => 'Apply';

  @override
  String get commonNone => 'None';

  @override
  String get commonNameLabel => 'NAME';

  @override
  String get loading => 'Loading…';

  @override
  String get errorSave => 'Could not save changes';

  @override
  String get errorLoad => 'Could not load your tasks';

  @override
  String get menuSearch => 'Search';

  @override
  String get menuToday => 'Today';

  @override
  String get menuPeople => 'People';

  @override
  String get menuHistory => 'History';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuHelp => 'Help';

  @override
  String get menuContact => 'Contact';

  @override
  String get menuAbout => 'About';

  @override
  String get menuUpdates => 'Check for updates';

  @override
  String get menuExpandAll => 'Expand all';

  @override
  String get menuCollapseAll => 'Collapse all';

  @override
  String get tooltipMore => 'More';

  @override
  String get tooltipMenu => 'Menu';

  @override
  String get tooltipTheme => 'Theme';

  @override
  String get fabCategory => 'Category';

  @override
  String get emptyTitle => 'No categories yet';

  @override
  String get emptyBody =>
      'Tap the button below to create your first category. A folder for the things you want to keep close.';

  @override
  String get emptyLedgerPreset => 'Set up money tracking';

  @override
  String get tipsTitle => 'Quick tips';

  @override
  String get tipsBody =>
      'Tap the box to complete · swipe a task left to delete · long-press to reorder · swipe right on the top bar for the menu.';

  @override
  String get tipsGotIt => 'Got it';

  @override
  String get categoryNew => 'New category';

  @override
  String get categoryEdit => 'Edit category';

  @override
  String get categoryNameHint => 'A new beginning…';

  @override
  String get categoryNameEmpty => 'Please enter a category name';

  @override
  String get categoryNameDuplicate => 'That name already exists';

  @override
  String get categoryTypeLabel => 'TYPE';

  @override
  String get categoryTypeTasks => 'Tasks';

  @override
  String get categoryCurrencyLabel => 'CURRENCY';

  @override
  String get categoryIconLabel => 'ICON';

  @override
  String get categoryColorLabel => 'COLOR';

  @override
  String get categoryDeleteTitle => 'Delete category?';

  @override
  String categoryDeleteBodyTasks(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
    );
    return '\"$name\" and its $_temp0 will move to history. You can restore it from there.';
  }

  @override
  String categoryDeleteBodyEmpty(String name) {
    return '\"$name\" will move to history. You can restore it from there.';
  }

  @override
  String categoryDeleted(String name) {
    return '\"$name\" deleted';
  }

  @override
  String get categoryNoTasks => 'No tasks yet';

  @override
  String categoryProgress(int done, int total, int left) {
    return '$done of $total · $left left';
  }

  @override
  String get categoryNoTasksHint =>
      'No tasks yet · tap below to add your first';

  @override
  String get categoryAddTask => 'ADD TASK';

  @override
  String get categoryAddEntry => 'ADD ENTRY';

  @override
  String get categoryPin => 'Pin to top';

  @override
  String get categoryUnpin => 'Unpin';

  @override
  String get categoryHideCompleted => 'Hide completed';

  @override
  String get categoryShowCompleted => 'Show completed';

  @override
  String get categorySinkCompleted => 'Completed to bottom';

  @override
  String get categoryClearCompleted => 'Clear completed';

  @override
  String categoryClearedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Cleared $count tasks',
      one: 'Cleared 1 task',
    );
    return '$_temp0';
  }

  @override
  String get categoryShareList => 'Share list';

  @override
  String get categoryConvertToLedger => 'Convert to ledger…';

  @override
  String get categorySort => 'Sort';

  @override
  String categoryHiddenCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count completed hidden',
      one: '1 completed hidden',
    );
    return '$_temp0';
  }

  @override
  String categoryHiddenSettled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count settled hidden',
      one: '1 settled hidden',
    );
    return '$_temp0';
  }

  @override
  String get swipeEdit => 'EDIT';

  @override
  String get swipeDelete => 'DELETE';

  @override
  String get swipeDone => 'DONE';

  @override
  String get sortManual => 'Manual';

  @override
  String get sortLargest => 'Largest amount';

  @override
  String get sortOldest => 'Oldest';

  @override
  String get sortDueSoonest => 'Due soonest';

  @override
  String get taskNew => 'New task';

  @override
  String get taskEdit => 'Edit task';

  @override
  String get taskAdd => 'Add task';

  @override
  String taskAddedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count added',
      one: '1 added',
    );
    return '$_temp0 · keep typing';
  }

  @override
  String get taskNameHint => 'What needs doing?';

  @override
  String get taskNameEmpty => 'Please enter a task name';

  @override
  String get taskDescriptionLabel => 'DESCRIPTION';

  @override
  String get taskDeleted => 'Task deleted';

  @override
  String get taskCompleted => 'Completed';

  @override
  String get taskReopened => 'Reopened';

  @override
  String get taskStatusOpen => 'OPEN';

  @override
  String get taskStatusCompleted => 'COMPLETED';

  @override
  String get taskNoDescription => 'No description.';

  @override
  String get taskDetailStatus => 'STATUS';

  @override
  String get taskDetailCreated => 'CREATED';

  @override
  String get taskDetailCompleted => 'COMPLETED';

  @override
  String get taskDetailDue => 'DUE';

  @override
  String get taskDetailRepeats => 'REPEATS';

  @override
  String get taskStatusDone => 'Done';

  @override
  String get taskStatusInProgress => 'In progress';

  @override
  String get taskDueLabel => 'DUE DATE';

  @override
  String get taskDueNone => 'No due date';

  @override
  String get taskDueAddTime => 'Add time';

  @override
  String get taskDueClear => 'Clear';

  @override
  String get taskRepeatLabel => 'REPEAT';

  @override
  String get repeatNone => 'Does not repeat';

  @override
  String get repeatDaily => 'Every day';

  @override
  String get repeatWeekly => 'Every week';

  @override
  String get repeatMonthly => 'Every month';

  @override
  String get repeatYearly => 'Every year';

  @override
  String taskNameLength(int count) {
    return '$count/120';
  }

  @override
  String taskChecklistProgress(int done, int total) {
    return '$done/$total';
  }

  @override
  String get taskAutoCompleted => 'All items checked — task completed';

  @override
  String get taskPromoted => 'Added as its own task';

  @override
  String get dueOverdue => 'Overdue';

  @override
  String get dueToday => 'Today';

  @override
  String get dueTomorrow => 'Tomorrow';

  @override
  String dueInDays(int days) {
    return 'In $days days';
  }

  @override
  String get richChecklist => 'CHECKLIST';

  @override
  String get richBullet => 'BULLET';

  @override
  String get richNumbered => 'NUMBERED';

  @override
  String get richHeading => 'HEADING';

  @override
  String get richQuote => 'QUOTE';

  @override
  String get richIndent => 'INDENT';

  @override
  String get richOutdent => 'OUTDENT';

  @override
  String get richClearChecked => 'Clear checked';

  @override
  String get richMoveToTop => 'Move to top';

  @override
  String get richMakeOwnTask => 'Make it its own task';

  @override
  String get richEditItem => 'Edit item';

  @override
  String get richConvertPrompt => 'Convert pasted lines to a checklist?';

  @override
  String get richConvert => 'Convert';

  @override
  String get richDescriptionHint => 'Add notes, steps, links…';

  @override
  String get richReorder => 'Drag to reorder';

  @override
  String get ledgerPersonLabel => 'PERSON';

  @override
  String get ledgerPersonHint => 'Who?';

  @override
  String get ledgerAmountLabel => 'AMOUNT';

  @override
  String get ledgerDateGiven => 'DATE';

  @override
  String get ledgerNoteLabel => 'NOTE';

  @override
  String get ledgerNewEntry => 'New entry';

  @override
  String get ledgerEditEntry => 'Edit entry';

  @override
  String get ledgerAddEntry => 'Add entry';

  @override
  String get ledgerAmountInvalid => 'Enter an amount greater than zero';

  @override
  String get ledgerPersonEmpty => 'Please enter a name';

  @override
  String ledgerPaidLeft(String paid, String left) {
    return 'paid $paid · $left left';
  }

  @override
  String get ledgerSettled => 'Settled';

  @override
  String get ledgerSettledOn => 'SETTLED';

  @override
  String get ledgerOpen => 'OPEN';

  @override
  String get ledgerOutstanding => 'OUTSTANDING';

  @override
  String get ledgerTotal => 'TOTAL';

  @override
  String get ledgerPaid => 'PAID';

  @override
  String get ledgerPayments => 'PAYMENTS';

  @override
  String get ledgerNoPayments => 'No payments yet.';

  @override
  String get ledgerRecordPayment => 'Record payment';

  @override
  String get ledgerPaymentAmount => 'Payment amount';

  @override
  String get ledgerPaymentNote => 'Note (optional)';

  @override
  String get ledgerPaymentRecorded => 'Payment recorded';

  @override
  String get ledgerPaymentDeleted => 'Payment removed';

  @override
  String get ledgerRemind => 'Remind';

  @override
  String ledgerRemindMessage(String person, String amount, String date) {
    return 'Hi $person, just a reminder about the $amount from $date. Thanks!';
  }

  @override
  String get ledgerSettle => 'Settle';

  @override
  String get ledgerSettledToast => 'Marked as settled';

  @override
  String ledgerDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days ago',
      one: 'yesterday',
      zero: 'today',
    );
    return '$_temp0';
  }

  @override
  String get ledgerNet => 'NET';

  @override
  String ledgerNetLabel(String amount) {
    return 'Net $amount';
  }

  @override
  String get ledgerAllSquare => 'all square';

  @override
  String get ledgerHidden => '••••';

  @override
  String get convertTitle => 'Convert to ledger';

  @override
  String get convertBody =>
      'Each task becomes an entry. Names like \"Abebe – 500\" are split into person and amount. Check the preview before applying.';

  @override
  String get convertNoAmount => 'no amount';

  @override
  String get peopleTitle => 'People';

  @override
  String get peopleEmpty =>
      'No money entries yet. Create a Money list to track who owes whom.';

  @override
  String peopleEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '1 entry',
    );
    return '$_temp0';
  }

  @override
  String get searchHint => 'Search tasks, notes, people…';

  @override
  String searchEmpty(String query) {
    return 'Nothing matches \"$query\"';
  }

  @override
  String get searchPrompt => 'Type to search across every category.';

  @override
  String get todayTitle => 'Today';

  @override
  String get todayEmpty => 'Nothing due today. Enjoy the quiet.';

  @override
  String todayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count due today',
      one: '1 due today',
    );
    return '$_temp0';
  }

  @override
  String todayOverdueCount(int count) {
    return '$count overdue';
  }

  @override
  String get historyTitle => 'HISTORY';

  @override
  String get historyEmptyTitle => 'Nothing here';

  @override
  String get historyEmptyBody =>
      'Deleted categories will land here. You can restore them, or let them go.';

  @override
  String historyRestored(String name) {
    return '\"$name\" restored';
  }

  @override
  String historyPurged(String name) {
    return '\"$name\" deleted forever';
  }

  @override
  String get historyDeleteForever => 'Delete forever';

  @override
  String get historyDeleteForeverTitle => 'Delete forever?';

  @override
  String historyDeleteForeverBody(String name) {
    return 'This cannot be undone. \"$name\" and its tasks will be erased.';
  }

  @override
  String historyTaskCount(int count, int done) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
    );
    return '$_temp0 · $done done';
  }

  @override
  String historyDeletedOn(String date) {
    return 'Deleted $date';
  }

  @override
  String get historyClearAll => 'Clear history';

  @override
  String get historyClearAllBody =>
      'Every category in history will be erased. This cannot be undone.';

  @override
  String get settingsTitle => 'SETTINGS';

  @override
  String get settingsAppearance => 'APPEARANCE';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System default';

  @override
  String get settingsEthiopianCalendar => 'Ethiopian calendar';

  @override
  String get settingsEthiopianCalendarBody =>
      'Show dates as Meskerem 15 instead of Sep 25.';

  @override
  String get settingsGestures => 'GESTURES & LISTS';

  @override
  String get settingsSwipeRight => 'Swipe right on a task';

  @override
  String get settingsSwipeComplete => 'Complete';

  @override
  String get settingsSwipeEdit => 'Edit';

  @override
  String get settingsAutoComplete => 'Complete task when checklist is done';

  @override
  String get settingsSinkChecked => 'Move checked items to the bottom';

  @override
  String get settingsMoney => 'MONEY';

  @override
  String get settingsCurrency => 'Default currency';

  @override
  String get settingsPrivacy => 'Privacy mode';

  @override
  String get settingsPrivacyBody => 'Hide amounts until tapped.';

  @override
  String get settingsReminders => 'REMINDERS';

  @override
  String get settingsRemindersEnabled => 'Due-date reminders';

  @override
  String get settingsRemindersBody =>
      'Notify at the due time, or 9:00 for all-day tasks.';

  @override
  String get settingsWeeklyDigest => 'Weekly money digest';

  @override
  String get settingsWeeklyDigestBody =>
      'Monday morning summary of open loans.';

  @override
  String get settingsNotificationsDenied =>
      'Notifications are turned off for Tooran in system settings.';

  @override
  String get settingsSecurity => 'SECURITY';

  @override
  String get settingsAppLock => 'App lock';

  @override
  String get settingsAppLockBody =>
      'Fingerprint, face or device PIN when opening Tooran.';

  @override
  String get settingsAppLockUnavailable =>
      'This device has no fingerprint, face or screen lock set up.';

  @override
  String get settingsLockAfter => 'Lock again after';

  @override
  String get settingsLockImmediately => 'Immediately';

  @override
  String settingsLockMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String get settingsWidget => 'HOME-SCREEN WIDGET';

  @override
  String get settingsWidgetSource => 'Widget shows';

  @override
  String get settingsWidgetFirst => 'First category';

  @override
  String get settingsWidgetToday => 'Today';

  @override
  String get settingsWidgetHint =>
      'Long-press your home screen → Widgets → Tooran to add it.';

  @override
  String get settingsBackup => 'BACKUP';

  @override
  String get settingsExport => 'Export backup';

  @override
  String get settingsExportBody =>
      'Save a .json file anywhere — Drive, Telegram, Files.';

  @override
  String get settingsImport => 'Import backup';

  @override
  String get settingsImportBody => 'Restore from a .json file.';

  @override
  String get settingsAutoBackup => 'Weekly automatic backup';

  @override
  String get settingsAutoBackupBody =>
      'Keeps the last 4 weekly copies on this device.';

  @override
  String settingsAutoBackupLast(String date) {
    return 'Last backup: $date';
  }

  @override
  String get settingsBackupNow => 'Back up now';

  @override
  String get settingsBackupDone => 'Backup saved';

  @override
  String get importPreviewTitle => 'Import backup?';

  @override
  String importPreviewBody(int categories, int tasks) {
    String _temp0 = intl.Intl.pluralLogic(
      categories,
      locale: localeName,
      other: '$categories categories',
      one: '1 category',
    );
    String _temp1 = intl.Intl.pluralLogic(
      tasks,
      locale: localeName,
      other: '$tasks tasks',
      one: '1 task',
    );
    return 'This file has $_temp0 and $_temp1.';
  }

  @override
  String get importMerge => 'Merge';

  @override
  String get importReplace => 'Replace';

  @override
  String get importMergeBody =>
      'Merge adds what\'s missing. Replace deletes your current lists first.';

  @override
  String get importDone => 'Backup imported';

  @override
  String get importInvalid => 'That file isn\'t a Tooran backup';

  @override
  String get exportSubject => 'Tooran backup';

  @override
  String get shareReceivedTitle => 'Add shared text';

  @override
  String get shareReceivedPick => 'Add as task to…';

  @override
  String shareAdded(String name) {
    return 'Added to \"$name\"';
  }

  @override
  String get shareNoCategories => 'Create a category first, then share again.';

  @override
  String get lockTitle => 'Tooran is locked';

  @override
  String get lockUnlock => 'Unlock';

  @override
  String get lockReason => 'Unlock Tooran';

  @override
  String get notifChannelName => 'Reminders';

  @override
  String get notifChannelDescription =>
      'Due-date reminders and the weekly money digest';

  @override
  String notifDueBody(String category) {
    return 'Due now · $category';
  }

  @override
  String notifLedgerDueBody(String person, String amount) {
    return '$person · $amount due today';
  }

  @override
  String get notifDigestTitle => 'Your money this week';

  @override
  String notifDigestBody(int count, String net) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count open loans',
      one: '1 open loan',
      zero: 'No open loans',
    );
    return '$_temp0 · Net $net';
  }

  @override
  String widgetLeft(int count) {
    return '$count left';
  }

  @override
  String get widgetEmpty => 'All clear ✓';

  @override
  String get widgetNoCategories => 'Open Tooran to create a category';

  @override
  String get helpTitle => 'HELP';

  @override
  String get helpTroubleshooting => 'TROUBLESHOOTING';

  @override
  String get helpGestureTapCategory => 'Tap a category';

  @override
  String get helpGestureTapCategoryBody =>
      'Expands the list of tasks beneath it.';

  @override
  String get helpGestureCircle => 'Tap the box';

  @override
  String get helpGestureCircleBody =>
      'Marks a task complete. In a ledger, settles the entry.';

  @override
  String get helpGestureTapTask => 'Tap a task';

  @override
  String get helpGestureTapTaskBody =>
      'Opens the full description, checklist and details.';

  @override
  String get helpGestureLongPress => 'Long press';

  @override
  String get helpGestureLongPressBody => 'Picks up the row to reorder.';

  @override
  String get helpGestureSwipe => 'Swipe';

  @override
  String get helpGestureSwipeBody =>
      'Right to complete (or edit — see Settings). Left to delete, with undo.';

  @override
  String get helpGestureChecklist => 'Checklists';

  @override
  String get helpGestureChecklistBody =>
      'Type [ ] at the start of a line, or use CHECKLIST. Tick items from the task details.';

  @override
  String get helpFaqMissing => 'My tasks disappeared';

  @override
  String get helpFaqMissingBody =>
      'Tasks save automatically. If a category is missing, check History — deleted categories can be restored from there. Settings → Import backup restores an exported file.';

  @override
  String get helpFaqTheme => 'Theme not switching';

  @override
  String get helpFaqThemeBody =>
      'Tap the sun/moon icon in the top bar. Your choice is remembered.';

  @override
  String get helpFaqReorder => 'Can\'t reorder';

  @override
  String get helpFaqReorderBody =>
      'Long-press a row first, then drag. Categories must be expanded to reorder their tasks. Ledgers sorted by amount or date can\'t be dragged — switch Sort to Manual.';

  @override
  String get helpFaqReminders => 'Reminders don\'t show up';

  @override
  String get helpFaqRemindersBody =>
      'Allow notifications for Tooran in system settings, and turn off battery optimisation for it if your phone delays alarms.';

  @override
  String get helpLocalFirst =>
      'Tooran is local-first. Your lists never leave your device unless you say so.';

  @override
  String get aboutTitle => 'ABOUT';

  @override
  String aboutVersion(String version) {
    return 'VERSION $version';
  }

  @override
  String get aboutIntro =>
      'Tooran is a local-first task organizer. Categories hold tasks. Tasks have descriptions. Nothing leaves your device. Productivity, in a quieter key.';

  @override
  String get aboutWhatItDoes => 'WHAT IT DOES';

  @override
  String get aboutFeatureCategories => 'Categories';

  @override
  String get aboutFeatureCategoriesBody =>
      'A folder for the things you keep close.';

  @override
  String get aboutFeatureTasks => 'Tasks';

  @override
  String get aboutFeatureTasksBody =>
      'Names, checklists, due dates, gentle progress.';

  @override
  String get aboutFeatureLedger => 'Money';

  @override
  String get aboutFeatureLedgerBody =>
      'Who owes whom, partial payments, reminders.';

  @override
  String get aboutFeatureDrag => 'Drag & drop';

  @override
  String get aboutFeatureDragBody => 'Long-press to lift. Drop anywhere.';

  @override
  String get aboutFeatureHistory => 'History';

  @override
  String get aboutFeatureHistoryBody => 'Deleted categories are recoverable.';

  @override
  String get aboutFeatureThemes => 'Themes';

  @override
  String get aboutFeatureThemesBody => 'Warm paper by day. Deep ink by night.';

  @override
  String get aboutFeatureLocal => 'Local-first';

  @override
  String get aboutFeatureLocalBody => 'No cloud, no sign-in, no telemetry.';

  @override
  String get aboutCraftedBy => 'CRAFTED BY';

  @override
  String get aboutCraftedByBody =>
      'Jiru Gutema, Addis Ababa University. Made with care, in Flutter, on a quiet evening.';

  @override
  String get aboutRights => 'ALL RIGHTS RESERVED';

  @override
  String get contactTitle => 'CONTACT';

  @override
  String get contactEmail => 'EMAIL';

  @override
  String get contactEmailDetail => 'For questions and support';

  @override
  String get contactWebsite => 'WEBSITE';

  @override
  String get contactWebsiteDetail => 'Updates and news';

  @override
  String get contactSource => 'SOURCE';

  @override
  String get contactSourceDetail => 'Read the code, send a patch';

  @override
  String get contactDeveloper => 'THE DEVELOPER';

  @override
  String get contactDeveloperRole =>
      'Software developer · Addis Ababa University';

  @override
  String get contactDeveloperBio =>
      'Building tools that feel calm. Open to feedback and collaboration.';

  @override
  String get contactPortfolio => 'PORTFOLIO →';

  @override
  String contactCopied(String label) {
    return '$label copied';
  }

  @override
  String get desktopCategories => 'CATEGORIES';

  @override
  String get desktopNoCategories => 'No categories yet. Create one to begin.';

  @override
  String get desktopNewCategory => 'New category';

  @override
  String get desktopRename => 'Rename';

  @override
  String get desktopArchive => 'Archive';

  @override
  String get desktopNoTasksYet => 'NO TASKS YET';

  @override
  String desktopComplete(int done, int total) {
    return '$done OF $total COMPLETE';
  }

  @override
  String get desktopNothingHere => 'Nothing here yet.';

  @override
  String get desktopNothingHereBody =>
      'Add a task to fill this category with intent.';

  @override
  String get desktopBlankA => 'A ';

  @override
  String get desktopBlankWord => 'blank';

  @override
  String get desktopBlankRest => ' page, yours.';

  @override
  String get desktopBlankBody =>
      'Categories hold tasks. Tasks hold what they hold. Nothing more — start with a folder for the things you want to keep close.';

  @override
  String get desktopCreateFirst => 'Create your first category';

  @override
  String get categoryTypeShopping => 'Shopping';

  @override
  String get categoryTypeBills => 'Bills';

  @override
  String get categoryTypeSavings => 'Savings goal';

  @override
  String get categoryTypeNotes => 'Notes';

  @override
  String get categoryTypeOther => 'Other';

  @override
  String get typeTasksDesc => 'Things to check off';

  @override
  String get typeShoppingDesc => 'Items, with optional prices';

  @override
  String get typeBillsDesc => 'Payments that come back';

  @override
  String get typeSavingsDesc => 'Save toward a target';

  @override
  String get typeNotesDesc => 'Notes, no checkboxes';

  @override
  String get typeOtherDesc => 'Name your own kind of list';

  @override
  String get categoryCustomTypeLabel => 'TYPE NAME';

  @override
  String get categoryCustomTypeHint => 'e.g. Recipes, Books, Ideas';

  @override
  String get categoryTargetLabel => 'TARGET AMOUNT';

  @override
  String get categoryLedgerLockedHint =>
      'To turn these tasks into money entries, use ⋮ → Convert to ledger.';

  @override
  String summaryShopping(int done, int total, String amount) {
    return '$done of $total · $amount left';
  }

  @override
  String summaryBills(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unpaid',
      one: '1 unpaid',
      zero: 'All paid',
    );
    return '$_temp0 · $amount';
  }

  @override
  String summarySavings(String saved, String target) {
    return '$saved of $target';
  }

  @override
  String summarySavingsNoTarget(String saved) {
    return '$saved saved';
  }

  @override
  String summaryNotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes',
      one: '1 note',
      zero: 'No notes yet',
    );
    return '$_temp0';
  }

  @override
  String get fieldItem => 'ITEM';

  @override
  String get fieldItemHint => 'What to buy?';

  @override
  String get fieldPrice => 'PRICE (OPTIONAL)';

  @override
  String get fieldBill => 'BILL';

  @override
  String get fieldBillHint => 'Electricity, rent, internet…';

  @override
  String get fieldBillAmount => 'AMOUNT (OPTIONAL)';

  @override
  String get fieldTitle => 'TITLE';

  @override
  String get fieldTitleHint => 'Note title';

  @override
  String get fieldNoteBody => 'NOTE';

  @override
  String get fieldDeposit => 'DESCRIPTION';

  @override
  String get savingsDepositDefault => 'Deposit';

  @override
  String get addItem => 'ADD ITEM';

  @override
  String get addBill => 'ADD BILL';

  @override
  String get addDeposit => 'ADD DEPOSIT';

  @override
  String get addNote => 'ADD NOTE';

  @override
  String get newItem => 'New item';

  @override
  String get newBill => 'New bill';

  @override
  String get newDeposit => 'New deposit';

  @override
  String get newNote => 'New note';

  @override
  String get editEntry => 'Edit';

  @override
  String get commonAdd => 'Add';

  @override
  String get detailAmount => 'AMOUNT';

  @override
  String get detailPrice => 'PRICE';

  @override
  String get settingsColorTheme => 'Color theme';

  @override
  String get settingsCorners => 'Corners';

  @override
  String get cornersTheme => 'Theme default';

  @override
  String get cornersSharp => 'Sharp';

  @override
  String get cornersRounded => 'Rounded';

  @override
  String get cornersRound => 'Extra round';

  @override
  String get settingsCardStyle => 'Cards';

  @override
  String get cardsTheme => 'Theme default';

  @override
  String get cardsOutlined => 'Outlined';

  @override
  String get cardsElevated => 'Shadow';

  @override
  String get cardsFilled => 'Filled';

  @override
  String get themeHorizon => 'Horizon';

  @override
  String get themeOcean => 'Ocean';

  @override
  String get themeForest => 'Forest';

  @override
  String get themeSunset => 'Sunset';

  @override
  String get themeLavender => 'Lavender';

  @override
  String get themeGraphite => 'Graphite';

  @override
  String ledgerNewEntryFor(String name) {
    return 'New entry for $name';
  }

  @override
  String ledgerEntryOn(String date) {
    return 'Entry · $date';
  }

  @override
  String get ledgerPlusTotal => '+ TOTAL';

  @override
  String get ledgerMinusTotal => '− TOTAL';

  @override
  String get categoryTypeMoney => 'Money';

  @override
  String get typeMoneyDesc => 'Who owes whom: + they owe you, − you owe them';

  @override
  String get ledgerCaptionOwesYou => 'owes you';

  @override
  String get ledgerCaptionYouOwe => 'you owe';

  @override
  String get moneySignPlus => '+ They owe me';

  @override
  String get moneySignMinus => '− I owe them';

  @override
  String get moneySignHelp =>
      '+ you lent or they borrowed · − you borrowed or they paid you back';

  @override
  String get categoryMergeLedgers => 'Merge money lists…';

  @override
  String get mergeTitle => 'Merge into one list';

  @override
  String get mergeBody =>
      'The checked lists become one Money list. Each person\'s entries are joined, and the other lists move to History.';

  @override
  String get mergeNameLabel => 'LIST NAME';

  @override
  String get mergeApply => 'Merge';

  @override
  String mergePeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count people',
      one: '1 person',
    );
    return '$_temp0 after merging';
  }

  @override
  String mergeDone(String name) {
    return 'Merged into “$name”';
  }

  @override
  String duplicatePersonHint(String name, String category) {
    return '$name is already in “$category”.';
  }

  @override
  String duplicatePersonAction(String sign) {
    return 'Add there as $sign instead';
  }

  @override
  String get ledgerPresetMoney => 'Money';

  @override
  String get taskAddAnother => 'Add another';

  @override
  String get richBold => 'BOLD';

  @override
  String get richItalic => 'ITALIC';

  @override
  String get richCode => 'CODE';

  @override
  String get richLink => 'LINK';

  @override
  String get richPreview => 'Preview';

  @override
  String get richEdit => 'Edit';

  @override
  String get helpMarkdown => 'Markdown';

  @override
  String get helpMarkdownBody =>
      'Notes support Markdown: **bold**, *italic*, ~~strike~~, `code`, [link](https://…), # headings, > quotes, ``` code blocks and | tables |. Use Preview to check how it looks.';

  @override
  String get categoryTypeSpending => 'Spending';

  @override
  String get typeSpendingDesc => 'What you spend, with an optional budget';

  @override
  String get addExpense => 'ADD EXPENSE';

  @override
  String get newExpense => 'New expense';

  @override
  String get fieldExpenseFor => 'WHAT FOR (OPTIONAL)';

  @override
  String get fieldExpenseForHint => 'Lunch, taxi, groceries…';

  @override
  String get fieldTag => 'TAG';

  @override
  String get tagFood => 'Food';

  @override
  String get tagTransport => 'Transport';

  @override
  String get tagHome => 'Home';

  @override
  String get tagBills => 'Bills';

  @override
  String get tagShopping => 'Shopping';

  @override
  String get tagHealth => 'Health';

  @override
  String get tagFun => 'Fun';

  @override
  String get tagFamily => 'Family';

  @override
  String get tagEducation => 'Education';

  @override
  String get tagOther => 'Other';

  @override
  String get categoryBudgetLabel => 'MONTHLY BUDGET (OPTIONAL)';

  @override
  String get spendToday => 'TODAY';

  @override
  String get spendWeek => 'THIS WEEK';

  @override
  String get spendMonth => 'THIS MONTH';

  @override
  String spendVsLastMonth(String percent) {
    return '$percent vs last month';
  }

  @override
  String spendBudgetLeft(String amount, String budget) {
    return '$amount left of $budget';
  }

  @override
  String spendBudgetOver(String amount) {
    return '$amount over budget';
  }

  @override
  String summarySpending(String today, String month) {
    return 'Today $today · Month $month';
  }

  @override
  String summarySpendingBudget(String today, String month, String budget) {
    return 'Today $today · $month of $budget';
  }

  @override
  String get spendYesterday => 'Yesterday';

  @override
  String get spendAddAgain => 'Add again today';

  @override
  String get spendAddedAgain => 'Added again for today';

  @override
  String spendBudgetWarn(String percent) {
    return 'You\'ve used $percent of this month\'s budget';
  }

  @override
  String spendBudgetOverToast(String amount) {
    return 'Over this month\'s budget by $amount';
  }

  @override
  String get categoryShareCsv => 'Share as CSV';

  @override
  String get spendingNoEntries => 'No expenses yet · tap below to log one';

  @override
  String get settingsSpending => 'SPENDING';

  @override
  String get settingsSpendingReminder => 'Daily spending reminder';

  @override
  String get settingsSpendingReminderBody =>
      'Reminds you to log today\'s spending. Skipped on days you already have.';

  @override
  String get settingsSpendingReminderTime => 'Reminder time';

  @override
  String get notifSpendingTitle => 'Log today\'s spending';

  @override
  String get notifSpendingBody => 'Tap to add what you spent today.';

  @override
  String get overviewTitle => 'Overview';

  @override
  String get periodWeek => 'Week';

  @override
  String get periodMonth => 'Month';

  @override
  String get periodYear => 'Year';

  @override
  String get periodCustom => 'Custom';

  @override
  String get kpiTotal => 'TOTAL';

  @override
  String get kpiDailyAvg => 'PER DAY';

  @override
  String get kpiCount => 'EXPENSES';

  @override
  String get kpiVsPrev => 'VS PREVIOUS';

  @override
  String get chartOverTime => 'Spending over time';

  @override
  String get chartByTag => 'By tag';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get searchExpenses => 'Search expenses…';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String get noMatches => 'Nothing matches these filters.';

  @override
  String get moneyKpiOwedToYou => 'OWED TO YOU';

  @override
  String get moneyKpiYouOwe => 'YOU OWE';

  @override
  String get moneyKpiPeople => 'PEOPLE';

  @override
  String get chartByPerson => 'Balance by person';

  @override
  String get chartFlow => 'Money flow · last 6 months';

  @override
  String get legendPlus => '+ lent / they owe you';

  @override
  String get legendMinus => '− borrowed / paid back';

  @override
  String get filterOpen => 'Open';

  @override
  String get filterSettled => 'Settled';

  @override
  String get filterAll => 'All';

  @override
  String get sortName => 'Name';

  @override
  String get searchPeople => 'Search people…';

  @override
  String overviewOldest(String date) {
    return 'Oldest open entry: $date';
  }

  @override
  String get chartTapHint => 'Tap a bar to filter the list';

  @override
  String get overviewBudget => 'MONTHLY BUDGET';
}
