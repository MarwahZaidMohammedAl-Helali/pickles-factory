import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/transaction.dart';
import '../models/product.dart';
import '../services/transaction_service.dart';
import '../providers/auth_provider.dart';
import '../screens/add_transaction_screen.dart';

class TransactionListWidget extends StatefulWidget {
  final List<Transaction> transactions;
  final Map<String, Product>? productMap;
  final Function()? onTransactionUpdated;

  const TransactionListWidget({
    super.key,
    required this.transactions,
    this.productMap,
    this.onTransactionUpdated,
  });

  @override
  State<TransactionListWidget> createState() => _TransactionListWidgetState();
}

class _TransactionListWidgetState extends State<TransactionListWidget> {
  final TransactionService _transactionService = TransactionService();
  final Set<String> _expandedNotes = <String>{};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.isAdmin();
    final theme = Theme.of(context);

    if (widget.transactions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(l10n.noData),
        ),
      );
    }

    return Column(
      children: [
        // Results count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'عدد المعاملات: ${widget.transactions.length}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.secondary,
            ),
          ),
        ),
        
        // Table header
        _buildTableHeader(context, theme),
        
        // Table rows
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.transactions.length,
          itemBuilder: (context, index) {
            final transaction = widget.transactions[index];
            return _buildTableRow(context, transaction, theme, isAdmin);
          },
        ),
      ],
    );
  }

  Widget _buildTableHeader(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              'التاريخ',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              'المسلم',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          SizedBox(
            width: 50,
            child: Text(
              'المرتجع',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                'ملاحظات',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(width: 64), // Space for edit and delete buttons
        ],
      ),
    );
  }

  Widget _buildTableRow(
    BuildContext context,
    Transaction transaction,
    ThemeData theme,
    bool isAdmin,
  ) {
    final isExpanded = _expandedNotes.contains(transaction.id);
    
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date
            SizedBox(
              width: 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormat('yyyy-MM-dd').format(transaction.deliveryDate),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 10,
                    ),
                  ),
                  if (transaction.createdByUsername != null)
                    Text(
                      transaction.createdByUsername!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontSize: 9,
                      ),
                    ),
                ],
              ),
            ),
            
            // Delivered
            SizedBox(
              width: 50,
              child: Text(
                '${transaction.jarsDelivered}',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  fontSize: 14,
                ),
              ),
            ),
            
            // Returned
            SizedBox(
              width: 50,
              child: Text(
                '${transaction.jarsEmpty}',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  fontSize: 14,
                ),
              ),
            ),
            
            // Notes
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: GestureDetector(
                  onTap: () {
                    if (transaction.notes != null && transaction.notes!.isNotEmpty) {
                      setState(() {
                        if (isExpanded) {
                          _expandedNotes.remove(transaction.id);
                        } else {
                          _expandedNotes.add(transaction.id);
                        }
                      });
                    }
                  },
                  child: Text(
                    transaction.notes ?? '-',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.secondary,
                      fontSize: 11,
                    ),
                    maxLines: isExpanded ? null : 2,
                    overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            
            // Edit and Delete buttons
            if (isAdmin)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    iconSize: 18,
                    onPressed: () => _editTransaction(context, transaction),
                    icon: Icon(
                      Icons.edit,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    iconSize: 18,
                    onPressed: () => _deleteTransaction(context, transaction),
                    icon: Icon(
                      Icons.delete,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              )
            else
              const SizedBox(width: 64),
          ],
        ),
      ),
    );
  }

  Future<void> _editTransaction(
    BuildContext context,
    Transaction transaction,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddTransactionScreen(
          existingTransaction: transaction,
        ),
      ),
    );

    if (result == true && widget.onTransactionUpdated != null) {
      widget.onTransactionUpdated!();
    }
  }

  Future<void> _deleteTransaction(
    BuildContext context,
    Transaction transaction,
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

        if (widget.onTransactionUpdated != null) {
          widget.onTransactionUpdated!();
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