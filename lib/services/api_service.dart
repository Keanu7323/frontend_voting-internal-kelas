import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../models/user.dart';
import '../../../models/voting.dart';

class ApiService {
  static const String baseUrl = 'https://your-api-url.com/api';
  static String? _token;

  // Auth endpoints
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Registration failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _token = data['token'];
        final user = User.fromJson(data['user']);
        return {'success': true, 'user': user, 'token': data['token']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  static Future<void> logout() async {
    _token = null;
    // Optionally call logout endpoint
    try {
      await http.post(
        Uri.parse('$baseUrl/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
    } catch (e) {
      // Handle error silently
    }
  }

  // Voting endpoints
  static Future<List<Voting>> getVotings() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/votings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> votingsJson = data['votings'];
        return votingsJson.map((json) => Voting.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load votings');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> submitVote({
    required String votingId,
    required String optionId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/votes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: jsonEncode({
          'votingId': votingId,
          'optionId': optionId,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Vote submission failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  static Future<Map<String, String>> getUserVotes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/votes'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final Map<String, String> userVotes = {};

        for (var vote in data['votes']) {
          userVotes[vote['votingId']] = vote['optionId'];
        }

        return userVotes;
      } else {
        throw Exception('Failed to load user votes');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  static Future<List<VoteResult>> getVotingResults(String votingId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/votings/$votingId/results'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> resultsJson = data['results'];
        return resultsJson.map((json) => VoteResult.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load voting results');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  static Future<User?> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['user']);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static void setToken(String token) {
    _token = token;
  }

  static String? getToken() {
    return _token;
  }
}