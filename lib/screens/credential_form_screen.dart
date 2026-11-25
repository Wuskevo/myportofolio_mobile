import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

class CredentialFormPage extends StatefulWidget {
  const CredentialFormPage({super.key});

  @override
  State<CredentialFormPage> createState() => _CredentialFormState();
}

class _CredentialFormState extends State<CredentialFormPage> {
  final _formKey = GlobalKey<FormState>();

  String _title = "";
  String _description = "";
  String _category = "Certification"; // default
  String _issuer = "";
  DateTime _dateReceived = DateTime.now();
  DateTime? _expiryDate;
  String _credentialUrl = "";
  String? _image;

  final List<String> _categories = [
    'Certification',
    'Award',
    'Competition',
    'Scholarship',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Add Credential Form')),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Credential Title ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Credential Title",
                    labelText: "Credential Title",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _title = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Enter a credential title.";
                    }
                    return null;
                  },
                ),
              ),

              // === Description ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Credential Description",
                    labelText: "Credential Description",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _description = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Enter a credential description.";
                    }
                    return null;
                  },
                ),
              ),

              // === Category ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Credential Category",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  initialValue: _category,
                  items: _categories
                      .map(
                        (category) => DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _category = newValue!;
                    });
                  },
                ),
              ),

              // === Issuer ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Credential Issuer",
                    labelText: "Credential Issuer",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _issuer = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Enter an issuer.";
                    }
                    return null;
                  },
                ),
              ),

              // === Credential Receival Date ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InputDatePickerFormField(
                  firstDate: DateTime(2007),
                  lastDate: DateTime(2126),
                  onDateSubmitted: (DateTime? value) {
                    setState(() {
                      _dateReceived = value!;
                    });
                  },
                ),
              ),

              // === Credential Expiry Date ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: InputDatePickerFormField(
                  firstDate: DateTime(2007),
                  lastDate: DateTime(2126),

                  onDateSubmitted: (DateTime? value) {
                    setState(() {
                      if (value == null) {
                        _expiryDate = value;
                      } else if (value.isAfter(_dateReceived)) {
                        _expiryDate = value;
                      } else {
                        _expiryDate = _dateReceived;
                      }
                    });
                  },
                ),
              ),

              // === Credential URL ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Credential URL",
                    labelText: "Credential URL",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _credentialUrl = value!;
                    });
                  },
                ),
              ),

              // === Credential Image URL ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Credential Image URL (optional)",
                    labelText: "Credential Image Link",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _image = value!;
                    });
                  },
                ),
              ),

              // === Save Button ===
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.indigo),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text(
                                'Credential added successfully!',
                              ),
                              content: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Title: $_title'),
                                    Text('Description: $_description'),
                                    Text('Category: $_category'),
                                    Text('Issuer: $_issuer'),
                                    Text('Date received: $_dateReceived'),
                                    Text('Expiry Date: $_expiryDate'),
                                    Text('URL: $_credentialUrl'),
                                    Text('Image URL: $_image'),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _formKey.currentState!.reset();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                    child: const Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
