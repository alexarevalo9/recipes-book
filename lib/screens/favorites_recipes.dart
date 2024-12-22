import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_book/models/recipe_model.dart';
import 'package:recipe_book/providers/recipes_provider.dart';
import 'package:recipe_book/screens/recipe_detail.dart';

class FavoritesRecipes extends StatelessWidget {
  const FavoritesRecipes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<RecipesProvider>(
        builder: (context, provider, child) {
          final favoriteRecipes = provider.favoriteRecipes;

          if (favoriteRecipes.isEmpty) {
            return const Center(
              child: Text(
                'No favorite recipes found',
              ),
            );
          } else {
            return ListView.builder(
              itemCount: favoriteRecipes.length,
              itemBuilder: (context, index) {
                return FavoriteRecipeCard(
                  recipe: favoriteRecipes[index],
                );
              },
            );
          }
        },
      ),
    );
  }
}

class FavoriteRecipeCard extends StatelessWidget {
  final Recipe recipe;
  const FavoriteRecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetail(
              recipes: recipe,
            ),
          ),
        );
      },
      child: Card(
        color: Colors.green[50],
        child: ListTile(
          title: Text(
            recipe.name,
          ),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(recipe.image_link),
          ),
          subtitle: Text(
            recipe.author,
          ),
        ),
      ),
    );
  }
}
