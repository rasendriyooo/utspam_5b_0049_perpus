import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user.dart';
import '../models/borrow_transaction.dart';
import '../database/database_helper.dart';
import 'borrow_form_screen.dart';

class BorrowDetailScreen extends StatefulWidget {
  final BorrowTransaction transaction;
  final User user;

  const BorrowDetailScreen({
    super.key,
    required this.transaction,
    required this.user,
  });

  @override
  State<BorrowDetailScreen> createState() => _BorrowDetailScreenState();
}

class _BorrowDetailScreenState extends State<BorrowDetailScreen> {
  late BorrowTransaction _transaction;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _transaction = widget.transaction;
  }

  Future<void> _cancelTransaction() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Pembatalan'),
        content: const Text(
          'Apakah Anda yakin ingin membatalkan peminjaman ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final db = DatabaseHelper.instance;
      final updatedTransaction = _transaction.copyWith(status: 'dibatalkan');
      await db.updateTransaction(updatedTransaction);

      setState(() {
        _transaction = updatedTransaction;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Peminjaman berhasil dibatalkan'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _completeTransaction() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Penyelesaian'),
        content: const Text(
          'Apakah Anda yakin ingin menyelesaikan peminjaman ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Selesaikan'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isLoading = true);

    try {
      final db = DatabaseHelper.instance;
      final updatedTransaction = _transaction.copyWith(status: 'selesai');
      await db.updateTransaction(updatedTransaction);

      setState(() {
        _transaction = updatedTransaction;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Peminjaman berhasil diselesaikan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _editTransaction() async {
    final db = DatabaseHelper.instance;
    final book = await db.getBook(_transaction.bookId);

    if (book == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Buku tidak ditemukan')));
      }
      return;
    }

    if (!mounted) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BorrowFormScreen(
          user: widget.user,
          book: book,
          existingTransaction: _transaction,
        ),
      ),
    );

    if (result == true) {
      final updatedTransaction = await db.getTransaction(_transaction.id!);
      if (updatedTransaction != null) {
        setState(() {
          _transaction = updatedTransaction;
        });
      }
    }
  }

  Color _getStatusColor(String status) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (status) {
      case 'aktif':
        return colorScheme.primary;
      case 'selesai':
        return Colors.green;
      case 'dibatalkan':
        return colorScheme.error;
      default:
        return colorScheme.outline;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'aktif':
        return Icons.timer_outlined;
      case 'selesai':
        return Icons.check_circle_outline;
      case 'dibatalkan':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('dd MMMM yyyy', 'id_ID');
    final statusColor = _getStatusColor(_transaction.status);
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Peminjaman'),
        actions: [
          if (_transaction.status == 'aktif')
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: _isLoading ? null : _editTransaction,
              tooltip: 'Edit',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 280,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primaryContainer,
                          colorScheme.secondaryContainer,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 200,
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'lib/assets/images/${_transaction.bookCoverUrl}',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _transaction.bookTitle ?? 'Unknown Book',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_transaction.bookAuthor != null)
                          Text(
                            _transaction.bookAuthor!,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: statusColor, width: 2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getStatusIcon(_transaction.status),
                                color: statusColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'STATUS: ${_transaction.status.toUpperCase()}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceVariant.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          child: Column(
                            children: [
                              _DetailRow(
                                icon: Icons.person_outline_rounded,
                                label: 'Nama Peminjam',
                                value: _transaction.borrowerName,
                              ),
                              const Divider(height: 24),
                              _DetailRow(
                                icon: Icons.event_rounded,
                                label: 'Tanggal Mulai',
                                value: dateFormat.format(
                                  _transaction.startDate,
                                ),
                              ),
                              const Divider(height: 24),
                              _DetailRow(
                                icon: Icons.schedule_rounded,
                                label: 'Lama Pinjam',
                                value: '${_transaction.durationDays} hari',
                              ),
                              const Divider(height: 24),
                              _DetailRow(
                                icon: Icons.event_available_rounded,
                                label: 'Tanggal Kembali',
                                value: dateFormat.format(
                                  _transaction.startDate.add(
                                    Duration(days: _transaction.durationDays),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primaryContainer,
                                colorScheme.tertiaryContainer,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Biaya',
                                    style: theme.textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currencyFormat.format(
                                      _transaction.totalCost,
                                    ),
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                        ),
                                  ),
                                ],
                              ),
                              Icon(
                                Icons.monetization_on_outlined,
                                size: 48,
                                color: colorScheme.primary.withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        if (_transaction.status == 'aktif')
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              FilledButton.icon(
                                onPressed: _completeTransaction,
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.check_circle_outline_rounded,
                                ),
                                label: const Text('Selesaikan Peminjaman'),
                              ),
                              const SizedBox(height: 12),
                              FilledButton.icon(
                                onPressed: _cancelTransaction,
                                style: FilledButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  backgroundColor: Colors.transparent,
                                  side: BorderSide(color: Colors.red),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),

                                icon: const Icon(Icons.cancel_outlined),
                                label: const Text('Batalkan Peminjaman'),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
