import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_text_styles.dart';
import '../providers/attendance_provider.dart';

class GymQRScannerSheet extends ConsumerStatefulWidget {
  const GymQRScannerSheet({super.key});

  @override
  ConsumerState<GymQRScannerSheet> createState() => _GymQRScannerSheetState();
}

class _GymQRScannerSheetState extends ConsumerState<GymQRScannerSheet> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  bool _isProcessing = false;
  bool _isTorchOn = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final rawValue = barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final result = await ref
          .read(attendanceControllerProvider.notifier)
          .scanAndCheckIn(rawQrData: rawValue);

      if (!mounted) return;

      Navigator.of(context).pop();

      // Show celebratory confirmation modal
      _showResultDialog(context, result);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red.shade800,
          duration: const Duration(seconds: 4),
        ),
      );

      // Re-enable scanning after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showResultDialog(BuildContext context, AttendanceCheckInResult result) {
    final isCheckIn = result.action == AttendanceAction.checkedIn;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: (isCheckIn ? AppColors.primary : Colors.orangeAccent)
                      .withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCheckIn ? Icons.check_circle_rounded : Icons.logout_rounded,
                  color: isCheckIn ? AppColors.primary : Colors.orangeAccent,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isCheckIn ? 'Attendance Confirmed!' : 'Checked Out!',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                result.message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Awesome!'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Scanner
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),

          // Scanner Overlay Mask
          SafeArea(
            child: Column(
              children: [
                // Top Action Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.black54,
                        shape: const CircleBorder(),
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Scan Gym QR',
                        style: AppTextStyles.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Material(
                        color: Colors.black54,
                        shape: const CircleBorder(),
                        child: IconButton(
                          icon: Icon(
                            _isTorchOn ? Icons.flash_on : Icons.flash_off,
                            color: _isTorchOn ? AppColors.primary : Colors.white,
                          ),
                          onPressed: () {
                            _scannerController.toggleTorch();
                            setState(() {
                              _isTorchOn = !_isTorchOn;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Target Frame Box
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isProcessing ? AppColors.primary : Colors.white70,
                      width: 2.5,
                    ),
                  ),
                  child: _isProcessing
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Align Gym QR code within the frame',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const Spacer(),

                // Bottom security badge
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_clock_outlined, color: Colors.white54, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Daily dynamic verification enabled',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
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
