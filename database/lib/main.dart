import 'package:database/AppDatabase.dart';
import 'package:flutter/material.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();
  runApp(MyApp(database));
}



class MyApp extends StatefulWidget {
  final AppDatabase database;

  const MyApp(this.database);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  TextEditingController _postTitleController = TextEditingController();
  TextEditingController _postContentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Floor Example'),
        ),
        body: Column(
          children: [
            _buildPostTextField(context),
            Expanded(
              child: FutureBuilder<List<Post>>(
                future: widget.database.postDao.getAllPosts(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final posts = snapshot.data!;
                    return ListView.builder(
                      itemCount: posts.length,
                      itemBuilder: (context, index) {
                        final post = posts[index];
                        return _buildPostTile(context, post);
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error fetching posts: ${snapshot.error}');
                  }
                  return Center(child: CircularProgressIndicator());
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostTextField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            controller: _postTitleController,
            decoration: InputDecoration(hintText: 'Enter post title'),
          ),
          SizedBox(height: 8.0),
          TextField(
            controller: _postContentController,
            decoration: InputDecoration(hintText: 'Enter post content'),
          ),
          SizedBox(height: 8.0),
          ElevatedButton(
            onPressed: () async {
              await _submitPost(_postTitleController.text, _postContentController.text);
              _postTitleController.clear();
              _postContentController.clear();
              // Aggiorna la lista dei post quando un nuovo post è stato aggiunto.
              setState(() {});
            },
            child: Text('Post'),
          ),
        ],
      ),
    );
  }

 Widget _buildPostTile(BuildContext context, Post post) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ExpansionTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Post ID: ${post.id}, Title: ${post.title}, Content: ${post.content}',
                maxLines: 3, // Limita il numero di righe
                overflow: TextOverflow.ellipsis, // Aggiunge "..." se il testo è troppo lungo
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                await _deletePost(post.id);
                // Aggiorna la lista dei post quando un post è stato eliminato.
                setState(() {});
              },
            ),
          ],
        ),
        children: [
          _buildCommentsList(context, post.id),
          _buildCommentTextField(context, post.id),
        ],
      ),
    );
  }

  Widget _buildCommentsList(BuildContext context, int postId) {
    return FutureBuilder<List<Comment>>(
      future: widget.database.commentDao.getCommentsForPost(postId),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final comments = snapshot.data!;
          return Column(
            children: [
              for (final comment in comments)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Comment ID: ${comment.id}, Post ID: ${comment.postId}, Text: ${comment.text}',
                    maxLines: 3, // Limita il numero di righe
                    overflow: TextOverflow.ellipsis, // Aggiunge "..." se il testo è troppo lungo
                  ),
                ),
            ],
          );
        } else if (snapshot.hasError) {
          return Text('Error fetching comments: ${snapshot.error}');
        }
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildCommentTextField(BuildContext context, int postId) {
    TextEditingController _commentController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(hintText: 'Add a comment'),
            ),
          ),
          SizedBox(width: 8.0),
          ElevatedButton(
            onPressed: () async {
              await _submitComment(postId, _commentController.text);
              _commentController.clear();
              // Aggiorna la lista dei commenti quando un nuovo commento è stato aggiunto.
              setState(() {});
            },
            child: Text('Comment'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitPost(String title, String content) async {
    final newPost = Post(DateTime.now().millisecondsSinceEpoch, title, content);
    await widget.database.postDao.insertPost(newPost);
  }

  Future<void> _deletePost(int postId) async {
    await widget.database.postDao.deletePostById(postId);
  }

  Future<void> _submitComment(int postId, String text) async {
    final newComment = Comment(DateTime.now().millisecondsSinceEpoch, postId, text);
    await widget.database.commentDao.insertComment(newComment);
  }
}