import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quick Notes',
      themeMode: ThemeMode.system,
      theme: ThemeData.light(
        useMaterial3: true,
      ), // Set the default light theme
      darkTheme: ThemeData.dark(
        useMaterial3: true,
      ), // Set the dark theme
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _noteController = TextEditingController();
  List<String> notes = [];

  int selectedNoteIndex = -1;

  @override
  void initState() {
    super.initState();
    // Load saved notes from local storage when the app starts
    loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quick Notes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: 'Enter your note...',
              ),
            ),
            SizedBox(height: 16.0),
            Theme(
              data: ThemeData(
                iconTheme: IconThemeData(
                    color: Theme.of(context).colorScheme.onPrimary),
              ),
              child: ElevatedButton(
                onPressed: () {
                  // Save the note when the button is pressed
                  saveNote();
                },
                child: Text('Save Note'),
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: Key(notes[index]),
                    onDismissed: (direction) {
                      // Remove the dismissed note from the list and storage
                      deleteNote(index);
                    },
                    background: Container(
                      color: Theme.of(context).errorColor,
                      child: Icon(Icons.delete, color: Colors.white),
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 16.0),
                    ),
                    child: NoteItem(
                      note: notes[index],
                      onTap: () {
                        setState(() {
                          selectedNoteIndex = index;
                          _noteController.text = notes[index];
                        });
                      },
                      onDelete: () {
                        // Delete the note when the delete button is pressed
                        deleteNote(index);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void saveNote() async {
    String note = _noteController.text.trim();
    if (note.isNotEmpty) {
      // Save the note to local storage using shared_preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (selectedNoteIndex != -1) {
        // Update the note if it already exists
        notes[selectedNoteIndex] = note;
      } else {
        // Add the note if it doesn't exist
        notes.insert(0, note);
      }
      prefs.setStringList('notes', notes);
      // Clear the text field
      _noteController.clear();
      selectedNoteIndex = -1;
      // Update the UI
      setState(() {});
    }
  }

  void loadNotes() async {
    // Load notes from local storage using shared_preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      notes = prefs.getStringList('notes') ?? [];
    });
  }

  void deleteNote(int index) async {
    // Delete the note from the list and local storage
    setState(() {
      notes.removeAt(index);
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('notes', notes);
  }
}

class NoteItem extends StatelessWidget {
  final String note;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const NoteItem(
      {Key? key,
      required this.note,
      required this.onDelete,
      required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        onTap: onTap,
        title: Text(
          note,
          style: TextStyle(fontSize: 16),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          color: Theme.of(context).errorColor,
          onPressed: onDelete,
        ),
      ),
    );
  }
}
