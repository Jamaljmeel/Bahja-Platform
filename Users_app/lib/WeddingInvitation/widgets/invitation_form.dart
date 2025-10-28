
import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../theme/app_theme.dart';


class InvitationWidget {
  static Widget buildTextField(
    TextEditingController controller, 
    String label, 
    IconData icon, 
    BuildContext context,
    [TextInputType? keyboardType]
  ) {
    final customColors = AppThemes.customColors(context);
    
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: customColors.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: customColors.borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          labelStyle: AppTextStyles.small(context),
          filled: true,
          fillColor: customColors.inputFillColor,
        ),
        style: AppTextStyles.small(context),
        keyboardType: keyboardType,
      ),
    );
  }

  static Widget buildGradientButton(String text, VoidCallback onPressed, BuildContext context, {double width = 250}) {
    return Container(
      width: width,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: Text(
          text,
          style: AppTextStyles.medium(context)?.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  static Widget buildDetailRow(String label, String value, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.medium(context)?.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(width: 8),
          Expanded(
            child: Text(value, style: AppTextStyles.medium(context)),
          ),
        ],
      ),
    );
  }
}