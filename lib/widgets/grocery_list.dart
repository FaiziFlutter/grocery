import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../data/categories.dart';
import '../models/grocery_item.dart';
import '../type_defines/types_defines.dart';
import 'new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  ListOfGrocery _groceryItems = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    try {
      final url = Uri.https(
          'first-62bb1-default-rtdb.firebaseio.com', 'shopping-cart.json');

      final response = await http.get(url);

      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data. Please try again later.';
          _isLoading = false;
        });
      }
      if (response.body == "null") {
        setState(() {
          _isLoading = false;
        });
        return;
      }
      final MapOfStringAndDynamic decodedData = json.decode(response.body);

      final ListOfGrocery listData = [];
      for (final item in decodedData.entries) {
        final category = categories.entries.firstWhere(
          (element) {
            return element.value.name == item.value['category'];
          },
        ).value;

        listData.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }
      setState(() {
        _groceryItems = listData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Something went Wrong! Please try again later.';
      });
    }
  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );
    _loadItems();
    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.https('first-62bb1-default-rtdb.firebaseio.com',
        'shopping-cart/${item.id}.json');
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _groceryItems.insert(index, item);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text('No items added yet.'));
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]);
          },
          key: ValueKey(_groceryItems[index].id),
          child: ListTile(
            title: Text(_groceryItems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(
              _groceryItems[index].quantity.toString(),
            ),
          ),
        ),
      );
    }
    if (_error != null) {
      content = Center(child: Text(_error!));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: content,
    );
  }
}
/*
----------------------------------------------------------------------------------------------------------------

--------=-------Below is the exact same functionality but with the help of future builder. But there we
cannot handle the functionality of remove and save. So this widget is not such a help for this specific 
application but it can be useful in many aspects. ------------------------------

----------------------------------------------------------------------------------------------------------------

*/

// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import '../data/categories.dart';
// import '../models/grocery_item.dart';
// import '../type_defines/types_defines.dart';
// import 'new_item.dart';

// class GroceryList extends StatefulWidget {
//   const GroceryList({super.key});

//   @override
//   State<GroceryList> createState() => _GroceryListState();
// }

// class _GroceryListState extends State<GroceryList> {
//   final ListOfGrocery _groceryItems = [];
//   late Future<ListOfGrocery> loadedItems;

//   @override
//   void initState() {
//     super.initState();
//     loadedItems = _loadItems();
//   }

//   Future<ListOfGrocery> _loadItems() async {
//     final url = Uri.https(
//         'first-62bb1-default-rtdb.firebaseio.com', 'shopping-cart.json');

//     final response = await http.get(url);

//     if (response.statusCode >= 400) {
//       Exception('Failed to fetch data. Please try again later.');
//     }
//     if (response.body == "null") {
//       return [];
//     }
//     final MapOfStringAndDynamic decodedData = json.decode(response.body);

//     final ListOfGrocery listData = [];
//     for (final item in decodedData.entries) {
//       final category = categories.entries.firstWhere(
//         (element) {
//           return element.value.name == item.value['category'];
//         },
//       ).value;

//       listData.add(
//         GroceryItem(
//           id: item.key,
//           name: item.value['name'],
//           quantity: item.value['quantity'],
//           category: category,
//         ),
//       );
//     }
//     return listData;
//   }

//   void _addItem() async {
//     final newItem = await Navigator.of(context).push<GroceryItem>(
//       MaterialPageRoute(
//         builder: (ctx) => const NewItem(),
//       ),
//     );
//     _loadItems();
//     if (newItem == null) {
//       return;
//     }

//     setState(() {
//       _groceryItems.add(newItem);
//     });
//   }

//   void _removeItem(GroceryItem item) async {
//     final index = _groceryItems.indexOf(item);
//     setState(() {
//       _groceryItems.remove(item);
//     });
//     final url = Uri.https('first-62bb1-default-rtdb.firebaseio.com',
//         'shopping-cart/${item.id}.json');
//     final response = await http.delete(url);
//     if (response.statusCode >= 400) {
//       _groceryItems.insert(index, item);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Your Groceries'),
//         actions: [
//           IconButton(
//             onPressed: _addItem,
//             icon: const Icon(Icons.add),
//           ),
//         ],
//       ),
//       body: FutureBuilder(
//         future: loadedItems,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(
//               child: CircularProgressIndicator(),
//             );
//           }
//           if (snapshot.hasError) {
//             return Center(
//               child: Text(snapshot.error.toString()),
//             );
//           }
//           if (snapshot.data!.isEmpty) {
//             return const Center(child: Text('No items added yet.'));
//           }

//           return ListView.builder(
//             itemCount: snapshot.data!.length,
//             itemBuilder: (ctx, index) => Dismissible(
//               onDismissed: (direction) {
//                 _removeItem(snapshot.data![index]);
//               },
//               key: ValueKey(snapshot.data![index].id),
//               child: ListTile(
//                 title: Text(snapshot.data![index].name),
//                 leading: Container(
//                   width: 24,
//                   height: 24,
//                   color: snapshot.data![index].category.color,
//                 ),
//                 trailing: Text(
//                   snapshot.data![index].quantity.toString(),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
