import 'package:co2fzs_admin/providers/school_provider.dart';
import 'package:co2fzs_admin/providers/user_provider.dart';
import 'package:co2fzs_admin/resources/firestore_methods.dart';
import 'package:co2fzs_admin/utils/colors.dart';
import 'package:co2fzs_admin/utils/utils.dart';
import 'package:co2fzs_admin/widgets/text_field_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

class AddContestScreen extends StatefulWidget {
  final VoidCallback refreshContest;
  const AddContestScreen({Key? key, required this.refreshContest})
      : super(key: key);

  @override
  State<AddContestScreen> createState() => _AddContestScreenState();
}

class _AddContestScreenState extends State<AddContestScreen> {
  var endDate;
  var startDate;
  final TextEditingController _titleController = TextEditingController();
  bool _isLoading = false;
  void uploadContest() async {
    setState(() {
      _isLoading = true;
    });

    String res = await FirestoreMethods().uploadContest(
      _titleController.text,
      startDate,
      endDate,
    );

    setState(() {
      _isLoading = false;
    });

    if (res != "success") {
      showSnackBar(context, res);
    } else {
      UserProvider _userProvider = Provider.of(context, listen: false);
      await _userProvider.refreshUser();

      widget.refreshContest();
      Navigator.of(context).pop();
    }
  }

  void safeDate(DateTime date, DateTime saveTo) {
    setState(() {
      saveTo = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting();
    Intl.defaultLocale = 'de_DE';
    return Scaffold(
      appBar: AppBar(
        title: Text("Wettbewerb erstellen"),
      
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          width: double.infinity,
          child: Column(
            children: [
              const SizedBox(height: 64),
              TextFieldInput(
                hintText: "Titel des Wettbewerbs",
                textInputType: TextInputType.text,
                textEditingController: _titleController,
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  DatePicker.showDatePicker(
                    context,
                    showTitleActions: true,
                    minTime: DateTime.now(),
                    maxTime: DateTime(2024, 6, 6),
                    onChanged: (date) {
                      setState(() {
                        startDate = date;
                      });
                    },
                    onConfirm: (date) {
                      setState(() {
                        startDate = date;
                      });
                    },
                    currentTime: DateTime.now(),
                    locale: LocaleType.de,
                  );
                },
                child: Text(
                  startDate != null
                      ? DateFormat.yMMMMd("de").format(
                          startDate,
                        )
                      : "Start Datum festlegen",
                  style: TextStyle(
                    color: Colors.blue,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  DatePicker.showDatePicker(
                    context,
                    showTitleActions: true,
                    minTime: DateTime.now(),
                    maxTime: DateTime(2024, 6, 6),
                    onChanged: (date) {
                      setState(() {
                        endDate = date;
                      });
                    },
                    onConfirm: (date) {
                      setState(() {
                        endDate = date;
                      });
                    },
                    currentTime: DateTime.now(),
                    locale: LocaleType.de,
                  );
                },
                child: Text(
                  endDate != null
                      ? DateFormat.yMMMMd("de").format(endDate)
                      : "End Datum festlegen",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              InkWell(
                onTap: uploadContest,
                child: Container(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: primaryColor,
                          ),
                        )
                      : const Text("Wettbewerb hinzufügen"),
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: const ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(6),
                      ),
                    ),
                    color: blueColor,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
