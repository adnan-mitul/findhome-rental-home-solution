import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_home/home_pages/home_details_page.dart';
import 'package:flutter/material.dart';
import 'package:velocity_x/velocity_x.dart';
import 'offer_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _selectedFilter;

  Future<List<Map<String, dynamic>>> _fetchHomes() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('homes').get();
    return querySnapshot.docs
        .map((doc) => {
              'imagePath': doc['images'][0],
              'houseType': doc['houseType'],
              'location': doc['location'],
              'bedrooms': (doc['bedrooms'] as num).toInt(),
              'bathrooms': (doc['bathrooms'] as num).toInt(),
              'balconies': (doc['balconies'] as num).toInt(),
              'description': doc['description'],
              'price': (doc['price'] as num).toInt(),
            })
        .toList();
  }

  List<Map<String, dynamic>> _sortHomes(List<Map<String, dynamic>> homes) {
    if (_selectedFilter == 'Low to High') {
      homes.sort((a, b) => a['price'].compareTo(b['price']));
    } else if (_selectedFilter == 'High to Low') {
      homes.sort((a, b) => b['price'].compareTo(a['price']));
    }
    return homes;
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Filter',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          DropdownButton<String>(
            hint: const Text('Select Price'),
            value: _selectedFilter,
            items: <String>['Low to High', 'High to Low'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _selectedFilter = newValue;
              });
            },
            underline: Container(
              height: 2,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(12),
        color: Colors.grey.shade200,
        child: SafeArea(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchHomes(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No homes found'));
              }

              final offerHouselist = snapshot.data!;
              final sortedHomes = _sortHomes(offerHouselist);

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterRow(),
                    VxSwiper.builder(
                      aspectRatio: 16 / 10,
                      autoPlay: true,
                      height: 150,
                      enlargeCenterPage: true,
                      itemCount: limitedOffres.length,
                      itemBuilder: (context, index) {
                        final item = limitedOffres[index];
                        return GestureDetector(
                          onTap: () {},
                          child: Image.asset(
                            item['imagePath'],
                            fit: BoxFit.contain,
                          )
                              .box
                              .rounded
                              .clip(Clip.antiAlias)
                              .margin(const EdgeInsets.symmetric(horizontal: 8))
                              .make(),
                        );
                      },
                    ),
                    20.heightBox,
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: sortedHomes.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        mainAxisExtent: 300,
                      ),
                      itemBuilder: (context, index) {
                        final item = sortedHomes[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailsPage(
                                  imagePath: item['imagePath'],
                                  name: item['houseType'],
                                  location: item['location'],
                                  bedrooms: item['bedrooms'],
                                  bathrooms: item['bathrooms'],
                                  balconies: item['balconies'],
                                  description: item['description'],
                                  price: item['price'],
                                ),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              Image.network(
                                item['imagePath'],
                                height: 200,
                                width: 200,
                                fit: BoxFit.cover,
                              ),
                              const Spacer(),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Text(
                                    item['houseType'],
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              2.heightBox,
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Text(
                                    item['location'],
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                              15.heightBox,
                            ],
                          ).box.white.roundedSM.outerShadowSm.make(),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
