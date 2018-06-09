import 'dart:async';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class _InputDropdown extends StatelessWidget {
  const _InputDropdown({Key key, this.child, this.labelText, this.valueText, this.valueStyle, this.onPressed}) : super(key: key);

  final String labelText;
  final String valueText;
  final TextStyle valueStyle;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return new InkWell(
      onTap: onPressed,
      child: new InputDecorator(
        decoration: new InputDecoration(
          hintText: 'Input the name of the event here',
          border: const OutlineInputBorder(),
//          labelText: labelText,
        ),
        baseStyle: valueStyle,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Text(valueText, style: valueStyle),
          ],
        ),
      ),
    );
  }
}

class DateTimePicker extends StatelessWidget {
  const DateTimePicker(
      {Key key, this.labelText, this.selectedDate, this.selectedTime, this.selectDate, this.selectTime, this.lastDate, this.firstDate})
      : super(key: key);

  final String labelText;
  final DateTime lastDate;
  final DateTime firstDate;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final ValueChanged<DateTime> selectDate;
  final ValueChanged<TimeOfDay> selectTime;

  Future<Null> _selectDate(BuildContext context) async {
    DateTime start;
    DateTime end;
    if (firstDate == null) {
      start = new DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    } else {
      start = new DateTime(firstDate.year, firstDate.month, firstDate.day);
    }

    if (lastDate == null) {
      end = new DateTime(2101);
    } else {
      end = new DateTime(lastDate.year, lastDate.month, lastDate.day);
    }
    final DateTime picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: start, lastDate: end);
    if (picked != null && picked != selectedDate) selectDate(picked);
  }

  Future<Null> _selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(context: context, initialTime: selectedTime);
    if (picked != null && picked != selectedTime) selectTime(picked);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> contents = <Widget>[];
    if (firstDate != lastDate || firstDate == null) {
      contents.add(new Expanded(
        flex: 4,
        child: new _InputDropdown(
          labelText: labelText,
          valueText: new DateFormat.yMMMMd().format(selectedDate),
          onPressed: () {
            _selectDate(context);
          },
        ),
      ));
      contents.add(const SizedBox(
        width: 12.0,
      ));
    }
    contents.add(new Expanded(
      flex: 3,
      child: new _InputDropdown(
        valueText: selectedTime.format(context),
        onPressed: () {
          _selectTime(context);
        },
      ),
    ));

    return new Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: contents,
    );
  }
}
