import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class TableItem extends StatelessWidget {
  final String label;
  final String info;
  const TableItem({
    Key? key,
    required this.info,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                child: AutoSizeText(
                  label,
                  maxLines: 2,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyText2!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.5,
                child: AutoSizeText(
                  info,
                  maxLines: 2,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyText2,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          Divider(),
        ],
      ),
    );
  }
}
