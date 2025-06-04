import 'package:flutter_assignment_task/presentation/bloc/user_list/user_list_event.dart';
import 'package:flutter_assignment_task/presentation/bloc/user_list/user_list_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/debouncer.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';

class UserListBloc extends Bloc<UserListEvent, UserListState> {
  final UserRepository _repository;
  final Debouncer _debouncer = Debouncer(delay: AppConstants.debounceDelay);

  UserListBloc(this._repository) : super(UserListInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<LoadMoreUsers>(_onLoadMoreUsers);
    on<SearchUsers>(_onSearchUsers);
    on<RefreshUsers>(_onRefreshUsers);
  }

  void _onLoadUsers(LoadUsers event, Emitter<UserListState> emit) async {
    emit(UserListLoading());
    try {
      final result = await _repository.getUsers(
        limit: AppConstants.pageSize,
        skip: 0,
      );

      final users = result['users'] as List<UserModel>;

      emit(UserListLoaded(
        users: users,
        hasReachedMax: users.length < AppConstants.pageSize,
        total: result['total'] as int,
        currentSkip: AppConstants.pageSize, // Next skip value
        isSearching: false,
      ));
    } catch (e) {
      emit(UserListError(e.toString()));
    }
  }

  void _onLoadMoreUsers(LoadMoreUsers event, Emitter<UserListState> emit) async {
    if (state is UserListLoaded) {
      final currentState = state as UserListLoaded;

      // Don't load more if already reached max or currently searching
      if (currentState.hasReachedMax || currentState.isSearching) return;

      emit(currentState.copyWith(isLoadingMore: true));

      try {
        final result = await _repository.getUsers(
          limit: AppConstants.pageSize,
          skip: currentState.currentSkip, // Use tracked skip value
        );

        final newUsers = result['users'] as List<UserModel>;
        final allUsers = [...currentState.users, ...newUsers];

        emit(UserListLoaded(
          users: allUsers,
          hasReachedMax: newUsers.length < AppConstants.pageSize,
          total: result['total'] as int,
          currentSkip: currentState.currentSkip + newUsers.length, // Update skip
          isSearching: false,
        ));
      } catch (e) {
        emit(currentState.copyWith(isLoadingMore: false));
      }
    }
  }

  void _onSearchUsers(SearchUsers event, Emitter<UserListState> emit) async {
    _debouncer.run(() async {
      if (event.query.isEmpty) {
        add(LoadUsers());
        return;
      }

      emit(UserListLoading());
      try {
        final result = await _repository.getUsers(
          limit: 100, // Increased limit for search results
          skip: 0,
          search: event.query,
        );

        final users = result['users'] as List<UserModel>;

        emit(UserListLoaded(
          users: users,
          hasReachedMax: true, // Disable infinite scroll for search
          total: result['total'] as int,
          currentSkip: 0,
          isSearching: true,
        ));
      } catch (e) {
        emit(UserListError(e.toString()));
      }
    });
  }

  void _onRefreshUsers(RefreshUsers event, Emitter<UserListState> emit) async {
    try {
      final result = await _repository.getUsers(
        limit: AppConstants.pageSize,
        skip: 0,
      );

      final users = result['users'] as List<UserModel>;

      emit(UserListLoaded(
        users: users,
        hasReachedMax: users.length < AppConstants.pageSize,
        total: result['total'] as int,
        currentSkip: AppConstants.pageSize,
        isSearching: false,
      ));
    } catch (e) {
      emit(UserListError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _debouncer.dispose();
    return super.close();
  }
}