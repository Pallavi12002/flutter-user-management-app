import 'package:equatable/equatable.dart';
import '../../../data/models/user_model.dart';

abstract class UserDetailEvent extends Equatable {
  const UserDetailEvent();

  @override
  List<Object> get props => [];
}

class LoadUserDetails extends UserDetailEvent {
  final UserModel user;

  const LoadUserDetails(this.user);

  @override
  List<Object> get props => [user];
}

class AddLocalPost extends UserDetailEvent {
  final String title;
  final String body;

  const AddLocalPost({required this.title, required this.body});

  @override
  List<Object> get props => [title, body];
}