import 'dart:io';
import 'package:http/http.dart' as http;

class Helpers {


  // static Future<List<List<String>>> readCsvFile(File file) async {
  //   List<List<String>> data = [];
  //   List<String> rows = await file.readAsLines();

  //   if (rows.isEmpty) {
  //     throw FormatException('CSV is empty: ${file.path}');
  //   }

  //   List<String> headerRow = rows.first.split(',');
  //   final headerLength = headerRow.length;

  //   for (int i = 0; i < rows.length - 1; i++) {
  //     List<String> columns = rows[i].split(',');

  //     // Skip rows with fewer columns than expected
  //     if (columns.length != headerLength) {
  //       print("fewer columns $i");
  //       continue;
  //     }

  //     // Skip rows where all columns are empty
  //     if (columns.every((element) => element.isEmpty)) {
  //       print("Empty Row $i");
  //       continue;
  //     }

  //     data.add(columns.map((col) => col.trim()).toList());
  //   }

  //   if (data.isEmpty) {
  //     throw FormatException(
  //         'All rows are empty or do not match header length: ${file.path}');
  //   }

  //   return data;
  // }

  static Future<String> writeCsvFileFromWeb(http.Response response) async {
    final directory = Directory.systemTemp;
    final tempFile = File('${directory.path}/temp_data.csv');
    await tempFile.writeAsString(response.body);
    if (!await tempFile.exists()) {
      throw const FileSystemException('Failed to create temp file');
    }
    return tempFile.path;
  }
}
