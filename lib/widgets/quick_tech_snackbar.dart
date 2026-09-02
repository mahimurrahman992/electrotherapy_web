import 'package:flutter/material.dart';
import 'package:get/get.dart';


class QuickTechSnackbar {
  QuickTechSnackbar._();

  static const Color _successColor = Color(0xFF2E7D32);
  static const Color _errorColor = Color(0xFFC62828);
  static const Color _warningColor = Color(0xFFEF6C00);
  static const Color _infoColor = Color(0xFF1565C0);

  /// Green – something completed successfully.
  static void success(String message, {String? title}) =>
      _show(message, title: title, background: _successColor, icon: Icons.check_circle_outline);

  /// Red – an operation failed.
  static void error(String message, {String? title}) =>
      _show(message, title: title, background: _errorColor, icon: Icons.error_outline);

  /// Orange – non-fatal caution (rate limit, validation, timeout).
  static void warning(String message, {String? title}) =>
      _show(message, title: title, background: _warningColor, icon: Icons.warning_amber_rounded);

  /// Blue – neutral information.
  static void info(String message, {String? title}) =>
      _show(message, title: title, background: _infoColor, icon: Icons.info_outline);

  /// Fully custom colour. Prefer the named helpers above.
  static void show(
    String message, {
    String? title,
    Color background = _infoColor,
    IconData? icon,
  }) =>
      _show(message, title: title, background: background, icon: icon);

  /// Removes any snackbar currently on screen.
  static void dismiss() {
    final ctx = _context;
    if (ctx == null) return;
    try {
      ScaffoldMessenger.maybeOf(ctx)?.clearSnackBars();
    } catch (_) {}
  }

  // ── internals ──────────────────────────────────────────────────────────────

  static BuildContext? get _context => Get.context ?? Get.overlayContext;

  static void _show(
    String message, {
    String? title,
    required Color background,
    IconData? icon,
  }) {
    final ctx = _context;
    if (ctx == null) return;

    // Defer to the next frame so we never fire mid-build / mid-transition,
    // and guard everything so a toast failure can't propagate to the caller.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final messenger = ScaffoldMessenger.maybeOf(ctx);
        if (messenger == null) return;

        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: background,
              duration: const Duration(seconds: 3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              content: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (title != null && title.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        Text(
                          message,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
      } catch (_) {
        // Intentionally swallowed – a notification must never crash the app.
      }
    });
  }
}
