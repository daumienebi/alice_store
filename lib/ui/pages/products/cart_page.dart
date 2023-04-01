import 'package:alice_store/models/cart_item_model.dart';
import 'package:alice_store/provider/auth_provider.dart';
import 'package:alice_store/provider/cart_provider.dart';
import 'package:alice_store/ui/pages/pages.dart';
import 'package:alice_store/utils/navigator_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItemModel> cartItems = [];
  @override
  Widget build(BuildContext context) {
    CartProvider provider = Provider.of<CartProvider>(context, listen: true);
    cartItems = provider.getCartItems;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(bottom: 5),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: bodyContent(provider)
            ),
          ),
        ),
      ),
    );
  }

  /// List of widget to decide the content that will be displayed depending
  /// on if the user is authenticated or if the cart is empty
  List<Widget> bodyContent(CartProvider provider){
    bool userIsAuthenticated = Provider.of<AuthProvider>(context).userIsAuthenticated;
    List<Widget> widgets =  [];

    // item to be returned if the cart is empty
    if(cartItems.isEmpty && userIsAuthenticated){
      widgets.add(
          Center(
        child: Column(
          children: [
            Lottie.asset(
              'assets/lottie_animations/empty-cart.json',
            ),
            const Text('There are no items in the cart',
                style: TextStyle(fontSize: 15))
          ],
        ),
      ));
    }

    // widget to be returned if the user is not authenticated
    if(!userIsAuthenticated){
      widgets.add(
          Container(
        child: Center(
          child: Column(
            children: [
              LottieBuilder.asset(
                'assets/lottie_animations/auth.json',
                repeat: false,
              ),
              Text('Sign In to access your cart if you already have an account, or Sign Up to create a new account in few seconds',
                style: TextStyle(fontSize: 17),textAlign: TextAlign.center),
              SizedBox(height: 10),
              TextButton(
                onPressed: (){
                  Navigator.of(context).pop();
                  Navigator.of(context).push(NavigatorUtil.createRouteWithSlideAnimation(newPage: SignInPage()));
                },
                child: Text('Sign In',style: TextStyle(color: Colors.black87),),
                style: TextButton.styleFrom(backgroundColor: Colors.greenAccent,fixedSize: Size(200,60)),
              ),
              SizedBox(height: 10),
              TextButton(
                  onPressed: (){
                    Navigator.of(context).pop();
                    Navigator.of(context).push(NavigatorUtil.createRouteWithSlideAnimation(newPage: SignUpPage()));
                  },
                  child: Text('Sign Up',style: TextStyle(color: Colors.white),),
                  style: TextButton.styleFrom(backgroundColor: Colors.black87,fixedSize: Size(200,60))
              )
            ],
          ),
        ),
      ));
    }

    if(userIsAuthenticated){
      widgets.add(
        Expanded(
          child: ListView.builder(
            itemBuilder: (BuildContext context, index) {
              return cartItemContainer(cartItems[index],provider);
            },
            itemCount: cartItems.length,
          ),
        ),
      );
      widgets.add(cartItems.isEmpty ? Container() : _payNowWidget(provider));
    }
    return widgets;
  }

  /// Widget to represent each cart item
  Widget cartItemContainer(CartItemModel cartItem,CartProvider provider){
    // split the price in two texts to apply a different
    // style
    String price1,price2 = '';
    var split = cartItem.product.price.toString().split('.');
    price1 = split[0];
    price2 = split[1];
    // product item
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
            NavigatorUtil.createRouteWithSlideAnimation(
                newPage: ProductDetailPage(product : cartItem.product),
                arguments: cartItem.product));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
              color: Colors.white54,
              borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              CachedNetworkImage(
                placeholder: ((context, url) =>
                    Image.asset('assets/gifs/loading.gif')),
                imageUrl: cartItem.product.image,
                height: 120,
                width: 100,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      cartItem.product.name,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Text(
                          price1,
                          style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '.$price2€',
                          style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 15),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Quantity : ${cartItem.quantity}',
                      style: TextStyle(
                          color: Colors.black54,
                          fontSize: 15),
                    ),
                    TextButton(
                        onPressed: () => provider
                            .removeItem(cartItem
                            .product
                            .id),
                        style: TextButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(
                                    10))),
                        child: Text(
                          'Remove item',
                          style: TextStyle(
                              color: Colors.redAccent[200]),
                        ))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _payNowWidget(CartProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15), color: Colors.green[500]),
        height: 85,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Price',
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.white70,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  '${provider.getTotalPrice} €',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 23),
                )
              ],
            ),
            InkWell(
              onTap: () => Navigator.of(context).push(
                  NavigatorUtil.createRouteWithSlideAnimation(
                      newPage: const PaymentPage())),
              child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(color: Colors.white70)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Pay now',
                        style: TextStyle(color: Colors.white),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_sharp,
                        size: 15,
                        color: Colors.white,
                      )
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }
}
