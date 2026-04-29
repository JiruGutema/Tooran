import 'package:flutter/material.dart';

import '../models/deleted_category.dart';
import '../services/data_service.dart';
import '../theme/app_theme.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final DataService _dataService = DataService();
  List<DeletedCategory> _deleted = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() => _isLoading = true);
      final list = await _dataService.loadDeletedCategoriesWithRecovery();
      setState(() {
        _deleted = list;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
      _toast('Could not load history');
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _restore(DeletedCategory dc) async {
    try {
      final active = await _dataService.loadCategoriesWithRecovery();
      active.add(dc.toCategory());
      await _dataService.saveCategories(active);
      _deleted.removeWhere((x) => x.id == dc.id);
      await _dataService.saveDeletedCategories(_deleted);
      setState(() {});
      _toast('"${dc.name}" restored');
    } catch (_) {
      _toast('Could not restore category');
    }
  }

  Future<void> _purge(DeletedCategory dc) async {
    try {
      _deleted.removeWhere((x) => x.id == dc.id);
      await _dataService.saveDeletedCategories(_deleted);
      setState(() {});
      _toast('"${dc.name}" deleted forever');
    } catch (_) {
      _toast('Could not delete');
    }
  }

  void _confirmPurge(DeletedCategory dc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete forever?',
            style: AppTheme.display(size: 24)),
        content: Text(
          'This cannot be undone. "${dc.name}" and its tasks will be erased.',
          style: AppTheme.body(size: 14)
              .copyWith(height: 1.5),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _purge(dc);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? AppTheme.dInk : AppTheme.lInk;
    final ink2 = dark ? AppTheme.dInk2 : AppTheme.lInk2;
    final ink3 = dark ? AppTheme.dInk3 : AppTheme.lInk3;

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 14, 0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back, size: 18),
                            color: ink2,
                            onPressed: () => Navigator.pop(context),
                          ),
                          Text('HISTORY', style: AppTheme.eyebrow(ink3)),
                          const Spacer(),
                          const SizedBox(width: 40),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 18)),
                  if (_deleted.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: AppTheme.hairlineStrong(dark),
                                    width: 1.5,
                                  ),
                                ),
                                child: Icon(Icons.inbox_outlined,
                                    color: ink3, size: 24),
                              ),
                              const SizedBox(height: 16),
                              Text('Nothing here',
                                  style: AppTheme.display(size: 24, color: ink)),
                              const SizedBox(height: 6),
                              Text(
                                'Deleted categories will land here. You can restore them, or let them go.',
                                textAlign: TextAlign.center,
                                style: AppTheme.body(size: 14, color: ink3),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) {
                            final dc = _deleted[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _DeletedCard(
                                dc: dc,
                                onRestore: () => _restore(dc),
                                onPurge: () => _confirmPurge(dc),
                              ),
                            );
                          },
                          childCount: _deleted.length,
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

class _DeletedCard extends StatelessWidget {
  const _DeletedCard({
    required this.dc,
    required this.onRestore,
    required this.onPurge,
  });
  final DeletedCategory dc;
  final VoidCallback onRestore;
  final VoidCallback onPurge;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? AppTheme.dInk : AppTheme.lInk;
    final ink3 = dark ? AppTheme.dInk3 : AppTheme.lInk3;
    final error = Theme.of(context).colorScheme.error;
    final done = dc.tasks.where((t) => t.isCompleted).length;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.rMd),
        border: Border.all(color: AppTheme.hairline(dark), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(dc.name,
                    style: AppTheme.display(size: 22, color: ink)),
              ),
              const SizedBox(width: 8),
              Text(_fmtDate(dc.deletedAt),
                  style: AppTheme.mono(size: 11, color: ink3)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${dc.tasks.length} task${dc.tasks.length == 1 ? '' : 's'} · $done done',
            style: AppTheme.body(size: 13, color: ink3),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: OutlinedButton(
                    onPressed: onRestore,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      textStyle: AppTheme.body(size: 13, weight: FontWeight.w500),
                    ),
                    child: const Text('Restore'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: OutlinedButton(
                    onPressed: onPurge,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: error,
                      textStyle: AppTheme.body(size: 13, weight: FontWeight.w500),
                    ),
                    child: const Text('Delete forever'),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  String _fmtDate(DateTime d) => '${_months[d.month - 1]} ${d.day}';
}
