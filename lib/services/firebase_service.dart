// lib/services/firebase_service.dart
// Handles all Firebase Realtime Database REST API calls

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../models/todo_model.dart';

class FirebaseService {
  // ---------------------------------------------------------------
  // IMPORTANT: Replace this with your Firebase project's database URL
  // Example: "https://YOUR-PROJECT-ID-default-rtdb.firebaseio.com"
  // ---------------------------------------------------------------
  static const String _databaseUrl =
      'https://taskflow-todo-31a9f-default-rtdb.firebaseio.com';

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> _getIdToken() async {
    try {
      return await _auth.currentUser?.getIdToken();
    } catch (e) {
      return null;
    }
  }

  String get _userId => _auth.currentUser?.uid ?? '';

  // ─── CREATE ────────────────────────────────────────────────────
  Future<TodoModel?> addTodo({
    required String title,
    required String description,
    required String priority,
  }) async {
    final token = await _getIdToken();
    final url = Uri.parse('$_databaseUrl/todos/$_userId.json?auth=$token');

    final todo = TodoModel(
      id: '',
      title: title,
      description: description,
      priority: priority,
      isCompleted: false,
      createdAt: DateTime.now(),
      userId: _userId,
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(todo.toJson()),
    );

    debugPrint('addTodo url: $url');
    debugPrint('addTodo status: ${response.statusCode}');
    debugPrint('addTodo body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return todo.copyWith(id: data['name'] as String);
    }
    return null;
  }

  // ─── READ ──────────────────────────────────────────────────────
  Future<List<TodoModel>> getTodos() async {
    final token = await _getIdToken();
    final url = Uri.parse('$_databaseUrl/todos/$_userId.json?auth=$token');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data == null) return [];

      final List<TodoModel> todos = [];
      (data as Map<dynamic, dynamic>).forEach((key, value) {
        todos.add(TodoModel.fromJson(value as Map, key.toString()));
      });
      todos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return todos;
    }
    return [];
  }

  // ─── UPDATE ────────────────────────────────────────────────────
  Future<bool> updateTodo(TodoModel todo) async {
    final token = await _getIdToken();
    final url = Uri.parse(
        '$_databaseUrl/todos/$_userId/${todo.id}.json?auth=$token');

    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(todo.toJson()),
    );
    return response.statusCode == 200;
  }

  // ─── DELETE ────────────────────────────────────────────────────
  Future<bool> deleteTodo(String todoId) async {
    final token = await _getIdToken();
    final url = Uri.parse(
        '$_databaseUrl/todos/$_userId/$todoId.json?auth=$token');

    final response = await http.delete(url);
    return response.statusCode == 200;
  }

  // ─── TOGGLE COMPLETE ─────────────────────────────────────────
  Future<bool> toggleTodoCompletion(String todoId, bool isCompleted) async {
    final token = await _getIdToken();
    final url = Uri.parse(
        '$_databaseUrl/todos/$_userId/$todoId.json?auth=$token');

    final response = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'isCompleted': isCompleted}),
    );
    return response.statusCode == 200;
  }
}
