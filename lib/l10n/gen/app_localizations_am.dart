// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Amharic (`am`).
class AppLocalizationsAm extends AppLocalizations {
  AppLocalizationsAm([String locale = 'am']) : super(locale);

  @override
  String get appTitle => 'Tooran';

  @override
  String get commonCancel => 'ይቅር';

  @override
  String get commonSave => 'አስቀምጥ';

  @override
  String get commonDelete => 'ሰርዝ';

  @override
  String get commonUndo => 'ቀልብስ';

  @override
  String get commonDone => 'ጨርሻለሁ';

  @override
  String get commonEdit => 'አስተካክል';

  @override
  String get commonShare => 'አጋራ';

  @override
  String get commonClose => 'ዝጋ';

  @override
  String get commonCreate => 'ፍጠር';

  @override
  String get commonRestore => 'መልስ';

  @override
  String get commonShow => 'አሳይ';

  @override
  String get commonHide => 'ደብቅ';

  @override
  String get commonApply => 'ተግብር';

  @override
  String get commonNone => 'ምንም';

  @override
  String get commonNameLabel => 'ስም';

  @override
  String get loading => 'በመጫን ላይ…';

  @override
  String get errorSave => 'ለውጦቹን ማስቀመጥ አልተቻለም';

  @override
  String get errorLoad => 'ተግባሮችዎን መጫን አልተቻለም';

  @override
  String get menuSearch => 'ፈልግ';

  @override
  String get menuToday => 'ዛሬ';

  @override
  String get menuPeople => 'ሰዎች';

  @override
  String get menuHistory => 'ታሪክ';

  @override
  String get menuSettings => 'ቅንብሮች';

  @override
  String get menuHelp => 'እገዛ';

  @override
  String get menuContact => 'ያግኙን';

  @override
  String get menuAbout => 'ስለ Tooran';

  @override
  String get menuUpdates => 'ዝማኔዎችን ፈልግ';

  @override
  String get menuExpandAll => 'ሁሉንም ዘርጋ';

  @override
  String get menuCollapseAll => 'ሁሉንም ሰብስብ';

  @override
  String get tooltipMore => 'ተጨማሪ';

  @override
  String get tooltipMenu => 'ምናሌ';

  @override
  String get tooltipTheme => 'ገጽታ';

  @override
  String get fabCategory => 'ምድብ';

  @override
  String get emptyTitle => 'እስካሁን ምንም ምድብ የለም';

  @override
  String get emptyBody =>
      'የመጀመሪያ ምድብዎን ለመፍጠር ከታች ያለውን ቁልፍ ይንኩ። ቅርብ ማድረግ ለሚፈልጓቸው ነገሮች የሚሆን አቃፊ።';

  @override
  String get emptyLedgerPreset => 'የገንዘብ መከታተያ አዘጋጅ';

  @override
  String get tipsTitle => 'ፈጣን ምክሮች';

  @override
  String get tipsBody =>
      'ለመጨረስ ሳጥኑን ይንኩ · ለመሰረዝ ተግባሩን ወደ ግራ ይጎትቱ · ቦታ ለመቀየር ተጭነው ይያዙ · ምናሌውን ለመክፈት ከላይ ያለውን አሞሌ ወደ ቀኝ ይጎትቱ።';

  @override
  String get tipsGotIt => 'ገባኝ';

  @override
  String get categoryNew => 'አዲስ ምድብ';

  @override
  String get categoryEdit => 'ምድብ አስተካክል';

  @override
  String get categoryNameHint => 'አዲስ ጅማሬ…';

  @override
  String get categoryNameEmpty => 'እባክዎ የምድብ ስም ያስገቡ';

  @override
  String get categoryNameDuplicate => 'ይህ ስም አስቀድሞ አለ';

  @override
  String get categoryTypeLabel => 'ዓይነት';

  @override
  String get categoryTypeTasks => 'ተግባሮች';

  @override
  String get categoryCurrencyLabel => 'የገንዘብ ዓይነት';

  @override
  String get categoryIconLabel => 'አዶ';

  @override
  String get categoryColorLabel => 'ቀለም';

  @override
  String get categoryDeleteTitle => 'ምድቡ ይሰረዝ?';

  @override
  String categoryDeleteBodyTasks(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ተግባሮቹ',
      one: '1 ተግባሩ',
    );
    return '\"$name\" እና $_temp0 ወደ ታሪክ ይዛወራሉ። ከዚያ መመለስ ይችላሉ።';
  }

  @override
  String categoryDeleteBodyEmpty(String name) {
    return '\"$name\" ወደ ታሪክ ይዛወራል። ከዚያ መመለስ ይችላሉ።';
  }

  @override
  String categoryDeleted(String name) {
    return '\"$name\" ተሰርዟል';
  }

  @override
  String get categoryNoTasks => 'እስካሁን ምንም ተግባር የለም';

  @override
  String categoryProgress(int done, int total, int left) {
    return '$done/$total · $left ቀሪ';
  }

  @override
  String get categoryNoTasksHint =>
      'እስካሁን ምንም ተግባር የለም · የመጀመሪያውን ለመጨመር ከታች ይንኩ';

  @override
  String get categoryAddTask => 'ተግባር ጨምር';

  @override
  String get categoryAddEntry => 'ግቤት ጨምር';

  @override
  String get categoryPin => 'ከላይ ሰካ';

  @override
  String get categoryUnpin => 'ከላይ አንሳ';

  @override
  String get categoryHideCompleted => 'የተጠናቀቁትን ደብቅ';

  @override
  String get categoryShowCompleted => 'የተጠናቀቁትን አሳይ';

  @override
  String get categorySinkCompleted => 'የተጠናቀቁትን ወደ ታች';

  @override
  String get categoryClearCompleted => 'የተጠናቀቁትን አጽዳ';

  @override
  String categoryClearedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ተግባሮች ጸድተዋል',
      one: '1 ተግባር ጸድቷል',
    );
    return '$_temp0';
  }

  @override
  String get categoryShareList => 'ዝርዝሩን አጋራ';

  @override
  String get categoryConvertToLedger => 'ወደ ሂሳብ መዝገብ ቀይር…';

  @override
  String get categorySort => 'ደርድር';

  @override
  String categoryHiddenCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count የተጠናቀቁ ተደብቀዋል',
      one: '1 የተጠናቀቀ ተደብቋል',
    );
    return '$_temp0';
  }

  @override
  String categoryHiddenSettled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count የተዘጉ ተደብቀዋል',
      one: '1 የተዘጋ ተደብቋል',
    );
    return '$_temp0';
  }

  @override
  String get swipeEdit => 'አስተካክል';

  @override
  String get swipeDelete => 'ሰርዝ';

  @override
  String get swipeDone => 'ተጠናቋል';

  @override
  String get sortManual => 'በእጅ';

  @override
  String get sortLargest => 'ትልቁ መጠን';

  @override
  String get sortOldest => 'የቆየው መጀመሪያ';

  @override
  String get sortDueSoonest => 'ቀነ ገደቡ የቀረበው';

  @override
  String get taskNew => 'አዲስ ተግባር';

  @override
  String get taskEdit => 'ተግባር አስተካክል';

  @override
  String get taskAdd => 'ተግባር ጨምር';

  @override
  String taskAddedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ተጨምረዋል',
      one: '1 ተጨምሯል',
    );
    return '$_temp0 · መጻፍ ይቀጥሉ';
  }

  @override
  String get taskNameHint => 'ምን መሠራት አለበት?';

  @override
  String get taskNameEmpty => 'እባክዎ የተግባር ስም ያስገቡ';

  @override
  String get taskDescriptionLabel => 'መግለጫ';

  @override
  String get taskDeleted => 'ተግባሩ ተሰርዟል';

  @override
  String get taskCompleted => 'ተጠናቋል';

  @override
  String get taskReopened => 'እንደገና ተከፍቷል';

  @override
  String get taskStatusOpen => 'ክፍት';

  @override
  String get taskStatusCompleted => 'ተጠናቋል';

  @override
  String get taskNoDescription => 'መግለጫ የለም።';

  @override
  String get taskDetailStatus => 'ሁኔታ';

  @override
  String get taskDetailCreated => 'የተፈጠረው';

  @override
  String get taskDetailCompleted => 'የተጠናቀቀው';

  @override
  String get taskDetailDue => 'ቀነ ገደብ';

  @override
  String get taskDetailRepeats => 'ድግግሞሽ';

  @override
  String get taskStatusDone => 'ተጠናቋል';

  @override
  String get taskStatusInProgress => 'በሂደት ላይ';

  @override
  String get taskDueLabel => 'ቀነ ገደብ';

  @override
  String get taskDueNone => 'ቀነ ገደብ የለም';

  @override
  String get taskDueAddTime => 'ሰዓት ጨምር';

  @override
  String get taskDueClear => 'አጽዳ';

  @override
  String get taskRepeatLabel => 'ድግግሞሽ';

  @override
  String get repeatNone => 'አይደገምም';

  @override
  String get repeatDaily => 'በየቀኑ';

  @override
  String get repeatWeekly => 'በየሳምንቱ';

  @override
  String get repeatMonthly => 'በየወሩ';

  @override
  String get repeatYearly => 'በየዓመቱ';

  @override
  String taskNameLength(int count) {
    return '$count/120';
  }

  @override
  String taskChecklistProgress(int done, int total) {
    return '$done/$total';
  }

  @override
  String get taskAutoCompleted => 'ሁሉም ተመርጠዋል — ተግባሩ ተጠናቋል';

  @override
  String get taskPromoted => 'እንደ ራሱ ተግባር ተጨምሯል';

  @override
  String get dueOverdue => 'ጊዜው አልፏል';

  @override
  String get dueToday => 'ዛሬ';

  @override
  String get dueTomorrow => 'ነገ';

  @override
  String dueInDays(int days) {
    return 'በ$days ቀናት ውስጥ';
  }

  @override
  String get richChecklist => 'ማረጋገጫ ዝርዝር';

  @override
  String get richBullet => 'ነጥብ';

  @override
  String get richNumbered => 'ቁጥር';

  @override
  String get richHeading => 'ርዕስ';

  @override
  String get richQuote => 'ጥቅስ';

  @override
  String get richIndent => 'ወደ ውስጥ';

  @override
  String get richOutdent => 'ወደ ውጭ';

  @override
  String get richClearChecked => 'የተመረጡትን አጽዳ';

  @override
  String get richMoveToTop => 'ወደ ላይ አውጣ';

  @override
  String get richMakeOwnTask => 'የራሱ ተግባር አድርግ';

  @override
  String get richEditItem => 'ንጥሉን አስተካክል';

  @override
  String get richConvertPrompt => 'የተለጠፉት መስመሮች ወደ ማረጋገጫ ዝርዝር ይቀየሩ?';

  @override
  String get richConvert => 'ቀይር';

  @override
  String get richDescriptionHint => 'ማስታወሻ፣ ደረጃዎች፣ ሊንኮች ያክሉ…';

  @override
  String get richReorder => 'ቅደም ተከተል ለመቀየር ይጎትቱ';

  @override
  String get ledgerPersonLabel => 'ሰው';

  @override
  String get ledgerPersonHint => 'ማን?';

  @override
  String get ledgerAmountLabel => 'መጠን';

  @override
  String get ledgerDateGiven => 'ቀን';

  @override
  String get ledgerNoteLabel => 'ማስታወሻ';

  @override
  String get ledgerNewEntry => 'አዲስ ግቤት';

  @override
  String get ledgerEditEntry => 'ግቤት አስተካክል';

  @override
  String get ledgerAddEntry => 'ግቤት ጨምር';

  @override
  String get ledgerAmountInvalid => 'ከዜሮ የሚበልጥ መጠን ያስገቡ';

  @override
  String get ledgerPersonEmpty => 'እባክዎ ስም ያስገቡ';

  @override
  String ledgerPaidLeft(String paid, String left) {
    return '$paid ተከፍሏል · $left ቀሪ';
  }

  @override
  String get ledgerSettled => 'ተዘግቷል';

  @override
  String get ledgerSettledOn => 'የተዘጋበት';

  @override
  String get ledgerOpen => 'ክፍት';

  @override
  String get ledgerOutstanding => 'ቀሪ';

  @override
  String get ledgerTotal => 'ጠቅላላ';

  @override
  String get ledgerPaid => 'የተከፈለ';

  @override
  String get ledgerPayments => 'ክፍያዎች';

  @override
  String get ledgerNoPayments => 'እስካሁን ምንም ክፍያ የለም።';

  @override
  String get ledgerRecordPayment => 'ክፍያ መዝግብ';

  @override
  String get ledgerPaymentAmount => 'የክፍያ መጠን';

  @override
  String get ledgerPaymentNote => 'ማስታወሻ (አማራጭ)';

  @override
  String get ledgerPaymentRecorded => 'ክፍያው ተመዝግቧል';

  @override
  String get ledgerPaymentDeleted => 'ክፍያው ተወግዷል';

  @override
  String get ledgerRemind => 'አስታውስ';

  @override
  String ledgerRemindMessage(String person, String amount, String date) {
    return 'ሰላም $person፣ ከ$date ጀምሮ ስላለው $amount ለማስታወስ ያህል ነው። አመሰግናለሁ!';
  }

  @override
  String get ledgerSettle => 'ሂሳብ ዝጋ';

  @override
  String get ledgerSettledToast => 'ሂሳቡ ተዘግቷል';

  @override
  String ledgerDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'ከ$days ቀናት በፊት',
      one: 'ትናንት',
      zero: 'ዛሬ',
    );
    return '$_temp0';
  }

  @override
  String get ledgerNet => 'የተጣራ';

  @override
  String ledgerNetLabel(String amount) {
    return 'የተጣራ $amount';
  }

  @override
  String get ledgerAllSquare => 'ምንም ዕዳ የለም';

  @override
  String get ledgerHidden => '••••';

  @override
  String get convertTitle => 'ወደ ሂሳብ መዝገብ ቀይር';

  @override
  String get convertBody =>
      'እያንዳንዱ ተግባር ግቤት ይሆናል። እንደ \"አበበ – 500\" ያሉ ስሞች ወደ ሰው እና መጠን ይለያሉ። ከመተግበርዎ በፊት ቅድመ እይታውን ያረጋግጡ።';

  @override
  String get convertNoAmount => 'መጠን የለም';

  @override
  String get peopleTitle => 'ሰዎች';

  @override
  String get peopleEmpty =>
      'እስካሁን ምንም የገንዘብ ግቤት የለም። ማን ለማን ዕዳ እንዳለበት ለመከታተል የገንዘብ ዝርዝር ይፍጠሩ።';

  @override
  String peopleEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ግቤቶች',
      one: '1 ግቤት',
    );
    return '$_temp0';
  }

  @override
  String get searchHint => 'ተግባሮችን፣ ማስታወሻዎችን፣ ሰዎችን ይፈልጉ…';

  @override
  String searchEmpty(String query) {
    return 'ከ\"$query\" ጋር የሚዛመድ ምንም የለም';
  }

  @override
  String get searchPrompt => 'በሁሉም ምድቦች ውስጥ ለመፈለግ ይጻፉ።';

  @override
  String get todayTitle => 'ዛሬ';

  @override
  String get todayEmpty => 'ዛሬ ምንም የሚደርስ ነገር የለም። በእርጋታው ይደሰቱ።';

  @override
  String todayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ዛሬ የሚደርሱ',
      one: '1 ዛሬ የሚደርስ',
    );
    return '$_temp0';
  }

  @override
  String todayOverdueCount(int count) {
    return '$count ጊዜያቸው ያለፈ';
  }

  @override
  String get historyTitle => 'ታሪክ';

  @override
  String get historyEmptyTitle => 'እዚህ ምንም የለም';

  @override
  String get historyEmptyBody => 'የተሰረዙ ምድቦች እዚህ ይቀመጣሉ። መመለስ ወይም መተው ይችላሉ።';

  @override
  String historyRestored(String name) {
    return '\"$name\" ተመልሷል';
  }

  @override
  String historyPurged(String name) {
    return '\"$name\" ለዘለቄታው ተሰርዟል';
  }

  @override
  String get historyDeleteForever => 'ለዘለቄታው ሰርዝ';

  @override
  String get historyDeleteForeverTitle => 'ለዘለቄታው ይሰረዝ?';

  @override
  String historyDeleteForeverBody(String name) {
    return 'ይህ ሊቀለበስ አይችልም። \"$name\" እና ተግባሮቹ ይጠፋሉ።';
  }

  @override
  String historyTaskCount(int count, int done) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ተግባሮች',
      one: '1 ተግባር',
    );
    return '$_temp0 · $done ተጠናቋል';
  }

  @override
  String historyDeletedOn(String date) {
    return '$date ተሰርዟል';
  }

  @override
  String get historyClearAll => 'ታሪክ አጽዳ';

  @override
  String get historyClearAllBody =>
      'በታሪክ ውስጥ ያሉ ሁሉም ምድቦች ይጠፋሉ። ይህ ሊቀለበስ አይችልም።';

  @override
  String get settingsTitle => 'ቅንብሮች';

  @override
  String get settingsAppearance => 'መልክ';

  @override
  String get settingsTheme => 'ገጽታ';

  @override
  String get settingsThemeSystem => 'የስርዓቱ';

  @override
  String get settingsThemeLight => 'ብሩህ';

  @override
  String get settingsThemeDark => 'ጨለማ';

  @override
  String get settingsLanguage => 'ቋንቋ';

  @override
  String get settingsLanguageSystem => 'የስርዓቱ ነባሪ';

  @override
  String get settingsEthiopianCalendar => 'የኢትዮጵያ ቀን መቁጠሪያ';

  @override
  String get settingsEthiopianCalendarBody =>
      'ቀኖችን ከሴፕቴምበር 25 ይልቅ እንደ መስከረም 15 አሳይ።';

  @override
  String get settingsGestures => 'እንቅስቃሴዎች እና ዝርዝሮች';

  @override
  String get settingsSwipeRight => 'ተግባር ላይ ወደ ቀኝ ሲያንሸራትቱ';

  @override
  String get settingsSwipeComplete => 'አጠናቅ';

  @override
  String get settingsSwipeEdit => 'አስተካክል';

  @override
  String get settingsAutoComplete => 'ማረጋገጫ ዝርዝሩ ሲያልቅ ተግባሩን አጠናቅ';

  @override
  String get settingsSinkChecked => 'የተመረጡትን ንጥሎች ወደ ታች አውርድ';

  @override
  String get settingsMoney => 'ገንዘብ';

  @override
  String get settingsCurrency => 'ነባሪ የገንዘብ ዓይነት';

  @override
  String get settingsPrivacy => 'የግላዊነት ሁነታ';

  @override
  String get settingsPrivacyBody => 'እስኪነኩ ድረስ መጠኖችን ደብቅ።';

  @override
  String get settingsReminders => 'አስታዋሾች';

  @override
  String get settingsRemindersEnabled => 'የቀነ ገደብ አስታዋሾች';

  @override
  String get settingsRemindersBody =>
      'በቀነ ገደቡ ሰዓት፣ ወይም ሙሉ ቀን ለሆኑ ተግባሮች ጠዋት 3 ሰዓት (9:00) ላይ አሳውቅ።';

  @override
  String get settingsWeeklyDigest => 'ሳምንታዊ የገንዘብ ማጠቃለያ';

  @override
  String get settingsWeeklyDigestBody => 'ሰኞ ጠዋት የክፍት ብድሮች ማጠቃለያ።';

  @override
  String get settingsNotificationsDenied =>
      'በስርዓት ቅንብሮች ውስጥ ለTooran ማሳወቂያዎች ጠፍተዋል።';

  @override
  String get settingsSecurity => 'ደህንነት';

  @override
  String get settingsAppLock => 'የመተግበሪያ ቁልፍ';

  @override
  String get settingsAppLockBody => 'Tooran ሲከፍቱ የጣት አሻራ፣ ፊት ወይም የመሣሪያ ፒን።';

  @override
  String get settingsAppLockUnavailable =>
      'ይህ መሣሪያ የጣት አሻራ፣ ፊት ወይም የማያ ገጽ ቁልፍ አልተዘጋጀለትም።';

  @override
  String get settingsLockAfter => 'እንደገና የሚቆለፍበት ጊዜ';

  @override
  String get settingsLockImmediately => 'ወዲያውኑ';

  @override
  String settingsLockMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ደቂቃ',
      one: '1 ደቂቃ',
    );
    return '$_temp0';
  }

  @override
  String get settingsWidget => 'የመነሻ ገጽ ዊጀት';

  @override
  String get settingsWidgetSource => 'ዊጀቱ የሚያሳየው';

  @override
  String get settingsWidgetFirst => 'የመጀመሪያው ምድብ';

  @override
  String get settingsWidgetToday => 'ዛሬ';

  @override
  String get settingsWidgetHint => 'ለመጨመር የመነሻ ገጽዎን በረጅሙ ይጫኑ → ዊጀቶች → Tooran።';

  @override
  String get settingsBackup => 'ምትኬ';

  @override
  String get settingsExport => 'ምትኬ አውጣ';

  @override
  String get settingsExportBody =>
      '.json ፋይል የትም ያስቀምጡ — Drive፣ Telegram፣ Files።';

  @override
  String get settingsImport => 'ምትኬ አስገባ';

  @override
  String get settingsImportBody => 'ከ.json ፋይል መልስ።';

  @override
  String get settingsAutoBackup => 'ሳምንታዊ ራስ-ሰር ምትኬ';

  @override
  String get settingsAutoBackupBody =>
      'የመጨረሻዎቹን 4 ሳምንታዊ ቅጂዎች በዚህ መሣሪያ ላይ ያስቀምጣል።';

  @override
  String settingsAutoBackupLast(String date) {
    return 'የመጨረሻ ምትኬ፦ $date';
  }

  @override
  String get settingsBackupNow => 'አሁን ምትኬ ያዝ';

  @override
  String get settingsBackupDone => 'ምትኬ ተቀምጧል';

  @override
  String get importPreviewTitle => 'ምትኬው ይግባ?';

  @override
  String importPreviewBody(int categories, int tasks) {
    String _temp0 = intl.Intl.pluralLogic(
      categories,
      locale: localeName,
      other: '$categories ምድቦች',
      one: '1 ምድብ',
    );
    String _temp1 = intl.Intl.pluralLogic(
      tasks,
      locale: localeName,
      other: '$tasks ተግባሮች',
      one: '1 ተግባር',
    );
    return 'ይህ ፋይል $_temp0 እና $_temp1 አሉት።';
  }

  @override
  String get importMerge => 'አዋህድ';

  @override
  String get importReplace => 'ተካ';

  @override
  String get importMergeBody =>
      'አዋህድ የጎደሉትን ይጨምራል። ተካ መጀመሪያ አሁን ያሉትን ዝርዝሮችዎን ይሰርዛል።';

  @override
  String get importDone => 'ምትኬው ገብቷል';

  @override
  String get importInvalid => 'ይህ ፋይል የTooran ምትኬ አይደለም';

  @override
  String get exportSubject => 'የTooran ምትኬ';

  @override
  String get shareReceivedTitle => 'የተጋራ ጽሑፍ ጨምር';

  @override
  String get shareReceivedPick => 'እንደ ተግባር የት ይጨመር?';

  @override
  String shareAdded(String name) {
    return 'ወደ \"$name\" ተጨምሯል';
  }

  @override
  String get shareNoCategories => 'መጀመሪያ ምድብ ይፍጠሩ፣ ከዚያ እንደገና ያጋሩ።';

  @override
  String get lockTitle => 'Tooran ተቆልፏል';

  @override
  String get lockUnlock => 'ክፈት';

  @override
  String get lockReason => 'Tooran ክፈት';

  @override
  String get notifChannelName => 'አስታዋሾች';

  @override
  String get notifChannelDescription => 'የቀነ ገደብ አስታዋሾች እና ሳምንታዊ የገንዘብ ማጠቃለያ';

  @override
  String notifDueBody(String category) {
    return 'ጊዜው ደርሷል · $category';
  }

  @override
  String notifLedgerDueBody(String person, String amount) {
    return '$person · $amount ዛሬ ይደርሳል';
  }

  @override
  String get notifDigestTitle => 'የዚህ ሳምንት ገንዘብዎ';

  @override
  String notifDigestBody(int count, String net) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ክፍት ብድሮች',
      one: '1 ክፍት ብድር',
      zero: 'ምንም ክፍት ብድር የለም',
    );
    return '$_temp0 · የተጣራ $net';
  }

  @override
  String widgetLeft(int count) {
    return '$count ቀሪ';
  }

  @override
  String get widgetEmpty => 'ሁሉም ተጠናቋል ✓';

  @override
  String get widgetNoCategories => 'ምድብ ለመፍጠር Tooran ይክፈቱ';

  @override
  String get helpTitle => 'እገዛ';

  @override
  String get helpTroubleshooting => 'ችግር መፍቻ';

  @override
  String get helpGestureTapCategory => 'ምድብ ይንኩ';

  @override
  String get helpGestureTapCategoryBody => 'ከሥሩ ያሉትን ተግባሮች ይዘረጋል።';

  @override
  String get helpGestureCircle => 'ሳጥኑን ይንኩ';

  @override
  String get helpGestureCircleBody =>
      'ተግባሩን እንደተጠናቀቀ ምልክት ያደርጋል። በሂሳብ መዝገብ ውስጥ ግቤቱን ይዘጋል።';

  @override
  String get helpGestureTapTask => 'ተግባር ይንኩ';

  @override
  String get helpGestureTapTaskBody =>
      'ሙሉ መግለጫውን፣ ማረጋገጫ ዝርዝሩን እና ዝርዝሮቹን ይከፍታል።';

  @override
  String get helpGestureLongPress => 'በረጅሙ መጫን';

  @override
  String get helpGestureLongPressBody => 'ቅደም ተከተል ለመቀየር ረድፉን ያነሳል።';

  @override
  String get helpGestureSwipe => 'ማንሸራተት';

  @override
  String get helpGestureSwipeBody =>
      'ወደ ቀኝ ለማጠናቀቅ (ወይም ለማስተካከል — ቅንብሮችን ይመልከቱ)። ወደ ግራ ለመሰረዝ፣ መቀልበስም ይቻላል።';

  @override
  String get helpGestureChecklist => 'ማረጋገጫ ዝርዝሮች';

  @override
  String get helpGestureChecklistBody =>
      'በመስመር መጀመሪያ ላይ [ ] ይጻፉ፣ ወይም «ማረጋገጫ ዝርዝር»ን ይጠቀሙ። ንጥሎችን ከተግባሩ ዝርዝሮች ላይ ምልክት ያድርጉ።';

  @override
  String get helpFaqMissing => 'ተግባሮቼ ጠፍተዋል';

  @override
  String get helpFaqMissingBody =>
      'ተግባሮች በራሳቸው ይቀመጣሉ። ምድብ ከጠፋ ታሪክን ይመልከቱ — የተሰረዙ ምድቦች ከዚያ ሊመለሱ ይችላሉ። ቅንብሮች → ምትኬ አስገባ የወጣ ፋይልን ይመልሳል።';

  @override
  String get helpFaqTheme => 'ገጽታው አይቀየርም';

  @override
  String get helpFaqThemeBody => 'ከላይ ባለው አሞሌ የፀሐይ/ጨረቃ ምልክቱን ይንኩ። ምርጫዎ ይታወሳል።';

  @override
  String get helpFaqReorder => 'ቅደም ተከተል መቀየር አልተቻለም';

  @override
  String get helpFaqReorderBody =>
      'መጀመሪያ ረድፉን በረጅሙ ይጫኑ፣ ከዚያ ይጎትቱ። የምድብ ተግባሮችን ለመደርደር ምድቡ መዘርጋት አለበት። በመጠን ወይም በቀን የተደረደሩ የሂሳብ መዝገቦች መጎተት አይችሉም — ደርድርን ወደ «በእጅ» ይቀይሩ።';

  @override
  String get helpFaqReminders => 'አስታዋሾች አይታዩም';

  @override
  String get helpFaqRemindersBody =>
      'በስርዓት ቅንብሮች ውስጥ ለTooran ማሳወቂያዎችን ይፍቀዱ፤ ስልክዎ ማንቂያዎችን የሚያዘገይ ከሆነም ለTooran የባትሪ ማመቻቸትን ያጥፉ።';

  @override
  String get helpLocalFirst =>
      'Tooran በመሣሪያዎ ላይ ይሠራል። እርስዎ ካልፈቀዱ በስተቀር ዝርዝሮችዎ ከመሣሪያዎ አይወጡም።';

  @override
  String get aboutTitle => 'ስለ Tooran';

  @override
  String aboutVersion(String version) {
    return 'ስሪት $version';
  }

  @override
  String get aboutIntro =>
      'Tooran በመሣሪያዎ ላይ የሚሠራ የተግባር አደራጅ ነው። ምድቦች ተግባሮችን ይይዛሉ። ተግባሮች መግለጫ አላቸው። ምንም ነገር ከመሣሪያዎ አይወጣም። ምርታማነት፣ በእርጋታ።';

  @override
  String get aboutWhatItDoes => 'ምን ይሠራል';

  @override
  String get aboutFeatureCategories => 'ምድቦች';

  @override
  String get aboutFeatureCategoriesBody => 'ቅርብ ለሚያደርጓቸው ነገሮች የሚሆን አቃፊ።';

  @override
  String get aboutFeatureTasks => 'ተግባሮች';

  @override
  String get aboutFeatureTasksBody => 'ስሞች፣ ማረጋገጫ ዝርዝሮች፣ ቀነ ገደቦች፣ ረጋ ያለ እድገት።';

  @override
  String get aboutFeatureLedger => 'ገንዘብ';

  @override
  String get aboutFeatureLedgerBody => 'ማን ለማን ዕዳ እንዳለበት፣ ከፊል ክፍያዎች፣ አስታዋሾች።';

  @override
  String get aboutFeatureDrag => 'ጎትቶ ማስቀመጥ';

  @override
  String get aboutFeatureDragBody => 'ለማንሳት በረጅሙ ይጫኑ። የትም ያስቀምጡ።';

  @override
  String get aboutFeatureHistory => 'ታሪክ';

  @override
  String get aboutFeatureHistoryBody => 'የተሰረዙ ምድቦች ሊመለሱ ይችላሉ።';

  @override
  String get aboutFeatureThemes => 'ገጽታዎች';

  @override
  String get aboutFeatureThemesBody => 'ቀን ሞቅ ያለ ወረቀት። ማታ ጥቁር ቀለም።';

  @override
  String get aboutFeatureLocal => 'በመሣሪያዎ ላይ';

  @override
  String get aboutFeatureLocalBody => 'ክላውድ የለም፣ መግቢያ የለም፣ ክትትል የለም።';

  @override
  String get aboutCraftedBy => 'የሠራው';

  @override
  String get aboutCraftedByBody =>
      'Jiru Gutema፣ አዲስ አበባ ዩኒቨርሲቲ። በጥንቃቄ፣ በFlutter፣ በአንድ ጸጥ ያለ ምሽት የተሠራ።';

  @override
  String get aboutRights => 'መብቱ በሕግ የተጠበቀ ነው';

  @override
  String get contactTitle => 'ያግኙን';

  @override
  String get contactEmail => 'ኢሜይል';

  @override
  String get contactEmailDetail => 'ለጥያቄዎች እና ለድጋፍ';

  @override
  String get contactWebsite => 'ድረ-ገጽ';

  @override
  String get contactWebsiteDetail => 'ዝማኔዎች እና ዜናዎች';

  @override
  String get contactSource => 'ምንጭ ኮድ';

  @override
  String get contactSourceDetail => 'ኮዱን ያንብቡ፣ ማሻሻያ ይላኩ';

  @override
  String get contactDeveloper => 'ገንቢው';

  @override
  String get contactDeveloperRole => 'የሶፍትዌር ገንቢ · አዲስ አበባ ዩኒቨርሲቲ';

  @override
  String get contactDeveloperBio =>
      'የሚያረጋጉ መሣሪያዎችን እየገነባ። ለአስተያየት እና ለትብብር ዝግጁ።';

  @override
  String get contactPortfolio => 'ፖርትፎሊዮ →';

  @override
  String contactCopied(String label) {
    return '$label ተቀድቷል';
  }

  @override
  String get desktopCategories => 'ምድቦች';

  @override
  String get desktopNoCategories => 'እስካሁን ምንም ምድብ የለም። ለመጀመር አንድ ይፍጠሩ።';

  @override
  String get desktopNewCategory => 'አዲስ ምድብ';

  @override
  String get desktopRename => 'ስም ቀይር';

  @override
  String get desktopArchive => 'ወደ ማህደር';

  @override
  String get desktopNoTasksYet => 'እስካሁን ምንም ተግባር የለም';

  @override
  String desktopComplete(int done, int total) {
    return '$done ከ$total ተጠናቋል';
  }

  @override
  String get desktopNothingHere => 'እዚህ እስካሁን ምንም የለም።';

  @override
  String get desktopNothingHereBody => 'ይህን ምድብ በዓላማ ለመሙላት ተግባር ይጨምሩ።';

  @override
  String get desktopBlankA => 'የእርስዎ ';

  @override
  String get desktopBlankWord => 'ባዶ';

  @override
  String get desktopBlankRest => ' ገጽ።';

  @override
  String get desktopBlankBody =>
      'ምድቦች ተግባሮችን ይይዛሉ። ተግባሮች የሚይዙትን ይይዛሉ። ከዚህ በላይ ምንም የለም — ቅርብ ማድረግ ለሚፈልጓቸው ነገሮች በአንድ አቃፊ ይጀምሩ።';

  @override
  String get desktopCreateFirst => 'የመጀመሪያ ምድብዎን ይፍጠሩ';

  @override
  String get categoryTypeShopping => 'ግዢ';

  @override
  String get categoryTypeBills => 'ሂሳቦች';

  @override
  String get categoryTypeSavings => 'የቁጠባ ግብ';

  @override
  String get categoryTypeNotes => 'ማስታወሻዎች';

  @override
  String get categoryTypeOther => 'ሌላ';

  @override
  String get typeTasksDesc => 'ምልክት የሚደረግባቸው ነገሮች';

  @override
  String get typeShoppingDesc => 'ንጥሎች፣ ከአማራጭ ዋጋ ጋር';

  @override
  String get typeBillsDesc => 'በየጊዜው የሚደጋገሙ ክፍያዎች';

  @override
  String get typeSavingsDesc => 'ለአንድ ግብ ይቆጥቡ';

  @override
  String get typeNotesDesc => 'ማስታወሻዎች፣ ያለ ምልክት ማድረጊያ ሳጥን';

  @override
  String get typeOtherDesc => 'የራስዎን የዝርዝር ዓይነት ይሰይሙ';

  @override
  String get categoryCustomTypeLabel => 'የዓይነቱ ስም';

  @override
  String get categoryCustomTypeHint => 'ለምሳሌ፦ የምግብ አዘገጃጀት፣ መጻሕፍት፣ ሐሳቦች';

  @override
  String get categoryTargetLabel => 'የግብ መጠን';

  @override
  String get categoryLedgerLockedHint =>
      'እነዚህን ተግባሮች ወደ ገንዘብ ግቤቶች ለመቀየር ⋮ → «ወደ ሂሳብ መዝገብ ቀይር…»ን ይጠቀሙ።';

  @override
  String summaryShopping(int done, int total, String amount) {
    return '$done/$total · $amount ቀሪ';
  }

  @override
  String summaryBills(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ያልተከፈሉ',
      one: '1 ያልተከፈለ',
      zero: 'ሁሉም ተከፍሏል',
    );
    return '$_temp0 · $amount';
  }

  @override
  String summarySavings(String saved, String target) {
    return '$saved ከ$target';
  }

  @override
  String summarySavingsNoTarget(String saved) {
    return '$saved ተቆጥቧል';
  }

  @override
  String summaryNotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ማስታወሻዎች',
      one: '1 ማስታወሻ',
      zero: 'እስካሁን ምንም ማስታወሻ የለም',
    );
    return '$_temp0';
  }

  @override
  String get fieldItem => 'ንጥል';

  @override
  String get fieldItemHint => 'ምን ይገዛ?';

  @override
  String get fieldPrice => 'ዋጋ (አማራጭ)';

  @override
  String get fieldBill => 'ሂሳብ';

  @override
  String get fieldBillHint => 'መብራት፣ ኪራይ፣ ኢንተርኔት…';

  @override
  String get fieldBillAmount => 'መጠን (አማራጭ)';

  @override
  String get fieldTitle => 'ርዕስ';

  @override
  String get fieldTitleHint => 'የማስታወሻው ርዕስ';

  @override
  String get fieldNoteBody => 'ማስታወሻ';

  @override
  String get fieldDeposit => 'መግለጫ';

  @override
  String get savingsDepositDefault => 'ተቀማጭ';

  @override
  String get addItem => 'ንጥል ጨምር';

  @override
  String get addBill => 'ሂሳብ ጨምር';

  @override
  String get addDeposit => 'ተቀማጭ ጨምር';

  @override
  String get addNote => 'ማስታወሻ ጨምር';

  @override
  String get newItem => 'አዲስ ንጥል';

  @override
  String get newBill => 'አዲስ ሂሳብ';

  @override
  String get newDeposit => 'አዲስ ተቀማጭ';

  @override
  String get newNote => 'አዲስ ማስታወሻ';

  @override
  String get editEntry => 'አስተካክል';

  @override
  String get commonAdd => 'ጨምር';

  @override
  String get detailAmount => 'መጠን';

  @override
  String get detailPrice => 'ዋጋ';

  @override
  String get settingsColorTheme => 'የቀለም ገጽታ';

  @override
  String get settingsCorners => 'ማዕዘኖች';

  @override
  String get cornersTheme => 'የገጽታው ነባሪ';

  @override
  String get cornersSharp => 'ሹል';

  @override
  String get cornersRounded => 'የተጠጋጋ';

  @override
  String get cornersRound => 'በጣም የተጠጋጋ';

  @override
  String get settingsCardStyle => 'ካርዶች';

  @override
  String get cardsTheme => 'የገጽታው ነባሪ';

  @override
  String get cardsOutlined => 'ባለ ጠርዝ መስመር';

  @override
  String get cardsElevated => 'ጥላ';

  @override
  String get cardsFilled => 'የተሞላ';

  @override
  String get themeHorizon => 'አድማስ';

  @override
  String get themeOcean => 'ውቅያኖስ';

  @override
  String get themeForest => 'ደን';

  @override
  String get themeSunset => 'ጀምበር ስትጠልቅ';

  @override
  String get themeLavender => 'ላቬንደር';

  @override
  String get themeGraphite => 'ግራፋይት';

  @override
  String ledgerNewEntryFor(String name) {
    return 'ለ$name አዲስ ግቤት';
  }

  @override
  String ledgerEntryOn(String date) {
    return 'ግቤት · $date';
  }

  @override
  String get ledgerPlusTotal => '+ ድምር';

  @override
  String get ledgerMinusTotal => '− ድምር';

  @override
  String get categoryTypeMoney => 'ገንዘብ';

  @override
  String get typeMoneyDesc => 'ማን ለማን ዕዳ አለበት፦ + እነሱ ይመልሳሉ፣ − እርስዎ ይመልሳሉ';

  @override
  String get ledgerCaptionOwesYou => 'ይመልስልዎታል';

  @override
  String get ledgerCaptionYouOwe => 'ይመልሳሉ';

  @override
  String get moneySignPlus => '+ እነሱ ይመልሳሉ';

  @override
  String get moneySignMinus => '− እኔ እመልሳለሁ';

  @override
  String get moneySignHelp => '+ አበድረዋል ወይም ተበድረዋል · − ተበድረዋል ወይም መልሰውልዎታል';

  @override
  String get categoryMergeLedgers => 'የገንዘብ ዝርዝሮችን አዋህድ…';

  @override
  String get mergeTitle => 'ወደ አንድ ዝርዝር አዋህድ';

  @override
  String get mergeBody =>
      'የተመረጡት ዝርዝሮች አንድ የገንዘብ ዝርዝር ይሆናሉ። የእያንዳንዱ ሰው ግቤቶች ይጣመራሉ፣ ሌሎቹ ዝርዝሮች ወደ ታሪክ ይሄዳሉ።';

  @override
  String get mergeNameLabel => 'የዝርዝሩ ስም';

  @override
  String get mergeApply => 'አዋህድ';

  @override
  String mergePeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ሰዎች',
      one: '1 ሰው',
    );
    return 'ከውህደት በኋላ $_temp0';
  }

  @override
  String mergeDone(String name) {
    return 'ወደ «$name» ተዋህዷል';
  }

  @override
  String duplicatePersonHint(String name, String category) {
    return '$name አስቀድሞ በ«$category» ውስጥ አለ።';
  }

  @override
  String duplicatePersonAction(String sign) {
    return 'እዚያ እንደ $sign ጨምር';
  }

  @override
  String get ledgerPresetMoney => 'ገንዘብ';

  @override
  String get taskAddAnother => 'ሌላ ጨምር';

  @override
  String get richBold => 'ደማቅ';

  @override
  String get richItalic => 'ሰያፍ';

  @override
  String get richCode => 'ኮድ';

  @override
  String get richLink => 'ሊንክ';

  @override
  String get richPreview => 'ቅድመ እይታ';

  @override
  String get richEdit => 'አርትዕ';

  @override
  String get helpMarkdown => 'ማርክዳውን';

  @override
  String get helpMarkdownBody =>
      'ማስታወሻዎች ማርክዳውንን ይደግፋሉ፦ **ደማቅ**፣ *ሰያፍ*፣ ~~የተሰረዘ~~፣ `ኮድ`፣ [ሊንክ](https://…)፣ # ርዕሶች፣ > ጥቅሶች፣ ``` የኮድ ክፍሎች እና | ሰንጠረዦች |። እንዴት እንደሚታይ ለማየት ቅድመ እይታን ይጠቀሙ።';

  @override
  String get categoryTypeSpending => 'ወጪ';

  @override
  String get typeSpendingDesc => 'የሚያወጡት ገንዘብ፣ ከአማራጭ በጀት ጋር';

  @override
  String get addExpense => 'ወጪ ጨምር';

  @override
  String get newExpense => 'አዲስ ወጪ';

  @override
  String get fieldExpenseFor => 'ለምን (አማራጭ)';

  @override
  String get fieldExpenseForHint => 'ምሳ፣ ታክሲ፣ ሸቀጥ…';

  @override
  String get fieldTag => 'ዓይነት';

  @override
  String get tagFood => 'ምግብ';

  @override
  String get tagTransport => 'ትራንስፖርት';

  @override
  String get tagHome => 'ቤት';

  @override
  String get tagBills => 'ሂሳቦች';

  @override
  String get tagShopping => 'ግዢ';

  @override
  String get tagHealth => 'ጤና';

  @override
  String get tagFun => 'መዝናኛ';

  @override
  String get tagFamily => 'ቤተሰብ';

  @override
  String get tagEducation => 'ትምህርት';

  @override
  String get tagOther => 'ሌላ';

  @override
  String get categoryBudgetLabel => 'ወርሃዊ በጀት (አማራጭ)';

  @override
  String get spendToday => 'ዛሬ';

  @override
  String get spendWeek => 'በዚህ ሳምንት';

  @override
  String get spendMonth => 'በዚህ ወር';

  @override
  String spendVsLastMonth(String percent) {
    return 'ካለፈው ወር $percent';
  }

  @override
  String spendBudgetLeft(String amount, String budget) {
    return 'ከ$budget $amount ቀርቷል';
  }

  @override
  String spendBudgetOver(String amount) {
    return 'ከበጀት $amount በልጧል';
  }

  @override
  String summarySpending(String today, String month) {
    return 'ዛሬ $today · ወር $month';
  }

  @override
  String summarySpendingBudget(String today, String month, String budget) {
    return 'ዛሬ $today · $month ከ$budget';
  }

  @override
  String get spendYesterday => 'ትናንት';

  @override
  String get spendAddAgain => 'ዛሬ እንደገና ጨምር';

  @override
  String get spendAddedAgain => 'ለዛሬ እንደገና ተጨምሯል';

  @override
  String spendBudgetWarn(String percent) {
    return 'የዚህን ወር በጀት $percent ተጠቅመዋል';
  }

  @override
  String spendBudgetOverToast(String amount) {
    return 'የዚህ ወር በጀት በ$amount አልፏል';
  }

  @override
  String get categoryShareCsv => 'እንደ CSV አጋራ';

  @override
  String get spendingNoEntries => 'እስካሁን ወጪ የለም · ለመመዝገብ ከታች ይንኩ';

  @override
  String get settingsSpending => 'ወጪ';

  @override
  String get settingsSpendingReminder => 'የዕለት ወጪ ማስታወሻ';

  @override
  String get settingsSpendingReminderBody =>
      'የዛሬውን ወጪ እንዲመዘግቡ ያስታውሳል። አስቀድመው በመዘገቡባቸው ቀናት አይላክም።';

  @override
  String get settingsSpendingReminderTime => 'የማስታወሻ ሰዓት';

  @override
  String get notifSpendingTitle => 'የዛሬውን ወጪ ይመዝግቡ';

  @override
  String get notifSpendingBody => 'ዛሬ ያወጡትን ለመጨመር ይንኩ።';

  @override
  String get overviewTitle => 'አጠቃላይ እይታ';

  @override
  String get periodWeek => 'ሳምንት';

  @override
  String get periodMonth => 'ወር';

  @override
  String get periodYear => 'ዓመት';

  @override
  String get periodCustom => 'ብጁ';

  @override
  String get kpiTotal => 'ድምር';

  @override
  String get kpiDailyAvg => 'በቀን';

  @override
  String get kpiCount => 'ወጪዎች';

  @override
  String get kpiVsPrev => 'ካለፈው ጋር';

  @override
  String get chartOverTime => 'ወጪ በጊዜ ሂደት';

  @override
  String get chartByTag => 'በዓይነት';

  @override
  String get calendarTitle => 'የቀን መቁጠሪያ';

  @override
  String get searchExpenses => 'ወጪዎችን ፈልግ…';

  @override
  String get clearFilters => 'ማጣሪያዎችን አጽዳ';

  @override
  String get noMatches => 'ከነዚህ ማጣሪያዎች ጋር የሚዛመድ የለም።';

  @override
  String get moneyKpiOwedToYou => 'የሚመለስልዎት';

  @override
  String get moneyKpiYouOwe => 'ያለብዎት';

  @override
  String get moneyKpiPeople => 'ሰዎች';

  @override
  String get chartByPerson => 'ሂሳብ በሰው';

  @override
  String get chartFlow => 'የገንዘብ ፍሰት · ያለፉት 6 ወራት';

  @override
  String get legendPlus => '+ ያበደሩት / የሚመለስልዎት';

  @override
  String get legendMinus => '− የተበደሩት / የተመለሰ';

  @override
  String get filterOpen => 'ክፍት';

  @override
  String get filterSettled => 'የተዘጋ';

  @override
  String get filterAll => 'ሁሉም';

  @override
  String get sortName => 'ስም';

  @override
  String get searchPeople => 'ሰዎችን ፈልግ…';

  @override
  String overviewOldest(String date) {
    return 'በጣም የቆየ ክፍት ግቤት፦ $date';
  }

  @override
  String get chartTapHint => 'ዝርዝሩን ለማጣራት አምድ ይንኩ';
}
