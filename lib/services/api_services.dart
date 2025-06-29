import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> getQuizData(int category, bool any) async {
  String apiLink;
  if (any == true) {
    apiLink = 'https://opentdb.com/api.php?amount=20&difficulty=easy';
  } else {
    apiLink =
        'https://opentdb.com/api.php?amount=20&category=$category&difficulty=easy';
  }
  try {
    // Fetch the data from the API
    final http.Response response = await http.get(Uri.parse(apiLink));

    // Check for a successful response
    if (response.statusCode == 200) {
      // Parse and return the JSON data
      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['results'] != null && data['results'].isNotEmpty) {
        return data;
      } else {
        throw Exception('No quiz data available.');
      }
    } else {
      // Handle non-200 status codes
      throw Exception(
          'Failed to fetch quiz data. Status code: ${response.statusCode}');
    }
  } catch (error) {
    // Catch any network or parsing errors
    throw Exception('An error occurred while fetching quiz data: $error');
  }
}
