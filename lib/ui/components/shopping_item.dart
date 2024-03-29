import 'package:alice_store/models/cart_item_model.dart';
import 'package:alice_store/models/product_model.dart';
import 'package:alice_store/provider/auth_provider.dart';
import 'package:alice_store/provider/cart_provider.dart';
import 'package:alice_store/provider/product_provider.dart';
import 'package:alice_store/provider/wishlist_provider.dart';
import 'package:alice_store/ui/components/dialogs.dart';
import 'package:alice_store/utils/navigator_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/pages.dart';

class ShoppingItem extends StatelessWidget {
  final ProductModel product;
  final bool showSimilarProductButton;
  const ShoppingItem({Key? key, required this.product,
    required this.showSimilarProductButton}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String part1 = '';
    String part2 = '';
    var splitValue = product.price.toString().split('.');
    part1 = splitValue[0];
    part2 = splitValue[1];
    return GestureDetector(
        onTap: () => Navigator.of(context).push(NavigatorUtil.createRouteWithSlideAnimation(
            arguments: product, newPage: ProductDetailPage(product: product))),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            // Set a different shade of white depending if this widget will be
            // viewed from the SimilarProductPage or shoppingPage
              color: showSimilarProductButton ? Colors.white : Colors.white70,
              borderRadius: BorderRadius.circular(15)
          ),
          //Main column for the whole content
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    CachedNetworkImage(
                      placeholder: ((context, url) =>
                          Image.asset('assets/gifs/loading.gif')),
                      imageUrl: product.image,
                      alignment: Alignment.centerLeft,
                      height: 120,
                      width: 100,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(
                                fontSize: 20, overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              Text(
                                part1,
                                style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '.$part2€',
                                style: const TextStyle(
                                    color: Colors.black54, fontSize: 15),
                              )
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            product.description,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // the similar product button needs to be hidden then
                          // use a Space to push the two buttons to the end of Column
                          showSimilarProductButton ? const SizedBox() : const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //Add/Remove from wishlist icon
                              wishListIconButton(product, context),
                              //Add/remove from cart icon
                              addToCartButton(product, context)
                            ],
                          ),
                          //View Similar products button
                          //Show the button if the bool values is set to 'true',
                          //else return an empty SizedBox
                          showSimilarProductButton ?
                          Expanded(
                            child: SizedBox(
                              //use the available width
                              width: double.infinity,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                      NavigatorUtil.createRouteWithFadeAnimation(
                                        //Pass the categoryId to fetch products of the
                                        //same category
                                          newPage: SimilarProductsPage(
                                            categoryId: product.categoryId
                                          )
                                      )
                                  );
                                },
                                style: TextButton.styleFrom(
                                    backgroundColor: Colors.blueGrey[500],
                                    shape: StadiumBorder(),
                                ),
                                child: const Text(
                                  'View similar items',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ) : const SizedBox(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Future<bool> checkIfProductIsInWishList(String userId,BuildContext context, ProductModel product) async {
    WishListProvider provider = Provider.of<WishListProvider>(context, listen: false);
    bool isInWishList = await provider.isInWishList(userId, product);
    return isInWishList;
  }

  /// Displays the corresponding icon depending on if the product is available
  /// in the wish list or not
  Widget wishListIconButton(ProductModel product, BuildContext context) {
    WishListProvider provider = Provider.of<WishListProvider>(context, listen: true);
    String userId = '';
    if(Provider.of<AuthProvider>(context,listen: false).userIsAuthenticated){
      userId = Provider.of<AuthProvider>(context,listen: false).currentUser!.uid.toString();
    }
    return FutureBuilder<bool>(
      future: checkIfProductIsInWishList(userId,context, product),
      builder: (context, snapshot) {
        bool isInWishList = snapshot.data ?? false;

        //Possible Icons
        var addToFavIcon = Icon(
          Icons.favorite_border,
          color: Colors.black54,
          size: 35,
        );
        var removeFromFavIcon = Icon(
          Icons.favorite_rounded,
          color: Colors.cyan[300],
          size: 35,
        );

        SnackBar snackBar;
        return IconButton(
            onPressed: () {
              //check if the user is signed in to test
              if(Provider.of<AuthProvider>(context,listen: false).userIsAuthenticated){
                String userId = Provider.of<AuthProvider>(context,listen: false).currentUser!.uid.toString();
                if (isInWishList) {
                  provider.removeFromWishList(userId,product);
                  snackBar = SnackBar(
                    backgroundColor: Colors.green[500],
                    duration: const Duration(seconds: 2),
                    //Snack bar content with the message and the view
                    //wishlist page button
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Item removed from wishlist',style: TextStyle(fontSize: 16)),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).push(NavigatorUtil.createRouteWithFadeAnimation(
                                  newPage: const WishListPage()));
                            },
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: StadiumBorder()
                            ),
                            child: const Text(
                              'View wishlist',
                              style: TextStyle(color: Colors.black87),
                            ))
                      ],
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                } else {
                  provider.addToWishList(userId,product);
                  snackBar = SnackBar(
                    backgroundColor: Colors.green[500],
                    duration: const Duration(seconds: 2),
                    //Snack bar content with the message and the view
                    //wishlist page button
                    content: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Item added to wishlist',style: TextStyle(fontSize: 16),),
                        TextButton(
                            onPressed: () {
                              Navigator.of(context).push(NavigatorUtil.createRouteWithFadeAnimation(
                                  newPage: const WishListPage()));
                            },
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.white,
                                shape: StadiumBorder()
                            ),
                            child: const Text(
                              'View wishlist',
                              style: TextStyle(color: Colors.black87),
                            ))
                      ],
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                }
              }else{
                Dialogs.authPrompt(context);
              }
            },
            icon: isInWishList ? removeFromFavIcon : addToFavIcon
        );
      },
    );
  }


  /// Add to cart button
  TextButton addToCartButton(ProductModel product, BuildContext context) {
    CartProvider cartProvider =
        Provider.of<CartProvider>(context, listen: false);
    SnackBar snackBar;
    return TextButton(
        onPressed: () {
          // only carry out the action is the user is authenticated
          if(Provider.of<AuthProvider>(context,listen: false).userIsAuthenticated){
            String userId = Provider.of<AuthProvider>(context,listen: false).currentUser!.uid.toString();
            cartProvider.addItem(userId,CartItemModel(product:product,quantity: 1));
            snackBar = SnackBar(
              backgroundColor: Colors.green[500],
              duration: Duration(seconds: 1),
              content: Text(
                'Item added to cart',
              ),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }else{
            Dialogs.authPrompt(context);
          }
        },
        style: TextButton.styleFrom(
            backgroundColor: Colors.amber[700], shape: const StadiumBorder()),
        child: const Text(
          'Add to cart',
          style: TextStyle(color: Colors.white),
        ));
  }
}
