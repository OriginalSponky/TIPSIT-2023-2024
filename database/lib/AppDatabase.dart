import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'AppDatabase.g.dart';
@entity
class Post {
  @primaryKey
  final int id;
  final String title;
  final String content;

  Post(this.id, this.title, this.content);
}

@entity
class Comment {
  @primaryKey
  final int id;
  final int postId; // foreign key referencing Post
  final String text;

  Comment(this.id, this.postId, this.text);
}

@Database(version: 1, entities: [Post, Comment])
abstract class AppDatabase extends FloorDatabase {
  PostDao get postDao;
  CommentDao get commentDao;
}

@dao
abstract class PostDao {
  @Query('SELECT * FROM Post')
  Future<List<Post>> getAllPosts();

  @insert
  Future<void> insertPost(Post post);

  @Query('DELETE FROM Post WHERE id = :postId')
  Future<void> deletePostById(int postId);
}

@dao
abstract class CommentDao {
  @Query('SELECT * FROM Comment WHERE postId = :postId')
  Future<List<Comment>> getCommentsForPost(int postId);

  @insert
  Future<void> insertComment(Comment comment);
}
