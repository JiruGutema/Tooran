import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../models/task.dart';
import '../providers/categories_provider.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../utils/money.dart';
import '../utils/recurrence.dart';
import '../utils/spending.dart';
import 'common.dart';
import 'kind_info.dart';
import 'rich_text_editor.dart';

/// Add or edit a task — or, in a ledger category, an entry with a person
/// and an amount. New tasks support rapid entry: Enter on the name saves
/// and keeps the sheet open for the next one.
class TaskSheet extends StatefulWidget {
  const TaskSheet({
    super.key,
    required this.category,
    this.editing,
    this.initialName,
    this.initialNegative = false,
    this.initialAmount,
    this.initialDescription,
  });

  final Category category;
  final Task? editing;
  final String? initialName;

  /// Pre-filled values when an entry is moved over from another money list.
  final bool initialNegative;
  final String? initialAmount;
  final String? initialDescription;

  @override
  State<TaskSheet> createState() => _TaskSheetState();
}

class _TaskSheetState extends State<TaskSheet> {
  late final TextEditingController _name;
  late final TextEditingController _desc;
  late final TextEditingController _amount;
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _amountFocus = FocusNode();
  final FocusNode _descFocus = FocusNode();

  DateTime? _due;
  bool _dueHasTime = false;
  Recurrence _recurrence = Recurrence.none;
  DateTime _given = DateTime.now();
  String? _nameError;
  String? _amountError;
  int _added = 0;

  /// Ledger entries only: − takes away from the balance instead of adding.
  bool _negative = false;

  /// Adding an entry for a person already chosen (from their page, or after
  /// "Add another"): the name is known, so the sheet starts at the amount.
  late bool _personLocked =
      _ledger && widget.editing == null && (widget.initialName?.trim().isNotEmpty ?? false);

  bool get _ledger => widget.category.isLedger;
  CategoryKind get _kind => widget.category.kind;
  bool get _money => widget.category.tracksMoney;
  bool get _savings => _kind == CategoryKind.savings;
  bool get _notes => _kind == CategoryKind.notes;
  bool get _spending => _kind == CategoryKind.spending;
  bool get _hasDates => !_notes && !_savings && !_spending;

  /// Spending: the expense's tag. New expenses start with the last tag used.
  late String _tag = widget.editing?.tag ??
      (widget.category.tasks.isEmpty ? 'food' : (widget.category.tasks.last.tag ?? 'food'));
  bool get _editing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    final t = widget.editing;
    _name = TextEditingController(
        text: t == null
            ? (widget.initialName ?? '')
            : (_ledger ? (t.person ?? t.name) : t.name));
    _desc = TextEditingController(text: t?.description ?? widget.initialDescription ?? '');
    _amount = TextEditingController(
        text: t?.amountMinor == null
            ? (widget.initialAmount ?? '')
            : formatMinor(t!.amountMinor!.abs()));
    _negative = t == null ? widget.initialNegative : (t.amountMinor ?? 0) < 0;
    _due = t?.dueAt;
    _dueHasTime = t?.dueHasTime ?? false;
    _recurrence = t?.recurrence ??
        (widget.category.kind == CategoryKind.bills
            ? Recurrence.monthly
            : Recurrence.none);
    _given = t?.createdAt ?? DateTime.now();
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _amount.dispose();
    _nameFocus.dispose();
    _amountFocus.dispose();
    _descFocus.dispose();
    super.dispose();
  }

  /// Returns true when saved.
  Future<bool> _save() async {
    final l = context.l10n;
    final provider = context.read<CategoriesProvider>();
    var name = _name.text.trim();
    if (name.isEmpty && _savings) name = l.savingsDepositDefault;
    if (name.isEmpty && _spending) name = spendingTagName(l, _tag);
    if (name.isEmpty) {
      setState(
          () => _nameError = _ledger ? l.ledgerPersonEmpty : l.taskNameEmpty);
      return false;
    }
    int? amount;
    if (_money) {
      amount = parseAmountMinor(_amount.text);
      if (amount != null && _ledger && _negative) amount = -amount;
      final required = widget.category.amountRequired;
      if (amount == null && (required || _amount.text.trim().isNotEmpty)) {
        setState(() => _amountError = l.ledgerAmountInvalid);
        return false;
      }
    }
    // Ask for notification permission the first time a reminder matters.
    if (_due != null && widget.editing?.dueAt == null) {
      unawaited(NotificationService.instance.requestPermission());
    }
    final base = widget.editing;
    if (base == null) {
      await provider.addTask(
        widget.category.id,
        Task(
          name: name,
          description: _desc.text.trim(),
          dueAt: _due,
          dueHasTime: _dueHasTime,
          recurrence: _recurrence,
          person: _ledger ? name : null,
          amountMinor: amount,
          createdAt: _ledger || _savings || _spending ? _given : null,
          tag: _spending ? _tag : null,
        ),
      );
      if (_spending) _budgetCheck(provider);
    } else {
      await provider.updateTask(
        widget.category.id,
        base.copyWith(
          name: name,
          description: _desc.text.trim(),
          dueAt: _due,
          dueHasTime: _dueHasTime,
          recurrence: _recurrence,
          person: _ledger ? name : base.person,
          amountMinor: _money ? amount : base.amountMinor,
          createdAt: _ledger || _savings || _spending ? _given : base.createdAt,
          tag: _spending ? _tag : base.tag,
        ),
      );
    }
    return true;
  }

  /// After logging an expense: warn once the month passes 80% / 100% of
  /// the budget.
  void _budgetCheck(CategoriesProvider provider) {
    final c = provider.byId(widget.category.id);
    final budget = c?.targetMinor ?? 0;
    if (c == null || budget <= 0) return;
    final l = context.l10n;
    final spent = c.monthSpentMinor();
    final added = parseAmountMinor(_amount.text) ?? 0;
    final before = spent - added;
    String? msg;
    if (spent > budget && before <= budget) {
      msg = l.spendBudgetOverToast(formatMoney(spent - budget, c.currency));
    } else if (spent >= budget * 0.8 && before < budget * 0.8) {
      msg = l.spendBudgetWarn('${(spent * 100 / budget).round()}%');
    }
    if (msg != null) {
      ScaffoldMessenger.maybeOf(Navigator.of(context).context)?.showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Future<void> _submitAndClose() async {
    final nav = Navigator.of(context);
    if (await _save()) nav.pop();
  }

  /// Enter on the name moves on to the next field; it never saves.
  void _nameSubmitted() {
    (_money ? _amountFocus : _descFocus).requestFocus();
  }

  /// "Add another": save, clear, keep the sheet open for the next one.
  Future<void> _submitAndContinue() async {
    if (await _save()) {
      HapticFeedback.selectionClick();
      setState(() {
        _added++;
        // Money lists keep the person so the next entry is for them too.
        if (_ledger) {
          _personLocked = true;
        } else {
          _name.clear();
        }
        _amount.clear();
        _desc.clear();
        _due = null;
        _dueHasTime = false;
        _recurrence = Recurrence.none;
      });
      (_ledger ? _amountFocus : _nameFocus).requestFocus();
    }
  }

  Future<void> _pickDue() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _due ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 10),
    );
    if (picked == null) return;
    setState(() {
      _due = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _dueHasTime ? _due?.hour ?? 9 : 0,
          _dueHasTime ? _due?.minute ?? 0 : 0);
    });
  }

  Future<void> _pickTime() async {
    final d = _due ?? DateTime.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueHasTime
          ? TimeOfDay.fromDateTime(d)
          : const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked == null) return;
    setState(() {
      _due = DateTime(d.year, d.month, d.day, picked.hour, picked.minute);
      _dueHasTime = true;
    });
  }

  Future<void> _pickGiven() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _given,
      firstDate: DateTime(now.year - 20),
      lastDate: now,
    );
    if (picked != null) setState(() => _given = picked);
  }

  /// "Ephraim is already in Take back — add there as − instead".
  Widget _duplicateHint(BuildContext context) {
    final l = context.l10n;
    final other = context.read<CategoriesProvider>().otherLedgerWithPerson(widget.category, _name.text);
    if (other == null) return const SizedBox.shrink();
    // Every money list reads the same way, so the sign carries over as is.
    final otherNegative = _negative;
    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 4),
      decoration: BoxDecoration(
        color: context.warning.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppTheme.rSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.duplicatePersonHint(_name.text.trim(), other.name),
              style: AppTheme.body(size: 13, color: context.ink2)),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                final host = Navigator.of(context).context;
                Navigator.of(context).pop();
                openSheet(
                  host,
                  TaskSheet(
                    category: other,
                    initialName: _name.text.trim(),
                    initialNegative: otherNegative,
                    initialAmount: _amount.text,
                    initialDescription: _desc.text,
                  ),
                );
              },
              child: Text(l.duplicatePersonAction(otherNegative ? '−' : '+')),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final plainTasks =
        _kind == CategoryKind.tasks || _kind == CategoryKind.other;
    final eyebrow = _editing
        ? (_ledger
            ? l.ledgerEditEntry
            : (plainTasks ? l.taskEdit : l.editEntry))
        : _personLocked
            ? l.ledgerNewEntryFor(_name.text.trim())
            : newEntryTitle(l, widget.category);
    final submitLabel = _editing
        ? l.commonSave
        : (_ledger ? l.ledgerAddEntry : (plainTasks ? l.taskAdd : l.commonAdd));
    final (nameLabel, nameHint) = switch (_kind) {
      CategoryKind.shopping => (l.fieldItem, l.fieldItemHint),
      CategoryKind.bills => (l.fieldBill, l.fieldBillHint),
      CategoryKind.notes => (l.fieldTitle, l.fieldTitleHint),
      CategoryKind.savings => (l.fieldDeposit, l.savingsDepositDefault),
      _ => (l.commonNameLabel, l.taskNameHint),
    };
    final amountLabel = switch (_kind) {
      CategoryKind.shopping => l.fieldPrice,
      CategoryKind.bills => l.fieldBillAmount,
      _ => l.ledgerAmountLabel,
    };
    final people = _ledger
        ? context.read<CategoriesProvider>().knownPeople()
        : const <String>[];

    return SheetShell(
      eyebrow: eyebrow,
      trailing: _added > 0
          ? Text(l.taskAddedCount(_added),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.mono(size: 11, color: context.success))
          : null,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_ledger && !_personLocked)
              _PersonField(
                controller: _name,
                focusNode: _nameFocus,
                people: people,
                error: _nameError,
                autofocus: !_editing,
                onChanged: () => setState(() => _nameError = null),
                onSubmitted: _nameSubmitted,
              )
            else if (!_ledger && !_spending)
              TextField(
                controller: _name,
                focusNode: _nameFocus,
                autofocus: !_editing,
                maxLength: 120,
                maxLengthEnforcement: MaxLengthEnforcement.enforced,
                cursorColor: context.primary,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                style: AppTheme.display(size: 24, color: context.ink),
                decoration: InputDecoration(
                  labelText: nameLabel,
                  hintText: nameHint,
                  errorText: _nameError,
                  // Only show the counter once the name gets long.
                  counterText: _name.text.length > 80 ? null : '',
                ),
                onChanged: (_) {
                  if (_nameError != null) setState(() => _nameError = null);
                },
                onSubmitted: (_) => _nameSubmitted(),
              ),
            if (_ledger && !_editing && !_personLocked) _duplicateHint(context),
            if (_money) ...[
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _amount,
                      focusNode: _amountFocus,
                      autofocus: _personLocked || (_spending && !_editing),
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => _descFocus.requestFocus(),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: AppTheme.display(size: 24, color: context.ink),
                      decoration: InputDecoration(
                        prefixText: _ledger ? (_negative ? '− ' : '+ ') : null,
                        labelText: amountLabel,
                        suffixText: widget.category.currency,
                        errorText: _amountError,
                      ),
                      onChanged: (v) {
                        // Typing a leading minus flips a ledger entry to −.
                        final t = v.trimLeft();
                        if (_ledger && (t.startsWith('-') || t.startsWith('−'))) {
                          _amount.text = t.substring(1);
                          setState(() => _negative = true);
                        }
                        if (_amountError != null) {
                          setState(() => _amountError = null);
                        }
                      },
                    ),
                  ),
                  if (_ledger || _savings || _spending) ...[
                    const SizedBox(width: 14),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: _FieldButton(
                        label: l.ledgerDateGiven,
                        value: fmtDate(context, _given,
                            withYear: _given.year != DateTime.now().year),
                        onTap: _pickGiven,
                      ),
                    ),
                  ],
                ],
              ),
              if (_ledger) ...[
                const SizedBox(height: 12),
                SegmentedButton<bool>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                        value: false,
                        label: Text(l.moneySignPlus)),
                    ButtonSegment(
                        value: true,
                        label: Text(l.moneySignMinus)),
                  ],
                  selected: {_negative},
                  onSelectionChanged: (v) => setState(() => _negative = v.first),
                ),
                const SizedBox(height: 6),
                Text(
                  l.moneySignHelp,
                  style: AppTheme.body(size: 12, color: context.ink3),
                ),
              ],
            ],
            if (_spending) ...[
              const SizedBox(height: 16),
              Text(l.fieldTag, style: AppTheme.eyebrow(context.ink3)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final tag in spendingTags)
                    ChoiceChip(
                      label: Text(spendingTagLabel(l, tag)),
                      selected: _tag == tag,
                      showCheckmark: false,
                      onSelected: (_) => setState(() => _tag = tag),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _name,
                focusNode: _nameFocus,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _descFocus.requestFocus(),
                style: AppTheme.body(size: 16, color: context.ink),
                decoration: InputDecoration(
                  labelText: l.fieldExpenseFor,
                  hintText: l.fieldExpenseForHint,
                ),
              ),
            ],
            const SizedBox(height: 18),
            Text(
                _ledger || _savings || _spending
                    ? l.ledgerNoteLabel
                    : (_notes ? l.fieldNoteBody : l.taskDescriptionLabel),
                style: AppTheme.eyebrow(context.ink3)),
            const SizedBox(height: 8),
            RichTextEditor(
              controller: _desc,
              focusNode: _descFocus,
              labels: richLabels(l),
              minLines: _ledger || _savings || _spending ? 2 : (_notes ? 6 : 3),
              maxLines: _notes ? 14 : 8,
              style: AppTheme.body(size: 15, color: context.ink),
            ),
            if (_hasDates) ...[
              const SizedBox(height: 18),
              Text(l.taskDueLabel, style: AppTheme.eyebrow(context.ink3)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ActionChip(
                    avatar: Icon(Icons.event_outlined,
                        size: 16, color: context.ink2),
                    label: Text(_due == null
                        ? l.taskDueNone
                        : fmtDate(context, _due!,
                            withYear: _due!.year != DateTime.now().year)),
                    onPressed: _pickDue,
                  ),
                  if (_due != null)
                    ActionChip(
                      avatar:
                          Icon(Icons.schedule, size: 16, color: context.ink2),
                      label: Text(_dueHasTime
                          ? fmtTime(context, _due!)
                          : l.taskDueAddTime),
                      onPressed: _pickTime,
                    ),
                  if (_due != null)
                    IconBtn(
                      icon: Icons.close,
                      tooltip: l.taskDueClear,
                      onTap: () => setState(() {
                        _due = null;
                        _dueHasTime = false;
                      }),
                    ),
                ],
              ),
            ],
            if (!_ledger && _hasDates) ...[
              const SizedBox(height: 14),
              Text(l.taskRepeatLabel, style: AppTheme.eyebrow(context.ink3)),
              const SizedBox(height: 4),
              DropdownButton<Recurrence>(
                value: _recurrence,
                isExpanded: true,
                underline: Container(
                    height: 1, color: AppTheme.hairline(context.dark)),
                items: [
                  for (final r in Recurrence.values)
                    DropdownMenuItem(value: r, child: Text(repeatLabel(l, r))),
                ],
                onChanged: (r) =>
                    setState(() => _recurrence = r ?? Recurrence.none),
              ),
            ],
            const SizedBox(height: 22),
            if (!_editing)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _submitAndContinue,
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(l.taskAddAnother),
                ),
              ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(_added > 0 ? l.commonDone : l.commonCancel),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitAndClose,
                    child: Text(submitLabel),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldButton extends StatelessWidget {
  const _FieldButton(
      {required this.label, required this.value, required this.onTap});
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTheme.eyebrow(context.ink3)),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.event_outlined, size: 16, color: context.ink2),
                const SizedBox(width: 6),
                Text(value, style: AppTheme.body(size: 15, color: context.ink)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Person name field with autocomplete from earlier ledger entries.
class _PersonField extends StatelessWidget {
  const _PersonField({
    required this.controller,
    required this.focusNode,
    required this.people,
    required this.error,
    required this.autofocus,
    required this.onChanged,
    required this.onSubmitted,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<String> people;
  final String? error;
  final bool autofocus;
  final VoidCallback onChanged;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return RawAutocomplete<String>(
      textEditingController: controller,
      focusNode: focusNode,
      optionsBuilder: (v) {
        final q = v.text.trim().toLowerCase();
        if (q.isEmpty) return const Iterable<String>.empty();
        return people
            .where((p) => p.toLowerCase().contains(q) && p.toLowerCase() != q);
      },
      fieldViewBuilder: (context, ctrl, focus, onSubmit) => TextField(
        controller: ctrl,
        focusNode: focus,
        autofocus: autofocus,
        cursorColor: context.primary,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => onSubmitted(),
        style: AppTheme.display(size: 24, color: context.ink),
        decoration: InputDecoration(
          labelText: l.ledgerPersonLabel,
          hintText: l.ledgerPersonHint,
          errorText: error,
        ),
        onChanged: (_) => onChanged(),
      ),
      optionsViewBuilder: (context, onSelected, options) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(AppTheme.rSm),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 200, maxWidth: 320),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              children: [
                for (final o in options)
                  ListTile(
                      dense: true, title: Text(o), onTap: () => onSelected(o)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
