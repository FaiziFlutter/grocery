import 'dart:convert';
import 'package:grocery/models/grocery_item.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:grocery/data/categories.dart';
import 'package:grocery/models/category.dart';
import '../type_defines/types_defines.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var enteredName = '';
  var _quantity = 1;
  var _category = categories[Categories.vegetables];
  bool isSending = false;

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isSending = true;
      });

      final url = Uri.https(
          'first-62bb1-default-rtdb.firebaseio.com', 'shopping-cart.json');
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode(
          {
            'name': enteredName,
            'quantity': _quantity,
            'category': _category!.name,
          },
        ),
      );
      MapOfStringAndDynamic data = json.decode(response.body);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(
        GroceryItem(
            id: data['name'],
            name: enteredName,
            quantity: _quantity,
            category: _category!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  label: Text('Name'),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length > 50 ||
                      value.trim().length <= 1) {
                    return 'Fields should be between 1 to 50';
                  }
                  return null;
                },
                onSaved: (newValue) {
                  enteredName = newValue!;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      initialValue: _quantity.toString(),
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.parse(value) < 1) {
                          return 'Must be a valid, positive number';
                        }
                        return null;
                      },
                      onSaved: (newValue) {
                        _quantity = int.parse(newValue!);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _category,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  color: category.value.color,
                                ),
                                const SizedBox(
                                  width: 6,
                                ),
                                Text(category.value.name)
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _category = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  TextButton(
                    onPressed:
                        isSending ? null : () => _formKey.currentState!.reset(),
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: isSending ? null : _saveItem,
                    child: isSending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
