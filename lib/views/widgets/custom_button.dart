import 'package:flutter/material.dart';
import 'package:flutter_alinfo9/core/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isOutlined;
  final bool isLoading;
  final Color? color;

  const CustomButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isOutlined = false,
    this.isLoading = false,
    this.color,
  }) : super(key: key);

  bool get _isDisabled => onPressed == null;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading || _isDisabled ? null : onPressed;
    final buttonColor = color ?? AppTheme.accentBlue;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: isOutlined
          ? OutlinedButton(
              onPressed: effectiveOnPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: _isDisabled ? AppTheme.textGrey : buttonColor,
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      text,
                      style: TextStyle(
                        color: _isDisabled ? AppTheme.textGrey : buttonColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            )
          : ElevatedButton(
              onPressed: effectiveOnPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isDisabled ? AppTheme.textGrey : buttonColor,
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
    );
  }
}
