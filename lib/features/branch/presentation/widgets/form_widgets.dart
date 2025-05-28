import 'package:flutter/material.dart';

/// كارت لعرض قسم من النموذج
class SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final EdgeInsets padding;

  const SectionCard({
    super.key,
    required this.title,
    required this.children,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(top: 16, right: 16, left: 16),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
          ],
          Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

/// حقل إدخال مزدوج اللغة
class LocalizedInputField extends StatelessWidget {
  final TextEditingController arController;
  final TextEditingController enController;
  final String arLabel;
  final String enLabel;
  final String? Function(String?)? arValidator;
  final String? Function(String?)? enValidator;
  final int? maxLines;
  
  const LocalizedInputField({
    super.key,
    required this.arController,
    required this.enController,
    required this.arLabel,
    required this.enLabel,
    this.arValidator,
    this.enValidator,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: arController,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: arLabel,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.star, size: 12, color: Colors.red),
          ),
          validator: arValidator,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: enController,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: enLabel,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.star, size: 12, color: Colors.red),
          ),
          validator: enValidator,
        ),
      ],
    );
  }
}

/// طبقة تحميل للصفحة
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final String loadingText;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.loadingText,
    required this.child,
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
                margin: const EdgeInsets.all(16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
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
