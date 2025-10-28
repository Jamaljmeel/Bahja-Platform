import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/contact_us_controller.dart';
import '../widgets/SocialMediaLinks.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../utils/constants.dart';
import '../theme/app_theme.dart';

class ContactUsPage extends StatefulWidget {
  @override
  _ContactUsPageState createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> {
  final ContactUsController controller = ContactUsController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = AppThemes.customColors(context);
    
    return Scaffold(
      appBar: CustomAppBar(title: 'تواصل معنا'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            
            CustomTextField(
              controller: controller.phoneController,
              hintText: 'رقم الهاتف',
              prefixIcon: Icon(Icons.phone, color: theme.iconTheme.color),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: controller.selectedCategory,
              items: ['رسالة', 'شكوى', 'اقتراح']
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(
                          category,
                          style: AppTextStyles.medium(context),
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
                prefixIcon: Icon(Icons.message, color: theme.iconTheme.color),
                labelStyle: AppTextStyles.small(context).copyWith(
                  color: theme.hintColor,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: customColors.borderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: customColors.borderColor),
                ),
                filled: true,
                fillColor: customColors.inputFillColor,
              ),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: controller.messageController,
              hintText: 'الرسالة',
              prefixIcon: Icon(Icons.description, color: theme.iconTheme.color),
              maxLines: 5,
            ),
            const SizedBox(height: 16),

            CustomButton(
              text: controller.isLoading ? 'جاري الارسال...' : 'ارسال',
              onPressed: 
                 
                   () => controller.sendMessage(context, setState),
              backgroundColor: controller.isLoading 
                  ? Colors.grey 
                  : theme.primaryColor,
            ),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SocialIcon(
                  icon: Icons.facebook,
                  url: 'https://www.facebook.com/JamalAlawady',
                ),
                SizedBox(width: 16),
                SocialIcon(
                  icon: FontAwesomeIcons.whatsapp,
                  url: 'https://wa.me/967774583030',
                ),
                SizedBox(width: 16),
                SocialIcon(
                  icon: FontAwesomeIcons.instagram,
                  url: 'https://www.instagram.com/jmal_j1',
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text(
              'نسعى دائما لسماع اقتراحاتكم وشكواكم..',
              style: AppTextStyles.medium(context).copyWith(
                color: theme.primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}