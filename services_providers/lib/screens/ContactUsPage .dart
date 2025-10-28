import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/contact_us_controller.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_text_from_field.dart';
import '../widgets/social_icon.dart';
import '../utils/app_colors.dart';

class ContactUsPage extends StatefulWidget {
  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final ContactUsController controller = ContactUsController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: CustomAppBar(title: 'تواصل معنا '),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Center(
                child: Text(
                  'Bahja',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // حقل الهاتف
            CustomTextField(
              controller: controller.phoneController,
              hintText: 'رقم الهاتف',
              prefixIcon: Icon(
                Icons.phone,
                color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            // القائمة المنسدلة
            DropdownButtonFormField<String>(
              value: controller.selectedCategory,
              dropdownColor: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
              items: ['رسالة', 'شكوى', 'اقتراح']
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(
                          category, 
                          style: GoogleFonts.elMessiri(
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  controller.selectedCategory = value!;
                });
              },
               decoration: InputDecoration(
                      labelText: 'نوع الرسالة',
                      prefixIcon: Icon(
                        Icons.message,
                        color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
                      ),
                       labelStyle: GoogleFonts.elMessiri(
                        fontSize: 14,
                        color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
                        ),
                        filled: true,
                        fillColor: isDark ? AppColors.inputFillDark : AppColors.inputFillLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // حقل الرسالة
            CustomTextField(
              controller: controller.messageController,
              hintText: 'الرسالة',
              prefixIcon: Icon(
                Icons.description,
                color: isDark ? AppColors.hintTextDark : AppColors.hintTextLight,
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),

            // زر الإرسال
            ElevatedButton(
              onPressed: controller.isLoading
                  ? null
                  : () => controller.sendMessage(context, setState),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                backgroundColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
                disabledBackgroundColor: isDark ? AppColors.borderDark : AppColors.borderLight,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: controller.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Center(
                      child: Text(
                        'إرسال',
                        style: GoogleFonts.elMessiri(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 20),

            // روابط التواصل الاجتماعي
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SocialIcon(icon: Icons.facebook, url: 'https://www.facebook.com/Jamal Alawady'),
                SizedBox(width: 16),
                SocialIcon(icon: FontAwesomeIcons.whatsapp, url: 'https://wa.me/967774583030'),
                SizedBox(width: 16),
                SocialIcon(icon: FontAwesomeIcons.instagram, url: 'https://www.instagram.com/jmal_j1'),
              ],
            ),
            const SizedBox(height: 20),

            // النص السفلي
            Text(
              'نسعى دائما لسماع أقتراحاتكم وشكواكم..',
              style: GoogleFonts.elMessiri(
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}