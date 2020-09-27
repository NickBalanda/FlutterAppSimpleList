import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(new ListApp());

class ListApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Simple List',

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

  TextEditingController _writeController = TextEditingController();

  @override
  void initState(){
    super.initState();
    _getFromSharedPref();

  }

  void  _getFromSharedPref() async{
    //print(itemsLoaded);
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
    //print(itemsLoaded);
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
  void _addItem(String item) {
    // Only add the task if the user actually entered something
    if(item.length > 0) {
      setState(() {
        _shoppingItems.add(item);

        _checkedItems.add(false);
        _checkedItemsString.add(false.toString());
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      _shoppingItems.removeAt(index);

      _checkedItems.removeAt(index);
      _checkedItemsString.removeAt(index);
    });
  }
  void _editItem(int index, String newItem) {
    setState(() {
      _shoppingItems[index] = newItem;
    });
  }
 void _removeAllItems(){
   setState(() {
     _shoppingItems.clear();
     _checkedItems.clear();
     _checkedItemsString.clear();
   });
   _removeSharedPref();
 }

  void _promptRemoveAllItems() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
              title: new Text('Delete all items from the list?'),
              actions: <Widget>[
                new FlatButton(
                    child: new Text('CANCEL',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),),
                    onPressed: () => Navigator.of(context).pop()
                ),
                new FlatButton(
                    child: new Text('DELETE',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),),
                    onPressed: () {
                      _removeAllItems();
                      Navigator.of(context).pop();
                    }
                )
              ]
          );
        }
    );
  }

  void _promptAddItem() {
    //_writeController.value..text = '';

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
              title: new Text('Add a new item'),
              backgroundColor: Colors.amber[50],

              content: TextField(
                controller: _writeController,
                autofocus: true,
                cursorColor: Colors.grey[600],
                onSubmitted: (val) {
                  _addItem(val);
                  _writeController.clear();
                  Navigator.pop(context); // Close the add shopping screen
                },
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[600]),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[600]),
                  ),
                  hintText: 'Enter a new item...',
                ),

              ),
              actions: <Widget>[
                new FlatButton(
                    child: new Text(
                      'CANCEL',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop()
                ),
                new FlatButton(
                    child: new Text(
                      'OK',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    onPressed: () {
                      _addItem(_writeController.value.text);
                      _writeController.clear();
                      Navigator.of(context).pop();
                    }
                )
              ]
          );

        }
    );
  }

  void _promptEditItem(int index) {
    _writeController.text = '${_shoppingItems[index]}';
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
              title: new Text('Edit Item'),
              backgroundColor: Colors.amber[50],

              content: TextField(
                controller: _writeController,
                autofocus: true,
                cursorColor: Colors.grey[600],
                onSubmitted: (val) {
                  _editItem(index, _writeController.value.text);
                  Navigator.pop(context); // Close the add shopping screen
                },
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[600]),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[600]),
                  ),

                ),

              ),
              actions: <Widget>[
                new FlatButton(
                    child: new Text(
                      'CANCEL',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop()
                ),
                new FlatButton(
                    child: new Text(
                        'APPLY',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    onPressed: () {
                      _editItem(index, _writeController.value.text);
                      _writeController.text = '';
                      Navigator.of(context).pop();
                    }
                )
              ]
          );

        }
    );
  }

  void _promptRemoveItem(int index) {
        showDialog(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
              title: new Text('Delete "${_shoppingItems[index]}" ?'),
              backgroundColor: Colors.amber[50],
              actions: <Widget>[
                new FlatButton(
                    child: new Text(
                      'CANCEL',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop()
                ),
                new FlatButton(
                    child: new Text(
                      'DELETE',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    onPressed: () {
                      _removeItem(index);
                      Navigator.of(context).pop();
                    }
                )
              ]
          );

        }
    );

  }

  // Build the whole list of shopping items
  Widget _buildList() {
    return new ListView.builder(
      // ignore: missing_return
      itemBuilder: (context, index) {
        if(index < _shoppingItems.length) {
          _saveToSharedPref();
          return _buildItem(_shoppingItems[index],index);
        }
      },
    );
  }

  // Build a single shopping item
  Widget _buildItem(String itemText, int index) {

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
        trailing: Wrap(
          spacing: 12, // space between two icons
          children: <Widget>[
            IconButton(
              icon: _editIconColor(_checkedItems[index]),
              onPressed: () {
                _promptEditItem(index);
              },
            ),//
            IconButton(
              icon: _deleteIconColor(_checkedItems[index]),
              onPressed: () {
                _promptRemoveItem(index);
              },
            ), // icon-1
          ],
        ),

        title: _itemText(itemText, _checkedItems[index]),
    );

  }

  Widget _editIconColor(bool check){
    if(!check)
      return new Icon(Icons.edit);
    else
      return new Icon(Icons.edit, color: Colors.redAccent);
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

 /* void _pushAddShoppingItemScreen() {
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
                      _addItem(val);
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
*/
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.amber[50],
        appBar: new AppBar(

          title: new Text(
            'Simple List',
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
          */
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.delete_outline,
                color: Colors.grey[600],
              ),
              onPressed: () {
                _promptRemoveAllItems();
              },
            ),

          ],

        ),
        body: _buildList(),
        bottomNavigationBar: BottomAppBar(
          //shape: const CircularNotchedRectangle(),
          child: Container(
            height: 50.0,
          ),
          color: Colors.amber[50],
        ),
        floatingActionButton: new FloatingActionButton.extended(
          onPressed: _promptAddItem,
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

