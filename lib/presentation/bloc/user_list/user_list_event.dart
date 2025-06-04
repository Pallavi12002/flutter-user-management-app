import 'package:equatable/equatable.dart';

abstract class UserListEvent extends Equatable {
  const UserListEvent();

  @override
  List<Object> get props => [];
}

class LoadUsers extends UserListEvent {}

class LoadMoreUsers extends UserListEvent {}

class SearchUsers extends UserListEvent {
  final String query;

  const SearchUsers(this.query);

  @override
  List<Object> get props => [query];
}

class RefreshUsers extends UserListEvent {}