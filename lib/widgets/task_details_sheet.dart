import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/payment.dart';
import '../models/task.dart';
import '../providers/categories_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../utils/money.dart';
import '../utils/rich_text.dart';
import 'common.dart';
import 'formatted_text.dart';
import 'kind_info.dart';
import 'ledger_groups.dart';
import 'task_actions.dart';

/// Full view of one task: tappable checklist, dates, and for ledger
/// entries the amount, payment history and reminder action. Watches the
/// provider, so ticking items or recording payments updates it live.
class TaskDetailsSheet extends StatelessWidget {
  const TaskDetailsSheet({
    super.key,
    required this.categoryId,
    required this.taskId,
    this.scrollController,
    this.embedded = false,
    this.onClose,
  });

  final String categoryId;
  final String taskId;
  final ScrollController? scrollController;

  /// Desktop shows this in a side pane instead of a bottom sheet.
  final bool embedded;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CategoriesProvider>();
    final settings = context.watch<SettingsProvider>();
    final c = provider.byId(categoryId);
    final t = provider.taskById(categoryId, taskId);
    if (c == null || t == null) {
      return const SizedBox.shrink();
    }
    final l = context.l10n;
    final ledger = c.isLedger && t.isLedgerEntry;
    final statusLabel = !c.hasCheckboxes
        ? categoryTypeLabel(l, c).toUpperCase()
        : ledger
            ? (t.isCompleted ? l.ledgerSettledOn : l.ledgerOpen)
            : (t.isCompleted ? l.taskStatusCompleted : l.taskStatusOpen);

    // The sheet's own context dies when it closes; follow-up UI (edit sheet,
    // undo snackbar) is shown from the navigator's context instead.
    final host = embedded ? context : Navigator.of(context).context;

    void close() {
      if (onClose != null) {
        onClose!();
      } else {
        Navigator.of(context).maybePop();
      }
    }

    Future<void> descriptionChanged(String text) async {
      final updated = t.copyWith(description: text);
      await provider.updateTask(c.id, updated);
      if (!settings.autoCompleteChecklist || t.isCompleted || ledger) return;
      final counts = checklistCounts(text);
      if (counts.total > 0 && counts.done == counts.total) {
        await provider.toggleTask(c.id, t.id);
        if (context.mounted) showToast(context, l.taskAutoCompleted);
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: embedded
            ? null
            : BorderRadius.vertical(top: Radius.circular(AppTheme.rXl)),
      ),
      child: Column(
        children: [
          if (!embedded) const SheetGrabber(),
          Padding(
            padding: EdgeInsets.fromLTRB(22, embedded ? 16 : 0, 10, 6),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(statusLabel,
                          style: AppTheme.eyebrow(
                              t.isCompleted ? context.success : context.ink3)),
                      const SizedBox(height: 2),
                      Text(c.emoji == null ? c.name : '${c.emoji} ${c.name}',
                          style: AppTheme.mono(size: 11, color: context.ink3),
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                IconBtn(
                  icon: Icons.ios_share,
                  tooltip: l.commonShare,
                  onTap: () => TaskActions.share(c, t),
                ),
                IconBtn(
                  icon: Icons.edit_outlined,
                  tooltip: l.commonEdit,
                  onTap: () {
                    if (!embedded) Navigator.of(context).pop();
                    TaskActions.edit(host, c, t);
                  },
                ),
                IconBtn(
                  icon: Icons.delete_outline,
                  tooltip: l.commonDelete,
                  onTap: () {
                    close();
                    TaskActions.delete(host, c, t);
                  },
                ),
                if (embedded)
                  IconBtn(
                      icon: Icons.close, tooltip: l.commonClose, onTap: close),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 32),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (c.hasCheckboxes)
                      Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: AppCheckbox(
                          checked: t.isCompleted,
                          label: t.name,
                          onTap: () => TaskActions.toggle(context, c, t),
                        ),
                      ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          ledger ? (t.person ?? t.name) : t.name,
                          style: AppTheme.display(size: 30, color: context.ink),
                        ),
                      ),
                    ),
                  ],
                ),
                if (ledger) ...[
                  const SizedBox(height: 18),
                  _LedgerSummary(category: c, task: t),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        if (!embedded) Navigator.of(context).pop();
                        TaskActions.addTask(host, c, initialName: t.person ?? t.name);
                      },
                      icon: const Icon(Icons.add, size: 16),
                      label: Text(l.ledgerNewEntryFor(t.person ?? t.name)),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppTheme.rMd),
                  ),
                  child: t.description.trim().isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            l.taskNoDescription,
                            style: AppTheme.display(
                                size: 17,
                                color: context.ink3,
                                style: FontStyle.italic),
                          ),
                        )
                      : FormattedText(
                          text: t.description,
                          style: AppTheme.body(
                                  size: 14.5,
                                  color: context.ink,
                                  weight: FontWeight.w400)
                              .copyWith(height: 1.55),
                          labels: richLabels(l),
                          sinkChecked: settings.sinkCheckedItems,
                          onChanged: descriptionChanged,
                          onPromote: ledger
                              ? null
                              : (content) async {
                                  final i =
                                      c.tasks.indexWhere((x) => x.id == t.id);
                                  await provider.insertTask(
                                      c.id, Task(name: content), i + 1);
                                  if (context.mounted) {
                                    showToast(context, l.taskPromoted);
                                  }
                                },
                        ),
                ),
                if (ledger) ...[
                  const SizedBox(height: 22),
                  _Payments(category: c, task: t),
                ],
                if (c.isSpending) ...[
                  const SizedBox(height: 14),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await provider.addTask(
                          c.id,
                          Task(
                            name: t.name,
                            amountMinor: t.amountMinor,
                            tag: t.tag,
                            description: t.description,
                          ),
                        );
                        if (context.mounted) showToast(context, l.spendAddedAgain);
                      },
                      icon: const Icon(Icons.replay, size: 16),
                      label: Text(l.spendAddAgain),
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                _DetailGrid(category: c, task: t),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LedgerSummary extends StatelessWidget {
  const _LedgerSummary({required this.category, required this.task});
  final Category category;
  final Task task;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final total = task.amountMinor ?? 0;
    final paid = task.paidMinor;
    final pct = total == 0 ? 0.0 : (paid / total.abs()).clamp(0.0, 1.0);
    final cur = category.currency;
    final accent = ledgerAmountColor(context, category, total);

    Widget cell(String label, int minor, Color color, {bool signed = false}) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTheme.eyebrow(context.ink3)),
              const SizedBox(height: 4),
              MoneyText(minor, cur,
                  showPlus: signed,
                  style: AppTheme.display(size: 20, color: color)),
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            cell(l.ledgerTotal, total, context.ink, signed: true),
            cell(l.ledgerPaid, paid, context.ink2),
            cell(l.ledgerOutstanding, task.remainingMinor,
                task.isCompleted ? context.ink3 : accent, signed: true),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: pct),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => LinearProgressIndicator(
              value: v,
              minHeight: 6,
              color: accent,
              backgroundColor: context.ink4.withValues(alpha: 0.4),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            if (!task.isCompleted)
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => showPaymentSheet(context, category, task),
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(l.ledgerRecordPayment),
                ),
              ),
            if (!task.isCompleted &&
                !task.isNegative) ...[
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => TaskActions.remind(context, category, task),
                  icon:
                      const Icon(Icons.notifications_active_outlined, size: 16),
                  label: Text(l.ledgerRemind),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _Payments extends StatelessWidget {
  const _Payments({required this.category, required this.task});
  final Category category;
  final Task task;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final provider = context.read<CategoriesProvider>();
    final payments = List.of(task.payments)
      ..sort((a, b) => b.paidAt.compareTo(a.paidAt));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l.ledgerPayments, style: AppTheme.eyebrow(context.ink3)),
        const SizedBox(height: 8),
        if (payments.isEmpty)
          Text(l.ledgerNoPayments,
              style: AppTheme.body(size: 13.5, color: context.ink3))
        else
          for (final p in payments)
            Dismissible(
              key: ValueKey('pay_${p.id}'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 12),
                color: context.danger.withValues(alpha: 0.1),
                child:
                    Icon(Icons.delete_outline, size: 18, color: context.danger),
              ),
              onDismissed: (_) {
                provider.removePayment(category.id, task.id, p.id);
                showToast(context, l.ledgerPaymentDeleted,
                    onUndo: () => provider.addPayment(category.id, task.id, p));
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                      bottom:
                          BorderSide(color: AppTheme.hairline(context.dark))),
                ),
                child: Row(
                  children: [
                    Icon(Icons.south_west, size: 14, color: context.success),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                              fmtDate(context, p.paidAt,
                                  withYear:
                                      p.paidAt.year != DateTime.now().year),
                              style:
                                  AppTheme.body(size: 14, color: context.ink)),
                          if (p.note.isNotEmpty)
                            Text(p.note,
                                style: AppTheme.body(
                                    size: 12.5, color: context.ink3)),
                        ],
                      ),
                    ),
                    MoneyText(p.amountMinor, category.currency,
                        style: AppTheme.mono(size: 13, color: context.ink2)),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

class _DetailGrid extends StatelessWidget {
  const _DetailGrid({required this.category, required this.task});
  final Category category;
  final Task task;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = task;
    final ledger = category.isLedger && t.isLedgerEntry;
    final cells = <Widget>[
      if (!ledger && category.tracksMoney && t.amountMinor != null)
        _Detail(
          label: category.kind == CategoryKind.shopping
              ? l.detailPrice
              : l.detailAmount,
          primary: formatMoney(t.amountMinor!, category.currency),
          color: category.kind == CategoryKind.savings ? context.success : null,
        ),
      if (category.isSpending)

        _Detail(label: l.fieldTag, primary: spendingTagLabel(l, t.tag)),
      if (category.hasCheckboxes)
        _Detail(
          label: l.taskDetailStatus,
          primary: ledger
              ? (t.isCompleted ? l.ledgerSettled : l.taskStatusInProgress)
              : (t.isCompleted ? l.taskStatusDone : l.taskStatusInProgress),
          color: t.isCompleted ? context.success : null,
        ),
      _Detail(
        label: ledger || category.kind == CategoryKind.savings || category.isSpending
            ? l.ledgerDateGiven
            : l.taskDetailCreated,
        primary: fmtDate(context, t.createdAt,
            withYear: t.createdAt.year != DateTime.now().year),
        secondary: ledger ? null : fmtTime(context, t.createdAt),
      ),
      if (t.dueAt != null)
        _Detail(
          label: l.taskDetailDue,
          primary: fmtDue(context, t),
          color: isOverdue(t) ? context.danger : null,
        ),
      if (t.isRecurring)
        _Detail(
            label: l.taskDetailRepeats, primary: repeatLabel(l, t.recurrence)),
      if (t.completedAt != null)
        _Detail(
          label: ledger ? l.ledgerSettledOn : l.taskDetailCompleted,
          primary: fmtDate(context, t.completedAt!),
          secondary: fmtTime(context, t.completedAt!),
        ),
    ];
    return Wrap(
      runSpacing: 18,
      spacing: 18,
      children: [for (final c in cells) SizedBox(width: 140, child: c)],
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail(
      {required this.label, required this.primary, this.secondary, this.color});
  final String label;
  final String primary;
  final String? secondary;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.eyebrow(context.ink3)),
        const SizedBox(height: 4),
        Text(primary,
            style: AppTheme.display(size: 18, color: color ?? context.ink)),
        if (secondary != null) ...[
          const SizedBox(height: 2),
          Text(secondary!, style: AppTheme.mono(size: 11, color: context.ink3)),
        ],
      ],
    );
  }
}

/// Numeric sheet for recording a (partial) payment.
Future<void> showPaymentSheet(BuildContext context, Category c, Task t) {
  return openSheet(context, _PaymentSheet(category: c, task: t));
}

class _PaymentSheet extends StatefulWidget {
  const _PaymentSheet({required this.category, required this.task});
  final Category category;
  final Task task;

  @override
  State<_PaymentSheet> createState() => _PaymentSheetState();
}

class _PaymentSheetState extends State<_PaymentSheet> {
  late final TextEditingController _amount =
      TextEditingController(text: formatMinor(widget.task.remainingMinor.abs()));
  final TextEditingController _note = TextEditingController();
  DateTime _date = DateTime.now();
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = context.l10n;
    final minor = parseAmountMinor(_amount.text);
    if (minor == null) {
      setState(() => _error = l.ledgerAmountInvalid);
      return;
    }
    final nav = Navigator.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    await context.read<CategoriesProvider>().addPayment(
          widget.category.id,
          widget.task.id,
          Payment(amountMinor: minor, paidAt: _date, note: _note.text.trim()),
        );
    nav.pop();
    messenger?.showSnackBar(SnackBar(content: Text(l.ledgerPaymentRecorded)));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SheetShell(
      eyebrow: l.ledgerRecordPayment,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _amount,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: AppTheme.display(size: 28, color: context.ink),
              decoration: InputDecoration(
                labelText: l.ledgerPaymentAmount,
                suffixText: widget.category.currency,
                errorText: _error,
              ),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              style: AppTheme.body(size: 15, color: context.ink),
              decoration: InputDecoration(labelText: l.ledgerPaymentNote),
            ),
            const SizedBox(height: 12),
            ActionChip(
              avatar: Icon(Icons.event_outlined, size: 16, color: context.ink2),
              label: Text(fmtDate(context, _date)),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _date,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(l.commonCancel),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                      onPressed: _save, child: Text(l.commonSave)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
