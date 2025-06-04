import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../bloc/user_detail/user_detail_bloc.dart';
import '../bloc/user_detail/user_detail_event.dart';
import '../bloc/user_detail/user_detail_state.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_widget.dart';
import 'create_post_page.dart';
import '../../data/models/user_model.dart';
import '../../data/models/post_model.dart';
import '../../data/models/todo_model.dart';

class UserDetailPage extends StatelessWidget {
  const UserDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        elevation: 0,
      ),
      body: BlocBuilder<UserDetailBloc, UserDetailState>(
        builder: (context, state) {
          if (state is UserDetailLoading) {
            return const CustomLoadingIndicator(
              message: 'Loading user details...',
            );
          } else if (state is UserDetailError) {
            return CustomErrorWidget(
              message: state.message,
              onRetry: () {
                // You might want to pass the user again here
                // For now, we'll show a simple retry message
              },
            );
          } else if (state is UserDetailLoaded) {
            return DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  _buildUserInfo(context, state.user),
                  Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: const TabBar(
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.blue,
                      tabs: [
                        Tab(
                          icon: Icon(Icons.info),
                          text: 'Info',
                        ),
                        Tab(
                          icon: Icon(Icons.article),
                          text: 'Posts',
                        ),
                        Tab(
                          icon: Icon(Icons.checklist),
                          text: 'Todos',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildUserInfoTab(state.user),
                        _buildPostsTab(context, state.posts, state.localPosts),
                        _buildTodosTab(state.todos),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(
            child: Text('No user data available'),
          );
        },
      ),
    );
  }

  Widget _buildUserInfo(BuildContext context, UserModel user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: CachedNetworkImage(
              imageUrl: user.image,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 100,
                height: 100,
                color: Colors.grey[300],
                child: const Icon(Icons.person, size: 50, color: Colors.grey),
              ),
              errorWidget: (context, url, error) => Container(
                width: 100,
                height: 100,
                color: Colors.grey[300],
                child: const Icon(Icons.person, size: 50, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.fullName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            user.phone,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoTab(UserModel user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection('Personal Information', [
            _buildInfoRow('Full Name', user.fullName),
            _buildInfoRow('Email', user.email),
            _buildInfoRow('Phone', user.phone),
          ]),
          const SizedBox(height: 20),
          _buildInfoSection('Company Information', [
            _buildInfoRow('Company', user.company.name),
            _buildInfoRow('Job Title', user.company.title),
          ]),
          const SizedBox(height: 20),
          _buildInfoSection('Address', [
            _buildInfoRow('Street', user.address.address),
            _buildInfoRow('City', user.address.city),
            _buildInfoRow('State', user.address.state),
            _buildInfoRow('Postal Code', user.address.postalCode),
          ]),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Not specified',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsTab(BuildContext context, List<PostModel> posts, List<PostModel> localPosts) {
    final allPosts = [...localPosts, ...posts];

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () => _navigateToCreatePost(context),
            icon: const Icon(Icons.add),
            label: const Text('Create New Post'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
            ),
          ),
        ),
        Expanded(
          child: allPosts.isEmpty
              ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.article_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No posts available',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Create your first post!',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: allPosts.length,
            itemBuilder: (context, index) {
              final post = allPosts[index];
              final isLocal = index < localPosts.length;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              post.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isLocal)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'LOCAL',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        post.body,
                        style: const TextStyle(fontSize: 16),
                      ),
                      if (post.tags.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: post.tags.map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.blue.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              '#$tag',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          )).toList(),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.thumb_up_outlined,
                            size: 18,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${post.reactions.likes}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 20),
                          const Icon(
                            Icons.thumb_down_outlined,
                            size: 18,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${post.reactions.dislikes}',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTodosTab(List<TodoModel> todos) {
    if (todos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.checklist_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No todos available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6.0),
          elevation: 1,
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: todo.completed
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                todo.completed
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: todo.completed ? Colors.green : Colors.orange,
                size: 24,
              ),
            ),
            title: Text(
              todo.todo,
              style: TextStyle(
                decoration: todo.completed
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: todo.completed
                    ? Colors.grey
                    : null,
                fontSize: 16,
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: todo.completed
                    ? Colors.green.withOpacity(0.1)
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                todo.completed ? 'DONE' : 'PENDING',
                style: TextStyle(
                  color: todo.completed ? Colors.green : Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToCreatePost(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePostPage(
          onPostCreated: (title, body) {
            context.read<UserDetailBloc>().add(
              AddLocalPost(title: title, body: body),
            );
          },
        ),
      ),
    );
  }
}