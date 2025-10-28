import 'package:flutter/material.dart';
import '../model/service_model.dart';
import '../utils/constants.dart';

class ServicePricingCard extends StatelessWidget {
  final ServiceModel service;

  const ServicePricingCard({
    Key? key,
    required this.service,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!_shouldShowPricing()) return SizedBox.shrink();

    return Card(
      elevation: 4,
      color: AppColors.inputFillColor(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: EdgeInsets.only(bottom: 20),
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'التسعير',
              style: AppTextStyles.extraLarge(context).copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Divider(),
            ..._buildPricingContent(context),
            if (_shouldShowOffer()) ..._buildOfferContent(context),
          ],
        ),
      ),
    );
  }

  bool _shouldShowPricing() {
    return service.priceFrom != null || 
           service.priceTo != null || 
           service.finalPrice != null;
  }

  bool _shouldShowOffer() {
    return service.hasOffer && 
           service.discount != null && 
           service.offerDetails != null;
  }

  List<Widget> _buildPricingContent(BuildContext context) {
    List<Widget> widgets = [];

    if (service.priceFrom != null && service.priceTo != null) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'نطاق السعر:',
                style: AppTextStyles.medium(context).copyWith(
                  color: AppColors.textColor(context).withOpacity(0.7),
                ),
              ),
              Text(
                '${service.priceFrom} - ${service.priceTo} ريال',
                style: AppTextStyles.large(context).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (service.finalPrice != null) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'السعر النهائي:',
                style: AppTextStyles.medium(context).copyWith(
                  color: AppColors.textColor(context).withOpacity(0.7),
                ),
              ),
              Text(
                '${service.finalPrice} ريال',
                style: AppTextStyles.extraLarge(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  List<Widget> _buildOfferContent(BuildContext context) {
    return [
      Container(
        margin: EdgeInsets.only(top: 8),
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_offer, color: Colors.red, size: 16),
                SizedBox(width: 8),
                Text(
                  'خصم ${service.discount}% متاح!',
                  style: AppTextStyles.medium(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Text(
              service.offerDetails!,
              style: AppTextStyles.small(context).copyWith(
                color: AppColors.textColor(context).withOpacity(0.8),
              ),
            ),
            if (service.offerStartDate != null && service.offerEndDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  'ساري من ${service.offerStartDate} إلى ${service.offerEndDate}',
                  style: AppTextStyles.small(context).copyWith(
                    fontStyle: FontStyle.italic,
                    color: AppColors.textColor(context).withOpacity(0.6),
                  ),
                ),
              ),
          ],
        ),
      ),
    ];
  }
}