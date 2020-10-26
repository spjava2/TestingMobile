import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:e_shop/Counters/cartitemcounter.dart';
import 'package:e_shop/Store/cart.dart';
import 'package:e_shop/Store/product_page.dart';
import 'package:e_shop/Widgets/loadingWidget.dart';
import 'package:e_shop/Widgets/myDrawer.dart';
import 'package:e_shop/Widgets/searchBox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../Models/item.dart';

double width;

class StoreHome extends StatefulWidget {
  @override
  _StoreHomeState createState() => _StoreHomeState();
}

class _StoreHomeState extends State<StoreHome> {
  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: new BoxDecoration(
              gradient: new LinearGradient(
                colors: [Colors.pink, Colors.lightGreenAccent],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(1.0, 0.0),
                stops: [0.0, 1.0],
                tileMode: TileMode.clamp,
              ),
            ),
          ),
          title: Text(
            "e-shop",
            style: TextStyle(
                fontSize: 55.0, color: Colors.white, fontFamily: "Signatra"),
          ),
          centerTitle: true,
          actions: [
            Stack(
              children: [
                IconButton(
                    icon: Icon(
                      Icons.shopping_cart,
                      color: Colors.pink,
                    ),
                    onPressed: () {
                      Route route =
                          MaterialPageRoute(builder: (c) => CartPage());
                      Navigator.pushReplacement(context, route);
                    }),
                Positioned(
                  child: Stack(
                    children: [
                      Icon(Icons.brightness_1, size: 20.0, color: Colors.green),
                      Positioned(
                          top: 3.0,
                          bottom: 4.0,
                          left: 4.0,
                          child: Consumer<CartItemCounter>(
                            builder: (context, counter, _) {
                              return Text(
                                counter.count.toString(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w500),
                              );
                            },
                          ))
                    ],
                  ),
                ),
              ],
            )
          ],
        ),
        drawer: MyDrawer(),
        body: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              delegate: SearchBoxDelegate(),
              pinned: true,
            ),
            StreamBuilder<QuerySnapshot>(
              stream: Firestore.instance
                  .collection("items")
                  .orderBy("publishedDate", descending: true)
                  .snapshots(),
              builder: (context, datasnapshot) {
                return !datasnapshot.hasData
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: circularProgress(),
                        ),
                      )
                    : SliverStaggeredGrid.countBuilder(
                        crossAxisCount: 1,
                        staggeredTileBuilder: (c) => StaggeredTile.fit(1),
                        itemBuilder: (context, index) {
                          ItemModel itemModel = ItemModel.fromJson(
                              datasnapshot.data.documents[index].data);
                          return sourceInfo(itemModel, context);
                        },
                        itemCount: datasnapshot.data.documents.length,
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}

Widget sourceInfo(ItemModel model, BuildContext context,
    {Color background, removeCartFunction}) {
  return InkWell(
    onTap: () {
      Route route =
          MaterialPageRoute(builder: (c) => ProductPage(itemModel: model));
      Navigator.pushReplacement(context, route);
    },
    splashColor: Colors.pink,
    child: Padding(
      padding: EdgeInsets.all(6.0),
      child: Container(
        height: 190.0,
        width: width,
        child: Row(
          children: [
            Image.network(
              model.thumbnailUrl,
              width: 140.0,
              height: 140.0,
            ),
            SizedBox(
              width: 4.0,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 15.0,
                  ),
                  Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Text(
                            model.title,
                            style:
                                TextStyle(color: Colors.black, fontSize: 14.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Text(
                            model.shortInfo,
                            style: TextStyle(
                                color: Colors.black54, fontSize: 12.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.pink,
                        ),
                        alignment: Alignment.topLeft,
                        width: 40.0,
                        height: 43.0,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "50%",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 15.0,
                                ),
                              ),
                              Text(
                                "OFF",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 0.0),
                            child: Row(
                              children: [
                                Text(
                                  r"Original Price: $ ",
                                  style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough),
                                ),
                                Text(
                                  (model.price + model.price).toString(),
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      color: Colors.grey,
                                      decoration: TextDecoration.lineThrough),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 0.0),
                            child: Row(
                              children: [
                                Text(
                                  r"New Price: $ ",
                                  style: TextStyle(
                                      fontSize: 14.0, color: Colors.grey),
                                ),
                                Text(
                                  r"$ ",
                                  style: TextStyle(
                                      color: Colors.red, fontSize: 16.0),
                                ),
                                Text(
                                  (model.price).toString(),
                                  style: TextStyle(
                                      fontSize: 16.0, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Flexible(
                    child: Container(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget card({Color primaryColor = Colors.redAccent, String imgPath}) {
  return Container();
}

void checkItemInCart(String productID, BuildContext context) {}
