import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:game/screens/auth/widgets/food_log_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

class AddFoodSearchScreen extends StatefulWidget {
  const AddFoodSearchScreen({super.key});

  @override
  State<AddFoodSearchScreen> createState() => _AddFoodSearchScreenState();
}

class _AddFoodSearchScreenState extends State<AddFoodSearchScreen> {
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();
  List<Food> _searchResults = [];
  bool _isLoading = false;
  final Map<int, Food> _detailCache = {}; // fdcId → Food

  Future<void> _searchFoods(String query) async {
    if (query.isEmpty) return;
    setState(() => _isLoading = true);

    final apiKey = dotenv.env['USDA_API_KEY']!;
    final url =
        'https://api.nal.usda.gov/fdc/v1/foods/search?query=${Uri.encodeComponent(query)}&pageSize=25&api_key=$apiKey';

    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) throw Exception("Search failed");
      final List items = json.decode(res.body)['foods'];

      // Filter out bad results
      final filteredItems = items.where((item) {
        final dataType = (item['dataType'] ?? '').toString().toLowerCase();
        return dataType != 'survey (fndds)' && dataType != 'experimental' && dataType != 'branded';
      });

      // Build list from full detail fetch
      List<Food> finalList = [];

      for (var item in filteredItems) {
        final fdcId = item['fdcId'];
          if (fdcId == null) continue;

          final detail = await _fetchFoodDetails(fdcId, apiKey);
          if (detail == null || detail.calories == 0) continue;

          finalList.add(detail);
          _detailCache[fdcId] = detail;
      }

      setState(() => _searchResults = finalList);
    } catch (e) {
      debugPrint("Search error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<Food?> _fetchFoodDetails(int fdcId, String apiKey) async {
    final url = 'https://api.nal.usda.gov/fdc/v1/food/$fdcId?api_key=$apiKey';
    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) return null;
      return Food.fromJson(json.decode(res.body));
    } catch (e) {
      debugPrint("Detail fetch failed: $e");
      return null;
      
    }
    
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchFoods(_searchController.text.trim());
    });
  }


  void addToTracker(Food food) {
    Provider.of<FoodLogModel>(context, listen: false).addFood(food);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${food.name} added to tracker!')),
    );
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Search Food', style: TextStyle(color: Colors.green))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search food...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.search, color: Colors.green),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final food = _searchResults[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: Column(
                            children: [
                              ListTile(
                                title: Text(food.name),
                                subtitle: Text(
                                  'Calories: ${food.calories.toStringAsFixed(1)} | '
                                  'Protein: ${food.protein.toStringAsFixed(1)}g | '
                                  'Carbs: ${food.carbs.toStringAsFixed(1)}g | '
                                  'Fat: ${food.fat.toStringAsFixed(1)}g',
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.add, color: Colors.green),
                                  onPressed: () => addToTracker(food),
                                ),
                              ),
                              if (food.servingSizes.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: DropdownButton<ServingSize>(
                                    value: food.selectedServing,
                                    isExpanded: true,
                                    items: food.servingSizes
                                        .map(
                                          (s) => DropdownMenuItem(
                                            value: s,
                                            child: Text('${s.label} (${s.quantity}g)'),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        food.selectedServing = value;
                                      });
                                    },
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class ServingSize {
  final String label;
  final double quantity;

  ServingSize(this.label, this.quantity);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServingSize &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          quantity == other.quantity;

  @override
  int get hashCode => label.hashCode ^ quantity.hashCode;

  @override
  String toString() => '$label ($quantity)';
}


class Food {
  final int? fdcId;
  final String name;
  final double baseCalories;
  final double baseProtein;
  final double baseCarbs;
  final double baseFat;
  final List<ServingSize> servingSizes;
  ServingSize? selectedServing;

  Food({
    required this.fdcId,
    required this.name,
    required this.baseCalories,
    required this.baseProtein,
    required this.baseCarbs,
    required this.baseFat,
    required this.servingSizes,
    this.selectedServing,
  });

double get multiplier => (selectedServing?.quantity ?? 100) / 100;
  double get calories => baseCalories * multiplier;
  double get protein => baseProtein * multiplier;
  double get carbs => baseCarbs * multiplier;
  double get fat => baseFat * multiplier;

  factory Food.fromJson(Map<String, dynamic> json) {
  double getNutrientById(int id) {
  final nutrients = json['foodNutrients'] ?? [];
  try {
    final nutrient = nutrients.firstWhere(
      (n) => n['nutrient'] != null && n['nutrient']['id'] == id,
      orElse: () => null,
    );
    if (nutrient != null && nutrient['amount'] != null) {
      final val = nutrient['amount'];
      if (val is num) {
        return val.toDouble();
      }
    }
    return 0.0;
  } catch (e) {
    debugPrint('Error extracting nutrient $id: $e');
    return 0.0;
  }
}



  final double baseCalories = getNutrientById(1008);
  final double baseProtein = getNutrientById(1003);
  final double baseCarbs = getNutrientById(1005);
  final double baseFat = getNutrientById(1004);

  // Parse serving sizes
  final List<ServingSize> servingSizes = [];
  if (json['foodPortions'] != null) {
    for (final portion in json['foodPortions']) {
      final label = portion['modifier'] ?? portion['measureUnit']?['name'];
      final gramWeight = portion['gramWeight'];
      if (label != null && gramWeight is num && gramWeight > 0) {
          servingSizes.add(
            ServingSize(label.toString(), (gramWeight).toDouble()),
          );
        }
    }
  }

  return Food(
    fdcId: json['fdcId'],
    name: json['description'] ?? 'Unknown',
    baseCalories: baseCalories,
    baseProtein: baseProtein,
    baseCarbs: baseCarbs,
    baseFat: baseFat,
    servingSizes: servingSizes,
    selectedServing: servingSizes.isNotEmpty ? servingSizes.first : null,
  );
}
}