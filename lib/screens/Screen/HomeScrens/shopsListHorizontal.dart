import 'package:flutter/material.dart';
import 'package:meatzo/screens/shop/productdetailstpage.dart'; // Import ProductDetailList

class Categories extends StatelessWidget {
  final List<dynamic> categories;

  const Categories({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        // Display up to 4 categories in the grid, or fewer if less are available.
        itemCount: categories.length > 4 ? 4 : categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 170, // Height of each grid item
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemBuilder: (context, index) {
          final category = categories[index]; // Get the current category data

          return InkWell(
            onTap: () {
              // Navigate to ProductDetailList when a category is tapped
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductDetailList(
                    categoryId: category['category_id'], // Pass the category ID
                    categoryName: category['category_name'], // Pass the category name
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.08),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      category['image'] ?? 'https://via.placeholder.com/150', // Use category image, with fallback
                      height: 130,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        // Display a broken image icon or a placeholder if image fails to load
                        return const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey));
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      category['category_name'] ?? "Unknown Category", // Use category name, with fallback
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}