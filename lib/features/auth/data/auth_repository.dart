import '../../../services/api_service.dart';
import '../../../core/constants/api_urls.dart';
import '../domain/user_model.dart';

class AuthRepository {
  final ApiService _api;

  AuthRepository(this._api);

  /// Returns a record of (token, user) on success.
  Future<(String token, UserModel user)> login(
    String email,
    String password,
  ) async {
    try {
      final response = await _api.post(
        ApiUrls.login,
        data: {'email': email, 'password': password},
      );
      final body = response.data as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      await _api.saveToken(token);
      await _api.saveUser(user.toJson());
      return (token, user);
    } catch (e) {
      throw _api.handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _api.post(ApiUrls.logout);
    } catch (_) {
      // Always clear local token even if the server call fails.
    } finally {
      await _api.deleteToken();
      await _api.deleteUser();
    }
  }

  Future<bool> hasToken() async {
    final token = await _api.getToken();
    return token != null;
  }

  Future<UserModel?> getSavedUser() async {
    final json = await _api.getSavedUser();
    if (json == null) return null;
    return UserModel.fromJson(json);
  }
}
