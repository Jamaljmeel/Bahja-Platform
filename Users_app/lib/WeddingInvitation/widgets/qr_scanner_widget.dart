import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/qr_scanner_model.dart';

class QrScannerWidget {
  static Widget buildInfoCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.cairo(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.cairo(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildCornerDecoration({
    required Alignment alignment,
    required Color color,
    required BorderRadius borderRadius,
  }) {
    BorderSide topSide = BorderSide.none;
    BorderSide bottomSide = BorderSide.none;
    BorderSide leftSide = BorderSide.none;
    BorderSide rightSide = BorderSide.none;

    if (alignment == Alignment.topLeft) {
      topSide = BorderSide(color: color, width: 4);
      leftSide = BorderSide(color: color, width: 4);
    } else if (alignment == Alignment.topRight) {
      topSide = BorderSide(color: color, width: 4);
      rightSide = BorderSide(color: color, width: 4);
    } else if (alignment == Alignment.bottomLeft) {
      bottomSide = BorderSide(color: color, width: 4);
      leftSide = BorderSide(color: color, width: 4);
    } else if (alignment == Alignment.bottomRight) {
      bottomSide = BorderSide(color: color, width: 4);
      rightSide = BorderSide(color: color, width: 4);
    }

    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: topSide,
          bottom: bottomSide,
          left: leftSide,
          right: rightSide,
        ),
        borderRadius: borderRadius,
      ),
    );
  }

  static Widget buildScanningOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
      ),
      child: Center(
        child: Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              // Corner decorations
              Positioned(
                top: -2,
                left: -2,
                child: buildCornerDecoration(
                  alignment: Alignment.topLeft,
                  color: Colors.blue[400]!,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(12)),
                ),
              ),
              Positioned(
                top: -2,
                right: -2,
                child: buildCornerDecoration(
                  alignment: Alignment.topRight,
                  color: Colors.blue[400]!,
                  borderRadius: BorderRadius.only(topRight: Radius.circular(12)),
                ),
              ),
              Positioned(
                bottom: -2,
                left: -2,
                child: buildCornerDecoration(
                  alignment: Alignment.bottomLeft,
                  color: Colors.blue[400]!,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12)),
                ),
              ),
              Positioned(
                bottom: -2,
                right: -2,
                child: buildCornerDecoration(
                  alignment: Alignment.bottomRight,
                  color: Colors.blue[400]!,
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget buildInstructions() {
    return Positioned(
      top: 50,
      left: 0,
      right: 0,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'وجه الكاميرا نحو رمز الدعوة',
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

// في qr_scanner_widget.dart، عدل دالة buildStatusInfo:

static Widget buildStatusInfo(String? scannedCode, Map<String, dynamic>? lastScanResult) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 10),
    padding: EdgeInsets.all(5),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.white.withOpacity(0.2)),
    ),
    child: Column(
      children: [
        Icon(
          scannedCode != null ? Icons.check_circle : Icons.qr_code_scanner,
          color: scannedCode != null ? Colors.green[400] : Colors.blue[400],
          size: 32,
        ),
        SizedBox(height: 8),
        Text(
          scannedCode != null ? 'تم المسح بنجاح' : 'جاهز للمسح',
          style: GoogleFonts.cairo(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        if (scannedCode != null && lastScanResult != null) ...[
          SizedBox(height: 8),
          Text(
            'تم تسجيل: ${lastScanResult['checkedInCount'] ?? 0} من ${lastScanResult['totalPeople'] ?? 0}',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: Colors.grey[300],
            ),
          ),
          if (lastScanResult['isFullyCheckedIn'] != true) ...[
            SizedBox(height: 4),
            Text(
              'المتبقي: ${(lastScanResult['totalPeople'] ?? 0) - (lastScanResult['checkedInCount'] ?? 0)} أشخاص',
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 12,
                color: Colors.blue[300],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ] else if (scannedCode != null) ...[
          SizedBox(height: 8),
          Text(
            'آخر مسح: ${scannedCode.length > 30 ? scannedCode.substring(0, 30) + '...' : scannedCode}',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: Colors.grey[300],
            ),
          ),
        ],
      ],
    ),
  );
}

  static Widget buildInvalidDataContainer(String code) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 40),
          SizedBox(height: 8),
          Text(
            'بيانات غير صالحة',
            style: GoogleFonts.cairo(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          SizedBox(height: 8),
          Text(
            code.length > 100 ? '${code.substring(0, 100)}...' : code,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: Colors.red[700],
            ),
          ),
        ],
      ),
    );
  }
}