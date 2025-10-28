// lib/screens/profile_management_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../services/profile_management_controller.dart';

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
     final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: CustomAppBar(title: 'اعدادات الحساب الشخصي'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             // تحديث اسم المستخدم
              Text('اسم المستخدم', style: AppTextStyles.medium(context).copyWith( fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              CustomTextField(controller: _controller.usernameController, hintText: 'أدخل اسم المستخدم الجديد'),
              SizedBox(height: 16),
            CustomButton(
                text: _controller.isUpdating ? 'جاري التحديث...' : 'تحديث اسم المستخدم',
                onPressed: _controller.isUpdating ? () {} : () => _controller.updateUsername(context, setState),
                 backgroundColor: _controller.isUpdating ?  AppColors.grey : AppColors.primary,
              ),
              SizedBox(height: 24),


               // تحديث كلمة المرور
              Text('تغيير كلمة المرور', style: AppTextStyles.medium(context).copyWith( fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              CustomTextField(controller: _controller.oldPasswordController, hintText: 'أدخل كلمة المرور الحالية', obscureText: true),
              SizedBox(height: 8),
              CustomTextField(controller: _controller.newPasswordController, hintText: 'أدخل كلمة المرور الجديدة', obscureText: true),
              SizedBox(height: 8),
              CustomTextField(controller: _controller.confirmPasswordController, hintText: 'تأكيد كلمة المرور الجديدة', obscureText: true),
              SizedBox(height: 16),
              CustomButton(
                text: _controller.isUpdating ? 'جاري التحديث...' : 'تحديث كلمة المرور',
                onPressed: _controller.isUpdating ? () {} : () => _controller.updatePassword(context, setState),
                backgroundColor: _controller.isUpdating ? AppColors.grey : AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}