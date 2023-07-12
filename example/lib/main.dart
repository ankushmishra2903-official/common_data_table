import 'package:common_data_table/common_data_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Common Data Table Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
  });

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonDataTable(
        isSearchAble: true,
        sortColumn: [1],
        title: "Testing Table",
        titleBgColor: Colors.black,
        titleStyle: TextStyle(
          fontSize: 16,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        heading: [
          'S.NO',
          'Title',
          'Subtitle',
        ],
        rowActionButtons: [
          RowActionButton(
            tooltip: "View Image",
            icon: Icons.remove_red_eye,
            isDisabled: (index) {
              if (index == 3) {
                return true;
              }
              return null;
            },
            onTap: (index) {},
            color: Colors.blue,
          )
        ],
        tableActionButtons: [
          TableActionButton(
            child: Text("Add Highlight"),
            onTap: () {
              print("add");
            },
            shortcuts: SingleActivator(
              LogicalKeyboardKey.keyA,
              control: true,
            ),
            icon: Icon(
              FontAwesomeIcons.addressBook,
              size: 20,
            ),
          )
        ],
        rowDecoration: (index) {
          if (index.isOdd) {
            return BoxDecoration(
              color: Colors.red,
            );
          }
          return null;
        },
        data: [
          for (int i = 1; i <= 100; i++) ...[
            [
              '$i.',
              'Title of $i',
              'Subtitle of title of $i',
            ],
          ]
        ],
        headingAlign: {
          0: TblAlign.center,
          1: TblAlign.center,
        },
        dataAlign: {
          0: TblAlign.center,
        },
        onEdit: (index) {},
        onDelete: (index) {},
        disabledDeleteButtons: [1, 3, 5],
        disabledEditButtons: [0, 2, 4],
        dataTextStyle: (row) {
          if (row[0] == '4.') {
            return {
              1: TextStyle(
                color: Colors.red,
                fontSize: 20,
              )
            };
          }
          return null;
        },
        onExportExcel: (file) async {
          await launchUrl(Uri.file(file.path));
        },
        onExportPDF: (file) async {
          await launchUrl(Uri.file(file.path));
        },
      ),
    );
  }
}
