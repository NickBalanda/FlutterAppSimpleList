import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

void main() => runApp(new ListApp());

class ListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Items List',

      home: new ShoppingList()
    );
  }
}

class ShoppingList extends StatefulWidget {
  @override
  createState() => new ShoppingListState();
}

class ShoppingListState extends State<ShoppingList> {

  List<bool> _checkedItems = [];
  List<String> _checkedItemsString = [];

  List<String> _shoppingItems = [];
  //List<int> _indexList = [];

  bool itemsLoaded = false;
  bool allItemsChecked = false;

  @override
  void initState(){
    super.initState();
    _getFromSharedPref();

  }

  void  _getFromSharedPref() async{
    print(itemsLoaded);
    final prefs = await SharedPreferences.getInstance();

    final savedItems = prefs.getStringList("_shoppingItems");
    if(savedItems != null){
      setState(() {
        _shoppingItems = savedItems;
      });

    }

    final savedCheckedItems = prefs.getStringList("_checkedItems");
    if(savedCheckedItems != null){
      setState(() {
        _checkedItemsString = savedCheckedItems;
        _boolListConverter();
      });
    }
    itemsLoaded = true;
    print(itemsLoaded);
  }
  void _saveToSharedPref() async{
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList("_shoppingItems", _shoppingItems);
    await prefs.setStringList("_checkedItems", _checkedItemsString);
  }

  void _removeSharedPref() async{
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("_checkedItems");
    await prefs.remove("_shoppingItems");

  }

  bool toBoolean(String str, [bool strict]) {
    if (strict == true) {
      return str == '1' || str == 'true';
    }
    return str != '0' && str != 'false' && str != '';
  }
  void _boolListConverter(){
    _checkedItems.clear();
    for(int i =0; i<_checkedItemsString.length; i++){
      _checkedItems.add(toBoolean(_checkedItemsString[i]));
    }
  }

  // Items management
  void _addShoppingItem(String item) {
    // Only add the task if the user actually entered something
    if(item.length > 0) {
      setState(() {
        _shoppingItems.add(item);

        _checkedItems.add(false);
        _checkedItemsString.add(false.toString());
      });
    }
  }

  void _removeShoppingItem(int index) {
    setState(() {
      _shoppingItems.removeAt(index);

      _checkedItems.removeAt(index);
      _checkedItemsString.removeAt(index);
    });
  }
 void _removeAllSelectedItems(){
    for(int i = 0; i < _checkedItems.length; i++){
      if(_checkedItems[i] == true){
        print(_shoppingItems[i]);
        _removeShoppingItem(i);
      }
    }
    _getFromSharedPref();
 }
 //Show dialog to remove all selected items
  /*void _promptRemoveAllSelectedItems() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
              title: new Text('Delete selected items?'),
              actions: <Widget>[
                new FlatButton(
                    child: new Text('CANCEL'),
                    onPressed: () => Navigator.of(context).pop()
                ),
                new FlatButton(
                    child: new Text('DELETE'),
                    onPressed: () {
                      _removeAllSelectedItems();
                      Navigator.of(context).pop();
                    }
                )
              ]
          );
        }
    );
  }*/

// Show an alert dialog asking the user to confirm that the task is done
  void _promptRemoveShoppingItem(int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
              title: new Text('Delete "${_shoppingItems[index]}" ?'),
              actions: <Widget>[
                new FlatButton(
                    child: new Text('CANCEL'),
                    onPressed: () => Navigator.of(context).pop()
                ),
                new FlatButton(
                    child: new Text('DELETE'),
                    onPressed: () {
                      _removeShoppingItem(index);
                      Navigator.of(context).pop();
                    }
                )
              ]
          );

        }
    );

  }

  // Build the whole list of shopping items
  Widget _buildShoppingList() {
    return new ListView.builder(
      // ignore: missing_return
      itemBuilder: (context, index) {
        if(index < _shoppingItems.length) {
          _saveToSharedPref();
          return _buildShoppingItem(_shoppingItems[index],index);
        }
      },
    );
  }

  // Build a single shopping item
  Widget _buildShoppingItem(String itemText, int index) {

    return new ListTile(
        leading: Checkbox(
          value: _checkedItems[index],
          activeColor:  Colors.amber[50],
          checkColor: Colors.redAccent,

          onChanged:(bool value){
            setState(() {
              _checkedItems[index] = value;
              _checkedItemsString[index] = value.toString();

              _saveToSharedPref();
            });
          },

        ),
        trailing: IconButton(
          icon: _deleteIconColor(_checkedItems[index]),
          onPressed: () {
            _promptRemoveShoppingItem(index);
          },
        ),

        title: _itemText(itemText, _checkedItems[index]),
    );

  }

  Widget _deleteIconColor(bool check){
    if(!check)
      return new Icon(Icons.delete);
    else
      return new Icon(Icons.delete, color: Colors.redAccent);
  }
  Widget _itemText(String item, bool check){
    if(check)
      return new Text(item,  style: TextStyle(color: Colors.redAccent, decorationColor: Colors.redAccent,  decoration: TextDecoration.lineThrough));
    else
      return new Text(item);
  }

  void _pushAddShoppingItemScreen() {
    // Push this page onto the stack
    Navigator.of(context).push(
      // MaterialPageRoute will automatically animate the screen entry, as well
        new MaterialPageRoute(
            builder: (context) {
              return new Scaffold(
                  backgroundColor: Colors.amber[50],
                  appBar: new AppBar(
                    backgroundColor: Colors.amber[100],
                    iconTheme: IconThemeData(
                      color: Colors.grey[600],
                    ),
                      title: new Text('Add a new item',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),),
                    centerTitle: true,
                  ),
                  body: new TextField(
                    autofocus: true,
                    cursorColor: Colors.grey[600],
                    onSubmitted: (val) {
                      _addShoppingItem(val);
                      Navigator.pop(context); // Close the add shopping screen
                    },
                    decoration: new InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter a new item...',
                        contentPadding: const EdgeInsets.all(16.0),
                    ),
                  )
              );
            }
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.amber[50],
        appBar: new AppBar(

          title: new Text(
            'Items List',
            style: TextStyle(
              color: Colors.grey[600],
            ),),
          centerTitle: true,
          backgroundColor: Colors.amber[100],
          /*leading: Theme(
              data: ThemeData(unselectedWidgetColor: Colors.grey[850]),
              child: Checkbox(
                  value: allItemsChecked,
                  tristate: false,
                  activeColor:  Colors.grey[850],
                  checkColor: Colors.amber[100],
                  onChanged: (bool value) {
                    setState(() {
                      allItemsChecked = value;
                    });
                  }),
          ),

          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Colors.white,
              ),
              onPressed: () {
                //_promptRemoveAllSelectedItems();
              },
            ),

          ],

           */
        ),
        body: _buildShoppingList(),
        bottomNavigationBar: BottomAppBar(
          //shape: const CircularNotchedRectangle(),
          child: Container(
            height: 50.0,
          ),
          color: Colors.amber[50],
        ),
        floatingActionButton: new FloatingActionButton.extended(
          onPressed: _pushAddShoppingItemScreen,
          tooltip: 'Add item',
          label: Text(
            'Add Item',
            style: TextStyle(
            color: Colors.grey[600],
          ),),
          icon: Icon(Icons.add, color: Colors.grey[600],),
          backgroundColor: Colors.amber[100],
        ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

    );
  }
}

