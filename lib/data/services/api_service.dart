import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../../core/network/api_client.dart';
import '../../core/error/failures.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../models/todo_model.dart';

class ApiService {
  final ApiClient _apiClient;
  final Logger _logger = Logger();

  ApiService(this._apiClient);

  Future<Map<String, dynamic>> getUsers({
    int limit = 30, // Increased default limit
    int skip = 0,
    String? search,
  }) async {
    try {
      _logger.d('Fetching users - limit: $limit, skip: $skip, search: $search');

      final queryParams = <String, dynamic>{
        'limit': limit,
        'skip': skip,
      };

      String endpoint = '/users';

      // DummyJSON search endpoint
      if (search != null && search.trim().isNotEmpty) {
        endpoint = '/users/search';
        queryParams['q'] = search.trim();
        // For search, don't use skip parameter as it might not work correctly
        queryParams.remove('skip');
      }

      _logger.d('API Request - Endpoint: $endpoint, Params: $queryParams');

      final response = await _apiClient.get(endpoint, queryParameters: queryParams);

      if (response.data != null) {
        _logger.d('API Response received - Status: ${response.statusCode}');
        _logger.d('Response data type: ${response.data.runtimeType}');

        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;

          // Log the actual response structure
          _logger.d('Response keys: ${data.keys.toList()}');

          if (data.containsKey('users') && data['users'] is List) {
            _logger.d('Successfully parsed ${(data['users'] as List).length} users');
            return {
              'users': data['users'],
              'total': data['total'] ?? (data['users'] as List).length,
              'skip': data['skip'] ?? skip,
              'limit': data['limit'] ?? limit,
            };
          } else {
            _logger.e('Invalid response structure: $data');
            throw const ServerFailure('Invalid response format: users list not found');
          }
        } else {
          _logger.e('Response is not a Map: ${response.data.runtimeType}');
          throw const ServerFailure('Invalid response format: expected Map');
        }
      } else {
        throw const ServerFailure('Empty response received');
      }

    } on DioException catch (e) {
      _logger.e('DioException occurred: ${e.message}', error: e);
      _logger.e('Response status: ${e.response?.statusCode}');
      _logger.e('Response data: ${e.response?.data}');

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          throw const NetworkFailure('Connection timeout. Please check your internet connection.');

        case DioExceptionType.connectionError:
          throw const NetworkFailure('Unable to connect to server. Please check your internet connection.');

        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          if (statusCode != null) {
            if (statusCode >= 500) {
              throw const ServerFailure('Server error occurred. Please try again later.');
            } else if (statusCode == 404) {
              throw const ServerFailure('Requested data not found.');
            } else if (statusCode >= 400) {
              throw ServerFailure('Client error: ${e.response?.data?['message'] ?? 'Bad request'}');
            }
          }
          throw ServerFailure('HTTP Error: ${e.message ?? 'Unknown error'}');

        case DioExceptionType.cancel:
          throw const NetworkFailure('Request was cancelled');

        default:
          throw ServerFailure('Network error: ${e.message ?? 'Unknown error'}');
      }
    } catch (e) {
      _logger.e('Unexpected error occurred: $e');
      if (e is Failure) {
        rethrow;
      }
      throw ServerFailure('Unexpected error: ${e.toString()}');
    }
  }

  Future<List<PostModel>> getUserPosts(int userId) async {
    try {
      _logger.d('Fetching posts for user: $userId');

      final response = await _apiClient.get('/posts/user/$userId');

      if (response.data != null && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;

        if (data.containsKey('posts') && data['posts'] is List) {
          final postsJson = data['posts'] as List;
          final posts = postsJson
              .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
              .toList();

          _logger.d('Successfully fetched ${posts.length} posts for user $userId');
          return posts;
        } else {
          throw const ServerFailure('Invalid response format: posts list not found');
        }
      } else {
        throw const ServerFailure('Empty or invalid response received');
      }

    } on DioException catch (e) {
      _logger.e('DioException occurred while fetching user posts: ${e.message}', error: e);

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          throw const NetworkFailure('Connection timeout. Please check your internet connection.');

        case DioExceptionType.connectionError:
          throw const NetworkFailure('Unable to connect to server. Please check your internet connection.');

        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          if (statusCode != null) {
            if (statusCode >= 500) {
              throw const ServerFailure('Server error occurred. Please try again later.');
            } else if (statusCode == 404) {
              throw const ServerFailure('Posts not found for this user.');
            } else if (statusCode >= 400) {
              throw ServerFailure('Client error: ${e.response?.data?['message'] ?? 'Bad request'}');
            }
          }
          throw ServerFailure('HTTP Error: ${e.message ?? 'Unknown error'}');

        case DioExceptionType.cancel:
          throw const NetworkFailure('Request was cancelled');

        default:
          throw ServerFailure('Network error: ${e.message ?? 'Unknown error'}');
      }
    } catch (e) {
      _logger.e('Unexpected error occurred while fetching user posts: $e');
      if (e is Failure) {
        rethrow;
      }
      throw ServerFailure('Unexpected error: ${e.toString()}');
    }
  }

  Future<List<TodoModel>> getUserTodos(int userId) async {
    try {
      _logger.d('Fetching todos for user: $userId');

      final response = await _apiClient.get('/todos/user/$userId');

      if (response.data != null && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;

        if (data.containsKey('todos') && data['todos'] is List) {
          final todosJson = data['todos'] as List;
          final todos = todosJson
              .map((json) => TodoModel.fromJson(json as Map<String, dynamic>))
              .toList();

          _logger.d('Successfully fetched ${todos.length} todos for user $userId');
          return todos;
        } else {
          throw const ServerFailure('Invalid response format: todos list not found');
        }
      } else {
        throw const ServerFailure('Empty or invalid response received');
      }

    } on DioException catch (e) {
      _logger.e('DioException occurred while fetching user todos: ${e.message}', error: e);

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          throw const NetworkFailure('Connection timeout. Please check your internet connection.');

        case DioExceptionType.connectionError:
          throw const NetworkFailure('Unable to connect to server. Please check your internet connection.');

        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          if (statusCode != null) {
            if (statusCode >= 500) {
              throw const ServerFailure('Server error occurred. Please try again later.');
            } else if (statusCode == 404) {
              throw const ServerFailure('Todos not found for this user.');
            } else if (statusCode >= 400) {
              throw ServerFailure('Client error: ${e.response?.data?['message'] ?? 'Bad request'}');
            }
          }
          throw ServerFailure('HTTP Error: ${e.message ?? 'Unknown error'}');

        case DioExceptionType.cancel:
          throw const NetworkFailure('Request was cancelled');

        default:
          throw ServerFailure('Network error: ${e.message ?? 'Unknown error'}');
      }
    } catch (e) {
      _logger.e('Unexpected error occurred while fetching user todos: $e');
      if (e is Failure) {
        rethrow;
      }
      throw ServerFailure('Unexpected error: ${e.toString()}');
    }
  }

  Future<UserModel> getUser(int userId) async {
    try {
      _logger.d('Fetching user details for ID: $userId');

      final response = await _apiClient.get('/users/$userId');

      if (response.data != null && response.data is Map<String, dynamic>) {
        final userData = response.data as Map<String, dynamic>;
        final user = UserModel.fromJson(userData);

        _logger.d('Successfully fetched user details for ID: $userId');
        return user;
      } else {
        throw const ServerFailure('Empty or invalid response received');
      }

    } on DioException catch (e) {
      _logger.e('DioException occurred while fetching user details: ${e.message}', error: e);

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          throw const NetworkFailure('Connection timeout. Please check your internet connection.');

        case DioExceptionType.connectionError:
          throw const NetworkFailure('Unable to connect to server. Please check your internet connection.');

        case DioExceptionType.badResponse:
          final statusCode = e.response?.statusCode;
          if (statusCode != null) {
            if (statusCode >= 500) {
              throw const ServerFailure('Server error occurred. Please try again later.');
            } else if (statusCode == 404) {
              throw const ServerFailure('User not found.');
            } else if (statusCode >= 400) {
              throw ServerFailure('Client error: ${e.response?.data?['message'] ?? 'Bad request'}');
            }
          }
          throw ServerFailure('HTTP Error: ${e.message ?? 'Unknown error'}');

        case DioExceptionType.cancel:
          throw const NetworkFailure('Request was cancelled');

        default:
          throw ServerFailure('Network error: ${e.message ?? 'Unknown error'}');
      }
    } catch (e) {
      _logger.e('Unexpected error occurred while fetching user details: $e');
      if (e is Failure) {
        rethrow;
      }
      throw ServerFailure('Unexpected error: ${e.toString()}');
    }
  }
}