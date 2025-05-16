import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'note_model.dart'; // Импортируем модель заметки

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late Box<Note> notesBox; // Хранилище заметок

  @override
  void initState() {
    super.initState();
    // Открытие Hive Box для заметок
    _openBox();
  }

  void _openBox() async {
    notesBox = await Hive.openBox<Note>('notes');
    setState(() {}); // Перезагружаем состояние, когда открыли box
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Заметки')),
      body: ValueListenableBuilder(
        valueListenable:
            Hive.box<Note>(
              'notes',
            ).listenable(), // Подключение к box для получения изменений
        builder: (context, Box<Note> box, _) {
          if (box.isEmpty) {
            return Center(child: Text('Нет заметок.'));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final note = box.getAt(index);
              return ListTile(
                title: Text(note!.title),
                subtitle: Text(note.content),
                onTap: () {
                  _showEditNoteDialog(note, index);
                },
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteNote(index);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddNoteDialog,
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddNoteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return _NoteDialog(
          onSave: (title, content) {
            final newNote = Note(title: title, content: content);
            notesBox.add(newNote); // Сохраняем заметку в Hive
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _showEditNoteDialog(Note note, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return _NoteDialog(
          title: note.title,
          content: note.content,
          onSave: (title, content) {
            final updatedNote = Note(title: title, content: content);
            notesBox.putAt(index, updatedNote); // Обновляем заметку в Hive
            Navigator.pop(context);
          },
        );
      },
    );
  }

  void _deleteNote(int index) {
    notesBox.deleteAt(index); // Удаляем заметку из Hive
  }
}

class _NoteDialog extends StatelessWidget {
  final String? title;
  final String? content;
  final Function(String title, String content) onSave;

  _NoteDialog({this.title, this.content, required this.onSave});

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _titleController.text = title ?? '';
    _contentController.text = content ?? '';

    return AlertDialog(
      title: Text(title == null ? 'Добавить заметку' : 'Редактировать заметку'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'Заголовок'),
          ),
          TextField(
            controller: _contentController,
            decoration: InputDecoration(labelText: 'Содержание'),
            maxLines: 5,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Отмена'),
        ),
        TextButton(
          onPressed: () {
            final title = _titleController.text;
            final content = _contentController.text;
            onSave(title, content); // Сохранить заметку
          },
          child: Text('Сохранить'),
        ),
      ],
    );
  }
}
