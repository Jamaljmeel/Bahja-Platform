import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../theme/app_theme.dart';

class ServiceProvidersCard extends StatelessWidget {
  final String companyName;
  final String location;
  final String phone;
  final String companyLogo;
  // final double rating;
  // final int reviewsCount;
  final double? finalPrice;
  final double? priceFrom;
  final double? priceTo;
  final double? discount;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const ServiceProvidersCard({
    required this.companyName,
    required this.location,
    required this.phone,
    required this.companyLogo,
    // required this.rating,
    // required this.reviewsCount,
    this.finalPrice,
    this.priceFrom,
    this.priceTo,
    this.discount,
    this.isFavorite = false,
    required this.onFavoriteToggle,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customColors = AppThemes.customColors(context);
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    companyLogo,
                    width: 90,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.image, size: 90, color: theme.disabledColor),
                  ),
                ),
                if (discount != null && discount! > 0)
                  Positioned(
                    top: 5,
                    left: 5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color:  theme.colorScheme.error,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${discount!.toStringAsFixed(0)}%',
                        style: AppTextStyles.extraSmall(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 10),

            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          companyName,
                          style: AppTextStyles.large(context).copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.primaryColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ?  theme.colorScheme.error : theme.disabledColor,
                        ),
                        onPressed: onFavoriteToggle,
                      ),
                    ],
                  ),

                  // Row(
                  //   children: [
                  //     Icon(Icons.star, color: Colors.amber, size: 18),
                  //     const SizedBox(width: 4),
                  //     Text(
                  //       '$rating',
                  //       style: AppTextStyles.small(context).copyWith(
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //     const SizedBox(width: 4),
                  //     Text(
                  //       '($reviewsCount تقييم)',
                  //       style: AppTextStyles.extraSmall(context).copyWith(
                  //         color: theme.disabledColor,
                  //       ),
                  //     ),
                  //   ],
                  // ),

                  // const SizedBox(height: 5),

                  Row(
                    children: [
                      Icon(Icons.location_on, color: theme.primaryColor, size: 18),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: AppTextStyles.small(context),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      Icon(Icons.phone, color: theme.primaryColor, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        phone,
                        style: AppTextStyles.small(context).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    finalPrice != null
                        ? '${finalPrice!.toStringAsFixed(0)} ريال'
                        : '${priceFrom!.toStringAsFixed(0)} - ${priceTo!.toStringAsFixed(0)} ريال',
                    style: AppTextStyles.medium(context).copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}