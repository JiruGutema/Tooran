import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/gen/app_localizations.dart';
import '../models/task.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/date_labels.dart';
import '../utils/ethiopian_calendar.dart';
import '../utils/money.dart';
import '../utils/recurrence.dart';
import 'formatted_text.dart';

/// Theme-aware colors and strings, so widgets don't repeat the
/// `dark ? AppTheme.dInk : AppTheme.lInk` dance.
extension TooranContext on BuildContext {
  bool get dark => Theme.of(this).brightness == Brightness.dark;
  Color get ink => dark ? AppTheme.dInk : AppTheme.lInk;
  Color get ink2 => dark ? AppTheme.dInk2 : AppTheme.lInk2;
  Color get ink3 => dark ? AppTheme.dInk3 : AppTheme.lInk3;
  Color get ink4 => dark ? AppTheme.dInk4 : AppTheme.lInk4;
  Color get success => dark ? AppTheme.dSuccess : AppTheme.lSuccess;
  Color get warning => dark ? AppTheme.dWarning : AppTheme.lWarning;
  Color get danger => dark ? AppTheme.dError : AppTheme.lError;
  Color get primary => Theme.of(this).colorScheme.primary;
  AppLocalizations get l10n => AppLocalizations.of(this);
}

// ════════════════════════════════════════════════════════════════════
// Formatting
// ════════════════════════════════════════════════════════════════════

/// intl has date symbols for English and Amharic; Oromo falls back to English.
String intlLocale(BuildContext context) {
  final code = Localizations.localeOf(context).languageCode;
  return code == 'am' ? 'am' : 'en';
}

String fmtDate(BuildContext context, DateTime d, {bool withYear = false}) {
  final settings = context.read<SettingsProvider>();
  final am = Localizations.localeOf(context).languageCode == 'am';
  if (settings.ethiopianCalendar) {
    return formatEthiopian(d, withYear: withYear, amharic: am);
  }
  final loc = intlLocale(context);
  return (withYear ? DateFormat.yMMMd(loc) : DateFormat.MMMd(loc)).format(d);
}

String fmtTime(BuildContext context, DateTime d) =>
    DateFormat.jm(intlLocale(context)).format(d);

String fmtDue(BuildContext context, Task t) {
  final d = t.dueAt!;
  final l = context.l10n;
  final info = dueInfo(t.dueHasTime ? d : DateTime(d.year, d.month, d.day, 23, 59), DateTime.now());
  final day = switch (info.kind) {
    DueKind.overdue => info.days == 0 ? l.dueToday : fmtDate(context, d),
    DueKind.today => l.dueToday,
    DueKind.tomorrow => l.dueTomorrow,
    DueKind.thisWeek => DateFormat.EEEE(intlLocale(context)).format(d),
    DueKind.later => fmtDate(context, d),
  };
  return t.dueHasTime ? '$day ${fmtTime(context, d)}' : day;
}

/// Plain label for widgets/notifications that only know a [DueInfo].
String dueKindLabel(AppLocalizations l, DueInfo info) => switch (info.kind) {
      DueKind.overdue => l.dueOverdue,
      DueKind.today => l.dueToday,
      DueKind.tomorrow => l.dueTomorrow,
      DueKind.thisWeek || DueKind.later => l.dueInDays(info.days),
    };

bool isOverdue(Task t) {
  if (t.dueAt == null || t.isCompleted) return false;
  final d = t.dueAt!;
  final end = t.dueHasTime ? d : DateTime(d.year, d.month, d.day, 23, 59, 59);
  return end.isBefore(DateTime.now());
}

String repeatLabel(AppLocalizations l, Recurrence r) => switch (r) {
      Recurrence.none => l.repeatNone,
      Recurrence.daily => l.repeatDaily,
      Recurrence.weekly => l.repeatWeekly,
      Recurrence.monthly => l.repeatMonthly,
      Recurrence.yearly => l.repeatYearly,
    };

RichTextLabels richLabels(AppLocalizations l) => RichTextLabels(
      clearChecked: l.richClearChecked,
      edit: l.commonEdit,
      delete: l.commonDelete,
      moveToTop: l.richMoveToTop,
      makeOwnTask: l.richMakeOwnTask,
      editItemTitle: l.richEditItem,
      save: l.commonSave,
      cancel: l.commonCancel,
      checklist: l.richChecklist,
      bullet: l.richBullet,
      numbered: l.richNumbered,
      heading: l.richHeading,
      quote: l.richQuote,
      indent: l.richIndent,
      outdent: l.richOutdent,
      convertPastedPrompt: l.richConvertPrompt,
      convert: l.richConvert,
      dismiss: l.commonClose,
      descriptionHint: l.richDescriptionHint,
      reorder: l.richReorder,
      bold: l.richBold,
      italic: l.richItalic,
      code: l.richCode,
      link: l.richLink,
      preview: l.richPreview,
    );

// ════════════════════════════════════════════════════════════════════
// Small building blocks
// ════════════════════════════════════════════════════════════════════

class IconBtn extends StatelessWidget {
  const IconBtn({super.key, required this.icon, required this.onTap, this.color, this.tooltip});
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final btn = InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Icon(icon, size: 20, color: color ?? context.ink2),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip!, child: btn);
  }
}

/// The app's rounded checkbox with a 44×44 tap target and a screen-reader label.
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.checked,
    required this.onTap,
    this.label,
  });
  final bool checked;
  final VoidCallback onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final primary = context.primary;
    return Semantics(
      checked: checked,
      button: true,
      label: label,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: checked ? primary : Colors.transparent,
                borderRadius: BorderRadius.circular(AppTheme.rXs),
                border: Border.all(color: checked ? primary : context.ink4, width: 1.5),
              ),
              child: AnimatedScale(
                scale: checked ? 1 : 0.5,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutBack,
                child: AnimatedOpacity(
                  opacity: checked ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.check, size: 14, color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated strike-through that grows left-to-right.
class StrikeText extends StatelessWidget {
  const StrikeText({super.key, required this.text, required this.done, required this.style, this.maxLines});
  final String text;
  final bool done;
  final TextStyle style;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, box) {
      final painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
        maxLines: 1,
      )..layout(maxWidth: box.maxWidth);
      final overflow = maxLines == null ? null : TextOverflow.ellipsis;
      // The animated line only lines up with single-line text; wrapped text
      // gets a regular strike-through instead.
      if (painter.didExceedMaxLines) {
        return Text(
          text,
          maxLines: maxLines,
          overflow: overflow,
          style: done
              ? style.copyWith(decoration: TextDecoration.lineThrough, decorationColor: context.ink3)
              : style,
        );
      }
      return Stack(
        alignment: Alignment.centerLeft,
        children: [
          Text(text, style: style, maxLines: maxLines, overflow: overflow),
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: done ? 1 : 0),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                builder: (_, v, __) => SizedBox(
                  width: painter.width * v,
                  child: Container(height: 1.5, color: context.ink3),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class SheetShell extends StatelessWidget {
  const SheetShell({super.key, required this.eyebrow, required this.child, this.trailing});
  final String eyebrow;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.rXl)),
      ),
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SheetGrabber(),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    eyebrow.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.eyebrow(context.ink3),
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  Flexible(child: trailing!),
                ],
              ],
            ),
          ),
          Flexible(child: child),
        ],
      ),
    );
  }
}

class SheetGrabber extends StatelessWidget {
  const SheetGrabber({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 14),
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(color: context.ink4, borderRadius: BorderRadius.circular(2)),
      ),
    );
  }
}

/// Opens a keyboard-aware bottom sheet (a centered dialog on wide screens).
Future<T?> openSheet<T>(BuildContext context, Widget child) {
  if (MediaQuery.sizeOf(context).width >= 900) {
    return showDialog<T>(
      context: context,
      builder: (ctx) => Dialog(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.rXl)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 560, maxHeight: MediaQuery.sizeOf(ctx).height * 0.85),
          child: child,
        ),
      ),
    );
  }
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: child,
    ),
  );
}

/// Snackbar with an optional Undo action.
void showToast(BuildContext context, String msg, {VoidCallback? onUndo}) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(msg),
      action: onUndo == null
          ? null
          : SnackBarAction(label: context.l10n.commonUndo.toUpperCase(), onPressed: onUndo),
    ));
}

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  bool destructive = true,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 22),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTheme.display(size: 24, color: ctx.ink)),
            const SizedBox(height: 10),
            Text(body, style: AppTheme.body(size: 14, color: ctx.ink2).copyWith(height: 1.5)),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(ctx.l10n.commonCancel),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: destructive
                        ? ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(ctx).colorScheme.error,
                            foregroundColor: Colors.white,
                          )
                        : null,
                    child: Text(confirmLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  return ok == true;
}

/// A formatted amount as plain text, hidden in privacy mode.
String formatAmountFor(BuildContext context, int minor, String currency) =>
    context.read<SettingsProvider>().privacyMode
        ? '${context.l10n.ledgerHidden} $currency'
        : formatMoney(minor, currency);

/// Amount text that respects privacy mode: shows •••• until tapped.
class MoneyText extends StatefulWidget {
  const MoneyText(this.minor, this.currency, {super.key, required this.style, this.showPlus = false});
  final int minor;
  final String currency;
  final TextStyle style;
  final bool showPlus;

  @override
  State<MoneyText> createState() => _MoneyTextState();
}

class _MoneyTextState extends State<MoneyText> {
  bool _revealed = false;

  @override
  Widget build(BuildContext context) {
    final privacy = context.watch<SettingsProvider>().privacyMode;
    final text = formatMoney(widget.minor, widget.currency, showPlus: widget.showPlus);
    if (!privacy) return Text(text, style: widget.style);
    return GestureDetector(
      onTap: () => setState(() => _revealed = !_revealed),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: Text(
          _revealed ? text : '${context.l10n.ledgerHidden} ${widget.currency}',
          key: ValueKey(_revealed),
          style: widget.style,
        ),
      ),
    );
  }
}

/// A small rounded label (due date, checklist progress, repeat…).
class Chip2 extends StatelessWidget {
  const Chip2({super.key, required this.label, this.icon, this.color});
  final String label;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.ink3;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: c.withValues(alpha: 0.35), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: c),
            const SizedBox(width: 3),
          ],
          Text(label, style: AppTheme.mono(size: 10.5, color: c)),
        ],
      ),
    );
  }
}

/// Emoji choices for categories.
const categoryEmojis = [
  '📋', '🛒', '💰', '🤝', '🏠', '💼', '📚', '🎯', '💡', '🏃', '🍲', '✈️',
  '🎁', '🧾', '💊', '🔧', '🌱', '🎓', '⛪', '🕌', '❤️', '⭐', '📅', '🧺',
];

/// Accent colors for categories (work on both themes).
const categoryColors = <int>[
  0xFFC8553D, 0xFFD08A3C, 0xFFB89B3E, 0xFF6A8C57, 0xFF3F8A7A,
  0xFF4A7BA8, 0xFF6E5BA8, 0xFFA8527A, 0xFF7A6A58,
];
