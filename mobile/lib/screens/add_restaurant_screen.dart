import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../l10n/app_localizations.dart';
import '../services/restaurant_service.dart';
import '../providers/auth_provider.dart';

class AddRestaurantScreen extends StatefulWidget {
  const AddRestaurantScreen({super.key});

  @override
  State<AddRestaurantScreen> createState() => _AddRestaurantScreenState();
}

class _AddRestaurantScreenState extends State<AddRestaurantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final RestaurantService _restaurantService = RestaurantService();
  final ImagePicker _imagePicker = ImagePicker();
  
  bool _isLoading = false;
  String? _errorMessage;
  File? _selectedImage;
  String? _imageBase64;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        final bytes = await imageFile.readAsBytes();
        final base64String = base64Encode(bytes);

        setState(() {
          _selectedImage = imageFile;
          _imageBase64 = 'data:image/jpeg;base64,$base64String';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ في اختيار الصورة: $e';
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _restaurantService.initialize();
      
      // Add restaurant with optional photo
      if (_imageBase64 != null) {
        final restaurant = await _restaurantService.addRestaurant(_nameController.text);
        // Update with photo
        await _restaurantService.updateRestaurant(
          restaurant.id,
          photoUrl: _imageBase64,
        );
      } else {
        await _restaurantService.addRestaurant(_nameController.text);
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authProvider = Provider.of<AuthProvider>(context);
    final isAdmin = authProvider.isAdmin();

    // Only admin can access this screen
    if (!isAdmin) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: AppBar(
            title: Text(l10n.addRestaurant),
          ),
          body: const Center(
            child: Text('هذه الصفحة متاحة للمدير فقط'),
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.addRestaurant),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Photo picker
                GestureDetector(
                  onTap: _isLoading ? null : _pickImage,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_outlined,
                                size: 48,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'اضغط لاختيار صورة المطعم',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Restaurant name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.restaurantName,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.restaurant),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.requiredField;
                    }
                    return null;
                  },
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                
                // Error message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.error.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Theme.of(context).colorScheme.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Save button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.save),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
