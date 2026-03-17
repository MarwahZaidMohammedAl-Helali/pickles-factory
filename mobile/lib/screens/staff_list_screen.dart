import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../models/user.dart';
import '../services/staff_service.dart';
import '../providers/auth_provider.dart';
import 'add_staff_screen.dart';

class StaffListScreen extends StatefulWidget {
  const StaffListScreen({super.key});

  @override
  State<StaffListScreen> createState() => _StaffListScreenState();
}

class _StaffListScreenState extends State<StaffListScreen> {
  final StaffService _staffService = StaffService();
  List<User>? _staff;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _staffService.initialize();
      final staff = await _staffService.getStaff();
      setState(() {
        _staff = staff;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToAddStaff() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddStaffScreen()),
    );

    if (result == true) {
      _loadStaff();
    }
  }

  Future<void> _editStaff(User user) async {
    final usernameController = TextEditingController(text: user.username);
    final passwordController = TextEditingController();
    final currentPasswordController = TextEditingController();
    bool isEditingAdmin = user.role == 'admin';
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text(isEditingAdmin ? 'تعديل حسابك' : 'تعديل الموظف'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: usernameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم المستخدم',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'كلمة المرور الجديدة (اختياري)',
                    border: OutlineInputBorder(),
                    hintText: 'اتركه فارغاً للإبقاء على كلمة المرور الحالية',
                  ),
                  obscureText: true,
                ),
                if (isEditingAdmin) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: currentPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'كلمة المرور الحالية (للتأكيد)',
                      border: OutlineInputBorder(),
                      hintText: 'أدخل كلمة المرور الحالية للتأكيد',
                    ),
                    obscureText: true,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );

    if (result == true && usernameController.text.isNotEmpty) {
      try {
        await _staffService.initialize();
        await _staffService.updateStaff(
          user.id,
          username: usernameController.text,
          password: passwordController.text.isNotEmpty ? passwordController.text : null,
          currentPassword: isEditingAdmin && currentPasswordController.text.isNotEmpty 
              ? currentPasswordController.text 
              : null,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تحديث البيانات بنجاح')),
          );
          _loadStaff();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ في التحديث: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteStaff(User user, AppLocalizations l10n) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد من حذف الموظف "${user.username}"؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.no),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.yes),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      try {
        await _staffService.initialize();
        await _staffService.deleteStaff(user.id);
        _loadStaff();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }

  void _showPasswordDialog(User user, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('كلمة مرور ${user.username}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('اسم المستخدم: ${user.username}'),
              const SizedBox(height: 8),
              Text('كلمة المرور: ${user.plainPassword ?? "غير متوفرة"}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('إغلاق'),
            ),
          ],
        ),
      ),
    );
  }

  String _getRoleLabel(String role, AppLocalizations l10n) {
    return role == 'admin' ? l10n.admin : l10n.staffRole;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.staffList),
        ),
        body: _buildBody(l10n),
        floatingActionButton: FloatingActionButton(
          onPressed: _navigateToAddStaff,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.isAdmin();

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStaff,
              child: Text(l10n.retry ?? 'إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_staff == null || _staff!.isEmpty) {
      return Center(child: Text(l10n.noData));
    }

    return RefreshIndicator(
      onRefresh: _loadStaff,
      child: ListView.builder(
        itemCount: _staff!.length,
        itemBuilder: (context, index) {
          final user = _staff![index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(user.username),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${l10n.role}: ${_getRoleLabel(user.role, l10n)}'),
                  if (isAdmin && user.role != 'admin' && user.plainPassword == null)
                    Text(
                      'كلمة المرور: لم يتم تعيينها',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              leading: CircleAvatar(
                child: Icon(
                  user.role == 'admin' ? Icons.admin_panel_settings : Icons.person,
                ),
              ),
              trailing: isAdmin
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editStaff(user),
                          tooltip: 'تعديل',
                        ),
                        if (user.role != 'admin')
                          IconButton(
                            icon: const Icon(Icons.visibility),
                            onPressed: () => _showPasswordDialog(user, l10n),
                            tooltip: 'عرض كلمة المرور',
                          ),
                        if (user.role != 'admin')
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteStaff(user, l10n),
                            tooltip: 'حذف',
                          ),
                      ],
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
