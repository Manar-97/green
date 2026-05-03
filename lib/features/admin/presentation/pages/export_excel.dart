import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';

class ExcelService {
  static Future<File> exportUsersFile(List users) async {
    final excel = Excel.createExcel();

    // ❗ امسحي الشيت الافتراضي
    excel.delete('Sheet1');

    // 👇 اعملي شيت جديد
    final sheet = excel['Users'];

    print("WRITING EXCEL...");

    // header
    sheet.appendRow([
      TextCellValue("Name"),
      TextCellValue("Phone"),
      TextCellValue("National ID"),
      TextCellValue("Address"),
      TextCellValue("Score"),
    ]);

    // data
    for (final u in users) {
      print("ADDING: ${u.name}");

      sheet.appendRow([
        TextCellValue(u.name),
        TextCellValue(u.phone),
        TextCellValue(u.nationalId),
        TextCellValue(u.address),
        IntCellValue(u.score),
      ]);
    }

    final bytes = excel.encode();

    final dir = await getApplicationDocumentsDirectory();

    final file = File(
      "${dir.path}/users_${DateTime.now().millisecondsSinceEpoch}.xlsx",
    );

    if (bytes != null) {
      await file.writeAsBytes(bytes, flush: true);
    }

    print("FILE SAVED: ${file.path}");

    return file;
  }
}
