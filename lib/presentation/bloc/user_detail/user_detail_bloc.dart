import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/post_model.dart';
import 'user_detail_event.dart';
import 'user_detail_state.dart';

class UserDetailBloc extends Bloc<UserDetailEvent, UserDetailState> {
  final UserRepository _repository;

  UserDetailBloc(this._repository) : super(UserDetailInitial()) {
    on<LoadUserDetails>(_onLoadUserDetails);
    on<AddLocalPost>(_onAddLocalPost);
  }

  void _onLoadUserDetails(LoadUserDetails event, Emitter<UserDetailState> emit) async {
    emit(UserDetailLoading());

    try {
      final posts = await _repository.getUserPosts(event.user.id);
      final todos = await _repository.getUserTodos(event.user.id);

      emit(UserDetailLoaded(
        user: event.user,
        posts: posts,
        todos: todos,
        localPosts: [],
      ));
    } catch (e) {
      emit(UserDetailError(e.toString()));
    }
  }

  void _onAddLocalPost(AddLocalPost event, Emitter<UserDetailState> emit) {
    if (state is UserDetailLoaded) {
      final currentState = state as UserDetailLoaded;

      final newPost = PostModel(
        id: DateTime.now().millisecondsSinceEpoch,
        title: event.title,
        body: event.body,
        userId: currentState.user.id,
        tags: [],
        reactions: const PostReactions(likes: 0, dislikes: 0),
      );

      emit(currentState.copyWith(
        localPosts: [...currentState.localPosts, newPost],
      ));
    }
  }
}