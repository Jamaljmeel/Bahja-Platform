import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:Admin_app/constants.dart';

class Service {
  String? id;
  String name;
  String imageUrl;

  Service({this.id, required this.name, required this.imageUrl});

  factory Service.fromFirestore(DocumentSnapshot doc) {
    try {
      if (!doc.exists) throw Exception('المستند غير موجود');

      final data = doc.data() as Map<String, dynamic>? ?? {};
      return Service(
        id: doc.id,
        name: data['name']?.toString() ?? 'بدون اسم',
        imageUrl: data['imageUrl']?.toString() ?? '',
      );
    } catch (e) {
      debugPrint('خطأ في تحويل المستند: $e');
      return Service(id: doc.id, name: 'خدمة غير معروفة', imageUrl: '');
    }
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'imageUrl': imageUrl,
      };
}

class ServiceManagementScreen extends StatefulWidget {
  @override
  _ServiceManagementScreenState createState() =>
      _ServiceManagementScreenState();
}

class _ServiceManagementScreenState extends State<ServiceManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = true;
  String? _errorMessage;
  List<Service> _services = [];

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final snapshot = await _firestore.collection('services').get();
      final services =
          snapshot.docs.map((doc) => Service.fromFirestore(doc)).toList();

      setState(() {
        _services = services;
        _isLoading = false;
      });

      debugPrint('تم تحميل ${services.length} خدمة بنجاح');
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل في تحميل الخدمات: ${e.toString()}';
        _isLoading = false;
      });
      debugPrint('حدث خطأ: $_errorMessage');
    }
  }

  Future<void> _addOrUpdateService(Service service, File? imageFile) async {
    setState(() => _isLoading = true);

    try {
      if (imageFile != null) {
        final fileName =
            'service_images/${service.id ?? DateTime.now().millisecondsSinceEpoch}';
        final snapshot = await _storage.ref(fileName).putFile(imageFile);
        service.imageUrl = await snapshot.ref.getDownloadURL();
      }

      if (service.id == null) {
        await _firestore.collection('services').add(service.toFirestore());
      } else {
        await _firestore
            .collection('services')
            .doc(service.id)
            .update(service.toFirestore());
      }

      await _loadServices();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteService(String serviceId) async {
    setState(() => _isLoading = true);

    try {
      await _firestore.collection('services').doc(serviceId).delete();
      await _loadServices();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('فشل في حذف الخدمة', style: GoogleFonts.elMessiri())),
      );
    }
  }

  Future<void> _showServiceDialog({Service? existingService}) async {
    final nameController = TextEditingController(text: existingService?.name);
    File? selectedImage;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: Text(
              textAlign: TextAlign.right,
              existingService == null ? 'إضافة خدمة جديدة' : 'تعديل الخدمة',
              style: GoogleFonts.elMessiri(),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'اسم الخدمة',
                        labelStyle: GoogleFonts.elMessiri().copyWith(
                          color: kBgColor.withOpacity(0.7),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () async {
                      final image =
                          await _picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setStateDialog(() => selectedImage = File(image.path));
                      }
                    },
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: selectedImage != null
                          ? Image.file(selectedImage!, fit: BoxFit.cover)
                          : existingService?.imageUrl.isNotEmpty == true
                              ? Image.network(existingService!.imageUrl,
                                  fit: BoxFit.cover)
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo),
                                    Text('إضافة صورة',
                                        style: GoogleFonts.elMessiri()),
                                  ],
                                ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('إلغاء', style: GoogleFonts.elMessiri()),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('الرجاء إدخال اسم الخدمة',
                          style: GoogleFonts.elMessiri()),
                    ));
                    return;
                  }

                  final service = Service(
                    id: existingService?.id,
                    name: nameController.text.trim(),
                    imageUrl: existingService?.imageUrl ?? '',
                  );

                  await _addOrUpdateService(service, selectedImage);
                  Navigator.pop(context);
                },
                child: Text(existingService == null ? 'إضافة' : 'حفظ',
                    style: GoogleFonts.elMessiri()),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kBgColor,
          iconTheme: IconThemeData(color: Colors.white),
          title: Text('إدارة الخدمات',
              style: GoogleFonts.elMessiri(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              )),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: kBgColor,
          child: Icon(
            Icons.add,
            size: 30,
            color: Colors.white,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onPressed: _showServiceDialog,
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_errorMessage!),
                        ElevatedButton(
                          onPressed: _loadServices,
                          child: Text('إعادة المحاولة',
                              style: GoogleFonts.elMessiri()),
                        ),
                      ],
                    ),
                  )
                : _services.isEmpty
                    ? Center(
                        child: Text('انقر على زر الإضافة لإنشاء خدمة جديدة',
                            style: GoogleFonts.elMessiri().copyWith(
                              color: Colors.grey[500],
                              fontSize: 14,
                            )))
                    : GridView.builder(
                        padding: EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: _services.length,
                        itemBuilder: (context, index) {
                          final service = _services[index];
                          return Card(
                            child: InkWell(
                              onTap: () =>
                                  _showServiceDialog(existingService: service),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: service.imageUrl.isNotEmpty
                                        ? Image.network(
                                            service.imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Icon(Icons.error),
                                          )
                                        : Icon(Icons.image, size: 50),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            service.name,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              color: Colors.red),
                                          onPressed: () =>
                                              _confirmDelete(service.id!),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }

  Future<void> _confirmDelete(String serviceId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          textAlign: TextAlign.right,
          'تأكيد الحذف',
          style: GoogleFonts.elMessiri().copyWith(
            fontSize: 20,
          ),
        ),
        content: Text(
          textAlign: TextAlign.right,
          'هل أنت متأكد من حذف هذه الخدمة؟',
          style: GoogleFonts.elMessiri().copyWith(
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء', style: GoogleFonts.elMessiri()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'حذف',
              style: GoogleFonts.elMessiri().copyWith(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteService(serviceId);
    }
  }
}
