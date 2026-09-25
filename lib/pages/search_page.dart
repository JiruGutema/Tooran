import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/categories_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/category_card.dart';
import '../widgets/common.dart';
import '../widgets/task_actions.dart';

/// Finds tasks by name, description or person across every category.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final provider = context.watch<CategoriesProvider>();
    final q = _query.text.trim();
    final results = provider.search(q);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                children: [
                  IconBtn(icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
                  Expanded(
                    child: TextField(
                      controller: _query,
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      style: AppTheme.body(size: 17, color: context.ink),
                      decoration: InputDecoration(
                        hintText: l.searchHint,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        suffixIcon: q.isEmpty
                            ? null
                            : IconButton(
                                icon: Icon(Icons.close, color: context.ink3),
                                onPressed: () => setState(_query.clear),
                              ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ],
              ),
            ),
            Container(height: 1, color: AppTheme.hairline(context.dark)),
            Expanded(
              child: q.isEmpty
                  ? _Hint(text: l.searchPrompt)
                  : results.isEmpty
                      ? _Hint(text: l.searchEmpty(q))
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 40),
                          itemCount: results.length,
                          itemBuilder: (_, i) {
                            final r = results[i];
                            return TaskRow(
                              category: r.category,
                              task: r.task,
                              isLast: i == results.length - 1,
                              showCategory: true,
                              onToggle: () => TaskActions.toggle(context, r.category, r.task),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Text(text,
            textAlign: TextAlign.center,
            style: AppTheme.display(size: 20, color: context.ink3, style: FontStyle.italic)),
      ),
    );
  }
}

/// Everything due today or overdue, across categories.
class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final items = context.watch<CategoriesProvider>().dueTodayOrOverdue();
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _PageHeader(
                eyebrow: l.todayTitle.toUpperCase(),
                title: fmtDate(context, DateTime.now()),
                subtitle: items.isEmpty ? null : l.todayCount(items.length),
              ),
            ),
            if (items.isEmpty)
              SliverFillRemaining(hasScrollBody: false, child: _Hint(text: l.todayEmpty))
            else
              SliverList.builder(
                itemCount: items.length,
                itemBuilder: (_, i) => TaskRow(
                  category: items[i].category,
                  task: items[i].task,
                  isLast: i == items.length - 1,
                  showCategory: true,
                  onToggle: () => TaskActions.toggle(context, items[i].category, items[i].task),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Who owes whom, grouped by person across ledger categories.
class PeoplePage extends StatelessWidget {
  const PeoplePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final provider = context.watch<CategoriesProvider>();
    final people = provider.people();
    final net = provider.ledgerNet();

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _PageHeader(
                eyebrow: l.peopleTitle.toUpperCase(),
                titleWidget: net.isEmpty
                    ? null
                    : Wrap(
                        spacing: 12,
                        children: [
                          for (final e in net.entries)
                            MoneyText(
                              e.value,
                              e.key,
                              showPlus: true,
                              style: AppTheme.display(
                                size: 36,
                                color: e.value >= 0 ? context.success : context.warning,
                              ),
                            ),
                        ],
                      ),
                subtitle: net.isEmpty ? null : l.ledgerNet,
              ),
            ),
            if (people.isEmpty)
              SliverFillRemaining(hasScrollBody: false, child: _Hint(text: l.peopleEmpty))
            else
              SliverList.builder(
                itemCount: people.length,
                itemBuilder: (_, i) => _PersonTile(person: people[i]),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}

class _PersonTile extends StatelessWidget {
  const _PersonTile({required this.person});
  final PersonBalance person;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = person;
    final net = p.netMinor;
    final settled = net == 0 && p.owedToMeMinor == 0 && p.iOweMinor == 0;
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 22),
        childrenPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: context.primary.withValues(alpha: 0.12),
          child: Text(
            p.person.characters.first.toUpperCase(),
            style: AppTheme.body(size: 16, color: context.primary, weight: FontWeight.w600),
          ),
        ),
        title: Text(p.person, style: AppTheme.body(size: 16, color: context.ink, weight: FontWeight.w500)),
        subtitle: Text(
          settled
              ? '${l.ledgerAllSquare} · ${l.peopleEntries(p.entries.length)}'
              : l.peopleEntries(p.entries.length),
          style: AppTheme.mono(size: 11, color: context.ink3),
        ),
        trailing: settled
            ? Icon(Icons.check_circle_outline, color: context.success, size: 20)
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MoneyText(
                    net.abs(),
                    p.currency,
                    style: AppTheme.mono(size: 13, color: net >= 0 ? context.success : context.warning),
                  ),
                  Text(
                    net >= 0 ? l.ledgerCaptionOwesYou : l.ledgerCaptionYouOwe,
                    style: AppTheme.mono(size: 10, color: context.ink3),
                  ),
                ],
              ),
        children: [
          for (var i = 0; i < p.entries.length; i++)
            TaskRow(
              category: p.entries[i].category,
              task: p.entries[i].task,
              isLast: i == p.entries.length - 1,
              showCategory: true,
              onToggle: () => TaskActions.toggle(context, p.entries[i].category, p.entries[i].task),
            ),
        ],
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({required this.eyebrow, this.title, this.titleWidget, this.subtitle});
  final String eyebrow;
  final String? title;
  final Widget? titleWidget;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 22, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconBtn(icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
              const SizedBox(width: 4),
              Text(eyebrow, style: AppTheme.eyebrow(context.ink3)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (titleWidget != null) titleWidget!,
                if (title != null) Text(title!, style: AppTheme.display(size: 36, color: context.ink)),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!, style: AppTheme.mono(size: 11, color: context.ink3)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
