import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/voting.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class VotingProvider extends ChangeNotifier {
  User? _user;
  List<Voting> _votings = [];
  Map<String, String> _userVotes = {};
  Map<String, List<VoteResult>> _votingResults = {};
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  List<Voting> get votings => _votings;
  Map<String, String> get userVotes => _userVotes;
  Map<String, List<VoteResult>> get votingResults => _votingResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get username => _user?.name;

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await ApiService.register(
        name: name,
        email: email,
        password: password,
      );

      if (result['success']) {
        _setLoading(false);
        return true;
      } else {
        _setError(result['message']);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> login(
    String? text, {
    required String email,
    required String password,
    required String name,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await ApiService.login(email: email, password: password);

      if (result['success']) {
        _user = result['user'];
        ApiService.setToken(result['token']);

        // Save token to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', result['token']);
        await prefs.setString('user_id', _user!.id);
        await prefs.setString('user_name', _user!.name);
        await prefs.setString('user_email', _user!.email);

        await _loadInitialData();
        _setLoading(false);
        return true;
      } else {
        _setError(result['message']);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);

    try {
      await ApiService.logout();

      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      _user = null;
      _votings = [];
      _userVotes = {};
      _votingResults = {};

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null) {
      ApiService.setToken(token);
      _user = User(
        id: prefs.getString('user_id') ?? '',
        name: prefs.getString('user_name') ?? '',
        email: prefs.getString('user_email') ?? '',
      );

      await _loadInitialData();
      return true;
    }

    return false;
  }

  Future<void> _loadInitialData() async {
    try {
      await Future.wait([loadVotings(), loadUserVotes()]);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadVotings() async {
    _setLoading(true);
    _setError(null);

    try {
      _votings = await ApiService.getVotings();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUserVotes() async {
    try {
      _userVotes = await ApiService.getUserVotes();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<bool> vote(String votingId, String optionId) async {
    _setLoading(true);
    _setError(null);

    try {
      final result = await ApiService.submitVote(
        votingId: votingId,
        optionId: optionId,
      );

      if (result['success']) {
        _userVotes[votingId] = optionId;

        // Refresh voting results for this voting
        await loadVotingResults(votingId);

        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError(result['message']);
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<void> loadVotingResults(String votingId) async {
    try {
      final results = await ApiService.getVotingResults(votingId);
      _votingResults[votingId] = results;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  bool hasVoted(String votingId) => _userVotes.containsKey(votingId);

  String? getUserVote(String votingId) => _userVotes[votingId];

  List<VoteResult>? getVotingResults(String votingId) =>
      _votingResults[votingId];

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
