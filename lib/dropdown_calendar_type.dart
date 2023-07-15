import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class MyDropDownCalendarButton extends StatefulWidget {
  final List<String> items;
  final String selectedValue;
  final ValueChanged<String?>?
      onSelectedValueChanged; // Add the callback function

  const MyDropDownCalendarButton({
    Key? key,
    required this.items,
    required this.selectedValue,
    this.onSelectedValueChanged,
  }) : super(key: key);

  @override
  State<MyDropDownCalendarButton> createState() =>
      _MyDropDownCalendarButtonState();
}

class _MyDropDownCalendarButtonState extends State<MyDropDownCalendarButton> {
  late String? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.selectedValue;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton2<String>(
      isExpanded: true,
      hint: const Row(
        children: [
          Icon(
            Icons.list,
            size: 16,
            color: Colors.yellow,
          ),
          SizedBox(
            width: 4,
          ),
          Expanded(
            child: Text(
              'Select Calendar Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.yellow,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      items: widget.items
          .map((String item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ))
          .toList(),
      value: widget.selectedValue,
      onChanged: (value) {
        setState(() {
          selectedValue = value;
        });

        // Notify the parent or other interested classes about the change
        if (widget.onSelectedValueChanged != null) {
          widget.onSelectedValueChanged!(value);
        }
      },
      buttonStyleData: ButtonStyleData(
        height: 50,
        width: 160,
        padding: const EdgeInsets.only(left: 14, right: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.black26,
          ),
          color: Colors.white,
        ),
        elevation: 2,
      ),
      iconStyleData: const IconStyleData(
        icon: Icon(
          Icons.arrow_forward_ios_outlined,
        ),
        iconSize: 14,
        iconEnabledColor: Colors.redAccent,
        iconDisabledColor: Colors.grey,
      ),
      dropdownStyleData: DropdownStyleData(
        maxHeight: 200,
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
        ),
        offset: const Offset(-20, 0),
        scrollbarTheme: ScrollbarThemeData(
          radius: const Radius.circular(40),
          thickness: MaterialStateProperty.all(6),
          thumbVisibility: MaterialStateProperty.all(true),
        ),
      ),
      menuItemStyleData: const MenuItemStyleData(
        height: 40,
        padding: EdgeInsets.only(left: 14, right: 14),
      ),
    );
  }
}
