import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_en.dart';
import 'app_localizations_om.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('am'),
    Locale('en'),
    Locale('om')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Tooran'**
  String get appTitle;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get commonUndo;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get commonShare;

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get commonCreate;

  /// No description provided for @commonRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get commonRestore;

  /// No description provided for @commonShow.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get commonShow;

  /// No description provided for @commonHide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get commonHide;

  /// No description provided for @commonApply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get commonApply;

  /// No description provided for @commonNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get commonNone;

  /// No description provided for @commonNameLabel.
  ///
  /// In en, this message translates to:
  /// **'NAME'**
  String get commonNameLabel;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @errorSave.
  ///
  /// In en, this message translates to:
  /// **'Could not save changes'**
  String get errorSave;

  /// No description provided for @errorLoad.
  ///
  /// In en, this message translates to:
  /// **'Could not load your tasks'**
  String get errorLoad;

  /// No description provided for @menuSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get menuSearch;

  /// No description provided for @menuToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get menuToday;

  /// No description provided for @menuPeople.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get menuPeople;

  /// No description provided for @menuHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get menuHistory;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @menuHelp.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get menuHelp;

  /// No description provided for @menuContact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get menuContact;

  /// No description provided for @menuAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get menuAbout;

  /// No description provided for @menuUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get menuUpdates;

  /// No description provided for @menuExpandAll.
  ///
  /// In en, this message translates to:
  /// **'Expand all'**
  String get menuExpandAll;

  /// No description provided for @menuCollapseAll.
  ///
  /// In en, this message translates to:
  /// **'Collapse all'**
  String get menuCollapseAll;

  /// No description provided for @tooltipMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get tooltipMore;

  /// No description provided for @tooltipMenu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get tooltipMenu;

  /// No description provided for @tooltipTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get tooltipTheme;

  /// No description provided for @fabCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get fabCategory;

  /// No description provided for @emptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get emptyTitle;

  /// No description provided for @emptyBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the button below to create your first category. A folder for the things you want to keep close.'**
  String get emptyBody;

  /// No description provided for @emptyLedgerPreset.
  ///
  /// In en, this message translates to:
  /// **'Set up money tracking'**
  String get emptyLedgerPreset;

  /// No description provided for @tipsTitle.
  ///
  /// In en, this message translates to:
  /// **'Quick tips'**
  String get tipsTitle;

  /// No description provided for @tipsBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the box to complete · swipe a task left to delete · long-press to reorder · swipe right on the top bar for the menu.'**
  String get tipsBody;

  /// No description provided for @tipsGotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get tipsGotIt;

  /// No description provided for @categoryNew.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get categoryNew;

  /// No description provided for @categoryEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get categoryEdit;

  /// No description provided for @categoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'A new beginning…'**
  String get categoryNameHint;

  /// No description provided for @categoryNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a category name'**
  String get categoryNameEmpty;

  /// No description provided for @categoryNameDuplicate.
  ///
  /// In en, this message translates to:
  /// **'That name already exists'**
  String get categoryNameDuplicate;

  /// No description provided for @categoryTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'TYPE'**
  String get categoryTypeLabel;

  /// No description provided for @categoryTypeTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get categoryTypeTasks;

  /// No description provided for @categoryCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'CURRENCY'**
  String get categoryCurrencyLabel;

  /// No description provided for @categoryIconLabel.
  ///
  /// In en, this message translates to:
  /// **'ICON'**
  String get categoryIconLabel;

  /// No description provided for @categoryColorLabel.
  ///
  /// In en, this message translates to:
  /// **'COLOR'**
  String get categoryColorLabel;

  /// No description provided for @categoryDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete category?'**
  String get categoryDeleteTitle;

  /// No description provided for @categoryDeleteBodyTasks.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" and its {count, plural, =1{1 task} other{{count} tasks}} will move to history. You can restore it from there.'**
  String categoryDeleteBodyTasks(String name, int count);

  /// No description provided for @categoryDeleteBodyEmpty.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" will move to history. You can restore it from there.'**
  String categoryDeleteBodyEmpty(String name);

  /// No description provided for @categoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" deleted'**
  String categoryDeleted(String name);

  /// No description provided for @categoryNoTasks.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet'**
  String get categoryNoTasks;

  /// No description provided for @categoryProgress.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} · {left} left'**
  String categoryProgress(int done, int total, int left);

  /// No description provided for @categoryNoTasksHint.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet · tap below to add your first'**
  String get categoryNoTasksHint;

  /// No description provided for @categoryAddTask.
  ///
  /// In en, this message translates to:
  /// **'ADD TASK'**
  String get categoryAddTask;

  /// No description provided for @categoryAddEntry.
  ///
  /// In en, this message translates to:
  /// **'ADD ENTRY'**
  String get categoryAddEntry;

  /// No description provided for @categoryPin.
  ///
  /// In en, this message translates to:
  /// **'Pin to top'**
  String get categoryPin;

  /// No description provided for @categoryUnpin.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get categoryUnpin;

  /// No description provided for @categoryHideCompleted.
  ///
  /// In en, this message translates to:
  /// **'Hide completed'**
  String get categoryHideCompleted;

  /// No description provided for @categoryShowCompleted.
  ///
  /// In en, this message translates to:
  /// **'Show completed'**
  String get categoryShowCompleted;

  /// No description provided for @categorySinkCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed to bottom'**
  String get categorySinkCompleted;

  /// No description provided for @categoryClearCompleted.
  ///
  /// In en, this message translates to:
  /// **'Clear completed'**
  String get categoryClearCompleted;

  /// No description provided for @categoryClearedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Cleared 1 task} other{Cleared {count} tasks}}'**
  String categoryClearedCount(int count);

  /// No description provided for @categoryShareList.
  ///
  /// In en, this message translates to:
  /// **'Share list'**
  String get categoryShareList;

  /// No description provided for @categoryConvertToLedger.
  ///
  /// In en, this message translates to:
  /// **'Convert to ledger…'**
  String get categoryConvertToLedger;

  /// No description provided for @categorySort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get categorySort;

  /// No description provided for @categoryHiddenCompleted.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 completed hidden} other{{count} completed hidden}}'**
  String categoryHiddenCompleted(int count);

  /// No description provided for @categoryHiddenSettled.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 settled hidden} other{{count} settled hidden}}'**
  String categoryHiddenSettled(int count);

  /// No description provided for @swipeEdit.
  ///
  /// In en, this message translates to:
  /// **'EDIT'**
  String get swipeEdit;

  /// No description provided for @swipeDelete.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get swipeDelete;

  /// No description provided for @swipeDone.
  ///
  /// In en, this message translates to:
  /// **'DONE'**
  String get swipeDone;

  /// No description provided for @sortManual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get sortManual;

  /// No description provided for @sortLargest.
  ///
  /// In en, this message translates to:
  /// **'Largest amount'**
  String get sortLargest;

  /// No description provided for @sortOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get sortOldest;

  /// No description provided for @sortDueSoonest.
  ///
  /// In en, this message translates to:
  /// **'Due soonest'**
  String get sortDueSoonest;

  /// No description provided for @taskNew.
  ///
  /// In en, this message translates to:
  /// **'New task'**
  String get taskNew;

  /// No description provided for @taskEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit task'**
  String get taskEdit;

  /// No description provided for @taskAdd.
  ///
  /// In en, this message translates to:
  /// **'Add task'**
  String get taskAdd;

  /// No description provided for @taskAddedCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 added} other{{count} added}} · keep typing'**
  String taskAddedCount(int count);

  /// No description provided for @taskNameHint.
  ///
  /// In en, this message translates to:
  /// **'What needs doing?'**
  String get taskNameHint;

  /// No description provided for @taskNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a task name'**
  String get taskNameEmpty;

  /// No description provided for @taskDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'DESCRIPTION'**
  String get taskDescriptionLabel;

  /// No description provided for @taskDeleted.
  ///
  /// In en, this message translates to:
  /// **'Task deleted'**
  String get taskDeleted;

  /// No description provided for @taskCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get taskCompleted;

  /// No description provided for @taskReopened.
  ///
  /// In en, this message translates to:
  /// **'Reopened'**
  String get taskReopened;

  /// No description provided for @taskStatusOpen.
  ///
  /// In en, this message translates to:
  /// **'OPEN'**
  String get taskStatusOpen;

  /// No description provided for @taskStatusCompleted.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get taskStatusCompleted;

  /// No description provided for @taskNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description.'**
  String get taskNoDescription;

  /// No description provided for @taskDetailStatus.
  ///
  /// In en, this message translates to:
  /// **'STATUS'**
  String get taskDetailStatus;

  /// No description provided for @taskDetailCreated.
  ///
  /// In en, this message translates to:
  /// **'CREATED'**
  String get taskDetailCreated;

  /// No description provided for @taskDetailCompleted.
  ///
  /// In en, this message translates to:
  /// **'COMPLETED'**
  String get taskDetailCompleted;

  /// No description provided for @taskDetailDue.
  ///
  /// In en, this message translates to:
  /// **'DUE'**
  String get taskDetailDue;

  /// No description provided for @taskDetailRepeats.
  ///
  /// In en, this message translates to:
  /// **'REPEATS'**
  String get taskDetailRepeats;

  /// No description provided for @taskStatusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get taskStatusDone;

  /// No description provided for @taskStatusInProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get taskStatusInProgress;

  /// No description provided for @taskDueLabel.
  ///
  /// In en, this message translates to:
  /// **'DUE DATE'**
  String get taskDueLabel;

  /// No description provided for @taskDueNone.
  ///
  /// In en, this message translates to:
  /// **'No due date'**
  String get taskDueNone;

  /// No description provided for @taskDueAddTime.
  ///
  /// In en, this message translates to:
  /// **'Add time'**
  String get taskDueAddTime;

  /// No description provided for @taskDueClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get taskDueClear;

  /// No description provided for @taskRepeatLabel.
  ///
  /// In en, this message translates to:
  /// **'REPEAT'**
  String get taskRepeatLabel;

  /// No description provided for @repeatNone.
  ///
  /// In en, this message translates to:
  /// **'Does not repeat'**
  String get repeatNone;

  /// No description provided for @repeatDaily.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get repeatDaily;

  /// No description provided for @repeatWeekly.
  ///
  /// In en, this message translates to:
  /// **'Every week'**
  String get repeatWeekly;

  /// No description provided for @repeatMonthly.
  ///
  /// In en, this message translates to:
  /// **'Every month'**
  String get repeatMonthly;

  /// No description provided for @repeatYearly.
  ///
  /// In en, this message translates to:
  /// **'Every year'**
  String get repeatYearly;

  /// No description provided for @taskNameLength.
  ///
  /// In en, this message translates to:
  /// **'{count}/120'**
  String taskNameLength(int count);

  /// No description provided for @taskChecklistProgress.
  ///
  /// In en, this message translates to:
  /// **'{done}/{total}'**
  String taskChecklistProgress(int done, int total);

  /// No description provided for @taskAutoCompleted.
  ///
  /// In en, this message translates to:
  /// **'All items checked — task completed'**
  String get taskAutoCompleted;

  /// No description provided for @taskPromoted.
  ///
  /// In en, this message translates to:
  /// **'Added as its own task'**
  String get taskPromoted;

  /// No description provided for @dueOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get dueOverdue;

  /// No description provided for @dueToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dueToday;

  /// No description provided for @dueTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get dueTomorrow;

  /// No description provided for @dueInDays.
  ///
  /// In en, this message translates to:
  /// **'In {days} days'**
  String dueInDays(int days);

  /// No description provided for @richChecklist.
  ///
  /// In en, this message translates to:
  /// **'CHECKLIST'**
  String get richChecklist;

  /// No description provided for @richBullet.
  ///
  /// In en, this message translates to:
  /// **'BULLET'**
  String get richBullet;

  /// No description provided for @richNumbered.
  ///
  /// In en, this message translates to:
  /// **'NUMBERED'**
  String get richNumbered;

  /// No description provided for @richHeading.
  ///
  /// In en, this message translates to:
  /// **'HEADING'**
  String get richHeading;

  /// No description provided for @richQuote.
  ///
  /// In en, this message translates to:
  /// **'QUOTE'**
  String get richQuote;

  /// No description provided for @richIndent.
  ///
  /// In en, this message translates to:
  /// **'INDENT'**
  String get richIndent;

  /// No description provided for @richOutdent.
  ///
  /// In en, this message translates to:
  /// **'OUTDENT'**
  String get richOutdent;

  /// No description provided for @richClearChecked.
  ///
  /// In en, this message translates to:
  /// **'Clear checked'**
  String get richClearChecked;

  /// No description provided for @richMoveToTop.
  ///
  /// In en, this message translates to:
  /// **'Move to top'**
  String get richMoveToTop;

  /// No description provided for @richMakeOwnTask.
  ///
  /// In en, this message translates to:
  /// **'Make it its own task'**
  String get richMakeOwnTask;

  /// No description provided for @richEditItem.
  ///
  /// In en, this message translates to:
  /// **'Edit item'**
  String get richEditItem;

  /// No description provided for @richConvertPrompt.
  ///
  /// In en, this message translates to:
  /// **'Convert pasted lines to a checklist?'**
  String get richConvertPrompt;

  /// No description provided for @richConvert.
  ///
  /// In en, this message translates to:
  /// **'Convert'**
  String get richConvert;

  /// No description provided for @richDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Add notes, steps, links…'**
  String get richDescriptionHint;

  /// No description provided for @richReorder.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get richReorder;

  /// No description provided for @ledgerPersonLabel.
  ///
  /// In en, this message translates to:
  /// **'PERSON'**
  String get ledgerPersonLabel;

  /// No description provided for @ledgerPersonHint.
  ///
  /// In en, this message translates to:
  /// **'Who?'**
  String get ledgerPersonHint;

  /// No description provided for @ledgerAmountLabel.
  ///
  /// In en, this message translates to:
  /// **'AMOUNT'**
  String get ledgerAmountLabel;

  /// No description provided for @ledgerDateGiven.
  ///
  /// In en, this message translates to:
  /// **'DATE'**
  String get ledgerDateGiven;

  /// No description provided for @ledgerNoteLabel.
  ///
  /// In en, this message translates to:
  /// **'NOTE'**
  String get ledgerNoteLabel;

  /// No description provided for @ledgerNewEntry.
  ///
  /// In en, this message translates to:
  /// **'New entry'**
  String get ledgerNewEntry;

  /// No description provided for @ledgerEditEntry.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get ledgerEditEntry;

  /// No description provided for @ledgerAddEntry.
  ///
  /// In en, this message translates to:
  /// **'Add entry'**
  String get ledgerAddEntry;

  /// No description provided for @ledgerAmountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than zero'**
  String get ledgerAmountInvalid;

  /// No description provided for @ledgerPersonEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get ledgerPersonEmpty;

  /// No description provided for @ledgerPaidLeft.
  ///
  /// In en, this message translates to:
  /// **'paid {paid} · {left} left'**
  String ledgerPaidLeft(String paid, String left);

  /// No description provided for @ledgerSettled.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get ledgerSettled;

  /// No description provided for @ledgerSettledOn.
  ///
  /// In en, this message translates to:
  /// **'SETTLED'**
  String get ledgerSettledOn;

  /// No description provided for @ledgerOpen.
  ///
  /// In en, this message translates to:
  /// **'OPEN'**
  String get ledgerOpen;

  /// No description provided for @ledgerOutstanding.
  ///
  /// In en, this message translates to:
  /// **'OUTSTANDING'**
  String get ledgerOutstanding;

  /// No description provided for @ledgerTotal.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get ledgerTotal;

  /// No description provided for @ledgerPaid.
  ///
  /// In en, this message translates to:
  /// **'PAID'**
  String get ledgerPaid;

  /// No description provided for @ledgerPayments.
  ///
  /// In en, this message translates to:
  /// **'PAYMENTS'**
  String get ledgerPayments;

  /// No description provided for @ledgerNoPayments.
  ///
  /// In en, this message translates to:
  /// **'No payments yet.'**
  String get ledgerNoPayments;

  /// No description provided for @ledgerRecordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record payment'**
  String get ledgerRecordPayment;

  /// No description provided for @ledgerPaymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Payment amount'**
  String get ledgerPaymentAmount;

  /// No description provided for @ledgerPaymentNote.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get ledgerPaymentNote;

  /// No description provided for @ledgerPaymentRecorded.
  ///
  /// In en, this message translates to:
  /// **'Payment recorded'**
  String get ledgerPaymentRecorded;

  /// No description provided for @ledgerPaymentDeleted.
  ///
  /// In en, this message translates to:
  /// **'Payment removed'**
  String get ledgerPaymentDeleted;

  /// No description provided for @ledgerRemind.
  ///
  /// In en, this message translates to:
  /// **'Remind'**
  String get ledgerRemind;

  /// No description provided for @ledgerRemindMessage.
  ///
  /// In en, this message translates to:
  /// **'Hi {person}, just a reminder about the {amount} from {date}. Thanks!'**
  String ledgerRemindMessage(String person, String amount, String date);

  /// No description provided for @ledgerSettle.
  ///
  /// In en, this message translates to:
  /// **'Settle'**
  String get ledgerSettle;

  /// No description provided for @ledgerSettledToast.
  ///
  /// In en, this message translates to:
  /// **'Marked as settled'**
  String get ledgerSettledToast;

  /// No description provided for @ledgerDaysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =0{today} =1{yesterday} other{{days} days ago}}'**
  String ledgerDaysAgo(int days);

  /// No description provided for @ledgerNet.
  ///
  /// In en, this message translates to:
  /// **'NET'**
  String get ledgerNet;

  /// No description provided for @ledgerNetLabel.
  ///
  /// In en, this message translates to:
  /// **'Net {amount}'**
  String ledgerNetLabel(String amount);

  /// No description provided for @ledgerAllSquare.
  ///
  /// In en, this message translates to:
  /// **'all square'**
  String get ledgerAllSquare;

  /// No description provided for @ledgerHidden.
  ///
  /// In en, this message translates to:
  /// **'••••'**
  String get ledgerHidden;

  /// No description provided for @convertTitle.
  ///
  /// In en, this message translates to:
  /// **'Convert to ledger'**
  String get convertTitle;

  /// No description provided for @convertBody.
  ///
  /// In en, this message translates to:
  /// **'Each task becomes an entry. Names like \"Abebe – 500\" are split into person and amount. Check the preview before applying.'**
  String get convertBody;

  /// No description provided for @convertNoAmount.
  ///
  /// In en, this message translates to:
  /// **'no amount'**
  String get convertNoAmount;

  /// No description provided for @peopleTitle.
  ///
  /// In en, this message translates to:
  /// **'People'**
  String get peopleTitle;

  /// No description provided for @peopleEmpty.
  ///
  /// In en, this message translates to:
  /// **'No money entries yet. Create a Money list to track who owes whom.'**
  String get peopleEmpty;

  /// No description provided for @peopleEntries.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 entry} other{{count} entries}}'**
  String peopleEntries(int count);

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search tasks, notes, people…'**
  String get searchHint;

  /// No description provided for @searchEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches \"{query}\"'**
  String searchEmpty(String query);

  /// No description provided for @searchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Type to search across every category.'**
  String get searchPrompt;

  /// No description provided for @todayTitle.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayTitle;

  /// No description provided for @todayEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing due today. Enjoy the quiet.'**
  String get todayEmpty;

  /// No description provided for @todayCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 due today} other{{count} due today}}'**
  String todayCount(int count);

  /// No description provided for @todayOverdueCount.
  ///
  /// In en, this message translates to:
  /// **'{count} overdue'**
  String todayOverdueCount(int count);

  /// No description provided for @historyTitle.
  ///
  /// In en, this message translates to:
  /// **'HISTORY'**
  String get historyTitle;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Deleted categories will land here. You can restore them, or let them go.'**
  String get historyEmptyBody;

  /// No description provided for @historyRestored.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" restored'**
  String historyRestored(String name);

  /// No description provided for @historyPurged.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" deleted forever'**
  String historyPurged(String name);

  /// No description provided for @historyDeleteForever.
  ///
  /// In en, this message translates to:
  /// **'Delete forever'**
  String get historyDeleteForever;

  /// No description provided for @historyDeleteForeverTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete forever?'**
  String get historyDeleteForeverTitle;

  /// No description provided for @historyDeleteForeverBody.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone. \"{name}\" and its tasks will be erased.'**
  String historyDeleteForeverBody(String name);

  /// No description provided for @historyTaskCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 task} other{{count} tasks}} · {done} done'**
  String historyTaskCount(int count, int done);

  /// No description provided for @historyDeletedOn.
  ///
  /// In en, this message translates to:
  /// **'Deleted {date}'**
  String historyDeletedOn(String date);

  /// No description provided for @historyClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get historyClearAll;

  /// No description provided for @historyClearAllBody.
  ///
  /// In en, this message translates to:
  /// **'Every category in history will be erased. This cannot be undone.'**
  String get historyClearAllBody;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsEthiopianCalendar.
  ///
  /// In en, this message translates to:
  /// **'Ethiopian calendar'**
  String get settingsEthiopianCalendar;

  /// No description provided for @settingsEthiopianCalendarBody.
  ///
  /// In en, this message translates to:
  /// **'Show dates as Meskerem 15 instead of Sep 25.'**
  String get settingsEthiopianCalendarBody;

  /// No description provided for @settingsGestures.
  ///
  /// In en, this message translates to:
  /// **'GESTURES & LISTS'**
  String get settingsGestures;

  /// No description provided for @settingsSwipeRight.
  ///
  /// In en, this message translates to:
  /// **'Swipe right on a task'**
  String get settingsSwipeRight;

  /// No description provided for @settingsSwipeComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete'**
  String get settingsSwipeComplete;

  /// No description provided for @settingsSwipeEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get settingsSwipeEdit;

  /// No description provided for @settingsAutoComplete.
  ///
  /// In en, this message translates to:
  /// **'Complete task when checklist is done'**
  String get settingsAutoComplete;

  /// No description provided for @settingsSinkChecked.
  ///
  /// In en, this message translates to:
  /// **'Move checked items to the bottom'**
  String get settingsSinkChecked;

  /// No description provided for @settingsMoney.
  ///
  /// In en, this message translates to:
  /// **'MONEY'**
  String get settingsMoney;

  /// No description provided for @settingsCurrency.
  ///
  /// In en, this message translates to:
  /// **'Default currency'**
  String get settingsCurrency;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy mode'**
  String get settingsPrivacy;

  /// No description provided for @settingsPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'Hide amounts until tapped.'**
  String get settingsPrivacyBody;

  /// No description provided for @settingsReminders.
  ///
  /// In en, this message translates to:
  /// **'REMINDERS'**
  String get settingsReminders;

  /// No description provided for @settingsRemindersEnabled.
  ///
  /// In en, this message translates to:
  /// **'Due-date reminders'**
  String get settingsRemindersEnabled;

  /// No description provided for @settingsRemindersBody.
  ///
  /// In en, this message translates to:
  /// **'Notify at the due time, or 9:00 for all-day tasks.'**
  String get settingsRemindersBody;

  /// No description provided for @settingsWeeklyDigest.
  ///
  /// In en, this message translates to:
  /// **'Weekly money digest'**
  String get settingsWeeklyDigest;

  /// No description provided for @settingsWeeklyDigestBody.
  ///
  /// In en, this message translates to:
  /// **'Monday morning summary of open loans.'**
  String get settingsWeeklyDigestBody;

  /// No description provided for @settingsNotificationsDenied.
  ///
  /// In en, this message translates to:
  /// **'Notifications are turned off for Tooran in system settings.'**
  String get settingsNotificationsDenied;

  /// No description provided for @settingsSecurity.
  ///
  /// In en, this message translates to:
  /// **'SECURITY'**
  String get settingsSecurity;

  /// No description provided for @settingsAppLock.
  ///
  /// In en, this message translates to:
  /// **'App lock'**
  String get settingsAppLock;

  /// No description provided for @settingsAppLockBody.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint, face or device PIN when opening Tooran.'**
  String get settingsAppLockBody;

  /// No description provided for @settingsAppLockUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This device has no fingerprint, face or screen lock set up.'**
  String get settingsAppLockUnavailable;

  /// No description provided for @settingsLockAfter.
  ///
  /// In en, this message translates to:
  /// **'Lock again after'**
  String get settingsLockAfter;

  /// No description provided for @settingsLockImmediately.
  ///
  /// In en, this message translates to:
  /// **'Immediately'**
  String get settingsLockImmediately;

  /// No description provided for @settingsLockMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute} other{{count} minutes}}'**
  String settingsLockMinutes(int count);

  /// No description provided for @settingsWidget.
  ///
  /// In en, this message translates to:
  /// **'HOME-SCREEN WIDGET'**
  String get settingsWidget;

  /// No description provided for @settingsWidgetSource.
  ///
  /// In en, this message translates to:
  /// **'Widget shows'**
  String get settingsWidgetSource;

  /// No description provided for @settingsWidgetFirst.
  ///
  /// In en, this message translates to:
  /// **'First category'**
  String get settingsWidgetFirst;

  /// No description provided for @settingsWidgetToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get settingsWidgetToday;

  /// No description provided for @settingsWidgetHint.
  ///
  /// In en, this message translates to:
  /// **'Long-press your home screen → Widgets → Tooran to add it.'**
  String get settingsWidgetHint;

  /// No description provided for @settingsBackup.
  ///
  /// In en, this message translates to:
  /// **'BACKUP'**
  String get settingsBackup;

  /// No description provided for @settingsExport.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get settingsExport;

  /// No description provided for @settingsExportBody.
  ///
  /// In en, this message translates to:
  /// **'Save a .json file anywhere — Drive, Telegram, Files.'**
  String get settingsExportBody;

  /// No description provided for @settingsImport.
  ///
  /// In en, this message translates to:
  /// **'Import backup'**
  String get settingsImport;

  /// No description provided for @settingsImportBody.
  ///
  /// In en, this message translates to:
  /// **'Restore from a .json file.'**
  String get settingsImportBody;

  /// No description provided for @settingsAutoBackup.
  ///
  /// In en, this message translates to:
  /// **'Weekly automatic backup'**
  String get settingsAutoBackup;

  /// No description provided for @settingsAutoBackupBody.
  ///
  /// In en, this message translates to:
  /// **'Keeps the last 4 weekly copies on this device.'**
  String get settingsAutoBackupBody;

  /// No description provided for @settingsAutoBackupLast.
  ///
  /// In en, this message translates to:
  /// **'Last backup: {date}'**
  String settingsAutoBackupLast(String date);

  /// No description provided for @settingsBackupNow.
  ///
  /// In en, this message translates to:
  /// **'Back up now'**
  String get settingsBackupNow;

  /// No description provided for @settingsBackupDone.
  ///
  /// In en, this message translates to:
  /// **'Backup saved'**
  String get settingsBackupDone;

  /// No description provided for @importPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Import backup?'**
  String get importPreviewTitle;

  /// No description provided for @importPreviewBody.
  ///
  /// In en, this message translates to:
  /// **'This file has {categories, plural, =1{1 category} other{{categories} categories}} and {tasks, plural, =1{1 task} other{{tasks} tasks}}.'**
  String importPreviewBody(int categories, int tasks);

  /// No description provided for @importMerge.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get importMerge;

  /// No description provided for @importReplace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get importReplace;

  /// No description provided for @importMergeBody.
  ///
  /// In en, this message translates to:
  /// **'Merge adds what\'s missing. Replace deletes your current lists first.'**
  String get importMergeBody;

  /// No description provided for @importDone.
  ///
  /// In en, this message translates to:
  /// **'Backup imported'**
  String get importDone;

  /// No description provided for @importInvalid.
  ///
  /// In en, this message translates to:
  /// **'That file isn\'t a Tooran backup'**
  String get importInvalid;

  /// No description provided for @exportSubject.
  ///
  /// In en, this message translates to:
  /// **'Tooran backup'**
  String get exportSubject;

  /// No description provided for @shareReceivedTitle.
  ///
  /// In en, this message translates to:
  /// **'Add shared text'**
  String get shareReceivedTitle;

  /// No description provided for @shareReceivedPick.
  ///
  /// In en, this message translates to:
  /// **'Add as task to…'**
  String get shareReceivedPick;

  /// No description provided for @shareAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to \"{name}\"'**
  String shareAdded(String name);

  /// No description provided for @shareNoCategories.
  ///
  /// In en, this message translates to:
  /// **'Create a category first, then share again.'**
  String get shareNoCategories;

  /// No description provided for @lockTitle.
  ///
  /// In en, this message translates to:
  /// **'Tooran is locked'**
  String get lockTitle;

  /// No description provided for @lockUnlock.
  ///
  /// In en, this message translates to:
  /// **'Unlock'**
  String get lockUnlock;

  /// No description provided for @lockReason.
  ///
  /// In en, this message translates to:
  /// **'Unlock Tooran'**
  String get lockReason;

  /// No description provided for @notifChannelName.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get notifChannelName;

  /// No description provided for @notifChannelDescription.
  ///
  /// In en, this message translates to:
  /// **'Due-date reminders and the weekly money digest'**
  String get notifChannelDescription;

  /// No description provided for @notifDueBody.
  ///
  /// In en, this message translates to:
  /// **'Due now · {category}'**
  String notifDueBody(String category);

  /// No description provided for @notifLedgerDueBody.
  ///
  /// In en, this message translates to:
  /// **'{person} · {amount} due today'**
  String notifLedgerDueBody(String person, String amount);

  /// No description provided for @notifDigestTitle.
  ///
  /// In en, this message translates to:
  /// **'Your money this week'**
  String get notifDigestTitle;

  /// No description provided for @notifDigestBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No open loans} =1{1 open loan} other{{count} open loans}} · Net {net}'**
  String notifDigestBody(int count, String net);

  /// No description provided for @widgetLeft.
  ///
  /// In en, this message translates to:
  /// **'{count} left'**
  String widgetLeft(int count);

  /// No description provided for @widgetEmpty.
  ///
  /// In en, this message translates to:
  /// **'All clear ✓'**
  String get widgetEmpty;

  /// No description provided for @widgetNoCategories.
  ///
  /// In en, this message translates to:
  /// **'Open Tooran to create a category'**
  String get widgetNoCategories;

  /// No description provided for @helpTitle.
  ///
  /// In en, this message translates to:
  /// **'HELP'**
  String get helpTitle;

  /// No description provided for @helpTroubleshooting.
  ///
  /// In en, this message translates to:
  /// **'TROUBLESHOOTING'**
  String get helpTroubleshooting;

  /// No description provided for @helpGestureTapCategory.
  ///
  /// In en, this message translates to:
  /// **'Tap a category'**
  String get helpGestureTapCategory;

  /// No description provided for @helpGestureTapCategoryBody.
  ///
  /// In en, this message translates to:
  /// **'Expands the list of tasks beneath it.'**
  String get helpGestureTapCategoryBody;

  /// No description provided for @helpGestureCircle.
  ///
  /// In en, this message translates to:
  /// **'Tap the box'**
  String get helpGestureCircle;

  /// No description provided for @helpGestureCircleBody.
  ///
  /// In en, this message translates to:
  /// **'Marks a task complete. In a ledger, settles the entry.'**
  String get helpGestureCircleBody;

  /// No description provided for @helpGestureTapTask.
  ///
  /// In en, this message translates to:
  /// **'Tap a task'**
  String get helpGestureTapTask;

  /// No description provided for @helpGestureTapTaskBody.
  ///
  /// In en, this message translates to:
  /// **'Opens the full description, checklist and details.'**
  String get helpGestureTapTaskBody;

  /// No description provided for @helpGestureLongPress.
  ///
  /// In en, this message translates to:
  /// **'Long press'**
  String get helpGestureLongPress;

  /// No description provided for @helpGestureLongPressBody.
  ///
  /// In en, this message translates to:
  /// **'Picks up the row to reorder.'**
  String get helpGestureLongPressBody;

  /// No description provided for @helpGestureSwipe.
  ///
  /// In en, this message translates to:
  /// **'Swipe'**
  String get helpGestureSwipe;

  /// No description provided for @helpGestureSwipeBody.
  ///
  /// In en, this message translates to:
  /// **'Right to complete (or edit — see Settings). Left to delete, with undo.'**
  String get helpGestureSwipeBody;

  /// No description provided for @helpGestureChecklist.
  ///
  /// In en, this message translates to:
  /// **'Checklists'**
  String get helpGestureChecklist;

  /// No description provided for @helpGestureChecklistBody.
  ///
  /// In en, this message translates to:
  /// **'Type [ ] at the start of a line, or use CHECKLIST. Tick items from the task details.'**
  String get helpGestureChecklistBody;

  /// No description provided for @helpFaqMissing.
  ///
  /// In en, this message translates to:
  /// **'My tasks disappeared'**
  String get helpFaqMissing;

  /// No description provided for @helpFaqMissingBody.
  ///
  /// In en, this message translates to:
  /// **'Tasks save automatically. If a category is missing, check History — deleted categories can be restored from there. Settings → Import backup restores an exported file.'**
  String get helpFaqMissingBody;

  /// No description provided for @helpFaqTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme not switching'**
  String get helpFaqTheme;

  /// No description provided for @helpFaqThemeBody.
  ///
  /// In en, this message translates to:
  /// **'Tap the sun/moon icon in the top bar. Your choice is remembered.'**
  String get helpFaqThemeBody;

  /// No description provided for @helpFaqReorder.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reorder'**
  String get helpFaqReorder;

  /// No description provided for @helpFaqReorderBody.
  ///
  /// In en, this message translates to:
  /// **'Long-press a row first, then drag. Categories must be expanded to reorder their tasks. Ledgers sorted by amount or date can\'t be dragged — switch Sort to Manual.'**
  String get helpFaqReorderBody;

  /// No description provided for @helpFaqReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders don\'t show up'**
  String get helpFaqReminders;

  /// No description provided for @helpFaqRemindersBody.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications for Tooran in system settings, and turn off battery optimisation for it if your phone delays alarms.'**
  String get helpFaqRemindersBody;

  /// No description provided for @helpLocalFirst.
  ///
  /// In en, this message translates to:
  /// **'Tooran is local-first. Your lists never leave your device unless you say so.'**
  String get helpLocalFirst;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get aboutTitle;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'VERSION {version}'**
  String aboutVersion(String version);

  /// No description provided for @aboutIntro.
  ///
  /// In en, this message translates to:
  /// **'Tooran is a local-first task organizer. Categories hold tasks. Tasks have descriptions. Nothing leaves your device. Productivity, in a quieter key.'**
  String get aboutIntro;

  /// No description provided for @aboutWhatItDoes.
  ///
  /// In en, this message translates to:
  /// **'WHAT IT DOES'**
  String get aboutWhatItDoes;

  /// No description provided for @aboutFeatureCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get aboutFeatureCategories;

  /// No description provided for @aboutFeatureCategoriesBody.
  ///
  /// In en, this message translates to:
  /// **'A folder for the things you keep close.'**
  String get aboutFeatureCategoriesBody;

  /// No description provided for @aboutFeatureTasks.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get aboutFeatureTasks;

  /// No description provided for @aboutFeatureTasksBody.
  ///
  /// In en, this message translates to:
  /// **'Names, checklists, due dates, gentle progress.'**
  String get aboutFeatureTasksBody;

  /// No description provided for @aboutFeatureLedger.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get aboutFeatureLedger;

  /// No description provided for @aboutFeatureLedgerBody.
  ///
  /// In en, this message translates to:
  /// **'Who owes whom, partial payments, reminders.'**
  String get aboutFeatureLedgerBody;

  /// No description provided for @aboutFeatureDrag.
  ///
  /// In en, this message translates to:
  /// **'Drag & drop'**
  String get aboutFeatureDrag;

  /// No description provided for @aboutFeatureDragBody.
  ///
  /// In en, this message translates to:
  /// **'Long-press to lift. Drop anywhere.'**
  String get aboutFeatureDragBody;

  /// No description provided for @aboutFeatureHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get aboutFeatureHistory;

  /// No description provided for @aboutFeatureHistoryBody.
  ///
  /// In en, this message translates to:
  /// **'Deleted categories are recoverable.'**
  String get aboutFeatureHistoryBody;

  /// No description provided for @aboutFeatureThemes.
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get aboutFeatureThemes;

  /// No description provided for @aboutFeatureThemesBody.
  ///
  /// In en, this message translates to:
  /// **'Warm paper by day. Deep ink by night.'**
  String get aboutFeatureThemesBody;

  /// No description provided for @aboutFeatureLocal.
  ///
  /// In en, this message translates to:
  /// **'Local-first'**
  String get aboutFeatureLocal;

  /// No description provided for @aboutFeatureLocalBody.
  ///
  /// In en, this message translates to:
  /// **'No cloud, no sign-in, no telemetry.'**
  String get aboutFeatureLocalBody;

  /// No description provided for @aboutCraftedBy.
  ///
  /// In en, this message translates to:
  /// **'CRAFTED BY'**
  String get aboutCraftedBy;

  /// No description provided for @aboutCraftedByBody.
  ///
  /// In en, this message translates to:
  /// **'Jiru Gutema, Addis Ababa University. Made with care, in Flutter, on a quiet evening.'**
  String get aboutCraftedByBody;

  /// No description provided for @aboutRights.
  ///
  /// In en, this message translates to:
  /// **'ALL RIGHTS RESERVED'**
  String get aboutRights;

  /// No description provided for @contactTitle.
  ///
  /// In en, this message translates to:
  /// **'CONTACT'**
  String get contactTitle;

  /// No description provided for @contactEmail.
  ///
  /// In en, this message translates to:
  /// **'EMAIL'**
  String get contactEmail;

  /// No description provided for @contactEmailDetail.
  ///
  /// In en, this message translates to:
  /// **'For questions and support'**
  String get contactEmailDetail;

  /// No description provided for @contactWebsite.
  ///
  /// In en, this message translates to:
  /// **'WEBSITE'**
  String get contactWebsite;

  /// No description provided for @contactWebsiteDetail.
  ///
  /// In en, this message translates to:
  /// **'Updates and news'**
  String get contactWebsiteDetail;

  /// No description provided for @contactSource.
  ///
  /// In en, this message translates to:
  /// **'SOURCE'**
  String get contactSource;

  /// No description provided for @contactSourceDetail.
  ///
  /// In en, this message translates to:
  /// **'Read the code, send a patch'**
  String get contactSourceDetail;

  /// No description provided for @contactDeveloper.
  ///
  /// In en, this message translates to:
  /// **'THE DEVELOPER'**
  String get contactDeveloper;

  /// No description provided for @contactDeveloperRole.
  ///
  /// In en, this message translates to:
  /// **'Software developer · Addis Ababa University'**
  String get contactDeveloperRole;

  /// No description provided for @contactDeveloperBio.
  ///
  /// In en, this message translates to:
  /// **'Building tools that feel calm. Open to feedback and collaboration.'**
  String get contactDeveloperBio;

  /// No description provided for @contactPortfolio.
  ///
  /// In en, this message translates to:
  /// **'PORTFOLIO →'**
  String get contactPortfolio;

  /// No description provided for @contactCopied.
  ///
  /// In en, this message translates to:
  /// **'{label} copied'**
  String contactCopied(String label);

  /// No description provided for @desktopCategories.
  ///
  /// In en, this message translates to:
  /// **'CATEGORIES'**
  String get desktopCategories;

  /// No description provided for @desktopNoCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories yet. Create one to begin.'**
  String get desktopNoCategories;

  /// No description provided for @desktopNewCategory.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get desktopNewCategory;

  /// No description provided for @desktopRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get desktopRename;

  /// No description provided for @desktopArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get desktopArchive;

  /// No description provided for @desktopNoTasksYet.
  ///
  /// In en, this message translates to:
  /// **'NO TASKS YET'**
  String get desktopNoTasksYet;

  /// No description provided for @desktopComplete.
  ///
  /// In en, this message translates to:
  /// **'{done} OF {total} COMPLETE'**
  String desktopComplete(int done, int total);

  /// No description provided for @desktopNothingHere.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get desktopNothingHere;

  /// No description provided for @desktopNothingHereBody.
  ///
  /// In en, this message translates to:
  /// **'Add a task to fill this category with intent.'**
  String get desktopNothingHereBody;

  /// No description provided for @desktopBlankA.
  ///
  /// In en, this message translates to:
  /// **'A '**
  String get desktopBlankA;

  /// No description provided for @desktopBlankWord.
  ///
  /// In en, this message translates to:
  /// **'blank'**
  String get desktopBlankWord;

  /// No description provided for @desktopBlankRest.
  ///
  /// In en, this message translates to:
  /// **' page, yours.'**
  String get desktopBlankRest;

  /// No description provided for @desktopBlankBody.
  ///
  /// In en, this message translates to:
  /// **'Categories hold tasks. Tasks hold what they hold. Nothing more — start with a folder for the things you want to keep close.'**
  String get desktopBlankBody;

  /// No description provided for @desktopCreateFirst.
  ///
  /// In en, this message translates to:
  /// **'Create your first category'**
  String get desktopCreateFirst;

  /// No description provided for @categoryTypeShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get categoryTypeShopping;

  /// No description provided for @categoryTypeBills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get categoryTypeBills;

  /// No description provided for @categoryTypeSavings.
  ///
  /// In en, this message translates to:
  /// **'Savings goal'**
  String get categoryTypeSavings;

  /// No description provided for @categoryTypeNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get categoryTypeNotes;

  /// No description provided for @categoryTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryTypeOther;

  /// No description provided for @typeTasksDesc.
  ///
  /// In en, this message translates to:
  /// **'Things to check off'**
  String get typeTasksDesc;

  /// No description provided for @typeShoppingDesc.
  ///
  /// In en, this message translates to:
  /// **'Items, with optional prices'**
  String get typeShoppingDesc;

  /// No description provided for @typeBillsDesc.
  ///
  /// In en, this message translates to:
  /// **'Payments that come back'**
  String get typeBillsDesc;

  /// No description provided for @typeSavingsDesc.
  ///
  /// In en, this message translates to:
  /// **'Save toward a target'**
  String get typeSavingsDesc;

  /// No description provided for @typeNotesDesc.
  ///
  /// In en, this message translates to:
  /// **'Notes, no checkboxes'**
  String get typeNotesDesc;

  /// No description provided for @typeOtherDesc.
  ///
  /// In en, this message translates to:
  /// **'Name your own kind of list'**
  String get typeOtherDesc;

  /// No description provided for @categoryCustomTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'TYPE NAME'**
  String get categoryCustomTypeLabel;

  /// No description provided for @categoryCustomTypeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Recipes, Books, Ideas'**
  String get categoryCustomTypeHint;

  /// No description provided for @categoryTargetLabel.
  ///
  /// In en, this message translates to:
  /// **'TARGET AMOUNT'**
  String get categoryTargetLabel;

  /// No description provided for @categoryLedgerLockedHint.
  ///
  /// In en, this message translates to:
  /// **'To turn these tasks into money entries, use ⋮ → Convert to ledger.'**
  String get categoryLedgerLockedHint;

  /// No description provided for @summaryShopping.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} · {amount} left'**
  String summaryShopping(int done, int total, String amount);

  /// No description provided for @summaryBills.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{All paid} =1{1 unpaid} other{{count} unpaid}} · {amount}'**
  String summaryBills(int count, String amount);

  /// No description provided for @summarySavings.
  ///
  /// In en, this message translates to:
  /// **'{saved} of {target}'**
  String summarySavings(String saved, String target);

  /// No description provided for @summarySavingsNoTarget.
  ///
  /// In en, this message translates to:
  /// **'{saved} saved'**
  String summarySavingsNoTarget(String saved);

  /// No description provided for @summaryNotes.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No notes yet} =1{1 note} other{{count} notes}}'**
  String summaryNotes(int count);

  /// No description provided for @fieldItem.
  ///
  /// In en, this message translates to:
  /// **'ITEM'**
  String get fieldItem;

  /// No description provided for @fieldItemHint.
  ///
  /// In en, this message translates to:
  /// **'What to buy?'**
  String get fieldItemHint;

  /// No description provided for @fieldPrice.
  ///
  /// In en, this message translates to:
  /// **'PRICE (OPTIONAL)'**
  String get fieldPrice;

  /// No description provided for @fieldBill.
  ///
  /// In en, this message translates to:
  /// **'BILL'**
  String get fieldBill;

  /// No description provided for @fieldBillHint.
  ///
  /// In en, this message translates to:
  /// **'Electricity, rent, internet…'**
  String get fieldBillHint;

  /// No description provided for @fieldBillAmount.
  ///
  /// In en, this message translates to:
  /// **'AMOUNT (OPTIONAL)'**
  String get fieldBillAmount;

  /// No description provided for @fieldTitle.
  ///
  /// In en, this message translates to:
  /// **'TITLE'**
  String get fieldTitle;

  /// No description provided for @fieldTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Note title'**
  String get fieldTitleHint;

  /// No description provided for @fieldNoteBody.
  ///
  /// In en, this message translates to:
  /// **'NOTE'**
  String get fieldNoteBody;

  /// No description provided for @fieldDeposit.
  ///
  /// In en, this message translates to:
  /// **'DESCRIPTION'**
  String get fieldDeposit;

  /// No description provided for @savingsDepositDefault.
  ///
  /// In en, this message translates to:
  /// **'Deposit'**
  String get savingsDepositDefault;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'ADD ITEM'**
  String get addItem;

  /// No description provided for @addBill.
  ///
  /// In en, this message translates to:
  /// **'ADD BILL'**
  String get addBill;

  /// No description provided for @addDeposit.
  ///
  /// In en, this message translates to:
  /// **'ADD DEPOSIT'**
  String get addDeposit;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'ADD NOTE'**
  String get addNote;

  /// No description provided for @newItem.
  ///
  /// In en, this message translates to:
  /// **'New item'**
  String get newItem;

  /// No description provided for @newBill.
  ///
  /// In en, this message translates to:
  /// **'New bill'**
  String get newBill;

  /// No description provided for @newDeposit.
  ///
  /// In en, this message translates to:
  /// **'New deposit'**
  String get newDeposit;

  /// No description provided for @newNote.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get newNote;

  /// No description provided for @editEntry.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editEntry;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @detailAmount.
  ///
  /// In en, this message translates to:
  /// **'AMOUNT'**
  String get detailAmount;

  /// No description provided for @detailPrice.
  ///
  /// In en, this message translates to:
  /// **'PRICE'**
  String get detailPrice;

  /// No description provided for @settingsColorTheme.
  ///
  /// In en, this message translates to:
  /// **'Color theme'**
  String get settingsColorTheme;

  /// No description provided for @settingsCorners.
  ///
  /// In en, this message translates to:
  /// **'Corners'**
  String get settingsCorners;

  /// No description provided for @cornersTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme default'**
  String get cornersTheme;

  /// No description provided for @cornersSharp.
  ///
  /// In en, this message translates to:
  /// **'Sharp'**
  String get cornersSharp;

  /// No description provided for @cornersRounded.
  ///
  /// In en, this message translates to:
  /// **'Rounded'**
  String get cornersRounded;

  /// No description provided for @cornersRound.
  ///
  /// In en, this message translates to:
  /// **'Extra round'**
  String get cornersRound;

  /// No description provided for @settingsCardStyle.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get settingsCardStyle;

  /// No description provided for @cardsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme default'**
  String get cardsTheme;

  /// No description provided for @cardsOutlined.
  ///
  /// In en, this message translates to:
  /// **'Outlined'**
  String get cardsOutlined;

  /// No description provided for @cardsElevated.
  ///
  /// In en, this message translates to:
  /// **'Shadow'**
  String get cardsElevated;

  /// No description provided for @cardsFilled.
  ///
  /// In en, this message translates to:
  /// **'Filled'**
  String get cardsFilled;

  /// No description provided for @themeHorizon.
  ///
  /// In en, this message translates to:
  /// **'Horizon'**
  String get themeHorizon;

  /// No description provided for @themeOcean.
  ///
  /// In en, this message translates to:
  /// **'Ocean'**
  String get themeOcean;

  /// No description provided for @themeForest.
  ///
  /// In en, this message translates to:
  /// **'Forest'**
  String get themeForest;

  /// No description provided for @themeSunset.
  ///
  /// In en, this message translates to:
  /// **'Sunset'**
  String get themeSunset;

  /// No description provided for @themeLavender.
  ///
  /// In en, this message translates to:
  /// **'Lavender'**
  String get themeLavender;

  /// No description provided for @themeGraphite.
  ///
  /// In en, this message translates to:
  /// **'Graphite'**
  String get themeGraphite;

  /// No description provided for @ledgerNewEntryFor.
  ///
  /// In en, this message translates to:
  /// **'New entry for {name}'**
  String ledgerNewEntryFor(String name);

  /// No description provided for @ledgerEntryOn.
  ///
  /// In en, this message translates to:
  /// **'Entry · {date}'**
  String ledgerEntryOn(String date);

  /// No description provided for @ledgerPlusTotal.
  ///
  /// In en, this message translates to:
  /// **'+ TOTAL'**
  String get ledgerPlusTotal;

  /// No description provided for @ledgerMinusTotal.
  ///
  /// In en, this message translates to:
  /// **'− TOTAL'**
  String get ledgerMinusTotal;

  /// No description provided for @categoryTypeMoney.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get categoryTypeMoney;

  /// No description provided for @typeMoneyDesc.
  ///
  /// In en, this message translates to:
  /// **'Who owes whom: + they owe you, − you owe them'**
  String get typeMoneyDesc;

  /// No description provided for @ledgerCaptionOwesYou.
  ///
  /// In en, this message translates to:
  /// **'owes you'**
  String get ledgerCaptionOwesYou;

  /// No description provided for @ledgerCaptionYouOwe.
  ///
  /// In en, this message translates to:
  /// **'you owe'**
  String get ledgerCaptionYouOwe;

  /// No description provided for @moneySignPlus.
  ///
  /// In en, this message translates to:
  /// **'+ They owe me'**
  String get moneySignPlus;

  /// No description provided for @moneySignMinus.
  ///
  /// In en, this message translates to:
  /// **'− I owe them'**
  String get moneySignMinus;

  /// No description provided for @moneySignHelp.
  ///
  /// In en, this message translates to:
  /// **'+ you lent or they borrowed · − you borrowed or they paid you back'**
  String get moneySignHelp;

  /// No description provided for @categoryMergeLedgers.
  ///
  /// In en, this message translates to:
  /// **'Merge money lists…'**
  String get categoryMergeLedgers;

  /// No description provided for @mergeTitle.
  ///
  /// In en, this message translates to:
  /// **'Merge into one list'**
  String get mergeTitle;

  /// No description provided for @mergeBody.
  ///
  /// In en, this message translates to:
  /// **'The checked lists become one Money list. Each person\'s entries are joined, and the other lists move to History.'**
  String get mergeBody;

  /// No description provided for @mergeNameLabel.
  ///
  /// In en, this message translates to:
  /// **'LIST NAME'**
  String get mergeNameLabel;

  /// No description provided for @mergeApply.
  ///
  /// In en, this message translates to:
  /// **'Merge'**
  String get mergeApply;

  /// No description provided for @mergePeopleCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 person} other{{count} people}} after merging'**
  String mergePeopleCount(int count);

  /// No description provided for @mergeDone.
  ///
  /// In en, this message translates to:
  /// **'Merged into “{name}”'**
  String mergeDone(String name);

  /// No description provided for @duplicatePersonHint.
  ///
  /// In en, this message translates to:
  /// **'{name} is already in “{category}”.'**
  String duplicatePersonHint(String name, String category);

  /// No description provided for @duplicatePersonAction.
  ///
  /// In en, this message translates to:
  /// **'Add there as {sign} instead'**
  String duplicatePersonAction(String sign);

  /// No description provided for @ledgerPresetMoney.
  ///
  /// In en, this message translates to:
  /// **'Money'**
  String get ledgerPresetMoney;

  /// No description provided for @taskAddAnother.
  ///
  /// In en, this message translates to:
  /// **'Add another'**
  String get taskAddAnother;

  /// No description provided for @richBold.
  ///
  /// In en, this message translates to:
  /// **'BOLD'**
  String get richBold;

  /// No description provided for @richItalic.
  ///
  /// In en, this message translates to:
  /// **'ITALIC'**
  String get richItalic;

  /// No description provided for @richCode.
  ///
  /// In en, this message translates to:
  /// **'CODE'**
  String get richCode;

  /// No description provided for @richLink.
  ///
  /// In en, this message translates to:
  /// **'LINK'**
  String get richLink;

  /// No description provided for @richPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get richPreview;

  /// No description provided for @richEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get richEdit;

  /// No description provided for @helpMarkdown.
  ///
  /// In en, this message translates to:
  /// **'Markdown'**
  String get helpMarkdown;

  /// No description provided for @helpMarkdownBody.
  ///
  /// In en, this message translates to:
  /// **'Notes support Markdown: **bold**, *italic*, ~~strike~~, `code`, [link](https://…), # headings, > quotes, ``` code blocks and | tables |. Use Preview to check how it looks.'**
  String get helpMarkdownBody;

  /// No description provided for @categoryTypeSpending.
  ///
  /// In en, this message translates to:
  /// **'Spending'**
  String get categoryTypeSpending;

  /// No description provided for @typeSpendingDesc.
  ///
  /// In en, this message translates to:
  /// **'What you spend, with an optional budget'**
  String get typeSpendingDesc;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'ADD EXPENSE'**
  String get addExpense;

  /// No description provided for @newExpense.
  ///
  /// In en, this message translates to:
  /// **'New expense'**
  String get newExpense;

  /// No description provided for @fieldExpenseFor.
  ///
  /// In en, this message translates to:
  /// **'WHAT FOR (OPTIONAL)'**
  String get fieldExpenseFor;

  /// No description provided for @fieldExpenseForHint.
  ///
  /// In en, this message translates to:
  /// **'Lunch, taxi, groceries…'**
  String get fieldExpenseForHint;

  /// No description provided for @fieldTag.
  ///
  /// In en, this message translates to:
  /// **'TAG'**
  String get fieldTag;

  /// No description provided for @tagFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get tagFood;

  /// No description provided for @tagTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get tagTransport;

  /// No description provided for @tagHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tagHome;

  /// No description provided for @tagBills.
  ///
  /// In en, this message translates to:
  /// **'Bills'**
  String get tagBills;

  /// No description provided for @tagShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get tagShopping;

  /// No description provided for @tagHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get tagHealth;

  /// No description provided for @tagFun.
  ///
  /// In en, this message translates to:
  /// **'Fun'**
  String get tagFun;

  /// No description provided for @tagFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get tagFamily;

  /// No description provided for @tagEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get tagEducation;

  /// No description provided for @tagOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get tagOther;

  /// No description provided for @categoryBudgetLabel.
  ///
  /// In en, this message translates to:
  /// **'MONTHLY BUDGET (OPTIONAL)'**
  String get categoryBudgetLabel;

  /// No description provided for @spendToday.
  ///
  /// In en, this message translates to:
  /// **'TODAY'**
  String get spendToday;

  /// No description provided for @spendWeek.
  ///
  /// In en, this message translates to:
  /// **'THIS WEEK'**
  String get spendWeek;

  /// No description provided for @spendMonth.
  ///
  /// In en, this message translates to:
  /// **'THIS MONTH'**
  String get spendMonth;

  /// No description provided for @spendVsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'{percent} vs last month'**
  String spendVsLastMonth(String percent);

  /// No description provided for @spendBudgetLeft.
  ///
  /// In en, this message translates to:
  /// **'{amount} left of {budget}'**
  String spendBudgetLeft(String amount, String budget);

  /// No description provided for @spendBudgetOver.
  ///
  /// In en, this message translates to:
  /// **'{amount} over budget'**
  String spendBudgetOver(String amount);

  /// No description provided for @summarySpending.
  ///
  /// In en, this message translates to:
  /// **'Today {today} · Month {month}'**
  String summarySpending(String today, String month);

  /// No description provided for @summarySpendingBudget.
  ///
  /// In en, this message translates to:
  /// **'Today {today} · {month} of {budget}'**
  String summarySpendingBudget(String today, String month, String budget);

  /// No description provided for @spendYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get spendYesterday;

  /// No description provided for @spendAddAgain.
  ///
  /// In en, this message translates to:
  /// **'Add again today'**
  String get spendAddAgain;

  /// No description provided for @spendAddedAgain.
  ///
  /// In en, this message translates to:
  /// **'Added again for today'**
  String get spendAddedAgain;

  /// No description provided for @spendBudgetWarn.
  ///
  /// In en, this message translates to:
  /// **'You\'ve used {percent} of this month\'s budget'**
  String spendBudgetWarn(String percent);

  /// No description provided for @spendBudgetOverToast.
  ///
  /// In en, this message translates to:
  /// **'Over this month\'s budget by {amount}'**
  String spendBudgetOverToast(String amount);

  /// No description provided for @categoryShareCsv.
  ///
  /// In en, this message translates to:
  /// **'Share as CSV'**
  String get categoryShareCsv;

  /// No description provided for @spendingNoEntries.
  ///
  /// In en, this message translates to:
  /// **'No expenses yet · tap below to log one'**
  String get spendingNoEntries;

  /// No description provided for @settingsSpending.
  ///
  /// In en, this message translates to:
  /// **'SPENDING'**
  String get settingsSpending;

  /// No description provided for @settingsSpendingReminder.
  ///
  /// In en, this message translates to:
  /// **'Daily spending reminder'**
  String get settingsSpendingReminder;

  /// No description provided for @settingsSpendingReminderBody.
  ///
  /// In en, this message translates to:
  /// **'Reminds you to log today\'s spending. Skipped on days you already have.'**
  String get settingsSpendingReminderBody;

  /// No description provided for @settingsSpendingReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get settingsSpendingReminderTime;

  /// No description provided for @notifSpendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Log today\'s spending'**
  String get notifSpendingTitle;

  /// No description provided for @notifSpendingBody.
  ///
  /// In en, this message translates to:
  /// **'Tap to add what you spent today.'**
  String get notifSpendingBody;

  /// No description provided for @overviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overviewTitle;

  /// No description provided for @periodWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get periodWeek;

  /// No description provided for @periodMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get periodMonth;

  /// No description provided for @periodYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get periodYear;

  /// No description provided for @periodCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get periodCustom;

  /// No description provided for @kpiTotal.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get kpiTotal;

  /// No description provided for @kpiDailyAvg.
  ///
  /// In en, this message translates to:
  /// **'PER DAY'**
  String get kpiDailyAvg;

  /// No description provided for @kpiCount.
  ///
  /// In en, this message translates to:
  /// **'EXPENSES'**
  String get kpiCount;

  /// No description provided for @kpiVsPrev.
  ///
  /// In en, this message translates to:
  /// **'VS PREVIOUS'**
  String get kpiVsPrev;

  /// No description provided for @chartOverTime.
  ///
  /// In en, this message translates to:
  /// **'Spending over time'**
  String get chartOverTime;

  /// No description provided for @chartByTag.
  ///
  /// In en, this message translates to:
  /// **'By tag'**
  String get chartByTag;

  /// No description provided for @calendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// No description provided for @searchExpenses.
  ///
  /// In en, this message translates to:
  /// **'Search expenses…'**
  String get searchExpenses;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @noMatches.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches these filters.'**
  String get noMatches;

  /// No description provided for @moneyKpiOwedToYou.
  ///
  /// In en, this message translates to:
  /// **'OWED TO YOU'**
  String get moneyKpiOwedToYou;

  /// No description provided for @moneyKpiYouOwe.
  ///
  /// In en, this message translates to:
  /// **'YOU OWE'**
  String get moneyKpiYouOwe;

  /// No description provided for @moneyKpiPeople.
  ///
  /// In en, this message translates to:
  /// **'PEOPLE'**
  String get moneyKpiPeople;

  /// No description provided for @chartByPerson.
  ///
  /// In en, this message translates to:
  /// **'Balance by person'**
  String get chartByPerson;

  /// No description provided for @chartFlow.
  ///
  /// In en, this message translates to:
  /// **'Money flow · last 6 months'**
  String get chartFlow;

  /// No description provided for @legendPlus.
  ///
  /// In en, this message translates to:
  /// **'+ lent / they owe you'**
  String get legendPlus;

  /// No description provided for @legendMinus.
  ///
  /// In en, this message translates to:
  /// **'− borrowed / paid back'**
  String get legendMinus;

  /// No description provided for @filterOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get filterOpen;

  /// No description provided for @filterSettled.
  ///
  /// In en, this message translates to:
  /// **'Settled'**
  String get filterSettled;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortName;

  /// No description provided for @searchPeople.
  ///
  /// In en, this message translates to:
  /// **'Search people…'**
  String get searchPeople;

  /// No description provided for @overviewOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest open entry: {date}'**
  String overviewOldest(String date);

  /// No description provided for @chartTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a bar to filter the list'**
  String get chartTapHint;
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
      <String>['am', 'en', 'om'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'en':
      return AppLocalizationsEn();
    case 'om':
      return AppLocalizationsOm();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
