import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SQLite Demo',
      home: ChangeNotifierProvider(
        create: (context) => AppDatabase(),
        child: HomePage(),
      ),
    );
  }
}

class AppDatabase extends ChangeNotifier {
  late Database _database;

  Future<void> initializeDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'app_database.db'),
      onCreate: (db, version) {
        db.execute('''
          CREATE TABLE posts(
            id INTEGER PRIMARY KEY,
            title TEXT,
            content TEXT
          )
        ''');
        db.execute('''
          CREATE TABLE comments(
            id INTEGER PRIMARY KEY,
            postId INTEGER,
            text TEXT
          )
        ''');
      },
      version: 1,
    );
  }

  Future<void> insertPost(Post post) async {
    await _database.insert('posts', post.toMap());
    notifyListeners();
  }

  Future<void> insertComment(Comment comment) async {
    await _database.insert('comments', comment.toMap());
    notifyListeners();
  }

  Future<List<Post>> getPosts() async {
    final List<Map<String, dynamic>> maps = await _database.query('posts');
    return List.generate(maps.length, (i) {
      return Post(
        id: maps[i]['id'],
        title: maps[i]['title'],
        content: maps[i]['content'],
      );
    });
  }

  Future<List<Comment>> getCommentsForPost(int postId) async {
    final List<Map<String, dynamic>> maps =
        await _database.query('comments', where: 'postId = ?', whereArgs: [postId]);
    return List.generate(maps.length, (i) {
      return Comment(
        id: maps[i]['id'],
        postId: maps[i]['postId'],
        text: maps[i]['text'],
      );
    });
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<AppDatabase>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('SQLite Demo'),
      ),
      body: FutureBuilder(
        future: database.initializeDatabase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return PostList();
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

class PostList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final database = Provider.of<AppDatabase>(context);
    return FutureBuilder<List<Post>>(
      future: database.getPosts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final posts = snapshot.data ?? [];
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(posts[index].title),
                subtitle: FutureBuilder<List<Comment>>(
                  future: database.getCommentsForPost(posts[index].id),
                  builder: (context, commentSnapshot) {
                    if (commentSnapshot.connectionState == ConnectionState.done) {
                      final comments = commentSnapshot.data ?? [];
                      return Text('${comments.length} comments');
                    } else {
                      return CircularProgressIndicator();
                    }
                  },
                ),
              );
            },
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}

class Post {
  final int id;
  final String title;
  final String content;

  Post({required this.id, required this.title, required this.content});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
    };
  }
}

class Comment {
  final int id;
  final int postId;
  final String text;

  Comment({required this.id, required this.postId, required this.text});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'text': text,
    };
  }
}