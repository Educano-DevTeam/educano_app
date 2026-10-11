import 'package:flutter/material.dart';
import '../../../core/theme/theme.dart';

const _radius = 18.0;
const _small = 16.0;

class DashboardSummaryData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const DashboardSummaryData({required this.label, required this.value, required this.icon, required this.color});
}

class DashboardSummaryGrid extends StatelessWidget {
  final List<DashboardSummaryData> items;
  const DashboardSummaryGrid({super.key, required this.items});
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    final columns = constraints.maxWidth < 700 ? 1 : items.length.clamp(1, 4).toInt();
    return GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: columns, crossAxisSpacing: _small, mainAxisSpacing: _small, childAspectRatio: 2.6),
      itemBuilder: (_, index) { final item = items[index]; return Container(padding: const EdgeInsets.all(_small), decoration: BoxDecoration(color: EducanoColors.background, borderRadius: BorderRadius.circular(_radius), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))]), child: Row(children: [CircleAvatar(backgroundColor: item.color.withValues(alpha: .15), child: Icon(item.icon, color: item.color)), const SizedBox(width: _small), Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.label, style: const TextStyle(color: EducanoColors.textSecondary, fontSize: 12), overflow: TextOverflow.ellipsis), Text(item.value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: EducanoColors.textPrimary))]))])); });
  });
}

class DashboardListCard extends StatelessWidget {
  final String title;
  final int? count;
  final List<Widget> children;
  const DashboardListCard({super.key, required this.title, this.count, required this.children});
  @override Widget build(BuildContext context) => Container(decoration: BoxDecoration(color: EducanoColors.background, borderRadius: BorderRadius.circular(_radius), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Padding(padding: const EdgeInsets.all(24), child: Text(count == null ? title : '$title ($count)', style: Theme.of(context).textTheme.titleLarge)), const Divider(height: 1), ...children]));
}

class DashboardListRow extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  const DashboardListRow({super.key, this.leading, required this.title, this.subtitle, this.trailing, this.onTap});
  @override Widget build(BuildContext context) => InkWell(onTap: onTap, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: _small), child: Row(children: [if (leading != null) ...[leading!, const SizedBox(width: _small)], Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: EducanoColors.textPrimary), overflow: TextOverflow.ellipsis), if (subtitle != null) Text(subtitle!, style: const TextStyle(color: EducanoColors.textSecondary, fontSize: 12), overflow: TextOverflow.ellipsis)])), if (trailing != null) trailing!])));
}
