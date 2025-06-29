import 'dart:convert';
import 'package:http/http.dart' as http;

class QuoteApi {
  static const String apiKey =
      'tP7nfAmF/Q89vSLvcr7BZg==pNkfTxYEyZBhDlob'; // Replace with your API key

  static Future<String> getQuote() async {
    final response = await http.get(
      Uri.parse('https://api.api-ninjas.com/v1/quotes'),
      headers: {'X-Api-Key': apiKey}, // Add API key header
    );
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body);
      if (jsonData.isNotEmpty) {
        return jsonData[0]['quote']; // Extract the 'quote' field
      } else {
        return 'No quote available.';
      }
    } else {
      throw Exception('Failed to load quote');
    }
  }
}
