import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:game/screens/auth/home/views/calorieTracker/food_log_model.dart';
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

  Future<void> _searchFoods(String query) async {
    if (query.isEmpty || !mounted) return;

    setState(() => _isLoading = true);
    final apiKey = dotenv.env['USDA_API_KEY'];
    if (apiKey == null) {
      debugPrint("Missing USDA API key");
      return;
    }

    final url =
        'https://api.nal.usda.gov/fdc/v1/foods/search?query=${Uri.encodeComponent(query)}&pageSize=25&api_key=$apiKey';

    try {
      final res = await http.get(Uri.parse(url));
      if (res.statusCode != 200) throw Exception("Search failed");
      final List items = json.decode(res.body)['foods'];

      final filteredItems = items.where((item) {
        final dataType = (item['dataType'] ?? '').toString().toLowerCase();
        return dataType != 'survey (fndds)' && dataType != 'experimental';
      });

      final List<Food> results = filteredItems
          .map((item) => Food.fromSearchJson(item))
          .where((food) => food.calories > 0)
          .toList();

      if (!mounted) return;
      setState(() => _searchResults = results);
    } catch (e) {
      debugPrint("Search error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }



  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchFoods(_searchController.text.trim());
    });
  }

  void addToTracker(Food food) {
    final trackedFood = food.copyWith(timestamp: DateTime.now());
    Provider.of<FoodLogModel>(context, listen: false).addFood(trackedFood);
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Search Food', style: TextStyle(color: Colors.green)),
      backgroundColor: colorScheme.onPrimary,),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search food...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.search, color: Colors.green),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
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
                                  '${food.brandName != null ? '${food.brandName!} | ' : ''}'
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
  final String? docId;
  final int? fdcId;
  final String name;
  final double baseCalories;
  final double baseProtein;
  final double baseCarbs;
  final double baseFat;
  final DateTime timestamp;
  final List<ServingSize> servingSizes;
  ServingSize? selectedServing;

  Food({
    this.docId,
    this.fdcId,
    required this.name,
    required this.baseCalories,
    required this.baseProtein,
    required this.baseCarbs,
    required this.baseFat,
    required this.timestamp,
    required this.servingSizes,
    this.selectedServing,
  });

  double get calories => baseCalories;
  double get protein => baseProtein;
  double get carbs => baseCarbs;
  double get fat => baseFat;

  String? get brandName {
    final parts = name.split('(');
    if (parts.length > 1) return parts.last.replaceAll(')', '').trim();
    return null;
  }

  factory Food.fromSearchJson(Map<String, dynamic> json) {
    double getNutrientById(int id) {
      final nutrients = (json['foodNutrients'] as List?) ?? [];
      try {
        final nutrient = nutrients.firstWhere(
          (n) => n['nutrientId'] == id,
          orElse: () => null,
        );
        if (nutrient != null && nutrient['value'] != null) {
          final val = nutrient['value'];
          if (val is num) return val.toDouble();
        }
        return 0.0;
      } catch (_) {
        return 0.0;
      }
    }

    final name = json['description'] ?? 'Unknown';
    final brand = json['brandName'];
    final fullName = brand != null ? '$name ($brand)' : name;

    final servingSizes = <ServingSize>[
      if (json['servingSize'] != null && json['servingSizeUnit'] != null)
        ServingSize(json['servingSizeUnit'].toString(), (json['servingSize'] as num).toDouble())
    ];

    return Food(
      timestamp: DateTime.now(),
      fdcId: json['fdcId'] ?? 0,
      name: fullName,
      baseCalories: getNutrientById(1008),
      baseProtein: getNutrientById(1003),
      baseCarbs: getNutrientById(1005),
      baseFat: getNutrientById(1004),
      servingSizes: servingSizes,
      selectedServing: servingSizes.isNotEmpty ? servingSizes.first : null,
    );
  }

  factory Food.fromJson(Map<String, dynamic> json) {
    // Optional: Add implementation for full detail response
    throw UnimplementedError('fromJson not implemented');
  }

  Food copyWith({DateTime? timestamp}) {
    return Food(
      docId: docId,
      fdcId: fdcId,
      name: name,
      baseCalories: baseCalories,
      baseProtein: baseProtein,
      baseCarbs: baseCarbs,
      baseFat: baseFat,
      timestamp: timestamp ?? this.timestamp,
      servingSizes: servingSizes,
      selectedServing: selectedServing,
    );
  }
}
