import 'dart:async';

import 'package:core_kit/core_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nutrition_kit/nutrition_kit.dart';

import 'confirm_food_screen.dart';

/// Signature for providing a custom scanner widget in tests.
typedef MobileScannerWidgetBuilder = Widget Function(
  BuildContext context,
  MobileScannerController controller,
  void Function(BarcodeCapture capture) onDetect,
);

/// Full-screen barcode scanner that looks up products via [CompositeNutritionProvider].
class ScannerScreen extends StatefulWidget {
  const ScannerScreen({
    super.key,
    required this.mealRepository,
    CompositeNutritionProvider? nutritionProvider,
    this.mobileScannerBuilder,
    this.mealType = MealType.snack,
  }) : nutritionProvider = nutritionProvider ?? CompositeNutritionProvider();

  /// Repository used to persist the selected food item inside the meal log.
  final MealRepository mealRepository;

  /// Provider responsible for retrieving nutritional information based on barcodes.
  final CompositeNutritionProvider nutritionProvider;

  /// Optional builder primarily used by widget tests to avoid instantiating
  /// the platform camera widget.
  final MobileScannerWidgetBuilder? mobileScannerBuilder;

  /// Meal type that should receive the scanned ingredient.
  final MealType mealType;

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  late final MobileScannerController _controller;
  bool _hasPermission = true;
  bool _isProcessing = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
    _controller.onPermissionSet = _handlePermission;
    _statusMessage = null;
  }

  @override
  void dispose() {
    try {
      _controller.dispose();
    } catch (_) {
      // The controller invokes platform channels that are not available during
      // widget tests. Any resulting exceptions can be safely ignored here.
    }
    super.dispose();
  }

  void _handlePermission(bool granted) {
    if (!mounted) {
      return;
    }
    setState(() {
      _hasPermission = granted;
      if (!granted) {
        _statusMessage = null;
      } else {
        _statusMessage ??=
            AppLocalizations.of(context)?.scannerAlignBarcodeMessage;
      }
    });
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing || !_hasPermission) {
      return;
    }
    unawaited(_processBarcode(capture));
  }

  Future<void> _processBarcode(BarcodeCapture capture) async {
    final code = _extractBarcodeValue(capture);
    if (code == null) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _statusMessage = null;
    });

    await _pauseScanner();

    try {
      final item = await widget.nutritionProvider.lookupByBarcode(code);
      if (!mounted) {
        return;
      }

      if (item == null) {
        setState(() {
          _isProcessing = false;
          _statusMessage =
              AppLocalizations.of(context)?.scannerProductNotFoundMessage;
        });
        await _resumeScanner();
        return;
      }

      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => ConfirmFoodScreen(
            foodItem: item,
            mealRepository: widget.mealRepository,
            mealType: widget.mealType,
            nutritionProvider: widget.nutritionProvider,
          ),
        ),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isProcessing = false;
        _statusMessage =
            AppLocalizations.of(context)?.scannerCompletedMessage;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isProcessing = false;
        _statusMessage =
            AppLocalizations.of(context)?.scannerErrorMessage;
      });
    } finally {
      await _resumeScanner();
    }
  }

  Future<void> _pauseScanner() async {
    try {
      await _controller.stop();
    } on MissingPluginException {
      // Ignore when running in an environment without the underlying platform
      // implementation, such as widget tests.
    } catch (_) {
      // Best effort pause only.
    }
  }

  Future<void> _resumeScanner() async {
    try {
      await _controller.start();
    } on MissingPluginException {
      // Ignore for test environments without the native implementation.
    } catch (_) {
      // Ignore restart failures – the user can still continue scanning.
    }
  }

  String? _extractBarcodeValue(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue != null && rawValue.isNotEmpty) {
        return rawValue;
      }
      final displayValue = barcode.displayValue;
      if (displayValue != null && displayValue.isNotEmpty) {
        return displayValue;
      }
    }
    final dynamic raw = capture.raw;
    if (raw is String && raw.isNotEmpty) {
      return raw;
    }
    return null;
  }

  Widget _buildScannerView() {
    final builder = widget.mobileScannerBuilder;
    if (builder != null) {
      return builder(context, _controller, _onDetect);
    }

    return MobileScanner(
      controller: _controller,
      onDetect: _onDetect,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final statusMessage = _hasPermission
        ? _statusMessage ?? l10n.scannerAlignBarcodeMessage
        : l10n.scannerPermissionMessage;
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _TorchToggle(controller: _controller),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildScannerView(),
          const _ScannerOverlay(),
          if (_hasPermission)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (statusMessage.isNotEmpty)
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          statusMessage,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (_isProcessing)
                      const Padding(
                        padding: EdgeInsets.only(top: 16),
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),
            )
          else
            Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    statusMessage,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TorchToggle extends StatelessWidget {
  const _TorchToggle({required this.controller});

  final MobileScannerController controller;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool?>(
      valueListenable: controller.hasTorchState,
      builder: (context, hasTorch, child) {
        if (hasTorch != true) {
          return const SizedBox.shrink();
        }
        return ValueListenableBuilder<TorchState>(
          valueListenable: controller.torchState,
          builder: (context, state, child) {
            final isOn = state == TorchState.on;
            return IconButton(
              onPressed: () async {
                try {
                  await controller.toggleTorch();
                } on MissingPluginException {
                  // Ignore in tests.
                } catch (_) {
                  // Ignore toggle failures.
                }
              },
              icon: Icon(isOn ? Icons.flash_on : Icons.flash_off),
              color: Colors.white,
            );
          },
        );
      },
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  const _ScannerOverlay();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ScannerOverlayPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cutOutWidth = size.width * 0.75;
    final cutOutHeight = cutOutWidth * 0.6;
    final left = (size.width - cutOutWidth) / 2;
    final top = (size.height - cutOutHeight) / 2;
    final rect = Rect.fromLTWH(left, top, cutOutWidth, cutOutHeight);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(24));

    final darkPaint = Paint()..color = Colors.black54;
    final clearPaint = Paint()..blendMode = BlendMode.clear;

    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRect(Offset.zero & size, darkPaint);
    canvas.drawRRect(rrect, clearPaint);
    canvas.restore();

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
