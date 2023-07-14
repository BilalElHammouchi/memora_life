import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class MyDropDownConnectionsButton extends StatefulWidget {
  final List<String> items;
  final List<String> selectedItems;
  final ValueChanged<List<String>>?
      onSelectedItemsChanged; // Add the callback function

  const MyDropDownConnectionsButton({
    Key? key,
    required this.items,
    required this.selectedItems,
    this.onSelectedItemsChanged,
  }) : super(key: key);

  @override
  State<MyDropDownConnectionsButton> createState() =>
      _MyDropDownConnectionsButtonState();
}

class _MyDropDownConnectionsButtonState
    extends State<MyDropDownConnectionsButton> {
  List<String> selectedItems = [];

  @override
  void initState() {
    super.initState();
    selectedItems = widget.selectedItems;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        hint: const Text(
          'Select Items',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
        items: widget.items.map((item) {
          return DropdownMenuItem(
            value: item,
            //disable default onTap to avoid closing menu when selecting an item
            enabled: false,
            child: StatefulBuilder(
              builder: (context, menuSetState) {
                final isSelected = selectedItems.contains(item);
                return InkWell(
                  onTap: () {
                    isSelected
                        ? selectedItems.remove(item)
                        : selectedItems.add(item);
                    //This rebuilds the StatefulWidget to update the button's text
                    if (widget.onSelectedItemsChanged != null) {
                      widget.onSelectedItemsChanged!(selectedItems);
                    }
                    setState(() {});
                    //This rebuilds the dropdownMenu Widget to update the check mark
                    menuSetState(() {});
                  },
                  child: Container(
                    height: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        if (isSelected)
                          const Icon(Icons.check_box_outlined)
                        else
                          const Icon(Icons.check_box_outline_blank),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(
                                fontSize: 14, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),
        //Use last selected item as the current value so if we've limited menu height, it scroll to last item.
        value: selectedItems.isEmpty ? null : selectedItems.last,
        onChanged: (value) {},
        selectedItemBuilder: (context) {
          return widget.items.map(
            (item) {
              return Container(
                alignment: AlignmentDirectional.center,
                child: Text(
                  selectedItems.join(', '),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    overflow: TextOverflow.ellipsis,
                  ),
                  maxLines: 1,
                ),
              );
            },
          ).toList();
        },
        buttonStyleData: const ButtonStyleData(
          padding: EdgeInsets.only(left: 16, right: 8),
          height: 40,
          width: 140,
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40,
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
