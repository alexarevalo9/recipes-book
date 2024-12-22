import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipe_book/models/recipe_model.dart';
import 'package:recipe_book/providers/recipes_provider.dart';
import 'package:recipe_book/screens/recipe_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<RecipesProvider>(context, listen: false).fetchRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RecipesProvider>(builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final recipes = provider.recipes;

        if (recipes.isEmpty) {
          return const Center(
            child: Text('No recipes found'),
          );
        } else {
          return ListView.builder(
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              return _RecipesCard(context, recipes[index]);
            },
          );
        }
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showBottom(context);
        },
        backgroundColor: Colors.green,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Future<void> _showBottom(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(0),
        ),
      ),
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              height: 550,
              width: MediaQuery.of(context).size.width,
              child: const RecipeForm(),
            )),
      ),
    );
  }

  Widget _RecipesCard(BuildContext context, Recipe recipe) {
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
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: 125,
          child: Card(
            child: Row(
              children: [
                Container(
                  height: 125,
                  width: 100,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      recipe.image_link,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color:
                              Colors.grey[200], // Background for the fallback
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.grey[400],
                            size: 50,
                          ), // Placeholder icon
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 26),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Quicksand',
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      recipe.author,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'Quicksand',
                      ),
                    ),
                    Container(
                      height: 2,
                      width: 75,
                      color: Colors.green,
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class RecipeForm extends StatelessWidget {
  const RecipeForm({super.key});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _authorController = TextEditingController();
    final TextEditingController _imageController = TextEditingController();
    final TextEditingController _ingredientsController =
        TextEditingController();

    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Recipe',
              style: TextStyle(
                fontSize: 24,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            _buildTextField(
              label: 'Title',
              hint: 'Enter the title of the recipe',
              controller: _titleController,
              validator: (value) {
                if (value != null && value.isEmpty) {
                  return 'Please enter the title of the recipe';
                }
                return null;
              },
            ),
            const SizedBox(height: 10),
            _buildTextField(
              label: 'Author',
              hint: 'Enter the author of the recipe',
              controller: _authorController,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              label: 'Image URL',
              hint: 'Enter the image URL of the recipe',
              controller: _imageController,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              label: 'Ingredients',
              hint: 'Enter the ingredients of the recipe',
              controller: _ingredientsController,
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    print('Title: ${_titleController.text}');
                    print('Author: ${_authorController.text}');
                    print('Image URL: ${_imageController.text}');
                    print('Ingredients: ${_ingredientsController.text}');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

Widget _buildTextField({
  required String label,
  required String hint,
  required TextEditingController controller,
  String? Function(String?)? validator,
}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Colors.green,
          fontFamily: 'Quicksand',
        ),
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.green,
            width: 2,
          ),
        ),
      ),
    ),
  );
}
