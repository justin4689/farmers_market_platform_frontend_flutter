import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../transactions/domain/pending_transaction.dart';
import 'sync_notifier.dart';

class SyncStatusSheet extends ConsumerWidget {
  const SyncStatusSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const SyncStatusSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncNotifierProvider);
    final notifier = ref.read(syncNotifierProvider.notifier);
    final all = notifier.getAll();
    final pending = all.where((t) => !t.isFailed).toList();
    final failed = all.where((t) => t.isFailed).toList();

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      minChildSize: 0.35,
      builder: (_, scrollController) => Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 12, 12),
            child: Row(
              children: [
                const Icon(Icons.sync, color: AppColors.primary),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Offline Transactions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          // Status summary bar
          _StatusBar(syncState: syncState),

          // Action buttons
          if (failed.isNotEmpty || pending.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  if (pending.isNotEmpty && syncState.isOnline && !syncState.isSyncing)
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.sync, size: 16),
                        label: const Text('Sync now'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                        ),
                        onPressed: () => notifier.syncNow(),
                      ),
                    ),
                  if (pending.isNotEmpty && syncState.isOnline && !syncState.isSyncing && failed.isNotEmpty)
                    const SizedBox(width: 8),
                  if (failed.isNotEmpty) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Retry failed'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accent,
                          side: const BorderSide(color: AppColors.accent),
                        ),
                        onPressed: () => notifier.retryFailed(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text('Discard'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      onPressed: () => _confirmDiscard(context, notifier),
                    ),
                  ],
                ],
              ),
            ),

          const Divider(height: 1),

          // Transaction list
          Expanded(
            child: all.isEmpty
                ? const _EmptyState()
                : ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      if (syncState.isSyncing)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Synchronisation en cours…',
                                style: TextStyle(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      if (failed.isNotEmpty) ...[
                        _SectionHeader(
                          label: 'Echec (${failed.length})',
                          color: AppColors.error,
                          icon: Icons.error_outline,
                        ),
                        ...failed.map((tx) => _TxTile(tx: tx, isFailed: true)),
                      ],
                      if (pending.isNotEmpty) ...[
                        _SectionHeader(
                          label: 'En attente (${pending.length})',
                          color: AppColors.primary,
                          icon: Icons.schedule,
                        ),
                        ...pending.map((tx) => _TxTile(tx: tx, isFailed: false)),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void _confirmDiscard(BuildContext context, SyncNotifier notifier) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer les transactions échouées ?'),
        content: const Text(
          'Ces transactions ne pourront pas être récupérées. '
          'Les ventes correspondantes ne seront pas enregistrées sur le serveur.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              notifier.clearFailed();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _StatusBar extends StatelessWidget {
  final SyncState syncState;
  const _StatusBar({required this.syncState});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: syncState.isOnline
            ? const Color(0xFFE8F5E9)
            : const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            syncState.isOnline ? Icons.wifi : Icons.wifi_off,
            size: 16,
            color: syncState.isOnline
                ? const Color(0xFF2E7D32)
                : const Color(0xFFE65100),
          ),
          const SizedBox(width: 8),
          Text(
            syncState.isOnline ? 'Connecté' : 'Hors ligne',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: syncState.isOnline
                  ? const Color(0xFF2E7D32)
                  : const Color(0xFFE65100),
            ),
          ),
          const Spacer(),
          if (syncState.pendingCount > 0)
            _Chip(
              label: '${syncState.pendingCount} en attente',
              color: AppColors.primary,
            ),
          if (syncState.pendingCount > 0 && syncState.failedCount > 0)
            const SizedBox(width: 6),
          if (syncState.failedCount > 0)
            _Chip(
              label: '${syncState.failedCount} échouée(s)',
              color: AppColors.error,
            ),
          if (syncState.pendingCount == 0 && syncState.failedCount == 0)
            const Text(
              'Tout est synchronisé',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  const _SectionHeader({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _TxTile extends StatelessWidget {
  final PendingTransaction tx;
  final bool isFailed;
  const _TxTile({required this.tx, required this.isFailed});

  @override
  Widget build(BuildContext context) {
    final itemCount = tx.items.fold<int>(
      0,
      (sum, i) => sum + ((i['quantity'] as num?)?.toInt() ?? 1),
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isFailed
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isFailed ? Icons.error_outline : Icons.schedule,
                  size: 16,
                  color: isFailed ? AppColors.error : AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tx.farmerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  _formatDate(tx.createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const SizedBox(width: 24),
                _Badge(
                  label: tx.paymentMethod,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 6),
                _Badge(
                  label: '$itemCount article(s)',
                  color: AppColors.primary,
                ),
              ],
            ),
            if (isFailed && tx.errorMessage != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline,
                        size: 14, color: AppColors.error),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        tx.errorMessage!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return 'il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'il y a ${diff.inHours} h';
    return '${dt.day}/${dt.month} ${dt.hour}h${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, size: 48, color: Color(0xFF2E7D32)),
          SizedBox(height: 12),
          Text(
            'Toutes les transactions\nsont synchronisées',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
