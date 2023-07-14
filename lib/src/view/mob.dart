import 'dart:io';

import 'package:flutter/material.dart';

import '../../common_data_table.dart';

class Mob extends StatefulWidget {
  /// [title] will show in top of all table and table elements.
  /// if [title] will null than nothing will show on top.
  final String? title;

  ///  [titleBgColor] is for background color of [title] container.
  ///  if [titleBgColor] is null then default color of container.
  final Color? titleBgColor;

  ///  [titleStyle] is for [TextStyle] of [title] Text.
  ///  if [titleStyle] is null then default style is
  ///
  ///  TextStyle(
  ///     fontWeight: FontWeight.bold,
  ///     fontSize: 20,
  ///   ),
  final TextStyle? titleStyle;

  /// [heading] are table heading.
  /// [heading] are in [List] of [String].
  /// Also Same [heading] will show in excel and pdf.
  final List<String> heading;

  /// [data] are table row.
  /// [data] are in [List] of [List] of [String].
  /// each [List] of [String] will be row.
  /// where else each [List] will be column.
  /// Also Same [data] will show in excel and pdf.
  /// if data is empty then String "NO DATA FOUND" will show.
  final List<List<String>> data;

  /// [onEdit] and [onDelete] are show in the end of every row.
  /// when you click on [onEdit] and [onDelete] it will return you [index] of
  /// row then as action will you perform.
  /// if this will null then that iconButton will not show.
  final Function(int index)? onEdit, onDelete;
  final Color? Function(int index)? rowBGColor;

  /// [onExportExcel] and [onExportPDF] are show in top right corner.
  /// when you click on [onExportExcel] and [onExportPDF] it will return you
  /// Excel or Pdf [File] then developer can be save or share as requirement.
  /// if this will null then that [Button] will not show.
  // final Function(File file)? onExportExcel, onExportPDF;

  /// like [onEdit] and [onDelete] icon [rowActionButtons] are list and show in
  /// the end of every row before [onEdit].
  /// when you click on [rowActionButtons] it will return you [index] of
  /// row then as action will you perform.
  /// if this will empty then that iconButton will not show.
  final List<RowActionButton> rowActionButtons;

  /// like [onExportExcel] and [onExportPDF] button [tableActionButtons] are
  /// list and show in the top right corner before [onExportExcel].
  /// when you click on [tableActionButtons] work as action will you perform.
  /// if this will empty then that button will not show.
  final List<TableActionButton> tableActionButtons;
  final Map<int, TextStyle>? Function(List<String> row)? dataTextStyle;
  final Map<int, TextStyle> headingTextStyle;
  final bool isSearchAble;
  final List<int> disabledDeleteButtons, disabledEditButtons;

  const Mob({
    super.key,
    this.title,
    this.titleBgColor,
    this.titleStyle,
    required this.heading,
    required this.data,
    this.onEdit,
    this.onDelete,
    this.rowBGColor,
    required this.rowActionButtons,
    required this.tableActionButtons,
    this.dataTextStyle,
    required this.headingTextStyle,
    required this.isSearchAble,
    required this.disabledDeleteButtons,
    required this.disabledEditButtons,
  });

  @override
  State<Mob> createState() => _MobState();
}

class _MobState extends State<Mob> {
  List<List<String>> _data = [];

  @override
  void initState() {
    super.initState();
    _data = widget.data;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        if (widget.isSearchAble)
          Padding(
            padding: EdgeInsets.all(10),
            child: TextFormField(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
                border: OutlineInputBorder(),
                hintText: "Search",
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    width: 1,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              onChanged: (value) {
                _data = [];
                if (value.isEmpty) {
                  _data = widget.data;
                } else {
                  for (List<String> row in widget.data) {
                    for (String data in row) {
                      if (data.toLowerCase().contains(value.toLowerCase())) {
                        if (!_data.contains(row)) {
                          _data.add(row);
                        }
                      }
                    }
                  }
                }
                setState(() {});
              },
            ),
          ),
        if (widget.tableActionButtons.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.all(10),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.end,
              alignment: WrapAlignment.end,
              children: [
                for (TableActionButton tblAction
                    in widget.tableActionButtons) ...[
                  tblAction.icon == null
                      ? FilledButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(tblAction.bgColor),
                            foregroundColor:
                                MaterialStatePropertyAll(tblAction.fgColor),
                          ),
                          onPressed: tblAction.onTap,
                          child: tblAction.child,
                        )
                      : FilledButton.icon(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStatePropertyAll(tblAction.bgColor),
                            foregroundColor:
                                MaterialStatePropertyAll(tblAction.fgColor),
                          ),
                          onPressed: tblAction.onTap,
                          icon: tblAction.icon!,
                          label: tblAction.child,
                        ),
                ],
              ],
            ),
          )
        ],
        if (widget.title != null)
          ListTile(
            tileColor: widget.titleBgColor,
            title: Text(
              widget.title ?? "",
              style: widget.titleStyle ??
                  TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
            ),
          ),
        for (List<String> data in _data) ...[
          ExpansionTile(
            collapsedBackgroundColor: widget.rowBGColor == null
                ? null
                : widget.rowBGColor!(_data.indexOf(data)),
            backgroundColor: widget.rowBGColor == null
                ? null
                : widget.rowBGColor!(_data.indexOf(data)),
            leading: Text(
              data[0],
              style: () {
                    if (widget.dataTextStyle != null) {
                      return widget.dataTextStyle!(data)?[0];
                    }
                    return null;
                  }() ??
                  TextStyle(
                    fontSize: 16.0,
                  ),
            ),
            title: Text(
              data[1],
              style: () {
                    if (widget.dataTextStyle != null) {
                      return widget.dataTextStyle!(data)?[1];
                    }
                    return null;
                  }() ??
                  TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            children: [
              for (String da in data) ...[
                if (data.indexOf(da) > 0)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: Text(
                            widget.heading[data.indexOf(da)],
                            style: widget.headingTextStyle[widget.heading
                                    .indexOf(
                                        widget.heading[data.indexOf(da)])] ??
                                TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        Text(
                          "  :  ",
                          style: widget.headingTextStyle[widget.heading
                                  .indexOf(widget.heading[data.indexOf(da)])] ??
                              TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            da,
                            style: () {
                                  if (widget.dataTextStyle != null) {
                                    return widget.dataTextStyle!(
                                        data)?[data.indexOf(da)];
                                  }
                                  return null;
                                }() ??
                                TextStyle(
                                  fontSize: 16.0,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
              if (widget.rowActionButtons.isNotEmpty ||
                  widget.onEdit != null ||
                  widget.onDelete != null) ...[
                Divider(),
                Wrap(
                  runSpacing: 10,
                  spacing: 10,
                  children: [
                    for (RowActionButton act in widget.rowActionButtons) ...[
                      Container(
                        // width: double.infinity,
                        padding: EdgeInsets.all(10),
                        child: IconButton(
                          icon: Icon(act.icon),
                          tooltip: act.tooltip,
                          color: act.color,
                          onPressed: act.isDisabled != null &&
                                  (act.isDisabled!(_data.indexOf(data)) ??
                                      false)
                              ? null
                              : () {
                                  act.onTap(_data.indexOf(data));
                                },
                        ),
                      )
                    ],
                    if (widget.onEdit != null) ...[
                      Container(
                        // width: double.infinity,
                        padding: EdgeInsets.all(10),
                        child: IconButton(
                          icon: Icon(Icons.edit),
                          tooltip: "Edit",
                          color: Colors.blue,
                          onPressed: widget.disabledEditButtons
                                  .contains(_data.indexOf(data))
                              ? null
                              : () {
                                  widget.onEdit!(_data.indexOf(data));
                                },
                        ),
                      )
                    ],
                    if (widget.onDelete != null) ...[
                      Container(
                        // width: double.infinity,
                        padding: EdgeInsets.all(10),
                        child: IconButton(
                          icon: Icon(Icons.delete),
                          color: Colors.red,
                          tooltip: "Delete",
                          onPressed: widget.disabledDeleteButtons
                                  .contains(_data.indexOf(data))
                              ? null
                              : () {
                                  widget.onDelete!(_data.indexOf(data));
                                },
                        ),
                      )
                    ]
                  ],
                )
              ]
            ],
          )
        ]
      ],
    );
  }
}
