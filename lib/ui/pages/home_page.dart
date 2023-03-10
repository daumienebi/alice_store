import 'package:alice_store/ui/pages/pages.dart';
import 'package:alice_store/ui/widgets/widgets.dart';
import 'package:alice_store/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold,color: Colors.teal);

  @override
  Widget build(BuildContext context) {

    List<Widget> widgetOptions = <Widget>[
      const Product(),
      Text(AppLocalizations.of(context)!.cart,style: optionStyle),
      const AboutProjectPage()
    ];
    return Scaffold(
      bottomNavigationBar: _bottomNavigationBar(),
      body: Padding(
        padding: const EdgeInsets.only(top: 15,left: 10,right: 10),
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Alice",
                      style: TextStyle(
                          fontSize: 40,
                          //color: Colors.white,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    CustomButton(
                      iconData: Icons.favorite_border,
                      onPressed: () => Navigator.of(context).pushNamed(
                          AppRoutes.routeStrings.favouritesPage
                      ),
                    )
                  ],
                ),
                Center(
                  child: widgetOptions.elementAt(_selectedIndex),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBar _bottomNavigationBar(){
    return BottomNavigationBar(
      iconSize: 20,
      selectedIconTheme: const IconThemeData(
        color: Colors.black87,
        size: 27
      ),
      selectedFontSize: 15,
      backgroundColor: Colors.cyan[200],
      selectedItemColor: Colors.white,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            label: AppLocalizations.of(context)!.home
        ),
        BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_cart_outlined),
            label :AppLocalizations.of(context)!.cart
        ),
        BottomNavigationBarItem(
            icon: const Icon(Icons.menu_book_sharp),
            label :AppLocalizations.of(context)!.theProject
        )
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      type: BottomNavigationBarType.fixed,

    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget shoes(){
    List<Widget> movies = [];
    for(int i = 0; i<10; i++){
      movies.add(itemCard("Zapato de prueba ${i}"));
    }
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: ListView.separated(
        itemBuilder: (context,index){
          return movies[index];
        },
        separatorBuilder: (context, index) => SizedBox(width: 10,),
        itemCount: movies.length,
        scrollDirection: Axis.horizontal,
      ),
    );
  }

  Widget itemCard(String name){
    const textStyle = TextStyle(color: Colors.white,fontSize: 17,
        overflow: TextOverflow.ellipsis);
    return SizedBox(
      width: 150,
      child: Column(
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network('https://api.lorem.space/image/shoes?w=150&h=150')
          ),
          Text(name,style: textStyle,textAlign: TextAlign.left,)
        ],
      ),
    );
  }
}

class Product extends StatelessWidget {
  const Product({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
      SizedBox(height: 200,child: itemList('https://api.lorem.space/image/shoes?w=150&h=150'),),
        SizedBox(height: 200,child: itemList('https://api.lorem.space/image/fashion?w=150&h=150'),),
        SizedBox(height: 200,child: itemList('https://api.lorem.space/image/pizza?w=150&h=150'),)
      ],
    );
  }

  Widget itemList(String apiUrl){
    List<Widget> movies = [];
    for(int i = 0; i<10; i++){
      movies.add(itemCard("Item ${i}",apiUrl));
    }

    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: ListView.separated(
        itemBuilder: (context,index){
          return movies[index];
        },
        separatorBuilder: (context, index) => SizedBox(width: 10,),
        itemCount: movies.length,
        scrollDirection: Axis.horizontal,
      ),
    );
  }

  Widget itemCard(String name,String apiUrl){
    const textStyle = TextStyle(color: Colors.black,fontSize: 17,
        overflow: TextOverflow.ellipsis);
    return SizedBox(
      width: 150,
      child: Column(
        //crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(apiUrl)
          ),
          Text(name,style: textStyle,textAlign: TextAlign.left,)
        ],
      ),
    );
  }
}
