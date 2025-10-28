import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../utils/constants.dart';
import '../models/guests_model.dart';
import '../services/guests_service.dart';
import '../widgets/guests_widget.dart';

class GuestsScreen extends StatefulWidget {
  @override
  _GuestsScreenState createState() => _GuestsScreenState();
}

class _GuestsScreenState extends State<GuestsScreen> with TickerProviderStateMixin {
  final GuestsService _guestsService = GuestsService();
  
  late TabController _tabController;
  List<EventModel> _userEvents = [];
  List<InviteeModel> _allInvitees = [];
  String? _selectedEventId;
  bool _isLoading = false;

  final TextEditingController _newInviteeNameController = TextEditingController();
  final TextEditingController _newInviteePhoneController = TextEditingController();
  final TextEditingController _newInviteeCountController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _newInviteeNameController.dispose();
    _newInviteePhoneController.dispose();
    _newInviteeCountController.dispose();
    super.dispose();
  }

  Future<void> _loadUserEvents() async {
    setState(() => _isLoading = true);

    try {
      final events = await _guestsService.loadUserEvents();
      setState(() {
        _userEvents = events;
      });
    } catch (e) {
      _showErrorSnackbar('حدث خطأ في تحميل المناسبات: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadInviteesForEvent(String invitationId) async {
    setState(() {
      _isLoading = true;
      _selectedEventId = invitationId;
    });

    try {
      final invitees = await _guestsService.loadInviteesForEvent(invitationId);
      setState(() {
        _allInvitees = invitees;
      });
      _tabController.animateTo(1);
    } catch (e) {
      _showErrorSnackbar('حدث خطأ في تحميل المدعوين: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTextStyles.medium(context)?.copyWith(color: AppColors.surfaceColor)),
        backgroundColor: AppColors.errorColor,
      ),
    );
  }

  Future<void> _addNewInvitee() async {
    if (_selectedEventId == null) {
      _showErrorSnackbar('يرجى اختيار مناسبة أولاً');
      return;
    }

    if (_newInviteeNameController.text.isEmpty || _newInviteePhoneController.text.isEmpty) {
      _showErrorSnackbar('يرجى إدخال اسم المدعو ورقم الهاتف');
      return;
    }

    try {
      await _guestsService.addNewInvitee(
        invitationId: _selectedEventId!,
        name: _newInviteeNameController.text,
        phoneNumber: _newInviteePhoneController.text,
        numberOfPeople: _newInviteeCountController.text,
      );

      _newInviteeNameController.clear();
      _newInviteePhoneController.clear();
      _newInviteeCountController.text = '1';

      await _loadInviteesForEvent(_selectedEventId!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إضافة المدعو بنجاح', style: AppTextStyles.medium(context)?.copyWith(color: AppColors.surfaceColor)),
          backgroundColor: AppColors.successColor,
        ),
      );
    } catch (e) {
      _showErrorSnackbar('حدث خطأ في إضافة المدعو: ${e.toString()}');
    }
  }

  Future<void> _pickContactFromPhone() async {
    try {
      bool shouldRequestPermission = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Text('إذن الوصول لجهات الاتصال', style: AppTextStyles.title(context)),
          content: Text(
            'يحتاج التطبيق إلى إذن للوصول إلى جهات الاتصال لتسهيل إضافة المدعوين. هل تريد المتابعة؟',
            style: AppTextStyles.medium(context),
          ),
          backgroundColor: AppColors.surfaceColor,
          actions: [
            TextButton(
              child: Text('إلغاء', style: AppTextStyles.medium(context)?.copyWith(color: AppColors.grey)),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text('موافق', style: AppTextStyles.medium(context)?.copyWith(color: AppColors.surfaceColor)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ) ?? false;

      if (!shouldRequestPermission) return;

      final contacts = await _guestsService.getContacts();
      
      await GuestsWidget.showContactsDialog(
        context: context,
        contacts: contacts,
        onContactSelected: (name, phone) {
          setState(() {
            _newInviteeNameController.text = name;
            _newInviteePhoneController.text = phone;
          });
        },
      );
    } catch (e) {
      String message = 'حدث خطأ في الوصول لجهات الاتصال';
      
      if (e.toString().contains('permission_permanently_denied')) {
        GuestsWidget.showPermissionDialog(
          context: context,
          onSettings: () => openAppSettings(),
        );
        return;
      } else if (e.toString().contains('permission_denied')) {
        message = 'تم رفض إذن الوصول إلى جهات الاتصال';
      } else if (e.toString().contains('no_contacts')) {
        message = 'لا توجد جهات اتصال';
      }
      
      _showErrorSnackbar(message);
    }
  }

  List<InviteeModel> get _pendingInvitees {
    return _guestsService.filterInviteesByStatus(_allInvitees, InviteeStatus.pending);
  }

  List<InviteeModel> get _checkedInInvitees {
    return _guestsService.filterInviteesByStatus(_allInvitees, InviteeStatus.checkedIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor(context),
      appBar: AppBar(
        title: Text('المدعوون', style: AppTextStyles.title(context)),
        backgroundColor: AppColors.primary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.surfaceColor,
          labelColor: AppColors.surfaceColor,
          unselectedLabelColor: AppColors.surfaceColor.withOpacity(0.7),
          labelStyle: AppTextStyles.medium(context),
          tabs: [
            Tab(icon: Icon(Icons.event), text: 'المناسبات'),
            Tab(icon: Icon(Icons.hourglass_empty), text: 'قيد الانتظار'),
            Tab(icon: Icon(Icons.check_circle), text: 'حضروا'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEventsTab(),
          _buildPendingInviteesTab(),
          _buildCheckedInInviteesTab(),
        ],
      ),
      
          
       
    );
  }

  Widget _buildEventsTab() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          GuestsWidget.buildHeaderCard(
            title: 'أسماء المناسبات',
            subtitle: 'اختر مناسبة لعرض المدعوين',
            icon: Icons.event_available,
            color: AppColors.primary,
            context: context,
          ),
          SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _userEvents.isEmpty
                    ? GuestsWidget.buildEmptyState(
                        icon: Icons.event_busy,
                        title: 'لا توجد مناسبات',
                        subtitle: 'قم بإنشاء مناسبة جديدة أولاً',
                        context: context,
                      )
                    : RefreshIndicator(
                        onRefresh: _loadUserEvents,
                        child: ListView.builder(
                          itemCount: _userEvents.length,
                          itemBuilder: (context, index) {
                            final event = _userEvents[index];
                            return GuestsWidget.buildEventCard(
                              event,
                              () => _loadInviteesForEvent(event.id),
                              context,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingInviteesTab() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          GuestsWidget.buildHeaderCard(
            title: 'قيد الانتظار',
            subtitle: 'المدعوون الذين لم يحضروا بعد',
            icon: Icons.hourglass_empty,
            color: AppColors.accentColor,
            context: context,
          ),
          SizedBox(height: 20),
          
          if (_selectedEventId == null)
            Expanded(
              child: GuestsWidget.buildEmptyState(
                icon: Icons.event_note,
                title: 'اختر مناسبة أولاً',
                subtitle: 'انتقل إلى تبويب المناسبات واختر مناسبة',
                context: context,
              ),
            )
          else
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _pendingInvitees.isEmpty
                      ? GuestsWidget.buildEmptyState(
                          icon: Icons.people_outline,
                          title: 'لا يوجد مدعوون قيد الانتظار',
                          context: context,
                        )
                      : ListView.builder(
                          itemCount: _pendingInvitees.length,
                          itemBuilder: (context, index) {
                            final invitee = _pendingInvitees[index];
                            return GuestsWidget.buildInviteeCard(invitee, context);
                          },
                        ),
            ),
        ],
      ),
    );
  }

  Widget _buildCheckedInInviteesTab() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          GuestsWidget.buildHeaderCard(
            title: 'حضروا',
            subtitle: 'المدعوون الذين تم تسجيل حضورهم',
            icon: Icons.check_circle,
            color: AppColors.secondary,
            context: context,
          ),
          SizedBox(height: 20),
          
          if (_selectedEventId == null)
            Expanded(
              child: GuestsWidget.buildEmptyState(
                icon: Icons.event_note,
                title: 'اختر مناسبة أولاً',
                subtitle: 'انتقل إلى تبويب المناسبات واختر مناسبة',
                context: context,
              ),
            )
          else
            Expanded(
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : _checkedInInvitees.isEmpty
                      ? GuestsWidget.buildEmptyState(
                          icon: Icons.people_outline,
                          title: 'لم يحضر أحد بعد',
                          context: context,
                        )
                      : Column(
                          children: [
                            GuestsWidget.buildAttendanceStats(
                              _checkedInInvitees.length,
                              _guestsService.getTotalAttendees(_checkedInInvitees),
                              context,
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: _checkedInInvitees.length,
                                itemBuilder: (context, index) {
                                  final invitee = _checkedInInvitees[index];
                                  return GuestsWidget.buildInviteeCard(invitee, context);
                                },
                              ),
                            ),
                          ],
                        ),
            ),
        ],
      ),
    );
  }
}