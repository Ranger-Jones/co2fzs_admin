import 'package:co2fzs_admin/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();

  XFile? _file = await _imagePicker.pickImage(source: source);
  if (_file != null) {
    return await _file.readAsBytes();
  }

  print("No image selected");
}

showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

areYouSafeAlert(
    {required BuildContext context,
    required Function onTap,
    required String text}) {
  return showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            title: const Text('Sind Sie sich sicher?'),
            content: Text(text),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(
                  context,
                  'Abbrechen',
                ),
                child: Text(
                  'Abbrechen',
                  style: Theme.of(context).textTheme.bodyText2!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                ),
              ),
              TextButton(
                onPressed: () => onTap(),
                child: Text(
                  'Ich bin mir sicher!',
                  style: Theme.of(context).textTheme.bodyText2!.copyWith(
                        fontWeight: FontWeight.bold,
                        color: lightRed,
                      ),
                ),
              ),
            ],
          ));
}
