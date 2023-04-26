import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../common_data_table.dart';
import 'export.dart';

class CommonDataTable extends StatefulWidget {
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

  /// [onExportExcel] and [onExportPDF] are show in top right corner.
  /// when you click on [onExportExcel] and [onExportPDF] it will return you
  /// Excel or Pdf [File] then developer can be save or share as requirement.
  /// if this will null then that [Button] will not show.
  final Function(File file)? onExportExcel, onExportPDF;

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
  final Map<int, TblAlign> dataAlign, headingAlign;
  final Map<int, TextStyle>? Function(List<String> row)? dataTextStyle;
  final Map<int, TextStyle> headingTextStyle;
  final bool isSearchAble;
  final List<int> disabledDeleteButtons, disabledEditButtons;

  final double margin;

  const CommonDataTable({
    Key? key,
    this.heading = const [],
    this.rowActionButtons = const [],
    this.tableActionButtons = const [],
    this.data = const [],
    this.disabledDeleteButtons = const [],
    this.disabledEditButtons = const [],
    this.dataAlign = const {},
    this.headingAlign = const {},
    this.dataTextStyle,
    this.headingTextStyle = const {},
    this.onEdit,
    this.isSearchAble = false,
    this.onDelete,
    this.onExportExcel,
    this.onExportPDF,
    this.title,
    this.titleBgColor,
    this.titleStyle,
    this.margin = 20,
  }) : super(key: key);

  @override
  _CommonDataTableState createState() => _CommonDataTableState();
}

class _CommonDataTableState extends State<CommonDataTable> {
  TextAlign _tblAlignToTextAlign(TblAlign? align) {
    switch (align) {
      case TblAlign.center:
        return TextAlign.center;
      case TblAlign.left:
        return TextAlign.left;
      case TblAlign.right:
        return TextAlign.right;
      default:
        return TextAlign.left;
    }
  }

  List<List<String>> _data = [];

  int _limit = 5, _from = 0, _page = 1;
  final List<int> _limitList = [5, 10, 50, 100];

  @override
  void initState() {
    super.initState();
    _data = widget.data;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.title != null) ...[
          Container(
            margin: EdgeInsets.only(
              left: widget.margin,
              right: widget.margin,
              top: widget.margin,
            ),
            decoration: BoxDecoration(
              color: widget.titleBgColor,
              border: Border.all(),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            padding: EdgeInsets.all(10),
            alignment: Alignment.center,
            child: Text(
              widget.title!,
              style: widget.titleStyle ??
                  TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
            ),
          ),
        ],
        Expanded(
          child: Container(
            margin: EdgeInsets.only(
              left: widget.margin,
              right: widget.margin,
              bottom: widget.margin,
              top: widget.title != null ? 0 : widget.margin,
            ),
            decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: widget.title != null
                  ? BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    )
                  : BorderRadius.circular(10),
            ),
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  children: [
                    if (widget.isSearchAble) ...[
                      Text(
                        "Filter:  ",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(
                        width: 200,
                        height: 40,
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
                                  if (data
                                      .toLowerCase()
                                      .contains(value.toLowerCase())) {
                                    _data.add(row);
                                  }
                                }
                              }
                            }
                            setState(() {});
                          },
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                    SizedBox(
                      width: 70,
                      height: 40,
                      child: DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.all(10),
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              width: 1,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        onChanged: (value) {
                          _limit = value ?? 5;
                          _from = 0;
                          _page = 1;
                          FocusScope.of(context).unfocus();
                          setState(() {});
                        },
                        value: _limit,
                        items: [
                          for (int limit in _limitList) ...[
                            DropdownMenuItem(
                              value: limit,
                              child: Text("$limit"),
                            ),
                          ],
                          DropdownMenuItem(
                            value: _data.length,
                            child: Text("All"),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
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
                      SizedBox(
                        width: 10,
                      ),
                    ],
                    if (widget.onExportExcel != null) ...[
                      FilledButton.icon(
                        onPressed: () async {
                          File excel = await exportToExcel(
                            data: _data,
                            heading: widget.heading,
                          );
                          widget.onExportExcel!(excel);
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.green),
                        ),
                        icon: Icon(
                          FontAwesomeIcons.fileExcel,
                          size: 20,
                        ),
                        label: Text(
                          "Export to Excel",
                        ),
                      ),
                    ],
                    SizedBox(
                      width: 10,
                    ),
                    if (widget.onExportPDF != null) ...[
                      FilledButton.icon(
                        onPressed: () async {
                          File excel = await exportToPdf(
                            data: _data,
                            heading: widget.heading,
                          );
                          widget.onExportExcel!(excel);
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(Colors.red),
                        ),
                        icon: Icon(
                          FontAwesomeIcons.filePdf,
                          size: 20,
                        ),
                        label: Text(
                          "Export to PDF",
                        ),
                      ),
                    ]
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  height: 1,
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.all(5),
                    children: [
                      Table(
                        border: TableBorder.all(
                          color: Colors.grey,
                          style: BorderStyle.solid,
                          borderRadius: _data.isEmpty
                              ? BorderRadius.only(
                                  topLeft: Radius.circular(10),
                                  topRight: Radius.circular(10),
                                )
                              : BorderRadius.circular(10),
                        ),
                        columnWidths: {
                          0: FixedColumnWidth(70),
                          for (int i = 0;
                              i < widget.rowActionButtons.length;
                              i++)
                            widget.heading.length + i: FixedColumnWidth(73),
                          widget.heading.length +
                                  widget.rowActionButtons.length:
                              FixedColumnWidth(70),
                          widget.heading.length +
                              widget.rowActionButtons.length +
                              1: FixedColumnWidth(70),
                        },
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        children: [
                          TableRow(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                            children: [
                              for (String head in widget.heading) ...[
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    head,
                                    textAlign: _tblAlignToTextAlign(
                                        widget.headingAlign[
                                            widget.heading.indexOf(head)]),
                                    style: widget.headingTextStyle[
                                            widget.heading.indexOf(head)] ??
                                        TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                              ],
                              for (RowActionButton act
                                  in widget.rowActionButtons) ...[
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(10),
                                  child: Icon(
                                    act.icon,
                                    color: act.color,
                                  ),
                                ),
                              ],
                              if (widget.onEdit != null) ...[
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(10),
                                  child: Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                              if (widget.onDelete != null) ...[
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(10),
                                  child: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                ),
                              ]
                            ],
                          ),
                          if (_data.isNotEmpty) ...[
                            for (int j = _from;
                                j <
                                    ((_limit + _from) < (_data.length - 1)
                                        ? (_limit + _from)
                                        : _data.length);
                                j++) ...[
                              TableRow(
                                children: [
                                  for (int i = 0; i < _data[j].length; i++) ...[
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(10),
                                      child: Text(
                                        _data[j][i],
                                        textAlign: _tblAlignToTextAlign(
                                            widget.dataAlign[i]),
                                        style: () {
                                              if (widget.dataTextStyle !=
                                                  null) {
                                                return widget.dataTextStyle!(
                                                    _data[j])?[i];
                                              }
                                              return null;
                                            }() ??
                                            TextStyle(
                                              fontSize: 20.0,
                                            ),
                                      ),
                                    ),
                                  ],
                                  for (RowActionButton act
                                      in widget.rowActionButtons) ...[
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(10),
                                      child: IconButton(
                                        icon: Icon(act.icon),
                                        tooltip: act.tooltip,
                                        color: act.color,
                                        onPressed: act.isDisabled != null &&
                                                (act.isDisabled!(_data
                                                        .indexOf(_data[j])) ??
                                                    false)
                                            ? null
                                            : () {
                                                act.onTap(
                                                    _data.indexOf(_data[j]));
                                              },
                                      ),
                                    )
                                  ],
                                  if (widget.onEdit != null) ...[
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(10),
                                      child: IconButton(
                                        icon: Icon(Icons.edit),
                                        tooltip: "Edit",
                                        color: Colors.blue,
                                        onPressed: widget.disabledEditButtons
                                                .contains(
                                                    _data.indexOf(_data[j]))
                                            ? null
                                            : () {
                                                widget.onEdit!(
                                                    _data.indexOf(_data[j]));
                                              },
                                      ),
                                    )
                                  ],
                                  if (widget.onDelete != null) ...[
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(10),
                                      child: IconButton(
                                        icon: Icon(Icons.delete),
                                        color: Colors.red,
                                        tooltip: "Delete",
                                        onPressed: widget.disabledDeleteButtons
                                                .contains(
                                                    _data.indexOf(_data[j]))
                                            ? null
                                            : () {
                                                widget.onDelete!(
                                                    _data.indexOf(_data[j]));
                                              },
                                      ),
                                    )
                                  ]
                                ],
                              ),
                            ],
                          ],
                        ],
                      ),
                      if (_data.isEmpty) ...[
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: Text(
                            "NO Data Found",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                ),
                if (_data.isNotEmpty) ...[
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SegmentedButton<int>(
                        segments: [
                          for (int i = 1;
                              i <= (_data.length / _limit).ceil();
                              i++) ...[
                            ButtonSegment<int>(
                              value: i,
                              label: Text("$i"),
                            )
                          ]
                        ],
                        selected: {_page},
                        showSelectedIcon: false,
                        onSelectionChanged: (page) {
                          _page = page.first;
                          _from = (_limit * _page) - _limit;
                          setState(() {});
                        },
                        style: ButtonStyle(
                          shape: MaterialStatePropertyAll(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
