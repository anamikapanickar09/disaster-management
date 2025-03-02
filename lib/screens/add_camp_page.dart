import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class AddCampPage extends StatefulWidget {
  const AddCampPage({super.key});

  @override
  _AddCampPageState createState() => _AddCampPageState();
}

class _AddCampPageState extends State<AddCampPage> {
  final TextEditingController _campNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> _addCamp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await FirebaseFirestore.instance.collection('camps').add({
      'name': _campNameController.text,
      'location': _locationController.text,
      'capacity': int.tryParse(_capacityController.text) ?? 0,
      'contact': _contactController.text,
      'timestamp': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Camp added successfully')),
    );
    Navigator.pop(context);
  }

  Future<List<String>> _getLocationSuggestions(String query) async {
    List<String> locations = [
      "Relief Camp 1",
      "Disaster Relief Zone",
      "Temporary Shelter 3",
    ];
    return locations
        .where(
            (location) => location.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Camp Details"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _campNameController,
                decoration: const InputDecoration(labelText: "Camp Name"),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a camp name' : null,
              ),
              const SizedBox(height: 10),
              TypeAheadFormField<String>(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: "Location"),
                ),
                suggestionsCallback: (pattern) async {
                  return await _getLocationSuggestions(pattern);
                },
                itemBuilder: (context, String suggestion) {
                  return ListTile(title: Text(suggestion));
                },
                onSuggestionSelected: (String suggestion) {
                  _locationController.text = suggestion;
                },
                validator: (value) =>
                    value!.isEmpty ? 'Please enter or select a location' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Capacity"),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter capacity' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: "Contact Number"),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a contact number' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addCamp,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text("Save Camp"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
