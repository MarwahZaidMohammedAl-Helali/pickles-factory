import 'dart:io';
import 'dart:convert';
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _restaurants!.length,
        itemBuilder: (context, index) {
          final restaurant = _restaurants![index];
          return GestureDetector(
            onTap: () => _navigateToRestaurantDetail(restaurant),
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.surface,
                      Theme.of(context).colorScheme.surface.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Restaurant Photo
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 80,
                            height: 80,
                            color: Theme.of(context).colorScheme.primaryContainer,
                            child: restaurant.photoUrl != null && restaurant.photoUrl!.isNotEmpty
                                ? (restaurant.photoUrl!.startsWith('data:image')
                                    ? Image.memory(
                                        base64Decode(restaurant.photoUrl!.split(',')[1]),
                                        fit: BoxFit.cover,
                                      )
                                    : (restaurant.photoUrl!.startsWith('http')
                                        ? Image.network(
                                            restaurant.photoUrl!,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            File(restaurant.photoUrl!),
                                            fit: BoxFit.cover,
                                          )))
                                : Icon(
                                    Icons.restaurant,
                                    size: 40,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Restaurant Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              restaurant.name,
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'عدد العلب الفارغة: ${restaurant.balance!.abs().toInt()}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Actions
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isAdmin)
                            IconButton(
                              icon: const Icon(Icons.more_vert),
                              onPressed: () => _showRestaurantOptions(restaurant, isAdmin),
                              tooltip: 'خيارات',
                              iconSize: 20,
                            ),
                          const Icon(Icons.chevron_left, size: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
