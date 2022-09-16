import 'package:auto_size_text/auto_size_text.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:flutter/material.dart';

class BigButton extends StatelessWidget {
  final IconData iconData;
  final String label;
  final VoidCallback onPressed;
  const BigButton({
    Key? key,
    required this.iconData,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.15,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(primaryColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18.0),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData, size: 50, color: textColor),
            SizedBox(width: 10),
            Container(
              width: MediaQuery.of(context).size.width * 0.6,
              child: AutoSizeText(
                label,
                maxLines: 3,
                style: Theme.of(context).textTheme.headline2,
              ),
            )
          ],
        ),
        onPressed: onPressed,
      ),
    );
  }
}
