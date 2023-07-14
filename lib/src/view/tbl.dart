import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../common_data_table.dart';
import '../export.dart';

class Tbl extends StatefulWidget {
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
  final List<int> disabledDeleteButtons, disabledEditButtons, sortColumn;

  final double margin;
  const Tbl(
      {super.key,
      this.title,
      this.titleBgColor,
      this.titleStyle,
      required this.heading,
      required this.data,
      this.onEdit,
      this.onDelete,
      this.rowBGColor,
      this.onExportExcel,
      this.onExportPDF,
      required this.rowActionButtons,
      required this.tableActionButtons,
      required this.dataAlign,
      required this.headingAlign,
      this.dataTextStyle,
      required this.headingTextStyle,
      required this.isSearchAble,
      required this.disabledDeleteButtons,
      required this.disabledEditButtons,
      required this.sortColumn,
      required this.margin});

  @override
  State<Tbl> createState() => _TblState();
}

class _TblState extends State<Tbl> {
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

  int _limit = 10, _from = 0, _page = 1, _sorting = -1;
  bool _isSortAsc = false;
  final List<int> _limitList = [10, 50, 100, 200];

  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  List<int> max = [2, 3, 4, 5];

  List<ListTile> _shortcutKeys() {
    return [
      ListTile(
        leading: Icon(
          FontAwesomeIcons.magnifyingGlass,
        ),
        title: Text("Search in Table"),
        subtitle: Text("Ctrl + F"),
      ),
      ListTile(
        leading: Icon(
          FontAwesomeIcons.forwardStep,
        ),
        title: Text("Go to Next Page of Table"),
        subtitle: Text("Ctrl + →"),
      ),
      ListTile(
        leading: Icon(
          FontAwesomeIcons.backwardStep,
        ),
        title: Text("Go to Previous Page of Table"),
        subtitle: Text("Ctrl + ←"),
      ),
      ListTile(
        leading: Icon(
          FontAwesomeIcons.arrowTurnDown,
        ),
        title: Text("Scroll Down Table"),
        subtitle: Text("↓"),
      ),
      ListTile(
        leading: Icon(
          FontAwesomeIcons.arrowTurnUp,
        ),
        title: Text("Scroll Up Table"),
        subtitle: Text("↑"),
      ),
      ListTile(
        leading: Icon(
          FontAwesomeIcons.circleQuestion,
        ),
        title: Text("Show Table Shortcut Keys"),
        subtitle: Text("Ctrl + H"),
      ),
      ListTile(
        leading: Icon(
          FontAwesomeIcons.rotate,
        ),
        title: Text("Reset"),
        subtitle: Text("Ctrl + R"),
      ),
      if (widget.onExportExcel != null)
        ListTile(
          leading: Icon(
            FontAwesomeIcons.fileExcel,
          ),
          title: Text("Export to Excel"),
          subtitle: Text("Ctrl + E"),
        ),
      if (widget.onExportPDF != null)
        ListTile(
          leading: Icon(
            FontAwesomeIcons.filePdf,
          ),
          title: Text("Export to PDF"),
          subtitle: Text("Ctrl + P"),
        ),
      for (TableActionButton button in widget.tableActionButtons) ...[
        if (button.shortcuts != null) ...[
          ListTile(
            leading: button.icon,
            title: button.child,
            subtitle: Text(
                "${button.shortcuts!.control ? "Ctrl + " : button.shortcuts!.alt ? "Alt + " : button.shortcuts!.shift ? "Shift + " : ""}${button.shortcuts!.trigger.keyLabel}"),
          ),
        ]
      ]
    ];
  }

  @override
  void initState() {
    super.initState();
    _data = widget.data;
    setState(() {});
  }

  _setLimit() {
    int limit = (_data.length / _limit).ceil();

    int currLast = max.last, currFirst = max.first;
    if (_page >= limit - 3) {
      max = [
        limit - 4,
        limit - 3,
        limit - 2,
        limit - 1,
      ];
    }
    if (_page < 5) {
      max = [
        2,
        3,
        4,
        5,
      ];
    }
    if (_page == currLast && currLast < limit - 3) {
      max = [
        currLast - 1,
        currLast,
        currLast + 1,
      ];
    }
    if (_page == currFirst && _page >= 5) {
      max = [
        currFirst - 1,
        currFirst,
        currFirst + 1,
      ];
    }
  }

  List<Widget> _segments() {
    bool isAfterEmpty = false, isBeforeEmpty = false;

    List<Widget> segment = [];

    int limit = (_data.length / _limit).ceil();
    for (int i = 1; i <= limit; i++) {
      if (i == 1 || max.contains(i) || i == (_data.length / _limit).ceil()) {
        segment.add(
          InkWell(
            onTap: () {
              _page = i;
              _from = (_limit * _page) - _limit;
              _setLimit();
              setState(() {});
            },
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(),
                  bottom: BorderSide(),
                  right: i < (_data.length / _limit).ceil()
                      ? BorderSide()
                      : BorderSide.none,
                ),
                color: _page == i ? Colors.blue : Colors.transparent,
              ),
              child: Text(
                "$i",
                style: TextStyle(
                  color: _page == i ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
        );
      } else {
        if (!isAfterEmpty && i > max.last) {
          segment.add(
            InkWell(
              onTap: null,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(),
                    bottom: BorderSide(),
                    right: i < (_data.length / _limit).ceil()
                        ? BorderSide()
                        : BorderSide.none,
                  ),
                  color: Colors.black54,
                ),
                child: Text(
                  "...",
                ),
              ),
            ),
          );
          isAfterEmpty = true;
        }
        if (!isBeforeEmpty && i < max.first) {
          segment.add(
            InkWell(
              onTap: null,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(),
                    bottom: BorderSide(),
                    right: i < (_data.length / _limit).ceil()
                        ? BorderSide()
                        : BorderSide.none,
                  ),
                  color: Colors.black54,
                ),
                child: Text(
                  "...",
                ),
              ),
            ),
          );
          isBeforeEmpty = true;
        }
      }
    }

    return segment;
  }

  _openHelp() {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        elevation: 5,
        shadowColor: Colors.white,
        title: Text(
          "Table Shortcut Key",
          textAlign: TextAlign.center,
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * .4,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = 0;
                        i < (_shortcutKeys().length / 2).ceil();
                        i++) ...[
                      _shortcutKeys()[i],
                    ],
                  ],
                ),
              ),
              Container(
                width: 2,
                height: 60 * (_shortcutKeys().length / 2).ceil().toDouble(),
                color: Colors.black54,
              ),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (int i = (_shortcutKeys().length / 2).ceil();
                        i < _shortcutKeys().length;
                        i++) ...[
                      _shortcutKeys()[i],
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns the integer prefix from a string.
  ///
  /// Returns null if no integer prefix is found.
  int? parseIntPrefix(String s) {
    var re = RegExp(r'(-?[0-9]+).*');
    var match = re.firstMatch(s);
    if (match == null) {
      return null;
    } else {
      return int.tryParse(match.group(1) ?? "");
    }
  }

  int compareIntPrefixes(String a, String b) {
    var aValue = parseIntPrefix(a.toLowerCase());
    var bValue = parseIntPrefix(b.toLowerCase());
    if (aValue != null && bValue != null) {
      return aValue - bValue;
    }

    if (aValue == null && bValue == null) {
      // If neither string has an integer prefix, sort the strings lexically.
      return a.compareTo(b);
    }

    // Sort strings with integer prefixes before strings without.
    if (aValue == null) {
      return 1;
    } else {
      return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        SingleActivator(
          LogicalKeyboardKey.keyF,
          control: true,
        ): () {
          _focusNode.requestFocus();
        },
        SingleActivator(
          LogicalKeyboardKey.keyR,
          control: true,
        ): () {
          max = [2, 3, 4, 5];
          _data = widget.data;
          _limit = 10;
          _from = 0;
          _page = 1;
          _sorting = -1;
          _isSortAsc = false;
          _scrollController.jumpTo(0);
          setState(() {});
        },
        SingleActivator(
          LogicalKeyboardKey.arrowLeft,
          control: true,
        ): () {
          if (_page > 1) {
            _page -= 1;
            _from = (_limit * _page) - _limit;
            _setLimit();
            setState(() {});
          }
        },
        SingleActivator(
          LogicalKeyboardKey.arrowRight,
          control: true,
        ): () {
          if (_page < (_data.length / _limit).ceil()) {
            _page += 1;
            _from = (_limit * _page) - _limit;
            _setLimit();
            setState(() {});
          }
        },
        SingleActivator(
          LogicalKeyboardKey.arrowDown,
        ): () {
          if (_scrollController.position.pixels <=
              _scrollController.position.maxScrollExtent) {
            double value = _scrollController.position.pixels + 20;
            _scrollController.jumpTo(value);
          }
        },
        SingleActivator(
          LogicalKeyboardKey.arrowUp,
        ): () {
          if (_scrollController.position.pixels >
              _scrollController.position.minScrollExtent) {
            double value = _scrollController.position.pixels - 20;
            _scrollController.jumpTo(value);
          }
        },
        SingleActivator(
          LogicalKeyboardKey.keyE,
          control: true,
        ): () async {
          if (widget.onExportExcel != null) {
            File excel = await exportToExcel(
              data: _data,
              heading: widget.heading,
            );
            widget.onExportExcel!(excel);
          }
        },
        SingleActivator(
          LogicalKeyboardKey.keyP,
          control: true,
        ): () async {
          if (widget.onExportPDF != null) {
            File pdf = await exportToPdf(
              data: _data,
              heading: widget.heading,
            );
            widget.onExportPDF!(pdf);
          }
        },
        for (TableActionButton button in widget.tableActionButtons)
          if (button.shortcuts != null) button.shortcuts!: button.onTap,
        SingleActivator(
          LogicalKeyboardKey.keyH,
          control: true,
        ): _openHelp,
      },
      child: Focus(
        autofocus: true,
        child: Column(
          children: [
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
              child: Row(
                children: [
                  Text(
                    widget.title ?? "",
                    style: widget.titleStyle ??
                        TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
                        backgroundColor: MaterialStatePropertyAll(Colors.green),
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
                  if (widget.onExportPDF != null) ...[
                    SizedBox(
                      width: 10,
                    ),
                    FilledButton.icon(
                      onPressed: () async {
                        File pdf = await exportToPdf(
                          data: _data,
                          heading: widget.heading,
                        );
                        widget.onExportPDF!(pdf);
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
                  ],
                  IconButton(
                    onPressed: _openHelp,
                    color: Colors.blue,
                    iconSize: 25,
                    tooltip: "Table Shortcut Key",
                    icon: Icon(
                      FontAwesomeIcons.solidCircleQuestion,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(
                  left: widget.margin,
                  right: widget.margin,
                  bottom: widget.margin,
                ),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Row(
                          children: [
                            Text(
                              "Show  ",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(
                              width: 100,
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
                                  _setLimit();
                                  FocusScope.of(context).unfocus();
                                  setState(() {});
                                },
                                value: _limit,
                                alignment: Alignment.center,
                                items: [
                                  for (int limit in _limitList) ...[
                                    DropdownMenuItem(
                                      value: limit,
                                      child: Text("$limit"),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Text(
                              "  entries",
                              style: TextStyle(
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        if (widget.isSearchAble) ...[
                          Text(
                            "Search: ",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(
                            width: 200,
                            height: 40,
                            child: TextFormField(
                              focusNode: _focusNode,
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
                                _from = 0;
                                _data = [];
                                if (value.isEmpty) {
                                  _data = widget.data;
                                } else {
                                  for (List<String> row in widget.data) {
                                    for (String data in row) {
                                      if (data
                                          .toLowerCase()
                                          .contains(value.toLowerCase())) {
                                        if (!_data.contains(row)) {
                                          _data.add(row);
                                        }
                                      }
                                    }
                                  }
                                }
                                _page = 1;
                                _setLimit();
                                setState(() {});
                              },
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                        ],
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
                        controller: _scrollController,
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
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      hoverColor: Colors.transparent,
                                      focusColor: Colors.transparent,
                                      onTap: widget.sortColumn.contains(
                                              widget.heading.indexOf(head))
                                          ? () {
                                              if (_sorting !=
                                                  widget.heading
                                                      .indexOf(head)) {
                                                _sorting = widget.heading
                                                    .indexOf(head);
                                              }
                                              _isSortAsc = !_isSortAsc;
                                              if (_isSortAsc) {
                                                _data.sort(
                                                  (a, b) => compareIntPrefixes(
                                                    a[_sorting],
                                                    b[_sorting],
                                                  ),
                                                );
                                              } else {
                                                _data.sort(
                                                  (a, b) => compareIntPrefixes(
                                                    b[_sorting],
                                                    a[_sorting],
                                                  ),
                                                );
                                              }
                                              setState(() {});
                                            }
                                          : null,
                                      child: Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(10),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                head,
                                                textAlign: _tblAlignToTextAlign(
                                                    widget.headingAlign[widget
                                                        .heading
                                                        .indexOf(head)]),
                                                style: widget.headingTextStyle[
                                                        widget.heading
                                                            .indexOf(head)] ??
                                                    TextStyle(
                                                      fontSize: 20.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                            ),
                                            if (_sorting ==
                                                widget.heading
                                                    .indexOf(head)) ...[
                                              Icon(_isSortAsc
                                                  ? FontAwesomeIcons.arrowDown
                                                  : FontAwesomeIcons.arrowUp)
                                            ],
                                          ],
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
                                        ((_limit + _from) <= (_data.length - 1)
                                            ? (_limit + _from)
                                            : _data.length);
                                    j++) ...[
                                  TableRow(
                                    decoration: BoxDecoration(
                                      color: widget.rowBGColor != null
                                          ? widget.rowBGColor!(j)
                                          : null,
                                    ),
                                    children: [
                                      for (int i = 0;
                                          i < _data[j].length;
                                          i++) ...[
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
                                                    return widget
                                                            .dataTextStyle!(
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
                                                    (act.isDisabled!(
                                                            _data.indexOf(
                                                                _data[j])) ??
                                                        false)
                                                ? null
                                                : () {
                                                    act.onTap(_data
                                                        .indexOf(_data[j]));
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
                                            onPressed: widget
                                                    .disabledEditButtons
                                                    .contains(
                                                        _data.indexOf(_data[j]))
                                                ? null
                                                : () {
                                                    widget.onEdit!(_data
                                                        .indexOf(_data[j]));
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
                                            onPressed: widget
                                                    .disabledDeleteButtons
                                                    .contains(
                                                        _data.indexOf(_data[j]))
                                                ? null
                                                : () {
                                                    widget.onDelete!(_data
                                                        .indexOf(_data[j]));
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
                        children: [
                          Text(
                            "Showing ${_from + 1} to ${(_from + _limit) <= _data.length ? (_from + _limit) : _data.length} of ${_data.length} entries",
                          ),
                          if (_sorting >= 0)
                            Text(
                              "  (Sorting ${widget.heading[_sorting]} ${_isSortAsc ? "Ascending" : "Descending"})",
                            ),
                          Spacer(),
                          Material(
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: _page <= 1
                                      ? null
                                      : () {
                                          _page -= 1;
                                          _from = (_limit * _page) - _limit;
                                          _setLimit();
                                          setState(() {});
                                        },
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      border: Border.all(),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        bottomLeft: Radius.circular(10),
                                      ),
                                    ),
                                    child: Text("Previous"),
                                  ),
                                ),
                                for (Widget segment in _segments()) ...[
                                  segment
                                ],
                                InkWell(
                                  onTap: _page >= (_data.length / _limit).ceil()
                                      ? null
                                      : () {
                                          _page += 1;
                                          _from = (_limit * _page) - _limit;
                                          _setLimit();
                                          setState(() {});
                                        },
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      border: Border.all(),
                                      borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(10),
                                        bottomRight: Radius.circular(10),
                                      ),
                                    ),
                                    child: Text("Next"),
                                  ),
                                ),
                              ],
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
        ),
      ),
    );
  }
}
