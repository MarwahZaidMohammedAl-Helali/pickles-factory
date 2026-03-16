import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../l10n/app_localizations.dart';
import '../models/restaurant.dart';
import '../services/restaurant_service.dart';
import '../providers/auth_provider.dart';
import '../utils/formatters.dart';
import 'add_restaurant_screen.dart';
import 'restaurant_detail_screen.dart';

class RestaurantListScreen extends StatefulWidget {
  const RestaurantListScreen({super.key});

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  final RestaurantService _restaurantService = RestaurantService();
  final ImagePicker _imagePicker = ImagePicker();
  List<Restaurant>? _restaurants;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _restaurantService.initialize();
      final restaurants = await _restaurantService.getRestaurants();
      setState(() {
        _restaurants = restaurants;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _navigateToAddRestaurant() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddRestaurantScreen()),
    );

    if (result == true) {
      _loadRestaurants();
    }
  }

  Future<void> _navigateToRestaurantDetail(Restaurant restaurant) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantDetailScreen(restaurant: restaurant),
      ),
    );
    // Refresh list after returning from detail screen
    _loadRestaurants();
  }

  Future<void> _pickImageForRestaurant(Restaurant restaurant) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        // In a real app, you would upload the image to a server and get a URL
        // For now, we'll use the local file path as a placeholder
        // In production, implement proper image upload to your backend/cloud storage
        final photoUrl = image.path;
        
        await _restaurantService.initialize();
        await _restaurantService.updateRestaurant(
          restaurant.id,
          photoUrl: photoUrl,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('تم تحديث صورة ${restaurant.name}')),
          );
          _loadRestaurants();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في اختيار الصورة: $e')),
        );
      }
    }
  }

  void _showRestaurantOptions(Restaurant restaurant, bool isAdmin) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isAdmin) ...[
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('تغيير الصورة'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageForRestaurant(restaurant);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('تعديل المطعم'),
                  onTap: () {
                    Navigator.pop(context);
                    _editRestaurant(restaurant);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                  title: Text(
                    'حذف المطعم',
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteRestaurant(restaurant);
                  },
                ),
              ],
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('عرض التفاصيل'),
                onTap: () {
                  Navigator.pop(context);
                  _navigateToRestaurantDetail(restaurant);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editRestaurant(Restaurant restaurant) async {
    // Show edit dialog
    final nameController = TextEditingController(text: restaurant.name);
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تعديل المطعم'),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'اسم المطعم',
              border: OutlineInputBorder(),
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

    if (result == true && nameController.text.isNotEmpty) {
      try {
        await _restaurantService.initialize();
        await _restaurantService.updateRestaurant(
          restaurant.id,
          name: nameController.text,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تحديث المطعم بنجاح')),
          );
          _loadRestaurants();
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

  Future<void> _deleteRestaurant(Restaurant restaurant) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: Text('هل أنت متأكد من حذف مطعم "${restaurant.name}"؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      try {
        await _restaurantService.initialize();
        await _restaurantService.deleteRestaurant(restaurant.id);
        _loadRestaurants();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم حذف المطعم بنجاح')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('خطأ في الحذف: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.isAdmin();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.restaurantsList),
        ),
        body: _buildBody(l10n, isAdmin),
        floatingActionButton: isAdmin
            ? FloatingActionButton(
                onPressed: _navigateToAddRestaurant,
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n, bool isAdmin) {
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
              onPressed: _loadRestaurants,
              child: Text(l10n.retry ?? 'إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_restaurants == null || _restaurants!.isEmpty) {
      return Center(child: Text(l10n.noData));
    }

    return RefreshIndicator(
      onRefresh: _loadRestaurants,
      child: ListView.builder(
        itemCount: _restaurants!.length,
        itemBuilder: (context, index) {
          final restaurant = _restaurants![index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                backgroundImage: restaurant.photoUrl != null && restaurant.photoUrl!.isNotEmpty
                    ? (restaurant.photoUrl!.startsWith('http')
                        ? NetworkImage(restaurant.photoUrl!) as ImageProvider
                        : FileImage(File(restaurant.photoUrl!)))
                    : null,
                child: restaurant.photoUrl == null || restaurant.photoUrl!.isEmpty
                    ? Icon(
                        Icons.restaurant,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      )
                    : null,
              ),
              title: Text(
                restaurant.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: restaurant.balance != null
                  ? Text(
                      'عدد العلب الفارغة: ${restaurant.balance!.abs().toInt()}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : null,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isAdmin)
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => _showRestaurantOptions(restaurant, isAdmin),
                      tooltip: 'خيارات',
                    ),
                  const Icon(Icons.chevron_left),
                ],
              ),
              onTap: () => _navigateToRestaurantDetail(restaurant),
            ),
          );
        },
      ),
    );
  }
}
