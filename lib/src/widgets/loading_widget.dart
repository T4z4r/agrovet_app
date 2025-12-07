import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final Color? color;
  final double size;
  final String? message;

  const LoadingWidget({
    super.key,
    this.color,
    this.size = 24.0,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? const Color(0xFF2E7D32);
    
    if (message != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(themeColor),
            ),
            const SizedBox(height: 16),
            Text(
              message!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: themeColor,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(themeColor),
      ),
    );
  }
}

// Simple loading indicator for buttons
class ButtonLoadingWidget extends StatelessWidget {
  final Color? color;
  final double size;

  const ButtonLoadingWidget({
    super.key,
    this.color,
    this.size = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Colors.white,
        ),
      ),
    );
  }
}
