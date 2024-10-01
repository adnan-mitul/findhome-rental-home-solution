import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:find_home/catagories_pages/add_helping_hand.dart';
import 'package:flutter/material.dart';

class MaidPage extends StatefulWidget {
  const MaidPage({Key? key}) : super(key: key);

  @override
  _MaidPageState createState() => _MaidPageState();
}

class _MaidPageState extends State<MaidPage> {
  List<Map<String, dynamic>> maidCategories = [];
  bool isLoading = true; // For showing a loading spinner

  // Function to fetch maid data from Firestore
  Future<void> fetchMaidData() async {
    try {
      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('maids').get();

      setState(() {
        maidCategories = querySnapshot.docs.map((doc) {
          return {
            'task': doc['task'],
            'payment': doc['payment'],
            'location': doc['location'],
            'interestedArea': doc['interestedArea'],
            'details': List<Map<String, String>>.from(
                doc['details'] ?? []), // Handle null cases
          };
        }).toList();
        isLoading = false;
      });

      // Print fetched data for debugging
      print(maidCategories);
    } catch (e) {
      // Handle the error and print it for debugging
      print("Error fetching data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchMaidData(); // Fetch maid data on initialization
  }

  // Refresh maid data after a new maid is added
  void refreshMaidData() {
    setState(() {
      isLoading = true;
    });
    fetchMaidData();
  }

  // Function to display maid details in a bottom sheet
  void _showMaidDetails(
      BuildContext context, String task, List<Map<String, String>> details) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Available Maids for $task',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...details.map((maid) {
                return ListTile(
                  title: Text(maid['name']!),
                  subtitle: Text('Phone: ${maid['phone']}'),
                  leading: const Icon(Icons.person),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maid Services'),
        backgroundColor: Colors.cyan,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Loading state
          : maidCategories.isEmpty
              ? const Center(child: Text("No maids available")) // No data state
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.cyan.shade50,
                  ),
                  child: ListView.builder(
                    itemCount: maidCategories.length,
                    itemBuilder: (context, index) {
                      final category = maidCategories[index];
                      return Card(
                        margin: const EdgeInsets.all(10),
                        elevation: 4,
                        child: ListTile(
                          title: Text(
                            category['task'],
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Payment: ${category['payment']} \nLocation: ${category['location']} \nInterested Area: ${category['interestedArea']}',
                          ),
                          trailing: const Icon(Icons.arrow_forward),
                          onTap: () {
                            _showMaidDetails(
                                context, category['task'], category['details']);
                          },
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddMaidPage(onSubmit: refreshMaidData)),
          );
        },
      ),
    );
  }
}
