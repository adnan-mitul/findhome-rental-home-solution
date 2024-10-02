import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddMaidPage extends StatefulWidget {
  final Function onSubmit;
  AddMaidPage({required this.onSubmit});

  @override
  _AddMaidPageState createState() => _AddMaidPageState();
}

class _AddMaidPageState extends State<AddMaidPage> {
  final TextEditingController taskController = TextEditingController();
  final TextEditingController paymentController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController interestedAreaController =
      TextEditingController();
  final TextEditingController maidNameController = TextEditingController();
  final TextEditingController maidPhoneController = TextEditingController();

  List<Map<String, String>> maidDetails = [];

  // Function to add maid data to Firestore
  Future<void> addMaidToFirestore() async {
    await FirebaseFirestore.instance.collection('maids').add({
      'task': taskController.text,
      'payment': paymentController.text,
      'location': locationController.text,
      'interestedArea': interestedAreaController.text,
      'details': maidDetails,
    });

    widget.onSubmit(); // Callback to refresh the maid data in MaidPage
    Navigator.pop(context); // Go back to the maid list
  }

  // Function to add maid details (name and phone) to the list
  void addMaidDetail() {
    setState(() {
      maidDetails.add({
        'name': maidNameController.text,
        'phone': maidPhoneController.text,
      });
      maidNameController.clear();
      maidPhoneController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Maid')),
      body: SingleChildScrollView(
        // Makes the page scrollable
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: taskController,
                decoration: const InputDecoration(labelText: 'Task'),
              ),
              TextField(
                controller: paymentController,
                decoration: const InputDecoration(labelText: 'Payment'),
              ),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(labelText: 'Location'),
              ),
              TextField(
                controller: interestedAreaController,
                decoration: const InputDecoration(labelText: 'Interested Area'),
              ),
              const SizedBox(height: 20),
              const Text('Add Maid Details'),
              TextField(
                controller: maidNameController,
                decoration: const InputDecoration(labelText: 'Maid Name'),
              ),
              TextField(
                controller: maidPhoneController,
                decoration: const InputDecoration(labelText: 'Maid Phone'),
              ),
              ElevatedButton(
                onPressed: addMaidDetail,
                child: const Text('Add Maid Detail'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: addMaidToFirestore,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
