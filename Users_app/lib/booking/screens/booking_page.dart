import 'package:flutter/material.dart';
import '../../services/navigation_service.dart';
import '../../utils/constants.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/custom_app_bar.dart';
import '../services/booking_repository.dart';
import '../widgets/booking_components.dart';

class BookingPage extends StatefulWidget {
  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> with TickerProviderStateMixin {
  int _selectedIndex = 2;
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  String _selectedFilter = 'all';
  
  final BookingRepository _bookingRepository = BookingRepository();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _bookingRepository.getCurrentUser();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: CustomAppBars(title: 'حجوزاتي'),
      body: Column(
        children: [
          FilterChipsWidget(
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) => setState(() => _selectedFilter = filter),
          ),
          Expanded(
            child: BookingListWidget(
              userId: currentUser!.uid,
              selectedFilter: _selectedFilter,
              animationController: _animationController,
              fadeAnimation: _fadeAnimation,
              isLoading: _isLoading,
              onLoadingChanged: (loading) => setState(() => _isLoading = loading),
              bookingRepository: _bookingRepository,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) =>
            NavigationService.onItemTapped(context, index, _updateIndex),
      ),
    );
  }
}