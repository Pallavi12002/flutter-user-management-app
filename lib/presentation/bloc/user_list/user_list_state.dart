

import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';

abstract class UserListState extends Equatable {
const UserListState();

@override
List<Object> get props => [];
}

class UserListInitial extends UserListState {}

class UserListLoading extends UserListState {}

class UserListLoaded extends UserListState {
final List<UserModel> users;
final bool hasReachedMax;
final int total;
final int currentSkip; // Track current skip for pagination
final bool isLoadingMore;
final bool isSearching;

const UserListLoaded({
required this.users,
required this.hasReachedMax,
required this.total,
required this.currentSkip,
this.isLoadingMore = false,
this.isSearching = false,
});

UserListLoaded copyWith({
List<UserModel>? users,
bool? hasReachedMax,
int? total,
int? currentSkip,
bool? isLoadingMore,
bool? isSearching,
}) {
return UserListLoaded(
users: users ?? this.users,
hasReachedMax: hasReachedMax ?? this.hasReachedMax,
total: total ?? this.total,
currentSkip: currentSkip ?? this.currentSkip,
isLoadingMore: isLoadingMore ?? this.isLoadingMore,
isSearching: isSearching ?? this.isSearching,
);
}

@override
List<Object> get props => [
users,
hasReachedMax,
total,
currentSkip,
isLoadingMore,
isSearching,
];
}

class UserListError extends UserListState {
final String message;

const UserListError(this.message);

@override
List<Object> get props => [message];
}