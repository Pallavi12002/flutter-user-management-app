import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/theme/theme_state.dart';
import '../bloc/user_detail/user_detail_event.dart';
import '../bloc/user_list/user_list_bloc.dart';
import '../bloc/user_list/user_list_event.dart';
import '../bloc/user_list/user_list_state.dart';
import '../bloc/theme/theme_bloc.dart';
import '../bloc/theme/theme_event.dart';
import '../bloc/user_detail/user_detail_bloc.dart';
import '../widgets/user_card.dart';
import '../widgets/search_bar.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_widget.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/models/user_model.dart';
import '../../di/injection_container.dart' as di;
import 'user_detail_page.dart';

class UserListPage extends StatefulWidget {
  @override
  _UserListPageState createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load users when page initializes
    Future.microtask(() => context.read<UserListBloc>().add(LoadUsers()));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<UserListBloc>().state;
      if (state is UserListLoaded && !state.isLoadingMore && !state.hasReachedMax) {
        context.read<UserListBloc>().add(LoadMoreUsers());
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            icon: BlocBuilder<ThemeBloc, ThemeState>(
              builder: (context, state) {
                return Icon(
                  state.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                );
              },
            ),
            onPressed: () => context.read<ThemeBloc>().add(ToggleTheme()),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomSearchBar(
              controller: _searchController,
              onChanged: (query) {
                context.read<UserListBloc>().add(SearchUsers(query));
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<UserListBloc, UserListState>(
              builder: (context, state) {
                if (state is UserListLoading) {
                  return const CustomLoadingIndicator(
                    message: 'Loading users...',
                  );
                } else if (state is UserListError) {
                  return CustomErrorWidget(
                    message: state.message,
                    onRetry: () => context.read<UserListBloc>().add(LoadUsers()),
                  );
                } else if (state is UserListLoaded) {
                  if (state.users.isEmpty) {
                    return const Center(
                      child: Text('No users found'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<UserListBloc>().add(RefreshUsers());
                      // Wait for the refresh to complete
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: state.hasReachedMax
                          ? state.users.length
                          : state.users.length + 1,
                      itemBuilder: (context, index) {
                        if (index >= state.users.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CustomLoadingIndicator(),
                          );
                        }

                        return UserCard(
                          user: state.users[index],
                          onTap: () => _navigateToUserDetail(state.users[index]),
                        );
                      },
                    ),
                  );
                }
                return const Center(
                  child: Text('Welcome! Pull down to refresh or search for users.'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToUserDetail(UserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => di.sl<UserDetailBloc>()
            ..add(LoadUserDetails(user)),
          child: UserDetailPage(),
        ),
      ),
    );
  }
}