import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/transaction.dart';
import '../models/product.dart';
import '../services/transaction_service.dart';
import '../providers/auth_provider.dart';

class TransactionListWidget extends StatelessWidget {
  final List<Transaction> transactions;
  final Map<String, Product>? productMap;
  final Function()? onTransactionUpdated;
  final TransactionService _transactionService = TransactionService();

  TransactionListWidget({
    super.key,
    required this.transactions,
    this.productMap,
    this.onTransactionUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.isAdmin();

    if (transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(l10n.noData),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTransactionCard(context, transaction, l10n, isAdmin);
      },
    );
  }

  Widget _buildTransactionCard(
    BuildContext context,
    Transaction transaction,
    AppLocalizations l10n,
    bool isAdmin,
  ) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            Icons.receipt,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          DateFormat('yyyy-MM-dd').format(transaction.date),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('علب مباعة: ${transaction.jarsSold}'),
            Text('علب مرتجعة: ${transaction.jarsReturned}'),
            Text(
              'الرصيد: ${transaction.jarsSold - transaction.jarsReturned}',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: isAdmin
            ? PopupMenuButton(
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 8),
                        Text('تعديل التاريخ'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('حذف', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  if (value == 'edit') {
                    _editTransactionDate(context, transaction);
                  } else if (value == 'delete') {
                    _deleteTransaction(context, transaction, l10n);
                  }
                },
              )
            : null,
      ),
    );
  }

  Future<void> _editTransactionDate(
    BuildContext context,
    Transaction transaction,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: transaction.date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != transaction.date) {
      try {
        await _transactionService.initialize();
        await _transactionService.updateTransaction(
          transactionId: transaction.id,
          date: picked,
        );

        if (onTransactionUpdated != null) {
          onTransactionUpdated!();
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تحديث التاريخ بنجاح')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ في التحديث: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteTransaction(
    BuildContext context,
    Transaction transaction,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذه المعاملة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _transactionService.initialize();
        await _transactionService.deleteTransaction(transaction.id);

        if (onTransactionUpdated != null) {
          onTransactionUpdated!();
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف المعاملة بنجاح')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ في الحذف: $e')),
          );
        }
      }
    }
  }
}

