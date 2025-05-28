import 'package:flutter/material.dart';

/// Widget for a section card with input fields
class SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const SectionCard({
    super.key,
    required this.title,
    required this.children,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Widget for localized input (Arabic & English)
class LocalizedInputField extends StatelessWidget {
  final TextEditingController arController;
  final TextEditingController enController;
  final String arLabel;
  final String enLabel;
  final int? maxLines;
  final bool isRequired;
  final String? Function(String?)? arValidator;
  final String? Function(String?)? enValidator;

  const LocalizedInputField({
    super.key,
    required this.arController,
    required this.enController,
    required this.arLabel,
    required this.enLabel,
    this.maxLines,
    this.isRequired = true,
    this.arValidator,
    this.enValidator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: arController,
          decoration: InputDecoration(
            labelText: arLabel,
            border: const OutlineInputBorder(),
            suffixIcon: isRequired ? const Icon(Icons.star, size: 12, color: Colors.red) : null,
          ),
          maxLines: maxLines,
          textDirection: TextDirection.rtl,
          validator: arValidator ?? (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'هذا الحقل مطلوب';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: enController,
          decoration: InputDecoration(
            labelText: enLabel,
            border: const OutlineInputBorder(),
            suffixIcon: isRequired ? const Icon(Icons.star, size: 12, color: Colors.red) : null,
          ),
          maxLines: maxLines,
          validator: enValidator ?? (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
        ),
      ],
    );
  }
}

/// Loading indicator overlay
class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String loadingText;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingText = 'جار التحميل...',
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(loadingText),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
