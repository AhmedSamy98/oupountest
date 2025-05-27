import 'package:flutter/material.dart';
import '../../data/branch_model.dart';

class BranchToggleTile extends StatelessWidget {
  const BranchToggleTile({
    super.key,
    required this.branch,
    required this.checked,
    required this.onChanged,
  });

  final BranchModel branch;
  final bool checked;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: checked,
      onChanged: onChanged,
      title: Text('${branch.nameAr} / ${branch.nameEn}'),
      dense: true,
    );
  }
}
