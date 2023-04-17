import 'dart:convert';
//
// finishes executing, Android will restart the application. Since the data
// is never returned to the original call use the ImagePicker.retrieveLostData()
// method to retrieve the lost data. For example:
//
// Future<void> getLostData() async {
//   final LostDataResponse response = await picker.retrieveLostData();
//   if (response.isEmpty) {
//     return;
//   }
//   if (response.files != null) {
//     for (final XFile file in response.files) {
//       _handleFile(file);
//     }
//   } else {
//     _handleError(response.exception);
//   }
// }

void printWarning(String text) {
  print('\x1B[33m$text\x1B[0m');
}

void printError(String text) {
  print('\x1B[31m$text\x1B[0m');
}
