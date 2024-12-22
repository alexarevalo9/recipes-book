import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:recipe_book/models/recipe_model.dart';
import 'package:http/http.dart' as http;

class RecipesProvider extends ChangeNotifier {
  bool isLoading = false;
  List<Recipe> recipes = [];
  final List<Recipe> favoriteRecipes = [];

  Future<void> fetchRecipes() async {
    isLoading = true;
    notifyListeners();

    final url = Uri.parse(
      'https://554f-2800-bf0-7f-de4-3fb2-11a0-80c4-8102.ngrok-free.app/recipes',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        recipes = List<Recipe>.from(
          data['recipes'].map((recipe) => Recipe.fromJson(recipe)),
        );
      } else {
        print('Failed to load recipes ${response.statusCode}');
        recipes = [];
      }
    } catch (e) {
      print('Failed to load recipes $e');
      recipes = [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavoriteStatus(Recipe recipe) async {
    final isFavorite = favoriteRecipes.contains(recipe);

    try {
      final url = Uri.parse(
        'https://554f-2800-bf0-7f-de4-3fb2-11a0-80c4-8102.ngrok-free.app/favorites',
      );
      final response = isFavorite
          ? await http.delete(url, body: json.encode({"id": recipe.id}))
          : await http.post(url, body: json.encode(recipe.toJson()));

      if (response.statusCode == 200) {
        if (isFavorite) {
          favoriteRecipes.remove(recipe);
        } else {
          favoriteRecipes.add(recipe);
        }
        notifyListeners();
      } else {
        log('Failed to toggle favorite status ${response.statusCode}');
      }
    } catch (e) {
      log('Failed to toggle favorite status $e');
    }
  }
}
