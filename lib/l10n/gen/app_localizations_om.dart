// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Oromo (`om`).
class AppLocalizationsOm extends AppLocalizations {
  AppLocalizationsOm([String locale = 'om']) : super(locale);

  @override
  String get appTitle => 'Tooran';

  @override
  String get commonCancel => 'Dhiisi';

  @override
  String get commonSave => 'Olkaa\'i';

  @override
  String get commonDelete => 'Haqi';

  @override
  String get commonUndo => 'Deebisi';

  @override
  String get commonDone => 'Xumurame';

  @override
  String get commonEdit => 'Gulaali';

  @override
  String get commonShare => 'Qoodi';

  @override
  String get commonClose => 'Cufi';

  @override
  String get commonCreate => 'Uumi';

  @override
  String get commonRestore => 'Deebisi';

  @override
  String get commonShow => 'Agarsiisi';

  @override
  String get commonHide => 'Dhoksi';

  @override
  String get commonApply => 'Hojiirra oolchi';

  @override
  String get commonNone => 'Homaa';

  @override
  String get commonNameLabel => 'MAQAA';

  @override
  String get loading => 'Fe\'amaa jira…';

  @override
  String get errorSave => 'Jijjiirama olkaa\'uun hin danda\'amne';

  @override
  String get errorLoad => 'Hojiiwwan kee fe\'uun hin danda\'amne';

  @override
  String get menuSearch => 'Barbaadi';

  @override
  String get menuToday => 'Har\'a';

  @override
  String get menuPeople => 'Namoota';

  @override
  String get menuHistory => 'Seenaa';

  @override
  String get menuSettings => 'Qindaa\'ina';

  @override
  String get menuHelp => 'Gargaarsa';

  @override
  String get menuContact => 'Quunnamtii';

  @override
  String get menuAbout => 'Waa\'ee Tooran';

  @override
  String get menuUpdates => 'Haaromsa ilaali';

  @override
  String get menuExpandAll => 'Hunda bal\'isi';

  @override
  String get menuCollapseAll => 'Hunda walitti qabi';

  @override
  String get tooltipMore => 'Dabalata';

  @override
  String get tooltipMenu => 'Baafata';

  @override
  String get tooltipTheme => 'Bifa';

  @override
  String get fabCategory => 'Ramaddii';

  @override
  String get emptyTitle => 'Ammaaf ramaddiin hin jiru';

  @override
  String get emptyBody =>
      'Ramaddii kee isa jalqabaa uumuuf furtuu armaan gadii tuqi. Bakka wantoota siif dhihoo ta\'uu barbaadduuf.';

  @override
  String get emptyLedgerPreset => 'Hordoffii maallaqaa qopheessi';

  @override
  String get tipsTitle => 'Gorsa gabaabaa';

  @override
  String get tipsBody =>
      'Xumuruuf saanduqa tuqi · haquuf hojii gara bitaatti harkisi · bakka jijjiiruuf dheeressii tuqi · baafata banuuf sarara gubbaa gara mirgaatti harkisi.';

  @override
  String get tipsGotIt => 'Hubadheera';

  @override
  String get categoryNew => 'Ramaddii haaraa';

  @override
  String get categoryEdit => 'Ramaddii gulaali';

  @override
  String get categoryNameHint => 'Jalqaba haaraa…';

  @override
  String get categoryNameEmpty => 'Maaloo maqaa ramaddii galchi';

  @override
  String get categoryNameDuplicate => 'Maqaan kun duraan jira';

  @override
  String get categoryTypeLabel => 'GOSA';

  @override
  String get categoryTypeTasks => 'Hojiiwwan';

  @override
  String get categoryCurrencyLabel => 'MAALLAQA';

  @override
  String get categoryIconLabel => 'MALLATTOO';

  @override
  String get categoryColorLabel => 'HALLUU';

  @override
  String get categoryDeleteTitle => 'Ramaddiin haqamu?';

  @override
  String categoryDeleteBodyTasks(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hojiiwwan isaa $count',
      one: 'hojiin isaa 1',
    );
    return '\"$name\" fi $_temp0 gara seenaatti ce\'u. Achii deebisuu dandeessa.';
  }

  @override
  String categoryDeleteBodyEmpty(String name) {
    return '\"$name\" gara seenaatti ce\'a. Achii deebisuu dandeessa.';
  }

  @override
  String categoryDeleted(String name) {
    return '\"$name\" haqameera';
  }

  @override
  String get categoryNoTasks => 'Ammaaf hojiin hin jiru';

  @override
  String categoryProgress(int done, int total, int left) {
    return '$done/$total · $left hafe';
  }

  @override
  String get categoryNoTasksHint =>
      'Ammaaf hojiin hin jiru · kan jalqabaa dabaluuf gadii tuqi';

  @override
  String get categoryAddTask => 'HOJII DABALI';

  @override
  String get categoryAddEntry => 'GALMEE DABALI';

  @override
  String get categoryPin => 'Olitti qabsiisi';

  @override
  String get categoryUnpin => 'Qabsiisa kaasi';

  @override
  String get categoryHideCompleted => 'Kan xumuraman dhoksi';

  @override
  String get categoryShowCompleted => 'Kan xumuraman agarsiisi';

  @override
  String get categorySinkCompleted => 'Kan xumuraman gara gadiitti';

  @override
  String get categoryClearCompleted => 'Kan xumuraman qulqulleessi';

  @override
  String categoryClearedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hojiiwwan $count qulqulleeffaman',
      one: 'Hojiin 1 qulqulleeffame',
    );
    return '$_temp0';
  }

  @override
  String get categoryShareList => 'Tarree qoodi';

  @override
  String get categoryConvertToLedger => 'Gara herregaatti jijjiiri…';

  @override
  String get categorySort => 'Tartiibsi';

  @override
  String categoryHiddenCompleted(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kan xumuraman $count dhokfaman',
      one: 'Kan xumurame 1 dhokfame',
    );
    return '$_temp0';
  }

  @override
  String categoryHiddenSettled(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Kan kaffalaman $count dhokfaman',
      one: 'Kan kaffalame 1 dhokfame',
    );
    return '$_temp0';
  }

  @override
  String get swipeEdit => 'GULAALI';

  @override
  String get swipeDelete => 'HAQI';

  @override
  String get swipeDone => 'XUMURAME';

  @override
  String get sortManual => 'Harkaan';

  @override
  String get sortLargest => 'Hanga guddaa';

  @override
  String get sortOldest => 'Kan durii dura';

  @override
  String get sortDueSoonest => 'Kan yeroon isaa dhihaate';

  @override
  String get taskNew => 'Hojii haaraa';

  @override
  String get taskEdit => 'Hojii gulaali';

  @override
  String get taskAdd => 'Hojii dabali';

  @override
  String taskAddedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dabalaman',
      one: '1 dabalame',
    );
    return '$_temp0 · barreessuu itti fufi';
  }

  @override
  String get taskNameHint => 'Maaltu hojjetamuu qaba?';

  @override
  String get taskNameEmpty => 'Maaloo maqaa hojii galchi';

  @override
  String get taskDescriptionLabel => 'IBSA';

  @override
  String get taskDeleted => 'Hojiin haqameera';

  @override
  String get taskCompleted => 'Xumurameera';

  @override
  String get taskReopened => 'Irra deebi\'ee banameera';

  @override
  String get taskStatusOpen => 'BANAA';

  @override
  String get taskStatusCompleted => 'XUMURAME';

  @override
  String get taskNoDescription => 'Ibsi hin jiru.';

  @override
  String get taskDetailStatus => 'HAALA';

  @override
  String get taskDetailCreated => 'KAN UUMAME';

  @override
  String get taskDetailCompleted => 'KAN XUMURAME';

  @override
  String get taskDetailDue => 'GUYYAA DHUMAA';

  @override
  String get taskDetailRepeats => 'IRRA DEEBII';

  @override
  String get taskStatusDone => 'Xumurame';

  @override
  String get taskStatusInProgress => 'Adeemsa irra';

  @override
  String get taskDueLabel => 'GUYYAA DHUMAA';

  @override
  String get taskDueNone => 'Guyyaan dhumaa hin jiru';

  @override
  String get taskDueAddTime => 'Sa\'aatii dabali';

  @override
  String get taskDueClear => 'Qulqulleessi';

  @override
  String get taskRepeatLabel => 'IRRA DEEBII';

  @override
  String get repeatNone => 'Irra hin deebi\'u';

  @override
  String get repeatDaily => 'Guyyaa guyyaan';

  @override
  String get repeatWeekly => 'Torban torbaniin';

  @override
  String get repeatMonthly => 'Ji\'a ji\'aan';

  @override
  String get repeatYearly => 'Waggaa waggaan';

  @override
  String taskNameLength(int count) {
    return '$count/120';
  }

  @override
  String taskChecklistProgress(int done, int total) {
    return '$done/$total';
  }

  @override
  String get taskAutoCompleted =>
      'Wanti hundi mallattaa\'eera — hojiin xumurameera';

  @override
  String get taskPromoted => 'Akka hojii mataa isaatti dabalameera';

  @override
  String get dueOverdue => 'Yeroon darbeera';

  @override
  String get dueToday => 'Har\'a';

  @override
  String get dueTomorrow => 'Boru';

  @override
  String dueInDays(int days) {
    return 'Guyyaa $days keessatti';
  }

  @override
  String get richChecklist => 'TARREE MIRKANEESSAA';

  @override
  String get richBullet => 'TUQAA';

  @override
  String get richNumbered => 'LAKKOOFSAAN';

  @override
  String get richHeading => 'MATA DUREE';

  @override
  String get richQuote => 'WABII';

  @override
  String get richIndent => 'GARA KEESSAA';

  @override
  String get richOutdent => 'GARA ALAA';

  @override
  String get richClearChecked => 'Kan mallattaa\'an qulqulleessi';

  @override
  String get richMoveToTop => 'Gara olii baasi';

  @override
  String get richMakeOwnTask => 'Hojii mataa isaa godhi';

  @override
  String get richEditItem => 'Wanta gulaali';

  @override
  String get richConvertPrompt =>
      'Sararoota maxxanfaman gara tarree mirkaneessaatti jijjiiruu?';

  @override
  String get richConvert => 'Jijjiiri';

  @override
  String get richDescriptionHint => 'Yaadannoo, tarkaanfii, liinkii dabali…';

  @override
  String get richReorder => 'Tartiiba jijjiiruuf harkisi';

  @override
  String get ledgerPersonLabel => 'NAMA';

  @override
  String get ledgerPersonHint => 'Eenyu?';

  @override
  String get ledgerAmountLabel => 'HANGA';

  @override
  String get ledgerDateGiven => 'GUYYAA';

  @override
  String get ledgerNoteLabel => 'YAADANNOO';

  @override
  String get ledgerNewEntry => 'Galmee haaraa';

  @override
  String get ledgerEditEntry => 'Galmee gulaali';

  @override
  String get ledgerAddEntry => 'Galmee dabali';

  @override
  String get ledgerAmountInvalid => 'Hanga zeeroo caalu galchi';

  @override
  String get ledgerPersonEmpty => 'Maaloo maqaa galchi';

  @override
  String ledgerPaidLeft(String paid, String left) {
    return '$paid kaffalame · $left hafe';
  }

  @override
  String get ledgerSettled => 'Kaffalameera';

  @override
  String get ledgerSettledOn => 'KAN XUMURAME';

  @override
  String get ledgerOpen => 'BANAA';

  @override
  String get ledgerOutstanding => 'KAN HAFE';

  @override
  String get ledgerTotal => 'WALIIGALA';

  @override
  String get ledgerPaid => 'KAN KAFFALAME';

  @override
  String get ledgerPayments => 'KAFFALTIIWWAN';

  @override
  String get ledgerNoPayments => 'Ammaaf kaffaltiin hin jiru.';

  @override
  String get ledgerRecordPayment => 'Kaffaltii galmeessi';

  @override
  String get ledgerPaymentAmount => 'Hanga kaffaltii';

  @override
  String get ledgerPaymentNote => 'Yaadannoo (filannoo)';

  @override
  String get ledgerPaymentRecorded => 'Kaffaltiin galmaa\'eera';

  @override
  String get ledgerPaymentDeleted => 'Kaffaltiin haqameera';

  @override
  String get ledgerRemind => 'Yaadachiisi';

  @override
  String ledgerRemindMessage(String person, String amount, String date) {
    return 'Akkam $person, waa\'ee $amount $date irraa jiruu yaadachiisuuf qofa. Galatoomi!';
  }

  @override
  String get ledgerSettle => 'Xumuri';

  @override
  String get ledgerSettledToast => 'Akka kaffalameetti mallattaa\'eera';

  @override
  String ledgerDaysAgo(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'guyyaa $days dura',
      one: 'kaleessa',
      zero: 'har\'a',
    );
    return '$_temp0';
  }

  @override
  String get ledgerNet => 'HAFTEE';

  @override
  String ledgerNetLabel(String amount) {
    return 'Haftee $amount';
  }

  @override
  String get ledgerAllSquare => 'walqixa';

  @override
  String get ledgerHidden => '••••';

  @override
  String get convertTitle => 'Gara herregaatti jijjiiri';

  @override
  String get convertBody =>
      'Hojiin hundi galmee ta\'a. Maqaaleen akka \"Abebe – 500\" gara nama fi hangaatti qoodamu. Osoo hojiirra hin oolchin dura agarsiisa duraa ilaali.';

  @override
  String get convertNoAmount => 'hanga hin qabu';

  @override
  String get peopleTitle => 'Namoota';

  @override
  String get peopleEmpty =>
      'Ammaaf galmeen maallaqaa hin jiru. Eenyu eenyuuf idaa akka qabu hordofuuf tarree Maallaqaa uumi.';

  @override
  String peopleEntries(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'galmeewwan $count',
      one: 'galmee 1',
    );
    return '$_temp0';
  }

  @override
  String get searchHint => 'Hojiiwwan, yaadannoo, namoota barbaadi…';

  @override
  String searchEmpty(String query) {
    return 'Wanti \"$query\" waliin walsimu hin jiru';
  }

  @override
  String get searchPrompt => 'Ramaddiiwwan hunda keessa barbaaduuf barreessi.';

  @override
  String get todayTitle => 'Har\'a';

  @override
  String get todayEmpty =>
      'Har\'a wanti yeroon isaa ga\'u hin jiru. Tasgabbiin boqodhu.';

  @override
  String todayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count har\'a ga\'u',
      one: '1 har\'a ga\'a',
    );
    return '$_temp0';
  }

  @override
  String todayOverdueCount(int count) {
    return '$count yeroon darbe';
  }

  @override
  String get historyTitle => 'SEENAA';

  @override
  String get historyEmptyTitle => 'Asitti homaa hin jiru';

  @override
  String get historyEmptyBody =>
      'Ramaddiiwwan haqaman as galu. Deebisuu ykn dhiisuu dandeessa.';

  @override
  String historyRestored(String name) {
    return '\"$name\" deebi\'eera';
  }

  @override
  String historyPurged(String name) {
    return '\"$name\" bara baraan haqameera';
  }

  @override
  String get historyDeleteForever => 'Bara baraan haqi';

  @override
  String get historyDeleteForeverTitle => 'Bara baraan haqamu?';

  @override
  String historyDeleteForeverBody(String name) {
    return 'Kun deebi\'uu hin danda\'u. \"$name\" fi hojiiwwan isaa ni haqamu.';
  }

  @override
  String historyTaskCount(int count, int done) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hojiiwwan $count',
      one: 'hojii 1',
    );
    return '$_temp0 · $done xumurame';
  }

  @override
  String historyDeletedOn(String date) {
    return '$date haqame';
  }

  @override
  String get historyClearAll => 'Seenaa qulqulleessi';

  @override
  String get historyClearAllBody =>
      'Ramaddiiwwan seenaa keessa jiran hundi ni haqamu. Kun deebi\'uu hin danda\'u.';

  @override
  String get settingsTitle => 'QINDAA\'INA';

  @override
  String get settingsAppearance => 'MUL\'ATA';

  @override
  String get settingsTheme => 'Bifa';

  @override
  String get settingsThemeSystem => 'Sirna';

  @override
  String get settingsThemeLight => 'Ifaa';

  @override
  String get settingsThemeDark => 'Dukkana';

  @override
  String get settingsLanguage => 'Afaan';

  @override
  String get settingsLanguageSystem => 'Kan sirnaa';

  @override
  String get settingsEthiopianCalendar => 'Kaaleendarii Itoophiyaa';

  @override
  String get settingsEthiopianCalendarBody =>
      'Guyyaa akka Sep 25 osoo hin taane akka Meskerem 15 agarsiisi.';

  @override
  String get settingsGestures => 'SOCHII FI TARREEWWAN';

  @override
  String get settingsSwipeRight => 'Hojii irratti gara mirgaatti harkisuu';

  @override
  String get settingsSwipeComplete => 'Xumuri';

  @override
  String get settingsSwipeEdit => 'Gulaali';

  @override
  String get settingsAutoComplete =>
      'Yeroo tarreen mirkaneessaa xumuramu hojii xumuri';

  @override
  String get settingsSinkChecked =>
      'Wantoota mallattaa\'an gara gadiitti buusi';

  @override
  String get settingsMoney => 'MAALLAQA';

  @override
  String get settingsCurrency => 'Maallaqa durtii';

  @override
  String get settingsPrivacy => 'Haala dhuunfaa';

  @override
  String get settingsPrivacyBody => 'Hanga tuqamanitti hangawwan dhoksi.';

  @override
  String get settingsReminders => 'YAADACHIISA';

  @override
  String get settingsRemindersEnabled => 'Yaadachiisa guyyaa dhumaa';

  @override
  String get settingsRemindersBody =>
      'Yeroo dhumaatti, ykn hojii guyyaa guutuuf ganama sa\'aatii 3 (9:00) irratti beeksisi.';

  @override
  String get settingsWeeklyDigest => 'Cuunfaa maallaqaa torbanii';

  @override
  String get settingsWeeklyDigestBody => 'Cuunfaa liqaa banaa Wiixata ganama.';

  @override
  String get settingsNotificationsDenied =>
      'Beeksisni Tooran qindaa\'ina sirnaa keessatti cufameera.';

  @override
  String get settingsSecurity => 'NAGEENYA';

  @override
  String get settingsAppLock => 'Cufaa appii';

  @override
  String get settingsAppLockBody =>
      'Yeroo Tooran banattu faana quba, fuula ykn PIN meeshaa.';

  @override
  String get settingsAppLockUnavailable =>
      'Meeshaan kun faana quba, fuula ykn cufaa iskiriinii qindeeffame hin qabu.';

  @override
  String get settingsLockAfter => 'Irra deebi\'ee kan cufamu';

  @override
  String get settingsLockImmediately => 'Battalumatti';

  @override
  String settingsLockMinutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'daqiiqaa $count booda',
      one: 'daqiiqaa 1 booda',
    );
    return '$_temp0';
  }

  @override
  String get settingsWidget => 'WIIJETII FUULA JALQABAA';

  @override
  String get settingsWidgetSource => 'Wiijetiin kan agarsiisu';

  @override
  String get settingsWidgetFirst => 'Ramaddii jalqabaa';

  @override
  String get settingsWidgetToday => 'Har\'a';

  @override
  String get settingsWidgetHint =>
      'Dabaluuf fuula jalqabaa kee dheeressii tuqi → Widgets → Tooran.';

  @override
  String get settingsBackup => 'KUUSAA DUUBAA';

  @override
  String get settingsExport => 'Kuusaa duubaa baasi';

  @override
  String get settingsExportBody =>
      'Faayilii .json bakka barbaadde olkaa\'i — Drive, Telegram, Files.';

  @override
  String get settingsImport => 'Kuusaa duubaa galchi';

  @override
  String get settingsImportBody => 'Faayilii .json irraa deebisi.';

  @override
  String get settingsAutoBackup => 'Kuusaa duubaa torbanii ofumaan';

  @override
  String get settingsAutoBackupBody =>
      'Garagalchaa torbanii 4 dhumaa meeshaa kana irratti olkaa\'a.';

  @override
  String settingsAutoBackupLast(String date) {
    return 'Kuusaa duubaa dhumaa: $date';
  }

  @override
  String get settingsBackupNow => 'Amma kuusi';

  @override
  String get settingsBackupDone => 'Kuusaan duubaa olkaa\'ameera';

  @override
  String get importPreviewTitle => 'Kuusaa duubaa galchuu?';

  @override
  String importPreviewBody(int categories, int tasks) {
    String _temp0 = intl.Intl.pluralLogic(
      categories,
      locale: localeName,
      other: 'ramaddiiwwan $categories',
      one: 'ramaddii 1',
    );
    String _temp1 = intl.Intl.pluralLogic(
      tasks,
      locale: localeName,
      other: 'hojiiwwan $tasks',
      one: 'hojii 1',
    );
    return 'Faayiliin kun $_temp0 fi $_temp1 qaba.';
  }

  @override
  String get importMerge => 'Walitti makii';

  @override
  String get importReplace => 'Bakka buusi';

  @override
  String get importMergeBody =>
      'Walitti makuun kan hir\'ate dabala. Bakka buusuun dura tarreewwan kee amma jiran haqa.';

  @override
  String get importDone => 'Kuusaan duubaa galeera';

  @override
  String get importInvalid => 'Faayiliin sun kuusaa duubaa Tooran miti';

  @override
  String get exportSubject => 'Kuusaa duubaa Tooran';

  @override
  String get shareReceivedTitle => 'Barreeffama qoodame dabali';

  @override
  String get shareReceivedPick => 'Akka hojiitti eessatti haa dabalamu?';

  @override
  String shareAdded(String name) {
    return '\"$name\" irratti dabalameera';
  }

  @override
  String get shareNoCategories =>
      'Dura ramaddii uumi, sana booda irra deebi\'ii qoodi.';

  @override
  String get lockTitle => 'Tooran cufameera';

  @override
  String get lockUnlock => 'Bani';

  @override
  String get lockReason => 'Tooran bani';

  @override
  String get notifChannelName => 'Yaadachiisa';

  @override
  String get notifChannelDescription =>
      'Yaadachiisa guyyaa dhumaa fi cuunfaa maallaqaa torbanii';

  @override
  String notifDueBody(String category) {
    return 'Yeroon ga\'eera · $category';
  }

  @override
  String notifLedgerDueBody(String person, String amount) {
    return '$person · $amount har\'a ga\'a';
  }

  @override
  String get notifDigestTitle => 'Maallaqa kee torban kana';

  @override
  String notifDigestBody(int count, String net) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Liqaa banaa $count',
      one: 'Liqaa banaa 1',
      zero: 'Liqaan banaan hin jiru',
    );
    return '$_temp0 · Haftee $net';
  }

  @override
  String widgetLeft(int count) {
    return '$count hafe';
  }

  @override
  String get widgetEmpty => 'Hundi xumurameera ✓';

  @override
  String get widgetNoCategories => 'Ramaddii uumuuf Tooran bani';

  @override
  String get helpTitle => 'GARGAARSA';

  @override
  String get helpTroubleshooting => 'RAKKOO FURUU';

  @override
  String get helpGestureTapCategory => 'Ramaddii tuqi';

  @override
  String get helpGestureTapCategoryBody =>
      'Tarree hojiiwwan jala jiranii bal\'isa.';

  @override
  String get helpGestureCircle => 'Saanduqa tuqi';

  @override
  String get helpGestureCircleBody =>
      'Hojii akka xumurameetti mallatteessa. Herrega keessatti, galmee xumura.';

  @override
  String get helpGestureTapTask => 'Hojii tuqi';

  @override
  String get helpGestureTapTaskBody =>
      'Ibsa guutuu, tarree mirkaneessaa fi odeeffannoo bana.';

  @override
  String get helpGestureLongPress => 'Dheeressii tuquu';

  @override
  String get helpGestureLongPressBody =>
      'Tartiiba jijjiiruuf sarara ol fudhata.';

  @override
  String get helpGestureSwipe => 'Harkisuu';

  @override
  String get helpGestureSwipeBody =>
      'Mirgatti xumuruuf (ykn gulaaluuf — Qindaa\'ina ilaali). Bitaatti haquuf, deebisuun ni danda\'ama.';

  @override
  String get helpGestureChecklist => 'Tarree mirkaneessaa';

  @override
  String get helpGestureChecklistBody =>
      'Jalqaba sararaa irratti [ ] barreessi, ykn TARREE MIRKANEESSAA fayyadami. Wantoota odeeffannoo hojii keessaa mallatteessi.';

  @override
  String get helpFaqMissing => 'Hojiiwwan koo badan';

  @override
  String get helpFaqMissingBody =>
      'Hojiiwwan ofumaan olkaa\'amu. Ramaddiin yoo bade, Seenaa ilaali — ramaddiiwwan haqaman achii deebi\'uu danda\'u. Qindaa\'ina → Kuusaa duubaa galchi faayilii baafame deebisa.';

  @override
  String get helpFaqTheme => 'Bifni hin jijjiiramu';

  @override
  String get helpFaqThemeBody =>
      'Mallattoo aduu/ji\'aa gubbaa irratti jiru tuqi. Filannoon kee ni yaadatama.';

  @override
  String get helpFaqReorder => 'Tartiiba jijjiiruu hin danda\'u';

  @override
  String get helpFaqReorderBody =>
      'Dura sarara dheeressii tuqi, sana booda harkisi. Hojiiwwan isaa tartiibsuuf ramaddiin bal\'ifamuu qaba. Herregni hangaan ykn guyyaan tartiibsame harkifamuu hin danda\'u — Tartiibsi gara Harkaan jijjiiri.';

  @override
  String get helpFaqReminders => 'Yaadachiisni hin mul\'atu';

  @override
  String get helpFaqRemindersBody =>
      'Qindaa\'ina sirnaa keessatti beeksisa Tooran hayyami; bilbilli kee yoo yaadachiisa turse, qusannaa baatirii Tooran dhaamsi.';

  @override
  String get helpLocalFirst =>
      'Tooran meeshaa kee irratti hojjeta. Ati yoo hin heyyamne malee tarreewwan kee meeshaa kee irraa hin bahan.';

  @override
  String get aboutTitle => 'WAA\'EE';

  @override
  String aboutVersion(String version) {
    return 'VERSIYOONII $version';
  }

  @override
  String get aboutIntro =>
      'Tooran qindeessaa hojii meeshaa kee irratti hojjetudha. Ramaddiiwwan hojiiwwan qabatu. Hojiiwwan ibsa qabu. Wanti tokkollee meeshaa kee irraa hin bahu. Oomishtummaa, tasgabbiin.';

  @override
  String get aboutWhatItDoes => 'MAAL HOJJETA';

  @override
  String get aboutFeatureCategories => 'Ramaddiiwwan';

  @override
  String get aboutFeatureCategoriesBody =>
      'Bakka wantoota siif dhihoo ta\'aniif.';

  @override
  String get aboutFeatureTasks => 'Hojiiwwan';

  @override
  String get aboutFeatureTasksBody =>
      'Maqaa, tarree mirkaneessaa, guyyaa dhumaa, guddina suuta.';

  @override
  String get aboutFeatureLedger => 'Maallaqa';

  @override
  String get aboutFeatureLedgerBody =>
      'Eenyutu eenyuuf idaa qaba, kaffaltii gartokkee, yaadachiisa.';

  @override
  String get aboutFeatureDrag => 'Harkisii kaa\'i';

  @override
  String get aboutFeatureDragBody =>
      'Ol fuudhuuf dheeressii tuqi. Bakka barbaadde kaa\'i.';

  @override
  String get aboutFeatureHistory => 'Seenaa';

  @override
  String get aboutFeatureHistoryBody =>
      'Ramaddiiwwan haqaman deebi\'uu danda\'u.';

  @override
  String get aboutFeatureThemes => 'Bifoota';

  @override
  String get aboutFeatureThemesBody =>
      'Guyyaa waraqaa ho\'aa. Halkan qalama gadi fagoo.';

  @override
  String get aboutFeatureLocal => 'Meeshaa kee irratti';

  @override
  String get aboutFeatureLocalBody =>
      'Duumessa hin qabu, seensa hin qabu, hordoffii hin qabu.';

  @override
  String get aboutCraftedBy => 'KAN HOJJETE';

  @override
  String get aboutCraftedByBody =>
      'Jiru Gutema, Yuunivarsiitii Finfinnee. Of eeggannoon, Flutter-iin, galgala tasgabbaa\'aa tokko irratti hojjetame.';

  @override
  String get aboutRights => 'MIRGI HUNDI SEERAAN EEGAMAADHA';

  @override
  String get contactTitle => 'QUUNNAMTII';

  @override
  String get contactEmail => 'IMEELII';

  @override
  String get contactEmailDetail => 'Gaaffii fi deeggarsaaf';

  @override
  String get contactWebsite => 'WEEBSAAYITII';

  @override
  String get contactWebsiteDetail => 'Haaromsa fi oduu';

  @override
  String get contactSource => 'KOODII MADDAA';

  @override
  String get contactSourceDetail => 'Koodii dubbisi, fooyya\'iinsa ergi';

  @override
  String get contactDeveloper => 'MISOOMSAA';

  @override
  String get contactDeveloperRole =>
      'Misoomsaa sooftiweerii · Yuunivarsiitii Finfinnee';

  @override
  String get contactDeveloperBio =>
      'Meeshaalee tasgabbii kennan ijaara. Yaada fi hojii waloof banaadha.';

  @override
  String get contactPortfolio => 'PORTIFOOLIYOO →';

  @override
  String contactCopied(String label) {
    return '$label garagalfameera';
  }

  @override
  String get desktopCategories => 'RAMADDIIWWAN';

  @override
  String get desktopNoCategories =>
      'Ammaaf ramaddiin hin jiru. Jalqabuuf tokko uumi.';

  @override
  String get desktopNewCategory => 'Ramaddii haaraa';

  @override
  String get desktopRename => 'Maqaa jijjiiri';

  @override
  String get desktopArchive => 'Kuusaatti galchi';

  @override
  String get desktopNoTasksYet => 'AMMAAF HOJIIN HIN JIRU';

  @override
  String desktopComplete(int done, int total) {
    return '$done $total KEESSAA XUMURAME';
  }

  @override
  String get desktopNothingHere => 'Ammaaf asitti homaa hin jiru.';

  @override
  String get desktopNothingHereBody =>
      'Ramaddii kana kaayyoon guutuuf hojii dabali.';

  @override
  String get desktopBlankA => 'Fuulli ';

  @override
  String get desktopBlankWord => 'duwwaan';

  @override
  String get desktopBlankRest => ', kan keeti.';

  @override
  String get desktopBlankBody =>
      'Ramaddiiwwan hojiiwwan qabatu. Hojiiwwan waan qabatan qabatu. Kana caalaa homaa — bakka wantoota siif dhihoo ta\'uu barbaadduun jalqabi.';

  @override
  String get desktopCreateFirst => 'Ramaddii kee isa jalqabaa uumi';

  @override
  String get categoryTypeShopping => 'Bittaa';

  @override
  String get categoryTypeBills => 'Kaffaltii idilee';

  @override
  String get categoryTypeSavings => 'Kaayyoo qusannaa';

  @override
  String get categoryTypeNotes => 'Yaadannoo';

  @override
  String get categoryTypeOther => 'Kan biraa';

  @override
  String get typeTasksDesc => 'Wantoota mallatteessitu';

  @override
  String get typeShoppingDesc => 'Wantoota, gatii filannoo waliin';

  @override
  String get typeBillsDesc => 'Kaffaltiiwwan irra deebi\'an';

  @override
  String get typeSavingsDesc => 'Kaayyoo tokkoof qusadhu';

  @override
  String get typeNotesDesc => 'Yaadannoo, saanduqa mallattoo malee';

  @override
  String get typeOtherDesc => 'Gosa tarree kee mataa keetii moggaasi';

  @override
  String get categoryCustomTypeLabel => 'MAQAA GOSAA';

  @override
  String get categoryCustomTypeHint =>
      'fkn. Qophii nyaataa, Kitaabota, Yaadota';

  @override
  String get categoryTargetLabel => 'HANGA KAAYYOO';

  @override
  String get categoryLedgerLockedHint =>
      'Hojiiwwan kana gara galmee maallaqaatti jijjiiruuf, ⋮ → Gara herregaatti jijjiiri… fayyadami.';

  @override
  String summaryShopping(int done, int total, String amount) {
    return '$done/$total · $amount hafe';
  }

  @override
  String summaryBills(int count, String amount) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hin kaffalamne',
      one: '1 hin kaffalamne',
      zero: 'Hundi kaffalameera',
    );
    return '$_temp0 · $amount';
  }

  @override
  String summarySavings(String saved, String target) {
    return '$saved $target keessaa';
  }

  @override
  String summarySavingsNoTarget(String saved) {
    return '$saved qusatameera';
  }

  @override
  String summaryNotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'yaadannoowwan $count',
      one: 'yaadannoo 1',
      zero: 'Ammaaf yaadannoon hin jiru',
    );
    return '$_temp0';
  }

  @override
  String get fieldItem => 'WANTA';

  @override
  String get fieldItemHint => 'Maal bituu qabda?';

  @override
  String get fieldPrice => 'GATII (FILANNOO)';

  @override
  String get fieldBill => 'KAFFALTII';

  @override
  String get fieldBillHint => 'Ibsaa, kiraa, interneetii…';

  @override
  String get fieldBillAmount => 'HANGA (FILANNOO)';

  @override
  String get fieldTitle => 'MATA DUREE';

  @override
  String get fieldTitleHint => 'Mata duree yaadannoo';

  @override
  String get fieldNoteBody => 'YAADANNOO';

  @override
  String get fieldDeposit => 'IBSA';

  @override
  String get savingsDepositDefault => 'Kuusaa';

  @override
  String get addItem => 'WANTA DABALI';

  @override
  String get addBill => 'KAFFALTII DABALI';

  @override
  String get addDeposit => 'KUUSAA DABALI';

  @override
  String get addNote => 'YAADANNOO DABALI';

  @override
  String get newItem => 'Wanta haaraa';

  @override
  String get newBill => 'Kaffaltii haaraa';

  @override
  String get newDeposit => 'Kuusaa haaraa';

  @override
  String get newNote => 'Yaadannoo haaraa';

  @override
  String get editEntry => 'Gulaali';

  @override
  String get commonAdd => 'Dabali';

  @override
  String get detailAmount => 'HANGA';

  @override
  String get detailPrice => 'GATII';

  @override
  String get settingsColorTheme => 'Bifa halluu';

  @override
  String get settingsCorners => 'Golee';

  @override
  String get cornersTheme => 'Kan bifaa';

  @override
  String get cornersSharp => 'Qaroo';

  @override
  String get cornersRounded => 'Geengoo';

  @override
  String get cornersRound => 'Baay\'ee geengoo';

  @override
  String get settingsCardStyle => 'Kaardiiwwan';

  @override
  String get cardsTheme => 'Kan bifaa';

  @override
  String get cardsOutlined => 'Daangaa qabu';

  @override
  String get cardsElevated => 'Gaaddidduu';

  @override
  String get cardsFilled => 'Guutamaa';

  @override
  String get themeHorizon => 'Horizon';

  @override
  String get themeOcean => 'Galaana';

  @override
  String get themeForest => 'Bosona';

  @override
  String get themeSunset => 'Lixa aduu';

  @override
  String get themeLavender => 'Lavender';

  @override
  String get themeGraphite => 'Graphite';

  @override
  String ledgerNewEntryFor(String name) {
    return 'Galmee haaraa ${name}f';
  }

  @override
  String ledgerEntryOn(String date) {
    return 'Galmee · $date';
  }

  @override
  String get ledgerPlusTotal => '+ WALIIGALA';

  @override
  String get ledgerMinusTotal => '− WALIIGALA';

  @override
  String get categoryTypeMoney => 'Maallaqa';

  @override
  String get typeMoneyDesc =>
      'Eenyu eenyuuf idaa qaba: + isaan si kaffalu, − ati isaaniif kaffalta';

  @override
  String get ledgerCaptionOwesYou => 'si irraa qaba';

  @override
  String get ledgerCaptionYouOwe => 'isaaniif qabda';

  @override
  String get moneySignPlus => '+ Isaan na kaffalu';

  @override
  String get moneySignMinus => '− Ani isaaniif kaffala';

  @override
  String get moneySignHelp =>
      '+ liqeessite ykn isaan liqeeffatan · − ati liqeeffatte ykn isaan si deebisan';

  @override
  String get categoryMergeLedgers => 'Tarreewwan maallaqaa walitti makii…';

  @override
  String get mergeTitle => 'Tarree tokkotti makii';

  @override
  String get mergeBody =>
      'Tarreewwan filataman tarree Maallaqaa tokko ta\'u. Galmeewwan nama tokkoo walitti makamu, tarreewwan kaan gara seenaatti deemu.';

  @override
  String get mergeNameLabel => 'MAQAA TARREE';

  @override
  String get mergeApply => 'Makii';

  @override
  String mergePeopleCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'namoota $count',
      one: 'nama 1',
    );
    return 'Erga makamee booda $_temp0';
  }

  @override
  String mergeDone(String name) {
    return 'Gara «$name»tti makame';
  }

  @override
  String duplicatePersonHint(String name, String category) {
    return '$name duraanuu «$category» keessa jira.';
  }

  @override
  String duplicatePersonAction(String sign) {
    return 'Achitti akka ${sign}tti dabali';
  }

  @override
  String get ledgerPresetMoney => 'Maallaqa';

  @override
  String get taskAddAnother => 'Kan biraa dabali';

  @override
  String get richBold => 'CIMAA';

  @override
  String get richItalic => 'JALLISAA';

  @override
  String get richCode => 'KOODII';

  @override
  String get richLink => 'LIINKII';

  @override
  String get richPreview => 'Dursa ilaali';

  @override
  String get richEdit => 'Gulaali';

  @override
  String get helpMarkdown => 'Markdown';

  @override
  String get helpMarkdownBody =>
      'Yaadannoon Markdown ni deeggara: **cimaa**, *jallisaa*, ~~haqame~~, `koodii`, [liinkii](https://…), # mata-dureewwan, > wabiiwwan, ``` kutaalee koodii fi | gabatee |. Akkamitti akka mul\'atu ilaaluuf Dursa ilaali fayyadami.';

  @override
  String get categoryTypeSpending => 'Baasii';

  @override
  String get typeSpendingDesc => 'Waan baaftu, baajata filannoo wajjin';

  @override
  String get addExpense => 'BAASII DABALI';

  @override
  String get newExpense => 'Baasii haaraa';

  @override
  String get fieldExpenseFor => 'MAALIIF (FILANNOO)';

  @override
  String get fieldExpenseForHint => 'Laaqana, taaksii, meeshaa nyaataa…';

  @override
  String get fieldTag => 'GOSA';

  @override
  String get tagFood => 'Nyaata';

  @override
  String get tagTransport => 'Geejjiba';

  @override
  String get tagHome => 'Mana';

  @override
  String get tagBills => 'Kaffaltii';

  @override
  String get tagShopping => 'Bittaa';

  @override
  String get tagHealth => 'Fayyaa';

  @override
  String get tagFun => 'Bashannana';

  @override
  String get tagFamily => 'Maatii';

  @override
  String get tagEducation => 'Barnoota';

  @override
  String get tagOther => 'Kan biraa';

  @override
  String get categoryBudgetLabel => 'BAAJATA JI\'AA (FILANNOO)';

  @override
  String get spendToday => 'HAR\'A';

  @override
  String get spendWeek => 'TORBAN KANA';

  @override
  String get spendMonth => 'JI\'A KANA';

  @override
  String spendVsLastMonth(String percent) {
    return 'Ji\'a darbe irraa $percent';
  }

  @override
  String spendBudgetLeft(String amount, String budget) {
    return '$budget keessaa $amount hafe';
  }

  @override
  String spendBudgetOver(String amount) {
    return 'Baajata ${amount}n darbe';
  }

  @override
  String summarySpending(String today, String month) {
    return 'Har\'a $today · Ji\'a $month';
  }

  @override
  String summarySpendingBudget(String today, String month, String budget) {
    return 'Har\'a $today · $month / $budget';
  }

  @override
  String get spendYesterday => 'Kaleessa';

  @override
  String get spendAddAgain => 'Har\'a irra deebi\'ii dabali';

  @override
  String get spendAddedAgain => 'Har\'aaf irra deebi\'ee dabalame';

  @override
  String spendBudgetWarn(String percent) {
    return 'Baajata ji\'a kanaa keessaa $percent fayyadamteetta';
  }

  @override
  String spendBudgetOverToast(String amount) {
    return 'Baajata ji\'a kanaa ${amount}n darbiteetta';
  }

  @override
  String get categoryShareCsv => 'Akka CSVtti qoodi';

  @override
  String get spendingNoEntries =>
      'Ammaaf baasiin hin jiru · galmeessuuf gadii tuqi';

  @override
  String get settingsSpending => 'BAASII';

  @override
  String get settingsSpendingReminder => 'Yaadachiisa baasii guyyaa';

  @override
  String get settingsSpendingReminderBody =>
      'Baasii har\'aa akka galmeessitu si yaadachiisa. Guyyoota duraan galmeessite hin ergamu.';

  @override
  String get settingsSpendingReminderTime => 'Sa\'aatii yaadachiisaa';

  @override
  String get notifSpendingTitle => 'Baasii har\'aa galmeessi';

  @override
  String get notifSpendingBody => 'Waan har\'a baafte dabaluuf tuqi.';

  @override
  String get overviewTitle => 'Ilaalcha waliigalaa';

  @override
  String get periodWeek => 'Torban';

  @override
  String get periodMonth => 'Ji\'a';

  @override
  String get periodYear => 'Waggaa';

  @override
  String get periodCustom => 'Filannoo';

  @override
  String get kpiTotal => 'WALIIGALA';

  @override
  String get kpiDailyAvg => 'GUYYAATTI';

  @override
  String get kpiCount => 'BAASIIWWAN';

  @override
  String get kpiVsPrev => 'KAN DARBE WAJJIN';

  @override
  String get chartOverTime => 'Baasii yeroo keessa';

  @override
  String get chartByTag => 'Gosaan';

  @override
  String get calendarTitle => 'Kalaandara';

  @override
  String get searchExpenses => 'Baasii barbaadi…';

  @override
  String get clearFilters => 'Calaltuu qulqulleessi';

  @override
  String get noMatches => 'Calaltuu kanaan kan walsimu hin jiru.';

  @override
  String get moneyKpiOwedToYou => 'SI IRRAA QABAN';

  @override
  String get moneyKpiYouOwe => 'ISAANIIF QABDA';

  @override
  String get moneyKpiPeople => 'NAMOOTA';

  @override
  String get chartByPerson => 'Herrega namaan';

  @override
  String get chartFlow => 'Yaa\'insa maallaqaa · ji\'oota 6 darban';

  @override
  String get legendPlus => '+ liqeessite / si irraa qabu';

  @override
  String get legendMinus => '− liqeeffatte / deebi\'e';

  @override
  String get filterOpen => 'Banaa';

  @override
  String get filterSettled => 'Xumurame';

  @override
  String get filterAll => 'Hunda';

  @override
  String get sortName => 'Maqaa';

  @override
  String get searchPeople => 'Namoota barbaadi…';

  @override
  String overviewOldest(String date) {
    return 'Galmee banaa dulloomaa: $date';
  }

  @override
  String get chartTapHint => 'Tarree calaluuf utubaa tuqi';
}
