import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../models/visitor.dart';
import '../theme/app_colors.dart';
import '../utils/navigation.dart';
import '../viewmodels/visitor_viewmodel.dart';

/// Clean and understandable QR Code Scanner screen.
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key, required this.isActive});

  final bool isActive;

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  late final MobileScannerController _controller;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      autoStart: false,
      formats: const <BarcodeFormat>[BarcodeFormat.qrCode],
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    if (widget.isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startScanner());
    }
  }

  @override
  void didUpdateWidget(QrScannerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      isProcessing = false;
      _startScanner();
    } else if (!widget.isActive && oldWidget.isActive) {
      _stopScanner();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startScanner() async {
    try {
      await _controller.start();
    } catch (_) {}
  }

  Future<void> _stopScanner() async {
    try {
      await _controller.stop();
    } catch (_) {}
  }

  Future<void> _toggleTorch() async {
    try {
      await _controller.toggleTorch();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flashlight is unavailable.')),
      );
    }
  }

  Future<void> _switchCamera() async {
    try {
      await _controller.switchCamera();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to switch camera.')),
      );
    }
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (isProcessing) return;

    String? code;
    for (final Barcode barcode in capture.barcodes) {
      final String? raw = barcode.rawValue;
      if (raw != null && raw.trim().isNotEmpty) {
        code = raw.trim();
        break;
      }
    }
    if (code == null) return;

    isProcessing = true;
    HapticFeedback.mediumImpact();

    final VisitorViewModel vm = context.read<VisitorViewModel>();
    final Visitor? visitor = vm.getVisitorById(code);

    if (visitor == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No visitor found for this QR code.')),
      );
      await Future<void>.delayed(const Duration(seconds: 2));
      if (mounted) isProcessing = false;
      return;
    }

    await _stopScanner();
    if (!mounted) return;

    await openVisitorDetails(context, visitor.id);
    if (!mounted) return;

    isProcessing = false;
    if (widget.isActive) {
      await _startScanner();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return const ColoredBox(color: AppColors.backgroundDark);
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: ValueListenableBuilder<MobileScannerState>(
        valueListenable: _controller,
        builder: (BuildContext context, MobileScannerState state, Widget? _) {
          if (state.error != null) {
            return _buildErrorView(context, state.error!);
          }
          return _buildScannerView(context, state);
        },
      ),
    );
  }

  Widget _buildScannerView(BuildContext context, MobileScannerState state) {
    final bool torchOn = state.torchState == TorchState.on;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double boxSize =
            math.min(constraints.maxWidth * 0.75, 300).toDouble();

        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
            ),

            // Top Header Bar
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text(
                        'Scan Visitor Pass',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              torchOn
                                  ? Icons.flash_on_rounded
                                  : Icons.flash_off_rounded,
                              color: torchOn
                                  ? AppColors.warning
                                  : AppColors.white,
                            ),
                            onPressed: _toggleTorch,
                          ),
                          IconButton(
                            icon: const Icon(Icons.flip_camera_ios,
                                color: AppColors.white),
                            onPressed: _switchCamera,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Center Viewfinder
            Center(
              child: Container(
                width: boxSize,
                height: boxSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary, width: 2.5),
                ),
              ),
            ),

            // Bottom Instructions
            Positioned(
              left: 20,
              right: 20,
              bottom: 40,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Point your camera at a visitor\'s QR code pass to instantly verify and check them in.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.white, fontSize: 13),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildErrorView(BuildContext context, MobileScannerException error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.videocam_off, size: 48, color: AppColors.slate),
            const SizedBox(height: 16),
            const Text(
              'Camera Unavailable',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.errorDetails?.message ??
                  'Please grant camera permission to scan passes.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.slate, fontSize: 13),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _startScanner,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
