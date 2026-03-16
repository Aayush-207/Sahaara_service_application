import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all products
  Stream<List<ProductModel>> getProducts() {
    return _firestore
        .collection('products')
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final products = snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
      
      // Sort by name if createdAt is not available
      products.sort((a, b) => a.name.compareTo(b.name));
      
      return products;
    });
  }

  /// Get products by category
  Stream<List<ProductModel>> getProductsByCategory(String category) {
    if (category == 'All') {
      return getProducts();
    }

    return _firestore
        .collection('products')
        .where('category', isEqualTo: category)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final products = snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
      
      // Sort by name
      products.sort((a, b) => a.name.compareTo(b.name));
      
      return products;
    });
  }

  /// Get product by ID
  Future<ProductModel?> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        return ProductModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting product: $e');
      return null;
    }
  }

  /// Search products
  Stream<List<ProductModel>> searchProducts(String query) {
    return _firestore
        .collection('products')
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final products = snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();

      // Filter by name (case-insensitive)
      return products
          .where((product) =>
              product.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  /// Seed sample products (for development)
  /// 
  /// NOTE: For comprehensive seeding with better data, use ComprehensiveDataSeeder instead
  Future<void> seedProducts() async {
    final products = [
      // FOOD CATEGORY
      {
        'name': 'Royal Canin Maxi Adult Dog Food',
        'description': 'Premium nutrition for large breed adult dogs (26-44kg). Supports bone & joint health with optimal protein content.',
        'price': 3499.0,
        'category': 'Food',
        'images': ['https://firebasestorage.googleapis.com/v0/b/sahara-a72.appspot.com/o/products%2Froyal-canin-dog-food.jpg?alt=media'],
        'rating': 4.8,
        'reviewCount': 245,
        'stock': 45,
        'isAvailable': true,
        'discount': '15% OFF',
        'brand': 'Royal Canin',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Whiskas Adult Cat Food - Ocean Fish',
        'description': 'Complete and balanced nutrition for adult cats. Rich in Omega 3 & 6 for healthy skin and shiny coat.',
        'price': 899.0,
        'category': 'Food',
        'images': ['https://firebasestorage.googleapis.com/v0/b/sahara-a72.appspot.com/o/products%2Fwhiskas-cat-food.jpg?alt=media'],
        'rating': 4.6,
        'reviewCount': 189,
        'stock': 78,
        'isAvailable': true,
        'brand': 'Whiskas',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Pedigree Puppy Dry Dog Food',
        'description': 'Specially formulated for puppies with DHA for brain development and calcium for strong bones.',
        'price': 1299.0,
        'category': 'Food',
        'images': ['https://firebasestorage.googleapis.com/v0/b/sahara-a72.appspot.com/o/products%2Fpedigree-puppy-food.jpg?alt=media'],
        'rating': 4.7,
        'reviewCount': 312,
        'stock': 62,
        'isAvailable': true,
        'discount': '10% OFF',
        'brand': 'Pedigree',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Healthy Treats Variety Pack',
        'description': 'Assorted pack of healthy treats including chicken jerky, dental sticks, and training treats.',
        'price': 449.0,
        'category': 'Food',
        'images': ['https://firebasestorage.googleapis.com/v0/b/sahara-a72.appspot.com/o/products%2Fhealthy-treats.jpg?alt=media'],
        'rating': 4.9,
        'reviewCount': 423,
        'stock': 125,
        'isAvailable': true,
        'discount': '20% OFF',
        'brand': 'PetTreats',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },

      // TOYS CATEGORY
      {
        'name': 'Kong Classic Dog Toy - Large',
        'description': 'Durable rubber toy for aggressive chewers. Can be stuffed with treats for mental stimulation.',
        'price': 799.0,
        'category': 'Toys',
        'images': ['https://firebasestorage.googleapis.com/v0/b/sahara-a72.appspot.com/o/products%2Fkong-toy.jpg?alt=media'],
        'rating': 4.9,
        'reviewCount': 567,
        'stock': 89,
        'isAvailable': true,
        'brand': 'Kong',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Interactive Cat Feather Wand',
        'description': 'Retractable feather wand toy for cats. Encourages exercise and bonding.',
        'price': 299.0,
        'category': 'Toys',
        'images': ['https://firebasestorage.googleapis.com/v0/b/sahara-a72.appspot.com/o/products%2Fcat-feather-wand.jpg?alt=media'],
        'rating': 4.7,
        'reviewCount': 234,
        'stock': 156,
        'isAvailable': true,
        'brand': 'PetPlay',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Puzzle Treat Dispenser',
        'description': 'Interactive puzzle toy that dispenses treats. Adjustable difficulty levels.',
        'price': 899.0,
        'category': 'Toys',
        'images': ['https://firebasestorage.googleapis.com/v0/b/sahara-a72.appspot.com/o/products%2Fpuzzle-toy.jpg?alt=media'],
        'rating': 4.9,
        'reviewCount': 412,
        'stock': 67,
        'isAvailable': true,
        'discount': '10% OFF',
        'brand': 'SmartPet',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },

      // ACCESSORIES CATEGORY
      {
        'name': 'Premium Leather Collar with ID Tag',
        'description': 'Genuine leather collar with stainless steel buckle. Includes free personalized ID tag.',
        'price': 699.0,
        'category': 'Accessories',
        'images': ['https://firebasestorage.googleapis.com/v0/b/sahara-a72.appspot.com/o/products%2Fleather-collar.jpg?alt=media'],
        'rating': 4.8,
        'reviewCount': 345,
        'stock': 78,
        'isAvailable': true,
        'brand': 'PetLuxe',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Stainless Steel Food & Water Bowl Set',
        'description': 'Set of 2 stainless steel bowls with non-slip rubber base. Dishwasher safe.',
        'price': 599.0,
        'category': 'Accessories',
        'images': ['https://firebasestorage.googleapis.com/v0/b/sahara-a72.appspot.com/o/products%2Fsteel-bowls.jpg?alt=media'],
        'rating': 4.9,
        'reviewCount': 456,
        'stock': 134,
        'isAvailable': true,
        'brand': 'PetDine',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Orthopedic Memory Foam Pet Bed',
        'description': 'Premium memory foam bed with removable washable cover. Provides excellent support for joints.',
        'price': 2499.0,
        'category': 'Accessories',
        'images': ['https://firebasestorage.googleapis.com/v0/b/sahara-a72.appspot.com/o/products%2Fmemory-foam-bed.jpg?alt=media'],
        'rating': 4.9,
        'reviewCount': 389,
        'stock': 45,
        'isAvailable': true,
        'discount': '25% OFF',
        'brand': 'ComfyPet',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },

      // HEALTHCARE CATEGORY
      {
        'name': 'Multivitamin Supplements for Dogs',
        'description': 'Complete multivitamin with glucosamine for joint health and omega-3 for coat. 60 chewable tablets.',
        'price': 899.0,
        'category': 'Healthcare',
        'images': ['https://firebasestorage.googleapis.com/v0/b/sahara-a72.appspot.com/o/products%2Fmultivitamin.jpg?alt=media'],
        'rating': 4.7,
        'reviewCount': 312,
        'stock': 89,
        'isAvailable': true,
        'brand': 'PetHealth',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Dental Care Kit - Complete',
        'description': 'Complete dental care kit with toothbrush, toothpaste, and dental wipes.',
        'price': 599.0,
        'category': 'Healthcare',
        'images': ['https://firebasestorage.googleapis.com/v0/b/sahara-a72.appspot.com/o/products%2Fdental-kit.jpg?alt=media'],
        'rating': 4.6,
        'reviewCount': 198,
        'stock': 112,
        'isAvailable': true,
        'brand': 'FreshPet',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },

      // GROOMING CATEGORY
      {
        'name': 'Professional Grooming Kit - 7 Pieces',
        'description': 'Complete grooming kit with slicker brush, comb, nail clipper, scissors, and more.',
        'price': 1299.0,
        'category': 'Grooming',
        'images': ['https://firebasestorage.googleapis.com/v0/b/sahara-a72.appspot.com/o/products%2Fgrooming-kit.jpg?alt=media'],
        'rating': 4.9,
        'reviewCount': 378,
        'stock': 67,
        'isAvailable': true,
        'brand': 'GroomPro',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Natural Pet Shampoo & Conditioner Set',
        'description': 'pH-balanced shampoo and conditioner with natural ingredients. Suitable for sensitive skin.',
        'price': 699.0,
        'category': 'Grooming',
        'images': ['https://firebasestorage.googleapis.com/v0/b/sahara-a72.appspot.com/o/products%2Fshampoo-set.jpg?alt=media'],
        'rating': 4.8,
        'reviewCount': 289,
        'stock': 98,
        'isAvailable': true,
        'discount': '15% OFF',
        'brand': 'NaturalPet',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    try {
      for (final product in products) {
        await _firestore.collection('products').add(product);
      }
      debugPrint('✅ Products seeded successfully');
    } catch (e) {
      debugPrint('❌ Error seeding products: $e');
    }
  }
}
