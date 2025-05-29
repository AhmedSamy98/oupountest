import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/app_logger.dart';

class HomePage extends StatelessWidget {
  static const route = '/';
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cols = Responsive.gridColumns(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم • Dashboard'),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
        ),
        itemCount: _navItems.length,
        itemBuilder: (_, i) => _NavCard(item: _navItems[i]),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String labelAr;
  final String labelEn;
  final String route;
  const _NavItem(this.icon, this.labelAr, this.labelEn, this.route);
}

const _navItems = [
  _NavItem(Icons.add_box,      'إضافة ',   'Add ',   '/upload-phone'),
  _NavItem(Icons.table_view,   'عرض العروض',  'Offers List', '/list'),
  _NavItem(Icons.table_view,   'إداره الأعمال',  'Manage Business', '/business'),
  _NavItem(Icons.table_view,   'إضافه الفروع',  'Manage Brunch', '/branch/phone'),
];

class _NavCard extends StatefulWidget {
  final _NavItem item;
  const _NavCard({required this.item});

  @override
  State<_NavCard> createState() => _NavCardState();
}

class _NavCardState extends State<_NavCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
    lowerBound: 1,
    upperBound: 1.05,
  );

  @override
  Widget build(BuildContext context) {
    final horizontal = context.isDesktop || context.isTablet;

    return MouseRegion(
      onEnter: (_) => _ctrl.forward(),
      onExit: (_) => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () {
              log.i('Navigate → ${widget.item.route}');
              Navigator.of(context).pushNamed(widget.item.route);
            },
            child: Ink(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Flex(
                  direction: horizontal ? Axis.horizontal : Axis.vertical,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.item.icon,
                        color: Colors.white,
                        size: horizontal ? 48 : 64),
                    SizedBox(width: horizontal ? 16 : 0, height: horizontal ? 0 : 16),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(widget.item.labelAr,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        Text(widget.item.labelEn,
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
