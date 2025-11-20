import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RowDefault extends StatelessWidget {
  const RowDefault({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        debugPrint("Скопировано в буфер обмена");
        Clipboard.setData(ClipboardData(text: title));
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 18,
              color: Colors.blueGrey,
            ),
            SizedBox(
              width: 12,
            ),
            SizedBox(
              width: 100,
              child: Text(
                title,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            Expanded(
                child: Text(
              value,
              style: TextStyle(color: Colors.black54),
              softWrap: true,
            ))
          ],
        ),
      ),
    );
  }
}
