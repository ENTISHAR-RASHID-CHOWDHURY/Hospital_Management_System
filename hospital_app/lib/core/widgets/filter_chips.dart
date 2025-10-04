import 'package:flutter/material.dart';

class FilterChips extends StatelessWidget {
  final String label;
  final List<String> options;
  final String selectedOption;
  final Function(String) onSelected;
  final Color? selectedColor;
  final Color? unselectedColor;

  const FilterChips({
    super.key,
    required this.label,
    required this.options,
    required this.selectedOption,
    required this.onSelected,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: options.map((option) {
            final isSelected = option == selectedOption;
            return FilterChip(
              label: Text(
                option,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => onSelected(option),
              selectedColor: selectedColor ?? Colors.blue.shade600,
              backgroundColor: unselectedColor ?? Colors.grey.shade100,
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isSelected
                    ? selectedColor ?? Colors.blue.shade600
                    : Colors.grey.shade300,
                width: 1,
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        ),
      ],
    );
  }
}

class FilterChipGroup extends StatelessWidget {
  final List<FilterChips> filterChips;
  final Axis direction;
  final double spacing;

  const FilterChipGroup({
    super.key,
    required this.filterChips,
    this.direction = Axis.horizontal,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    if (direction == Axis.horizontal) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filterChips.map((chip) {
            final index = filterChips.indexOf(chip);
            return Padding(
              padding: EdgeInsets.only(
                right: index < filterChips.length - 1 ? spacing : 0,
              ),
              child: chip,
            );
          }).toList(),
        ),
      );
    } else {
      return Column(
        children: filterChips.map((chip) {
          final index = filterChips.indexOf(chip);
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < filterChips.length - 1 ? spacing : 0,
            ),
            child: chip,
          );
        }).toList(),
      );
    }
  }
}
