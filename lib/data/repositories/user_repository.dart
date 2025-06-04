import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/post_model.dart';
import '../models/todo_model.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class UserRepository {
  final ApiService _apiService;
  final SharedPreferences _prefs;

  UserRepository(this._apiService, this._prefs);

  Future<Map<String, dynamic>> getUsers({
    int limit = 30,
    int skip = 0,
    String? search,
  }) async {
    try {
      final result = await _apiService.getUsers(
        limit: limit,
        skip: skip,
        search: search,
      );

      // Ensure users is a List<UserModel>
      final usersJson = result['users'] as List;
      final users = usersJson
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();

      // Cache users locally (only for non-search requests)
      if (search == null || search.isEmpty) {
        await _cacheUsers(users, skip);
      }

      return {
        'users': users,
        'total': result['total'] ?? users.length,
        'skip': result['skip'] ?? skip,
        'limit': result['limit'] ?? limit,
      };
    } catch (e) {
      // Try to load from cache if network fails (only for non-search)
      if (search == null || search.isEmpty) {
        final cachedUsers = await _getCachedUsers(skip, limit);
        if (cachedUsers.isNotEmpty) {
          return {
            'users': cachedUsers,
            'total': cachedUsers.length,
            'skip': skip,
            'limit': limit,
          };
        }
      }
      rethrow;
    }
  }

  Future<List<PostModel>> getUserPosts(int userId) async {
    try {
      final posts = await _apiService.getUserPosts(userId);
      await _cachePosts(userId, posts);
      return posts;
    } catch (e) {
      final cachedPosts = await _getCachedPosts(userId);
      if (cachedPosts.isNotEmpty) {
        return cachedPosts;
      }
      rethrow;
    }
  }

  Future<List<TodoModel>> getUserTodos(int userId) async {
    try {
      final todos = await _apiService.getUserTodos(userId);
      await _cacheTodos(userId, todos);
      return todos;
    } catch (e) {
      final cachedTodos = await _getCachedTodos(userId);
      if (cachedTodos.isNotEmpty) {
        return cachedTodos;
      }
      rethrow;
    }
  }

  // Cache methods
  Future<void> _cacheUsers(List<UserModel> users, int skip) async {
    final key = 'users_$skip';
    final jsonString = json.encode(users.map((u) => u.toJson()).toList());
    await _prefs.setString(key, jsonString);
  }

  Future<List<UserModel>> _getCachedUsers(int skip, int limit) async {
    final key = 'users_$skip';
    final jsonString = _prefs.getString(key);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => UserModel.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> _cachePosts(int userId, List<PostModel> posts) async {
    final key = 'posts_$userId';
    final jsonString = json.encode(posts.map((p) => p.toJson()).toList());
    await _prefs.setString(key, jsonString);
  }

  Future<List<PostModel>> _getCachedPosts(int userId) async {
    final key = 'posts_$userId';
    final jsonString = _prefs.getString(key);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => PostModel.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> _cacheTodos(int userId, List<TodoModel> todos) async {
    final key = 'todos_$userId';
    final jsonString = json.encode(todos.map((t) => t.toJson()).toList());
    await _prefs.setString(key, jsonString);
  }

  Future<List<TodoModel>> _getCachedTodos(int userId) async {
    final key = 'todos_$userId';
    final jsonString = _prefs.getString(key);
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => TodoModel.fromJson(json)).toList();
    }
    return [];
  }
}