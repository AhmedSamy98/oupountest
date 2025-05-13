import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/utils/app_logger.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cols = crossAxisCount(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم • Dashboard'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
        builder: (ctx, constraints) {

          return GridView.count(
            crossAxisCount: cols,
            padding: const EdgeInsets.all(24),
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            children: const [
              _NavCard(
                icon: Icons.add_box,
                labelAr: 'إضافة عرض',
                labelEn: 'Add Offer',
                route: '/create',
              ),
              _NavCard(
                icon: Icons.table_view,
                labelAr: 'عرض العروض',
                labelEn: 'Offers List',
                route: '/list',
              ),
              _NavCard(
                icon: Icons.delete_forever,
                labelAr: 'حذف العروض',
                labelEn: 'Delete Offers',
                route: '/delete',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String labelAr;
  final String labelEn;
  final String route;

  const _NavCard({
    required this.icon,
    required this.labelAr,
    required this.labelEn,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          log.i('Navigate → $route');             // تسجيل الحدث
          if (Navigator.canPop(context)) {
            Navigator.pushNamed(context, route);
          } else {
            Navigator.of(context).pushNamed(route);
          }
        },
        onLongPress: () => log.d('Long‑press on $route'),
        child: Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF0D47A1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: LayoutBuilder(builder: (_, c) {
              final isWide = c.maxWidth > 180;
              return Flex(
                direction: isWide ? Axis.horizontal : Axis.vertical,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: isWide ? 48 : 64),
                  SizedBox(width: isWide ? 16 : 0, height: isWide ? 0 : 16),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(labelAr,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      Text(labelEn,
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                    ],
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
