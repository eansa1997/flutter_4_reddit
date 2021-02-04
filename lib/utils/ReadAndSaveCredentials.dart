import 'dart:io';

import 'package:path_provider/path_provider.dart';

class ReadAndSaveCredentials {
  static Future<File> getLocalFile() async {
    var directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/jsonCredentials.txt");
  }

  static Future<String> readFile() async {
    try {
      File file = await getLocalFile();
      String contents = await file.readAsString();
      return contents;
    } catch (e) {
      return null;
    }
  }

  static Future<void> writeFile(String credentials) async {
    try {
      File file = await getLocalFile();
      file.writeAsString(credentials);
    } catch (e) {}
  }
}
