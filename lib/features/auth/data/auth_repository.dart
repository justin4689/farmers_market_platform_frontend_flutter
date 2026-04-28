import '../../../services/api_service.dart';
import '../../../core/constants/api_urls.dart';
import '../domain/user_model.dart';

class AuthRepository {
  final ApiService _api;

  AuthRepository(this._api);

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _api.post(
        ApiUrls.login,
        data: {'email': email, 'password': password},
      );
      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String;
      await _api.saveToken(token);
      return UserModel.fromJson(data['user'] as Map<String, dynamic>, token);
    } catch (e) {
      throw _api.handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _api.post(ApiUrls.logout);
    } catch (_) {
      // Ignore logout errors — always clear local token
    } finally {
      await _api.deleteToken();
    }
  }

  Future<bool> hasToken() async {
    final token = await _api.getToken();
    return token != null;
  }
}
