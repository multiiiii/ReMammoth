import 'package:flutter/material.dart';

import '../models/sort_order.dart';

class SortMenu extends StatelessWidget {
  const SortMenu({
    super.key,
    required this.currentSort,
    required this.onSortChanged,
    this.showLastEdited = true,
  });

  final SortOrder currentSort;
  final ValueChanged<SortOrder> onSortChanged;
  final bool showLastEdited;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SortOrder>(
      icon: const Icon(Icons.sort),
      tooltip: 'Sort',
      onSelected: onSortChanged,
      itemBuilder: (_) => [
        _item(SortOrder.newest, 'Newest first', Icons.arrow_downward),
        _item(SortOrder.oldest, 'Oldest first', Icons.arrow_upward),
        _item(SortOrder.alphabetical, 'A \u2192 Z', Icons.sort_by_alpha),
        if (showLastEdited)
          _item(SortOrder.lastEdited, 'Last edited', Icons.edit_outlined),
      ],
    );
  }

  PopupMenuItem<SortOrder> _item(SortOrder value, String label, IconData icon) {
    return PopupMenuItem<SortOrder>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label),
          if (currentSort == value) ...[
            const Spacer(),
            const Icon(Icons.check, size: 16),
          ],
        ],
      ),
    );
  }
}
