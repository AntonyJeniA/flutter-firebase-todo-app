// lib/providers/todo_provider.dart
// Manages task state using Provider

import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import '../services/firebase_service.dart';

enum FilterType { all, active, completed }

enum TodoStatus { initial, loading, loaded, error }

class TodoProvider extends ChangeNotifier {
  final FirebaseService _service = FirebaseService();

  List<TodoModel> _todos = [];
  TodoStatus _status = TodoStatus.initial;
  String? _errorMessage;
  FilterType _filter = FilterType.all;
  String _searchQuery = '';

  List<TodoModel> get todos => _filteredTodos();
  TodoStatus get status => _status;
  String? get errorMessage => _errorMessage;
  FilterType get filter => _filter;
  String get searchQuery => _searchQuery;

  int get totalCount => _todos.length;
  int get completedCount => _todos.where((t) => t.isCompleted).length;
  int get activeCount => _todos.where((t) => !t.isCompleted).length;

  List<TodoModel> _filteredTodos() {
    List<TodoModel> result = List.from(_todos);

    // Apply filter
    switch (_filter) {
      case FilterType.active:
        result = result.where((t) => !t.isCompleted).toList();
        break;
      case FilterType.completed:
        result = result.where((t) => t.isCompleted).toList();
        break;
      default:
        break;
    }

    // Apply search
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result
          .where((t) =>
              t.title.toLowerCase().contains(query) ||
              t.description.toLowerCase().contains(query))
          .toList();
    }

    return result;
  }

  // ─── FETCH ALL TODOS ─────────────────────────────────────────
  Future<void> fetchTodos() async {
    _status = TodoStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _todos = await _service.getTodos();
      _status = TodoStatus.loaded;
    } catch (e) {
      _status = TodoStatus.error;
      _errorMessage = 'Failed to load tasks. Please check your connection.';
    }
    notifyListeners();
  }

  // ─── ADD TODO ────────────────────────────────────────────────
  Future<bool> addTodo({
    required String title,
    required String description,
    required String priority,
  }) async {
    try {
      final todo = await _service.addTodo(
        title: title,
        description: description,
        priority: priority,
      );
      if (todo != null) {
        _todos.insert(0, todo);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = 'Failed to add task. Please try again.';
      notifyListeners();
      return false;
    }
  }

  // ─── UPDATE TODO ─────────────────────────────────────────────
  Future<bool> updateTodo(TodoModel updated) async {
    try {
      final success = await _service.updateTodo(updated);
      if (success) {
        final index = _todos.indexWhere((t) => t.id == updated.id);
        if (index != -1) {
          _todos[index] = updated;
          notifyListeners();
        }
      }
      return success;
    } catch (e) {
      _errorMessage = 'Failed to update task. Please try again.';
      notifyListeners();
      return false;
    }
  }

  // ─── DELETE TODO ─────────────────────────────────────────────
  Future<bool> deleteTodo(String todoId) async {
    final todo = _todos.firstWhere((t) => t.id == todoId);
    final index = _todos.indexWhere((t) => t.id == todoId);

    // Optimistic update
    _todos.removeAt(index);
    notifyListeners();

    try {
      final success = await _service.deleteTodo(todoId);
      if (!success) {
        _todos.insert(index, todo);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _todos.insert(index, todo);
      _errorMessage = 'Failed to delete task.';
      notifyListeners();
      return false;
    }
  }

  // ─── TOGGLE COMPLETION ───────────────────────────────────────
  Future<void> toggleCompletion(String todoId) async {
    final index = _todos.indexWhere((t) => t.id == todoId);
    if (index == -1) return;

    final todo = _todos[index];
    final newValue = !todo.isCompleted;

    // Optimistic update
    _todos[index] = todo.copyWith(isCompleted: newValue);
    notifyListeners();

    try {
      await _service.toggleTodoCompletion(todoId, newValue);
    } catch (e) {
      // Revert on failure
      _todos[index] = todo;
      notifyListeners();
    }
  }

  // ─── FILTER & SEARCH ─────────────────────────────────────────
  void setFilter(FilterType filter) {
    _filter = filter;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearTodos() {
    _todos = [];
    _status = TodoStatus.initial;
    _filter = FilterType.all;
    _searchQuery = '';
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
