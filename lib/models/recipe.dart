import 'package:flutter/material.dart';

class Recipe {
  final String id;
  final String title;
  final String description;
  final List<String> ingredients;
  final String steps;
  final String category; // Breakfast, Lunch, Dinner, Snack
  final int prepTime;
  final int calories;
  final int servings;
  final double protein;
  final double carbs;
  final double fat;
  final bool isFeatured;
  final String? imageUrl;
  bool isFavorite;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.category,
    required this.prepTime,
    required this.calories,
    required this.servings,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.isFeatured = false,
    this.imageUrl,
    this.isFavorite = false,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        ingredients: List<String>.from(json['ingredients']),
        steps: json['steps'],
        category: json['category'],
        prepTime: json['prepTime'],
        calories: json['calories'],
        servings: json['servings'],
        protein: (json['protein'] as num).toDouble(),
        carbs: (json['carbs'] as num).toDouble(),
        fat: (json['fat'] as num).toDouble(),
        isFeatured: json['isFeatured'] ?? false,
        isFavorite: json['isFavorite'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'ingredients': ingredients,
        'steps': steps,
        'category': category,
        'prepTime': prepTime,
        'calories': calories,
        'servings': servings,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'isFeatured': isFeatured,
        'isFavorite': isFavorite,
      };
}
