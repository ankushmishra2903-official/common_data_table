import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

Map<int, String> _numAlphaMap = {
  0: 'A',
  1: 'B',
  2: 'C',
  3: 'D',
  4: 'E',
  5: 'F',
  6: 'G',
  7: 'H',
  8: 'I',
  9: 'J',
  10: 'K',
  11: 'L',
  12: 'M',
  13: 'N',
  14: 'O',
  15: 'P',
  16: 'Q',
  17: 'R',
  18: 'S',
  19: 'T',
  20: 'U',
  21: 'V',
  22: 'W',
  23: 'X',
  24: 'Y',
  25: 'Z',
};
String _title = "MedXP Excel Report";

Future<File> exportToExcel({
  required List<String> heading,
  required List<List<String>> data,
}) async {
  final Workbook workbook = Workbook();
  final Worksheet sheet = workbook.worksheets[0];

  final Range titleRange = sheet.getRangeByName(
    "A1:${_numAlphaMap[heading.length - 1]}1",
  );
  final Range allRange = sheet.getRangeByName(
    "A1:${_numAlphaMap[heading.length - 1]}${data.length + 1}",
  );

  for (int i = 0; i < heading.length; i++) {
    final Range range = sheet.getRangeByName('${_numAlphaMap[i]}1');
    range.setText(heading[i]);
  }

  for (int i = 0; i < data.length; i++) {
    for (int j = 0; j < data[i].length; j++) {
      int index = i + 2;
      final Range range = sheet.getRangeByName('${_numAlphaMap[j]}$index');
      range.setText(data[i][j]);
    }
  }

  final Style titleStyle = workbook.styles.add('style');
  final Style allStyle = workbook.styles.add('allStyle');

  allStyle.wrapText = false;
  allStyle.fontName = "Times New Roman";
  allStyle.borders.all.lineStyle = LineStyle.thin;

  allRange.cellStyle = allStyle;

  titleStyle.bold = true;
  titleStyle.hAlign = HAlignType.center;
  titleStyle.borders.all.lineStyle = LineStyle.thin;

  titleRange.cellStyle = titleStyle;

  allRange.autoFit();

  final List<int> bytes = workbook.saveAsStream();
  workbook.dispose();

  Directory directory = await getTemporaryDirectory();

  final String fileName = "${directory.path}${r'\'}$_title.xlsx";
  final File file = File(fileName);
  return await file.writeAsBytes(bytes, flush: true);
}

Future<File> exportToPdf({
  required List<String> heading,
  required List<List<String>> data,
}) async {
  final PdfDocument document = PdfDocument();

  document.pageSettings.size = PdfPageSize.a4;
  document.pageSettings.margins = PdfMargins()
    ..all = 20
    ..bottom = 0;

  document.documentInformation.title = _title;
  document.documentInformation.author = 'Ankush Mishra';

  final PdfPage page = document.pages.add();

  final PdfGrid grid = PdfGrid();
  grid.columns.add(count: heading.length);

  PdfGridRow headerRow = grid.headers.add(1)[0];
  grid.repeatHeader = true;

  for (int i = 0; i < heading.length; i++) {
    headerRow.cells[i].value = heading[i];
    headerRow.cells[i].stringFormat = PdfStringFormat(
      alignment: PdfTextAlignment.center,
      lineAlignment: PdfVerticalAlignment.middle,
    );
  }
  headerRow.style.font =
      PdfStandardFont(PdfFontFamily.timesRoman, 18, style: PdfFontStyle.bold);

  PdfGridRow row;

  for (int i = 0; i < data.length; i++) {
    row = grid.rows.add();
    for (int j = 0; j < data[i].length; j++) {
      row.cells[j].value = data[i][j];
    }
    row.style.font =
        PdfStandardFont(PdfFontFamily.timesRoman, 14, style: PdfFontStyle.bold);
  }

  grid.style.cellPadding =
      PdfPaddings(top: 10, right: 10, left: 10, bottom: 10);

  grid.draw(
    page: page,
    format: PdfLayoutFormat(
      breakType: PdfLayoutBreakType.fitColumnsToPage,
    ),
    bounds: Rect.fromLTWH(
      0,
      0,
      page.getClientSize().width,
      page.getClientSize().height,
    ),
  );

  Directory directory = await getTemporaryDirectory();

  final String fileName = "${directory.path}${r'\'}$_title.pdf";
  final File file = File(fileName);
  return await file.writeAsBytes(document.saveSync(), flush: true);
}
