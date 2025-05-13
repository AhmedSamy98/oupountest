import 'package:flutter/material.dart';

class MultiLangField extends StatefulWidget {
  final String label;
  final TextEditingController ar;
  final TextEditingController en;
  const MultiLangField({super.key, required this.label, required this.ar, required this.en});

  @override
  State<MultiLangField> createState() => _MultiLangFieldState();
}

class _MultiLangFieldState extends State<MultiLangField> with SingleTickerProviderStateMixin {
  late final TabController _tab = TabController(length: 2, vsync: this);

  @override Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        TabBar(
          controller: _tab,
          tabs: const [Tab(text:'AR'), Tab(text:'EN')],
          indicatorColor: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(
          height: 70,
          child: TabBarView(
            controller: _tab,
            children: [
              TextFormField(controller: widget.ar, decoration: const InputDecoration(hintText:'بالعربية')),
              TextFormField(controller: widget.en, decoration: const InputDecoration(hintText:'In English')),
            ],
          ),
        ),
      ],
    );
  }
}
