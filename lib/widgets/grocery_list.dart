import 'package:flutter/material.dart';
import 'package:grocery/models/grocery_item.dart';
import 'package:grocery/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> grocery = [];
  _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) {
          return const NewItem();
        },
      ),
    );
    if (newItem == null) {
      return;
    }
    setState(() {
      grocery.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) {
    setState(() {
      grocery.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text("Nothing to show here"));
    if (grocery.isNotEmpty) {
      content = ListView.builder(
        itemCount: grocery.length,
        itemBuilder: (context, index) {
          return Dismissible(
            onDismissed: (direction) {
              _removeItem(grocery[index]);
            },
            key: ValueKey(grocery[index].id),
            child: ListTile(
              leading: Container(
                height: 24,
                width: 24,
                color: grocery[index].category.color,
              ),
              title: Text(grocery[index].name),
              trailing: Text(grocery[index].quantity.toString()),
            ),
          );
        },
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body: content,
    );
  }
}
