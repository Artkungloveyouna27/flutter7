import 'package:flutter/material.dart';
import 'sql_helper2.dart';

class ShowTask2 extends StatefulWidget {
  const ShowTask2({super.key});

  @override
  State<ShowTask2> createState() => _ShowTask2State();
}

class _ShowTask2State extends State<ShowTask2> {
  List<Map<String, dynamic>> _contacts = [];
  bool _isLoading = true;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    refreshContacts();
  }

  void refreshContacts() async {
    final data = await SqlHelper2.getContacts();
    setState(() {
      _contacts = data;
      _isLoading = false;
    });
  }

  void showForm(int? id) {
    if (id != null) {
      final existingContact = _contacts.firstWhere((element) => element['id'] == id);
      firstNameController.text = existingContact['first_name'];
      lastNameController.text = existingContact['last_name'];
      emailController.text = existingContact['email'];
      phoneController.text = existingContact['phone'];
    } else {
      firstNameController.clear();
      lastNameController.clear();
      emailController.clear();
      phoneController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          top: 20,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: firstNameController,
              decoration: InputDecoration(labelText: 'First Name', border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              controller: lastNameController,
              decoration: InputDecoration(labelText: 'Last Name', border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
            ),
            SizedBox(height: 10),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                if (firstNameController.text.isEmpty ||
                    lastNameController.text.isEmpty ||
                    emailController.text.isEmpty ||
                    phoneController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Please enter all fields'),
                    backgroundColor: Colors.redAccent,
                  ));
                  return;
                }

                if (id == null) {
                  await addContact();
                } else {
                  await updateContact(id);
                }

                Navigator.of(context).pop();
              },
              child: Text(id == null ? 'Create New' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> addContact() async {
    await SqlHelper2.insertContact({
      'first_name': firstNameController.text,
      'last_name': lastNameController.text,
      'email': emailController.text,
      'phone': phoneController.text,
    });
    refreshContacts();
  }

  Future<void> updateContact(int id) async {
    await SqlHelper2.updateContact(id, {
      'first_name': firstNameController.text,
      'last_name': lastNameController.text,
      'email': emailController.text,
      'phone': phoneController.text,
    });
    refreshContacts();
  }

  void confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete this contact?"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text("Delete", style: TextStyle(color: Colors.red)),
            onPressed: () async {
              await SqlHelper2.deleteContact(id);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Contact deleted!')));
              refreshContacts();
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: Scaffold(
        appBar: AppBar(title: Text('Contacts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blueAccent,
          child: Icon(Icons.add, color: Colors.white),
          onPressed: () => showForm(null),
        ),
        body: _isLoading
            ? Center(child: CircularProgressIndicator())
            : _contacts.isEmpty
                ? Center(child: Text('No contacts available', style: TextStyle(fontSize: 18)))
                : ListView.builder(
                    itemCount: _contacts.length,
                    itemBuilder: (context, index) => Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 4,
                      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                            child: Text(
                              _contacts[index]['first_name'][0],
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            "${_contacts[index]['first_name']} ${_contacts[index]['last_name']}",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Text("📧 ${_contacts[index]['email']}\n📞 ${_contacts[index]['phone']}"),
                          trailing: Wrap(
                            spacing: 8,
                            children: [
                              IconButton(
                                icon: Icon(Icons.info, color: Colors.blueAccent),
                                onPressed: () => _showContactDetails(_contacts[index]),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.orange),
                                onPressed: () => showForm(_contacts[index]['id']),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => confirmDelete(_contacts[index]['id']),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
