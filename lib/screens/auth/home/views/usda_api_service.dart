import 'dart:convert';
import 'package:http/http.dart' as http;

class UsdaApiService {
  static const String _baseUrl = 'https://api.nal.usda.gov/fdc/v1';
  static const String _apiKey = 'kPguuLqSawsnzvvRhsTdEYLzOxakWnclEZYRHFgz';

  Future<List<Map<String, dynamic>>> searchFoods(String query) async {
    final url = Uri.parse(
        '$_baseUrl/foods/search?query=${Uri.encodeComponent(query)}&pageSize=50&api_key=$_apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List results = data['foods'];

      // Filter out unwanted data types
      final filtered = results.where((food) {
        final dataType = (food['dataType'] ?? '').toString().toLowerCase();
        return dataType != 'survey (fndds)' && dataType != 'experimental';
      }).toList();

      // Priority order for dataTypes (lower index = higher priority)
      const List<String> priorityOrder = ['foundation', 'sr legacy', 'branded'];

      // Map to store best unique entries keyed by normalized name
      final Map<String, Map<String, dynamic>> uniqueMap = {};

      for (final item in filtered) {
        final name = (item['description'] ?? '').toString().toLowerCase().trim();

        if (name.isEmpty) continue;

        final dataType = (item['dataType'] ?? '').toString().toLowerCase();

        // Calculate priority index (default to low priority)
        final priorityIndex =
            priorityOrder.indexOf(dataType) == -1 ? priorityOrder.length : priorityOrder.indexOf(dataType);

        if (!uniqueMap.containsKey(name)) {
          uniqueMap[name] = item as Map<String, dynamic>;
        } else {
          // Check if this item has higher priority than stored one, replace if yes
          final existingDataType =
              (uniqueMap[name]?['dataType'] ?? '').toString().toLowerCase();
          final existingPriorityIndex =
              priorityOrder.indexOf(existingDataType) == -1 ? priorityOrder.length : priorityOrder.indexOf(existingDataType);

          if (priorityIndex < existingPriorityIndex) {
            uniqueMap[name] = item as Map<String, dynamic>;
          }
        }
      }

      // Return the unique items as list
      return uniqueMap.values.toList();
    } else {
      throw Exception('Failed to load food data');
    }
  }

  Future<Map<String, dynamic>> getFoodDetails(int fdcId) async {
    final url = Uri.parse('$_baseUrl/food/$fdcId?api_key=$_apiKey');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load food details');
    }
  }
}
