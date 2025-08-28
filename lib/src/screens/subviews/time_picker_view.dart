import 'package:flashzone_web/src/helpers/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FZTimePickerView extends StatefulWidget {
  const FZTimePickerView({super.key, required this.initialDateTime, required this.onDateTimeChanged});
  final DateTime initialDateTime;
  final Function(DateTime) onDateTimeChanged;

  @override
  State<FZTimePickerView> createState() => _FZTimePickerViewState();
}

class _FZTimePickerViewState extends State<FZTimePickerView> {

  bool isAmSelected = true;
  int hour = 12;
  int minute = 0;
  DateTime selectedTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    final initialHour = widget.initialDateTime.hour;
    hour = initialHour > 12 ? initialHour - 12 : initialHour;
    minute = widget.initialDateTime.minute;
    isAmSelected = initialHour < 12;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        hourField(),
        const SizedBox(width: 8),
        const Column(
          children: [
            SizedBox(height: 10),
            Text(':', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),),
          ],
        ),
        const SizedBox(width: 8),
        minuteField(),
        const SizedBox(width: 16),
        amPmField(),
        
      ],
    );
  }

  minuteField() {
    return Column(
      children: [
        SizedBox(
              width: 50,
              child: TextFormField(
                initialValue: minute.toString(),
                decoration: inputFieldDecoration(),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                textAlign: TextAlign.center,
                onChanged: (value) {
                  final parsedMinute = int.tryParse(value);
                  if (parsedMinute != null && parsedMinute >= 0 && parsedMinute <= 59) {
                    setState(() {
                      minute = parsedMinute;
                      selectedTime = DateTime(
                        selectedTime.year,
                        selectedTime.month,
                        selectedTime.day,
                        isAmSelected ? (hour % 12) : ((hour % 12) + 12),
                        minute,
                      );
                      widget.onDateTimeChanged(selectedTime);
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter minute';
                  }
                  final minute = int.tryParse(value);
                  if (minute == null || minute < 0 || minute > 59) {
                    return 'Invalid minute';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                maxLength: 2,
              ),
            ),
          const SizedBox(height: 4),
          const Text('Minute', style: TextStyle(fontSize: 9),),
      ],
    );
  }

  hourField() {
    return Column(
      children: [
        SizedBox(
              width: 50,
              child: TextFormField(
                initialValue: hour.toString(),
                onChanged: (value) {
                  final parsedHour = int.tryParse(value);
                  if (parsedHour != null && parsedHour >= 1 && parsedHour <= 12) {
                    setState(() {
                      hour = parsedHour;
                      selectedTime = DateTime(
                        selectedTime.year,
                        selectedTime.month,
                        selectedTime.day,
                        isAmSelected ? (hour % 12) : ((hour % 12) + 12),
                        minute,
                      );
                      widget.onDateTimeChanged(selectedTime);
                    });
                  }
                },
                decoration: inputFieldDecoration(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter hour';
                  }
                  final hour = int.tryParse(value);
                  if (hour == null || hour < 1 || hour > 12) {
                    return 'Invalid hour';
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                maxLength: 2,
              ),
            ),

          const SizedBox(height: 4),
          const Text('Hour', style: TextStyle(fontSize: 9),),
      ],
    );
  }

  amPmField() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          // AM Button Container
          GestureDetector(
            onTap: () {
              setState(() {
                isAmSelected = true;
                selectedTime = DateTime(
                  selectedTime.year,
                  selectedTime.month,
                  selectedTime.day,
                  hour ,
                  minute,
                );
                widget.onDateTimeChanged(selectedTime);
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: isAmSelected? Constants.primaryColor(): Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('AM', style: TextStyle(
                color: isAmSelected? Colors.white: Colors.black,
              ),),
            ),
          ),
          // PM Button Container
          GestureDetector(
            onTap: () {
              setState(() {
                isAmSelected = false;
                selectedTime = DateTime(
                  selectedTime.year,
                  selectedTime.month,
                  selectedTime.day,
                  hour + 12,
                  minute,
                );
                widget.onDateTimeChanged(selectedTime);
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: !isAmSelected? Constants.primaryColor(): Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('PM', style: TextStyle(
                color: !isAmSelected? Colors.white: Colors.black,
              ),),
            ),
          ),
        ],
      ),
    );
    // return DropdownButton<String>(
    //   value: 'AM',
    //   items: <String>['AM', 'PM'].map<DropdownMenuItem<String>>((String value) {
    //     return DropdownMenuItem<String>(
    //       value: value,
    //       child: Text(value),
    //     );
    //   }).toList(),
    //   onChanged: (String? newValue) {
    //     setState(() {
    //       // Handle AM/PM change
    //     });
    //   },
    // );
  }

  inputFieldDecoration() {
    return InputDecoration(
              //isCollapsed: true,
              counterText: "",
              labelText: null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            );
  }

}