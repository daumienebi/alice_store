import 'package:alice_store/models/cart_item_model.dart';
import 'package:alice_store/models/product_model.dart';
import 'package:alice_store/services/api/product_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// This class will serve the purpose of carrying out the basic CRUD operations
/// by the [User]s, mainly for the cart and wishlist items.
class FirestoreService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final ProductService productService = ProductService();

  /// Adds an item to the user's cart if the items does not exist in the cart
  /// and updates the quantity if the item already exists
  Future<void> addToCart(String userId, CartItemModel newCartItem) async {
    // fetch the cart items
    final cartReference =
        firestore.collection('users').doc(userId).collection('cartItems');
    //filter out the one with the cart item to avoid fetching all of them
    final cartQuery = await cartReference
        .where('productId', isEqualTo: newCartItem.product.id)
        .get(GetOptions(source: Source.serverAndCache));
    final cartDocs = cartQuery.docs;
    if (cartDocs.isNotEmpty) {
      // If the cart item already exists, update its quantity
      final cartDoc = cartDocs.first;
      final cartData = cartDoc.data();
      final quantity = cartData['quantity'] + newCartItem.quantity;
      await cartDoc.reference.update({'quantity': quantity});
    } else {
      // If the cart item doesn't exist, add it to the cart
      await cartReference.add({
        'productId': newCartItem.product.id,
        'quantity': newCartItem.quantity,
      });
    }
  }

  /// Remove a whole existing cart item from the user's cart if it exists
  Future<void> removeFromCart(String userId, CartItemModel cartItem) async {
    // fetch the cart items
    final cartReference =
        firestore.collection('users').doc(userId).collection('cartItems');
    //filter out the one with the cart item to avoid fetching all of them
    final cartQuery = await cartReference
        .where('productId', isEqualTo: cartItem.product.id)
        .get(GetOptions(source: Source.serverAndCache));
    final cartDocs = cartQuery.docs;
    // Find the cart item with the matching product id
    for (final cartDoc in cartDocs) {
      final cartData = cartDoc.data();
      final productId = cartData['productId'];
      if (productId == cartItem.product.id) {
        await cartDoc.reference.delete();
        break;
      }
    }
  }

  /// Get the user's available cart items
  Future<List<CartItemModel>> getUserCartItems(String userId) async {
    List<CartItemModel> items = [];
    final cartReference = firestore.collection('users').doc(userId).collection('cartItems');
    // Get all cart items for the user
    final cartQuery = await cartReference.get(GetOptions(source: Source.serverAndCache));
    final cartDocs = cartQuery.docs;
    for (final cartDoc in cartDocs) {
      //get the data from the doc
      final cartData = cartDoc.data();
      //fetch the product, only the cart model is stored in Firestore[id & quantity]
      final product = await productService.fetchProduct(cartData['productId']);
      final cartItem = CartItemModel(product: product!, quantity: cartData['quantity']);
      items.add(cartItem);
    }
    return Future.value(items);
  }

  addItemToWishList(String userId, ProductModel product) async{
    // get the wishlist reference
    final wishListReference =
    firestore.collection('users').doc(userId).collection('wishlist');
    // add the new wishlist item
    final wishListQuery = await wishListReference.where('productId', isEqualTo: product.id)
        .get(GetOptions(source: Source.serverAndCache));
    final wishListDocs = wishListQuery.docs;
    // only add the item if it does not exist in the wishlist
    if(wishListDocs.isEmpty){
      await wishListReference.add({
        'productId': product.id,
      });
    }
  }

  removeItemFromWishList(String userId, ProductModel product) async{
    // get the wishlist reference
    final wishListReference =
    firestore.collection('users').doc(userId).collection('wishlist');
    final wishListQuery = await wishListReference.where('productId', isEqualTo: product.id)
        .get(GetOptions(source: Source.serverAndCache));
    final wishListDocs = wishListQuery.docs;
    for (final wishListDoc in wishListDocs) {
      final wishListData = wishListDoc.data();
      final productId = wishListData['productId'];
      if (productId == product.id) {
        await wishListDoc.reference.delete();
        break;
      }
    }
  }

  Future<List<ProductModel>> getWishListItems(String userId) async{
    List<ProductModel> items = [];
    final wishListReference = firestore.collection('users').doc(userId).collection('wishlist');
    // Get all cart items for the user
    final wishListQuery = await wishListReference.get(GetOptions(source: Source.serverAndCache));
    final wishListDocs = wishListQuery.docs;
    for (final wishListDoc in wishListDocs) {
      //get the data from the doc
      final wishListData = wishListDoc.data();
      //fetch the product, only the cart model is stored in Firestore[id & quantity]
      final product = await productService.fetchProduct(wishListData['productId']);
      items.add(product);
    }
    return Future.value(items);
  }

  isInWishList(String userId, ProductModel product) async{
    bool isInWishList = false;
    // get the wishlist reference
    final wishListReference =
    firestore.collection('users').doc(userId).collection('wishlist');
    // add the new wishlist item
    final wishListQuery = await wishListReference.where('productId', isEqualTo: product.id)
        .get(GetOptions(source: Source.serverAndCache));
    final wishListDocs = wishListQuery.docs;
    // only add the item if it does not exist in the wishlist
    if(!wishListDocs.isEmpty){
      isInWishList = true;
    }
    return isInWishList;
  }
}
