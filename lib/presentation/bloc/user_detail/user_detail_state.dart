import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/todo_model.dart';

abstract class UserDetailState extends Equatable {
  const UserDetailState();

  @override
  List<Object> get props => [];
}

class UserDetailInitial extends UserDetailState {}

class UserDetailLoading extends UserDetailState {}

class UserDetailLoaded extends UserDetailState {
  final UserModel user;
  final List<PostModel> posts;
  final List<TodoModel> todos;
  final List<PostModel> localPosts;

  const UserDetailLoaded({
    required this.user,
    required this.posts,
    required this.todos,
    required this.localPosts,
  });

  UserDetailLoaded copyWith({
    UserModel? user,
    List<PostModel>? posts,
    List<TodoModel>? todos,
    List<PostModel>? localPosts,
  }) {
    return UserDetailLoaded(
      user: user ?? this.user,
      posts: posts ?? this.posts,
      todos: todos ?? this.todos,
      localPosts: localPosts ?? this.localPosts,
    );
  }

  @override
  List<Object> get props => [user, posts, todos, localPosts];
}

class UserDetailError extends UserDetailState {
  final String message;

  const UserDetailError(this.message);

  @override
  List<Object> get props => [message];
}