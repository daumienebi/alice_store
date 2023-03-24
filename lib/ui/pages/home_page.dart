import 'package:alice_store/models/category.dart';
import 'package:alice_store/provider/cart_provider.dart';
import 'package:alice_store/services/category_service.dart';
import 'package:alice_store/ui/widgets/product_search_delegate.dart';
import 'package:badges/badges.dart' as badges;
import 'package:alice_store/ui/pages/pages.dart';
import 'package:alice_store/ui/widgets/widgets.dart';
import 'package:alice_store/utils/app_routes.dart';
import 'package:alice_store/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Category>> fetchCategoriesFuture;
  int _selectedIndex = 0;
  final CategoryService categoryService = CategoryService();

  Future<List<Category>> fetchAllCategories() async {
    List<Category> categories = await categoryService.fetchAllCategories();
    return Future.delayed(const Duration(seconds: 2),()=> categories);
  }

  @override
  void initState() {
    super.initState();
    fetchCategoriesFuture = fetchAllCategories();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> widgetOptions = <Widget>[
      categoriesFutureBuilder(),
      const ShoppingPage(),
      const CartPage(),
      const AboutProjectPage()
    ];
    return Scaffold(
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              backgroundColor: Colors.white,
              child: const Icon(Icons.share_sharp, color: Colors.black),
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        height: 110,
                        color: Colors.white,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text(
                                'Compartir la app',
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 20),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              Expanded(
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: socialMediaButtons(context),
                                ),
                              ),
                            ]),
                      );
                    });
              },
            )
          : Container(),
      drawer: const Drawer(
        child: DrawerPage(),
      ),
      appBar: AppBar(
        title: Text(
            "A L I C E S T O R E",
            style: GoogleFonts.albertSans(
              color: Colors.black,
              fontSize: 20,
            )
        ),
        centerTitle: true,
        backgroundColor: Colors.cyan[100],
        //systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
        // Need to use a Builder to obtain the context, if not it throws an
        // error
        leading: Builder(
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.only(left: 10, top: 10),
              child: CustomButton(
                  iconData: Icons.menu,
                  onPressed: Scaffold.of(context).openDrawer),
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10, top: 10),
            child: CustomButton(
              iconData: Icons.search,
              onPressed: (){
                showSearch(
                    context: context,
                    delegate:
                    ProductSearchDelegate(hintText: 'Search products'));
              },
            ),
          )
        ],
      ),
      bottomNavigationBar: _bottomNavigationBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _selectedIndex == 0
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Text(
                            getGreetingText(),
                            style: const TextStyle(fontSize: 19),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(
                            bottom: 40,
                          ),
                          child: Text(
                            'Desliza para explorar las categorías',
                            style:
                                TextStyle(fontSize: 17, color: Colors.black54),
                          ),
                        ),
                      ],
                    )
                  : Container(),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.80,
                child: Center(
                  child: widgetOptions[_selectedIndex],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBar _bottomNavigationBar() {
    return BottomNavigationBar(
      iconSize: 25,
      selectedIconTheme: const IconThemeData(color: Colors.lightBlue, size: 27),
      showSelectedLabels: true,
      unselectedIconTheme: const IconThemeData(color: Colors.grey),
      selectedFontSize: 17,
      backgroundColor: Colors.cyan[200],
      selectedItemColor: Colors.black,
      items: <BottomNavigationBarItem>[
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Inicio',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_outlined),
          label: 'Tienda',
        ),
        BottomNavigationBarItem(
            icon: badges.Badge(
              badgeContent: Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  int productCount = cartProvider.getProducts.length;
                  return Text(
                    productCount <= 9 ? productCount.toString() : '9+',
                    style: const TextStyle(color: Colors.white),
                  );
                },
              ),
              position: badges.BadgePosition.topEnd(top: -18),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            label: AppLocalizations.of(context)!.cart
        ),
        BottomNavigationBarItem(
            icon: const Icon(Icons.work_outline),
            label: AppLocalizations.of(context)!.theProject
        )
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.shifting,
      //selectedLabelStyle: TextStyle(color: Colors.black),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// List of the [SocialMedia] buttons
  List<Widget> socialMediaButtons(context) {
    //Very shitty work around
    // TODO : Change it later on
    List<Widget> items = [];
    items.add(const SizedBox(
      width: 10,
    ));
    items.add(socialButton(
        socialMedia: SocialMedia.Whatsapp.name,
        icon: const Icon(
          FontAwesomeIcons.whatsapp,
          color: Colors.green,
          size: 40,
        ),
        onClicked: () {
          Navigator.pop(context);
          share(SocialMedia.Whatsapp, context);
        }));
    items.add(const SizedBox(
      width: 15,
    ));
    items.add(socialButton(
        socialMedia: SocialMedia.Twitter.name,
        icon: const Icon(
          FontAwesomeIcons.twitter,
          color: Colors.lightBlueAccent,
          size: 40,
        ),
        onClicked: () {
          Navigator.pop(context);
          share(SocialMedia.Twitter, context);
        }));
    items.add(const SizedBox(
      width: 15,
    ));
    items.add(socialButton(
        socialMedia: SocialMedia.Facebook.name,
        icon: const Icon(
          FontAwesomeIcons.facebook,
          color: Colors.indigo,
          size: 40,
        ),
        onClicked: () {
          Navigator.pop(context);
          share(SocialMedia.Facebook, context);
        }));
    items.add(const SizedBox(
      width: 15,
    ));
    items.add(socialButton(
        socialMedia: 'Copiar Enlace',
        icon: const Icon(
          Icons.copy,
          color: Colors.grey,
          size: 40,
        ),
        onClicked: () async {
          String appId = Constants.playStoreId;
          final urlString =
              'https://play.google.com/store/apps/details?id=$appId';
          await Clipboard.setData(ClipboardData(text: urlString));
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Enlace copiado !'),
              duration: Duration(seconds: 2)));
        }));
    return items;
  }

  /// [SocialMedia] button
  Widget socialButton({required String socialMedia,required Icon icon,
      Function()? onClicked}) {
    const listTextStyle = TextStyle(color: Colors.black54);
    return Column(
      children: [
        InkWell(
          onTap: onClicked,
          child: icon,
        ),
        Text(
          socialMedia,
          style: listTextStyle,
        ),
      ],
    );
  }

  /// FutureBuilder for the [Category] card swiper, it returns the available
  /// categories or an error depending on the response
  FutureBuilder categoriesFutureBuilder() {
    //Try to use setState to rebuild the widget
    return FutureBuilder(
      future: fetchCategoriesFuture,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            //mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 50,
                width: 100,
                child: LoadingIndicator(
                  indicatorType: Indicator.ballPulseRise,
                  colors: Constants.loadingIndicatorColors,
                ),
              ),
              const SizedBox(height: 10),
              const Text('Cargando categorias...')
            ],
          );
        }
        // On error
        if (snapshot.hasError) {
          return Column(
            children: [Text(snapshot.error.toString())],
          );
        }
        if (snapshot.hasData && snapshot.data.length > 1) {
          return CategoryCardSwiper(categories: snapshot.data);
        }
        //When there is no data or server error
        return Column(
          children: [
            Lottie.asset(
              'assets/lottie_animations/error.json',
            ),
            const Text(
              'Servidor indisponible.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 17,
                  color: Colors.red,
                  fontWeight: FontWeight.bold
              ),
            ),
            const Text('Asegurese de disponer de conexión a internet.'),
            const SizedBox(height: 5),
            ElevatedButton(
              onPressed: (){
                setState(() {
                  fetchCategoriesFuture = fetchAllCategories();
                });
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  fixedSize: const Size(150,50)
              ),
              child: const Text(
                  'Reintentar',
                  style: TextStyle(color: Colors.black87,
                      fontSize:16
                  )
              ),
            )
          ],
        );
      },
    );
  }

  /// Get the greeting text depending on the time of the day
  String getGreetingText() {
    String greetingsText = ' ';
    final DateTime now = DateTime.now();
    final format = DateFormat.jm();
    String formattedString = format.format(now);
    if (formattedString.endsWith('AM')) {
      greetingsText = 'Buenos días,';
      //greetingsText = AppLocalizations.of(context)!.goodMorning;

      //Example of a formattedString could be 6:54 PM, so we split the string
      //to get the item at the first index and compare if its past 8 o'clock
    } else if (formattedString.endsWith('PM') &&
        int.parse(formattedString.split(":")[0]) > 8) {
      greetingsText = 'Buenas noches,';
      //greetingsText = AppLocalizations.of(context)!.goodNight;
    } else {
      greetingsText = 'Buenas tardes,';
      //greetingsText = AppLocalizations.of(context)!.goodEvening;
    }
    return greetingsText;
  }

  /// Method to launch each share option for the [SocialMedia]
  Future share(SocialMedia platform, BuildContext context) async {
    String text = 'Descarga esta app (Fix the text)';
    String appId = Constants.playStoreId;
    final urlString = 'https://play.google.com/store/apps/details?id=$appId';
    final urlShare = Uri.encodeComponent(urlString);
    final urls = {
      SocialMedia.Facebook:
          'https://www.facebook.com/sharer/sharer.php?u=$urlShare&t=$text',
      SocialMedia.Twitter:
          'https://twitter.com/intent/tweet?url=$urlShare&text=$text',
      SocialMedia.Whatsapp:
          'https://api.whatsapp.com/send?text=$text $urlShare',
    };
    final url = Uri.parse(urls[platform]!);
    await launchUrl(url, mode: LaunchMode.externalApplication);
  }

}