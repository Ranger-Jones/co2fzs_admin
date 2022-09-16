import 'dart:typed_data';

import 'package:co2fzs_admin/models/user.dart';
import 'package:co2fzs_admin/providers/user_provider.dart';
import 'package:co2fzs_admin/resources/firestore_methods.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:co2fzs_admin/utils/utils.dart';
import 'package:co2fzs_admin/widgets/auth_button.dart';
import 'package:co2fzs_admin/widgets/text_field_input.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class AddArticleScreen extends StatefulWidget {
  AddArticleScreen({Key? key}) : super(key: key);

  @override
  State<AddArticleScreen> createState() => _AddArticleScreenState();
}

class _AddArticleScreenState extends State<AddArticleScreen> {
  TextEditingController _articleNameController = TextEditingController();
  TextEditingController _articleTitleController = TextEditingController();
  Uint8List? _file;

  bool _isLoading = false;

  _selectImage(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(title: const Text("Create a Post"), children: [
            SimpleDialogOption(
                padding: EdgeInsets.all(20),
                child: const Text("Take a photo"),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(
                    ImageSource.camera,
                  );
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
                padding: EdgeInsets.all(20),
                child: const Text("Choose from Gallery"),
                onPressed: () async {
                  Navigator.of(context).pop();
                  Uint8List file = await pickImage(
                    ImageSource.gallery,
                  );
                  setState(() {
                    _file = file;
                  });
                }),
            SimpleDialogOption(
                padding: EdgeInsets.all(20),
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ]);
        });
  }

  uploadArticle(String author, String authorId) async {
    setState(() {
      _isLoading = true;
    });

    if (_file == null) {
      showSnackBar(context,
          "Bitte wähle ein geeignetes Bild aus mit einem Klick auf den Baum!");
      return;
    }

    String res = await FirestoreMethods().uploadArticle(
      author: author,
      authorId: authorId,
      file: _file!,
      text: _articleNameController.text,
      title: _articleTitleController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (res != "success") {
      showSnackBar(context, res);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      appBar: AppBar(
        title: Text("Artikel hinzüfugen"),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            width: double.infinity,
            child: Column(
              children: [
                const SizedBox(height: 64),
                InkWell(
                  onTap: () => _selectImage(context),
                  child: Container(
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _file != null
                          ? Image.memory(_file!)
                          : Image.network(
                              "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a9/Birnbaum_am_Lerchenberg_retouched.jpg/1200px-Birnbaum_am_Lerchenberg_retouched.jpg"),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextFieldInput(
                  hintText: "Artikel Titel",
                  textInputType: TextInputType.text,
                  textEditingController: _articleTitleController,
                ),
                const SizedBox(height: 24),
                TextFieldInput(
                  hintText: "Artikel Text",
                  minLines: 1,
                  maxLines: 15,
                  textInputType: TextInputType.multiline,
                  textEditingController: _articleNameController,
                ),
                const SizedBox(height: 24),
                AuthButton(
                  onTap: () => uploadArticle(user.username, user.uid),
                  label: "Artikel hinzufügen",
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
