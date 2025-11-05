import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ExpressionHistoryManager {
  static const String _historyKey = 'math_expression_history';
  static const String _favoritesKey = 'math_expression_favorites';
  static const int _maxHistoryItems = 20;
  static const int _maxFavoriteItems = 10;

  // Singleton pattern
  static final ExpressionHistoryManager _instance = ExpressionHistoryManager._internal();
  factory ExpressionHistoryManager() => _instance;
  ExpressionHistoryManager._internal();

  SharedPreferences? _prefs;

  Future<void> _ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> addToHistory(String expression) async {
    if (expression.trim().isEmpty) return;
    
    await _ensureInitialized();
    
    final history = await getHistory();
    
    // Remove if already exists (to move to top)
    history.removeWhere((item) => item.expression == expression);
    
    // Add to beginning
    history.insert(0, ExpressionHistoryItem(
      expression: expression,
      timestamp: DateTime.now(),
      usageCount: 1,
    ));
    
    // Limit size
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }
    
    // Save back
    await _saveHistory(history);
  }

  Future<List<ExpressionHistoryItem>> getHistory() async {
    await _ensureInitialized();
    
    final jsonString = _prefs!.getString(_historyKey);
    if (jsonString == null) return [];
    
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => ExpressionHistoryItem.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveHistory(List<ExpressionHistoryItem> history) async {
    await _ensureInitialized();
    
    final jsonList = history.map((item) => item.toJson()).toList();
    await _prefs!.setString(_historyKey, json.encode(jsonList));
  }

  Future<void> clearHistory() async {
    await _ensureInitialized();
    await _prefs!.remove(_historyKey);
  }

  Future<void> addToFavorites(String expression, {String? name}) async {
    if (expression.trim().isEmpty) return;
    
    await _ensureInitialized();
    
    final favorites = await getFavorites();
    
    // Check if already exists
    if (favorites.any((item) => item.expression == expression)) {
      return;
    }
    
    // Add new favorite
    favorites.add(ExpressionFavorite(
      expression: expression,
      name: name ?? _generateFavoriteName(expression),
      dateAdded: DateTime.now(),
    ));
    
    // Limit size
    if (favorites.length > _maxFavoriteItems) {
      favorites.removeAt(0); // Remove oldest
    }
    
    // Save back
    await _saveFavorites(favorites);
  }

  Future<List<ExpressionFavorite>> getFavorites() async {
    await _ensureInitialized();
    
    final jsonString = _prefs!.getString(_favoritesKey);
    if (jsonString == null) return [];
    
    try {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => ExpressionFavorite.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveFavorites(List<ExpressionFavorite> favorites) async {
    await _ensureInitialized();
    
    final jsonList = favorites.map((item) => item.toJson()).toList();
    await _prefs!.setString(_favoritesKey, json.encode(jsonList));
  }

  Future<void> removeFromFavorites(String expression) async {
    await _ensureInitialized();
    
    final favorites = await getFavorites();
    favorites.removeWhere((item) => item.expression == expression);
    await _saveFavorites(favorites);
  }

  Future<bool> isFavorite(String expression) async {
    final favorites = await getFavorites();
    return favorites.any((item) => item.expression == expression);
  }

  Future<void> clearFavorites() async {
    await _ensureInitialized();
    await _prefs!.remove(_favoritesKey);
  }

  String _generateFavoriteName(String expression) {
    // Generate a friendly name for the expression
    if (expression.contains(r'\frac')) {
      return 'Fraction';
    } else if (expression.contains(r'\sqrt')) {
      return 'Square Root';
    } else if (expression.contains(r'\int')) {
      return 'Integral';
    } else if (expression.contains(r'\sum')) {
      return 'Summation';
    } else if (expression.contains(r'\sin') || expression.contains(r'\cos') || expression.contains(r'\tan')) {
      return 'Trigonometry';
    } else if (expression.contains(r'\log') || expression.contains(r'\ln')) {
      return 'Logarithm';
    } else if (expression.contains(r'\lim')) {
      return 'Limit';
    } else if (expression.contains('=')) {
      return 'Equation';
    } else {
      return 'Expression';
    }
  }

  Future<List<String>> getRecentExpressions({int limit = 5}) async {
    final history = await getHistory();
    return history
        .take(limit)
        .map((item) => item.expression)
        .toList();
  }

  Future<List<String>> getPopularExpressions({int limit = 5}) async {
    final history = await getHistory();
    
    // Sort by usage count
    history.sort((a, b) => b.usageCount.compareTo(a.usageCount));
    
    return history
        .take(limit)
        .map((item) => item.expression)
        .toList();
  }

  Future<void> incrementUsageCount(String expression) async {
    await _ensureInitialized();
    
    final history = await getHistory();
    final index = history.indexWhere((item) => item.expression == expression);
    
    if (index != -1) {
      history[index] = history[index].copyWith(
        usageCount: history[index].usageCount + 1,
        timestamp: DateTime.now(),
      );
      await _saveHistory(history);
    }
  }
}

class ExpressionHistoryItem {
  final String expression;
  final DateTime timestamp;
  final int usageCount;

  const ExpressionHistoryItem({
    required this.expression,
    required this.timestamp,
    required this.usageCount,
  });

  Map<String, dynamic> toJson() => {
    'expression': expression,
    'timestamp': timestamp.toIso8601String(),
    'usageCount': usageCount,
  };

  factory ExpressionHistoryItem.fromJson(Map<String, dynamic> json) => 
      ExpressionHistoryItem(
        expression: json['expression'],
        timestamp: DateTime.parse(json['timestamp']),
        usageCount: json['usageCount'] ?? 1,
      );

  ExpressionHistoryItem copyWith({
    String? expression,
    DateTime? timestamp,
    int? usageCount,
  }) => ExpressionHistoryItem(
    expression: expression ?? this.expression,
    timestamp: timestamp ?? this.timestamp,
    usageCount: usageCount ?? this.usageCount,
  );
}

class ExpressionFavorite {
  final String expression;
  final String name;
  final DateTime dateAdded;

  const ExpressionFavorite({
    required this.expression,
    required this.name,
    required this.dateAdded,
  });

  Map<String, dynamic> toJson() => {
    'expression': expression,
    'name': name,
    'dateAdded': dateAdded.toIso8601String(),
  };

  factory ExpressionFavorite.fromJson(Map<String, dynamic> json) => 
      ExpressionFavorite(
        expression: json['expression'],
        name: json['name'],
        dateAdded: DateTime.parse(json['dateAdded']),
      );
}