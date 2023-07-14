import 'dart:io';

import 'package:common_data_table/src/view/mob.dart';
import 'package:flutter/material.dart';

import '../common_data_table.dart';
import 'view/tbl.dart';

class CommonDataTable extends StatelessWidget {
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

  const CommonDataTable({
    Key? key,
    this.heading = const [],
    this.rowActionButtons = const [],
    this.tableActionButtons = const [],
    this.data = const [],
    this.disabledDeleteButtons = const [],
    this.disabledEditButtons = const [],
    this.sortColumn = const [],
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
    this.rowBGColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 640) {
          return Tbl(
            title: title,
            dataTextStyle: dataTextStyle,
            rowBGColor: rowBGColor,
            key: key,
            onExportExcel: onExportExcel,
            onExportPDF: onExportPDF,
            onEdit: onEdit,
            onDelete: onDelete,
            titleStyle: titleStyle,
            titleBgColor: titleBgColor,
            heading: heading,
            data: data,
            rowActionButtons: rowActionButtons,
            tableActionButtons: tableActionButtons,
            dataAlign: dataAlign,
            headingAlign: headingAlign,
            headingTextStyle: headingTextStyle,
            isSearchAble: isSearchAble,
            disabledDeleteButtons: disabledDeleteButtons,
            disabledEditButtons: disabledEditButtons,
            sortColumn: sortColumn,
            margin: margin,
          );
        } else {
          return Mob(
            title: title,
            dataTextStyle: dataTextStyle,
            rowBGColor: rowBGColor,
            key: key,
            onEdit: onEdit,
            onDelete: onDelete,
            titleStyle: titleStyle,
            titleBgColor: titleBgColor,
            heading: heading,
            data: data,
            rowActionButtons: rowActionButtons,
            tableActionButtons: tableActionButtons,
            headingTextStyle: headingTextStyle,
            isSearchAble: isSearchAble,
            disabledDeleteButtons: disabledDeleteButtons,
            disabledEditButtons: disabledEditButtons,
          );
        }
      },
    );
  }
}
