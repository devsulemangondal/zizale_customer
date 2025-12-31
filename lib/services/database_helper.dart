import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:customer/app/models/cart_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class CartDatabaseHelper {
  static Database? cartDatabase;

  Future<Database> get database async {
    if (cartDatabase != null) return cartDatabase!;

    cartDatabase = await createDatabase();
    return cartDatabase!;
  }

  Future<Database> createDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = '${directory.path}/my_cart.db';
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE my_cart(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            productId TEXT,
            customerId TEXT,
            productName TEXT,
            vendorId TEXT,
            quantity INTEGER,
            totalAmount INTEGER,
            itemPrice INTEGER,
            addOns TEXT,
            variation TEXT,
            preparationTime TEXT
          )''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // Add the new column 'preparationTime'
          await db.execute(
            "ALTER TABLE my_cart ADD COLUMN preparationTime TEXT",
          );
        }
      },
    );
  }

  Future<void> insertCartItem(CartModel cartModel) async {
    final db = await database;

    String addOnsJson = cartModel.addOns != null ? jsonEncode(cartModel.addOns) : '[]';
    String variationJson = cartModel.variation != null ? jsonEncode(cartModel.variation) : 'null';
    await db.insert(
        'my_cart',
        {
          'productId': cartModel.productId,
          'customerId': cartModel.customerId,
          'productName': cartModel.productName,
          'vendorId': cartModel.vendorId,
          'quantity': cartModel.quantity,
          'totalAmount': cartModel.totalAmount,
          'itemPrice': cartModel.itemPrice,
          'addOns': addOnsJson,
          'variation': variationJson,
          'preparationTime': cartModel.preparationTime,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<CartModel>> getAllCartItems(String customerId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('my_cart', where: 'customerId = ?', whereArgs: [customerId]);
    return List.generate(maps.length, (i) {
      return CartModel.fromJson(maps[i]);
    });
  }

  Future<void> updateCartItem(CartModel cartModel) async {
    final db = await database;

    String addOnsJson = cartModel.addOns != null ? jsonEncode(cartModel.addOns) : '[]';
    String variationJson = cartModel.variation != null ? jsonEncode(cartModel.variation) : 'null';
    await db.update(
        'my_cart',
        {
          'productId': cartModel.productId,
          'customerId': cartModel.customerId,
          'productName': cartModel.productName,
          'vendorId': cartModel.vendorId,
          'quantity': cartModel.quantity,
          'totalAmount': cartModel.totalAmount,
          'itemPrice': cartModel.itemPrice,
          'addOns': addOnsJson,
          'variation': variationJson,
          'preparationTime': cartModel.preparationTime,
        },
        where: 'productId = ?',
        whereArgs: [cartModel.productId]);
  }

  Future<int> deleteCartItem(int id) async {
    final db = await database;
    return await db.delete('my_cart', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteCartItemByProductId(String productId) async {
    final db = await database;
    await db.delete(
      'my_cart',
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }

  Future<bool> isItemInCart(String productId) async {
    final db = await database;
    var result = await db.query(
      'my_cart',
      where: 'productId = ?',
      whereArgs: [productId],
    );
    return result.isNotEmpty;
  }

  Future<bool> isSameRestaurant(String vendorId) async {
    final db = await database;
    List<Map<String, dynamic>> cartItems = await db.rawQuery('SELECT vendorId FROM my_cart');

    if (cartItems.isEmpty) {
      return true;
    }

    for (var item in cartItems) {
      if (item['vendorId'] != vendorId) {
        return false;
      }
    }
    return true;
  }

  Future<void> clearCart() async {
    final db = await database;
    await db.delete('my_cart');
  }
}
