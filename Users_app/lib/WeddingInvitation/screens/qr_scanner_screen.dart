// qr_scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../utils/constants.dart';
import '../models/qr_scanner_model.dart';
import '../services/qr_scanner_service.dart';
import '../widgets/qr_scanner_widget.dart';

class QrScannerScreen extends StatefulWidget {
  final String? invitationId;

  const QrScannerScreen({Key? key, this.invitationId}) : super(key: key);

  @override
  _QrScannerScreenState createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  String? scannedCode;
  bool isDialogShown = false;
  bool isFlashOn = false;
  Map<String, dynamic>? lastScanResult;
  final MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );
  final QrScannerService _qrScannerService = QrScannerService();

  void _showScannedDialog(String code) async {
    if (!isDialogShown) {
      isDialogShown = true;
      
      final QrCodeData? qrData = await _qrScannerService.parseQrCodeWithData(code);
      
      if (qrData?.isValid == true) {
        // التحقق من اكتمال العدد قبل المحاولة
        if (qrData!.isFullyCheckedIn) {
          _showFullyCheckedInDialog(qrData);
        } else {
          await _updateInviteeStatus(qrData);
        }
      } else {
        _showSnackBar('بيانات الباركود غير صالحة.', Colors.red);
        _showInvalidQrDialog(code);
      }
    }
  }

  void _showFullyCheckedInDialog(QrCodeData qrData) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange[600]!, Colors.orange[800]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.warning, color: Colors.white, size: 30),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'اكتمل العدد!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16),
              Icon(Icons.group, size: 80, color: Colors.orange[600]),
              SizedBox(height: 16),
              Text(
                'تم تسجيل حضور جميع الأشخاص المدعوين لـ ${qrData.inviteeName}',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 24),
                        SizedBox(width: 8),
                        Text(
                          'مكتمل: ${qrData.numberOfPeople} من ${qrData.numberOfPeople}',
                          style: GoogleFonts.cairo(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'لا يمكن مسح الباركود مرة أخرى',
                      style: GoogleFonts.cairo(
                        fontSize: 14,
                        color: Colors.orange[800],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          Container(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[700],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'حسناً',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Future.delayed(Duration(milliseconds: 300), () {
                  setState(() {
                    isDialogShown = false;
                    scannedCode = null;
                    lastScanResult = null;
                  });
                  cameraController.start();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showInvalidQrDialog(String code) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red[600]!, Colors.red[800]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.error, color: Colors.white, size: 30),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'باركود غير صالح',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        content: QrScannerWidget.buildInvalidDataContainer(code),
        actions: [
          Container(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'حسناً',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Future.delayed(Duration(milliseconds: 300), () {
                  setState(() {
                    isDialogShown = false;
                    scannedCode = null;
                    lastScanResult = null;
                  });
                  cameraController.start();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateInviteeStatus(QrCodeData qrData) async {
    try {
      final result = await _qrScannerService.updateInviteeStatus(qrData);
      
      setState(() {
        lastScanResult = result;
      });
      
      Color snackBarColor;
      if (result['status'] == 'success') {
        // التحقق من القيم بطريقة آمنة
        bool isFullyCheckedIn = result['isFullyCheckedIn'] == true;
        snackBarColor = isFullyCheckedIn ? Colors.green : Colors.blue;
        
        // إظهار نافذة الإكمال إذا اكتمل العدد
        if (isFullyCheckedIn) {
          _showCompletionDialog(qrData, result);
        } else {
          _showProgressDialog(qrData, result);
        }
      } else if (result['status'] == 'fully_checked_in') {
        snackBarColor = Colors.orange;
        _showFullyCheckedInDialog(qrData);
      } else {
        snackBarColor = Colors.red;
        _showInvalidQrDialog(scannedCode ?? '');
      }
      
      _showSnackBar(result['message'] ?? 'تم المسح', snackBarColor);
    } catch (e) {
      _showSnackBar('حدث خطأ أثناء تحديث حالة المدعو: ${e.toString()}', Colors.red);
      _showInvalidQrDialog(scannedCode ?? '');
    }
  }

  void _showCompletionDialog(QrCodeData qrData, Map<String, dynamic> result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildCompletionDialog(qrData, result),
    );
  }

  void _showProgressDialog(QrCodeData qrData, Map<String, dynamic> result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildProgressDialog(qrData, result),
    );
  }

  AlertDialog _buildCompletionDialog(QrCodeData qrData, Map<String, dynamic> result) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green[600]!, Colors.green[800]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.celebration, color: Colors.white, size: 30),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'تم الإكمال!',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16),
            Icon(Icons.check_circle, size: 80, color: Colors.green),
            SizedBox(height: 16),
            QrScannerWidget.buildInfoCard('المناسبة', qrData.eventName, Icons.event, Colors.blue),
            SizedBox(height: 12),
            QrScannerWidget.buildInfoCard('المدعو', qrData.inviteeName, Icons.person, Colors.green),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                children: [
                  Text(
                    '🎉 تم تسجيل حضور جميع الأشخاص بنجاح! 🎉',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'العدد النهائي: ${result['totalPeople'] ?? 0} أشخاص',
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: Colors.green[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              'ممتاز!',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Future.delayed(Duration(milliseconds: 300), () {
                setState(() {
                  isDialogShown = false;
                  scannedCode = null;
                  lastScanResult = null;
                });
                cameraController.start();
              });
            },
          ),
        ),
      ],
    );
  }

  AlertDialog _buildProgressDialog(QrCodeData qrData, Map<String, dynamic> result) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue[600]!, Colors.blue[800]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.qr_code_scanner, color: Colors.white, size: 30),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'تم المسح بنجاح',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16),
            QrScannerWidget.buildInfoCard('المناسبة', qrData.eventName, Icons.event, Colors.blue),
            SizedBox(height: 12),
            QrScannerWidget.buildInfoCard('المدعو', qrData.inviteeName, Icons.person, Colors.green),
            SizedBox(height: 12),
            QrScannerWidget.buildInfoCard(
              'تم تسجيل حضور', 
              '${result['checkedInCount'] ?? 0} من ${result['totalPeople'] ?? 0}', 
              Icons.check_circle, 
              Colors.blue
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, size: 16, color: Colors.blue[700]),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'المتبقي: ${(result['totalPeople'] ?? 0) - (result['checkedInCount'] ?? 0)} أشخاص',
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              'متابعة المسح',
              style: GoogleFonts.cairo(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Future.delayed(Duration(milliseconds: 300), () {
                setState(() {
                  isDialogShown = false;
                  scannedCode = null;
                  lastScanResult = null;
                });
                cameraController.start();
              });
            },
          ),
        ),
      ],
    );
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              backgroundColor == Colors.green ? Icons.check_circle 
              : backgroundColor == Colors.blue ? Icons.person_add
              : backgroundColor == Colors.orange ? Icons.warning 
              : Icons.error,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(message, style: GoogleFonts.cairo()),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _toggleFlash() {
    setState(() {
      isFlashOn = !isFlashOn;
    });
    cameraController.toggleTorch();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'الماسح الضوئي',
          style: AppTextStyles.title(context),
        ),
        backgroundColor: const Color.fromARGB(255, 33, 150, 243),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: _toggleFlash,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                MobileScanner(
                  controller: cameraController,
                  onDetect: (capture) {
                    final String? code = capture.barcodes.first.rawValue;
                    if (code != null && scannedCode != code) {
                      cameraController.stop();
                      setState(() {
                        scannedCode = code;
                      });
                      _showScannedDialog(code);
                    }
                  },
                ),
                
                // Scanning overlay
                QrScannerWidget.buildScanningOverlay(),
                
                // Instructions
                QrScannerWidget.buildInstructions(),
              ],
            ),
          ),
          
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.grey[900]!, Colors.grey[800]!],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    QrScannerWidget.buildStatusInfo(scannedCode, lastScanResult),
                    
                    if (scannedCode != null) ...[
                      SizedBox(height: 16),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              scannedCode = null;
                              isDialogShown = false;
                              lastScanResult = null;
                            });
                            cameraController.start();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[900],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: Icon(Icons.refresh, color: Colors.white),
                          label: Text(
                            'إعادة المسح',
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}