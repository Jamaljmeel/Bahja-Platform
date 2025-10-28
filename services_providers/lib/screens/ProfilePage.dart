// lib/screens/profile_management_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../services/profile_management_controller.dart';
import '../utils/app_colors.dart';

class ProfileManagementPage extends StatefulWidget {
  @override
  _ProfileManagementPageState createState() => _ProfileManagementPageState();
}

class _ProfileManagementPageState extends State<ProfileManagementPage> {
  final ProfileManagementController _controller = ProfileManagementController();

  @override
  void initState() {
    super.initState();
    _controller.loadUserData(context, setState);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             // تحديث اسم المستخدم
              Text(
                'اسم المستخدم', 
                style: GoogleFonts.elMessiri(
                  fontSize: 15, 
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                )
              ),
              SizedBox(height: 8),
              CustomTextField(
                controller: _controller.usernameController, 
                hintText: 'أدخل اسم المستخدم الجديد'
              ),
              SizedBox(height: 16),
            CustomButton(
                text: _controller.isUpdating ? 'جاري التحديث...' : 'تحديث اسم المستخدم',
                onPressed: _controller.isUpdating ? () {} : () => _controller.updateUsername(context, setState),
                backgroundColor: _controller.isUpdating 
                  ? (isDark ? AppColors.borderDark : AppColors.borderLight)
                  : (isDark ? AppColors.primaryDark : AppColors.primaryLight),
              ),
              SizedBox(height: 24),

               // تحديث كلمة المرور
              Text(
                'تغيير كلمة المرور', 
                style: GoogleFonts.elMessiri(
                  fontSize: 15, 
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                )
              ),
              SizedBox(height: 8),
              CustomTextField(
                controller: _controller.oldPasswordController, 
                hintText: 'أدخل كلمة المرور الحالية', 
                obscureText: true
              ),
              SizedBox(height: 8),
              CustomTextField(
                controller: _controller.newPasswordController, 
                hintText: 'أدخل كلمة المرور الجديدة', 
                obscureText: true
              ),
              SizedBox(height: 8),
              CustomTextField(
                controller: _controller.confirmPasswordController, 
                hintText: 'تأكيد كلمة المرور الجديدة', 
                obscureText: true
              ),
              SizedBox(height: 16),
              CustomButton(
                text: _controller.isUpdating ? 'جاري التحديث...' : 'تحديث كلمة المرور',
                onPressed: _controller.isUpdating ? () {} : () => _controller.updatePassword(context, setState),
                backgroundColor: _controller.isUpdating 
                  ? (isDark ? AppColors.borderDark : AppColors.borderLight)
                  : (isDark ? AppColors.primaryDark : AppColors.primaryLight),
              ),
            ],
          ),
        ),
      ),
    );
  }
}