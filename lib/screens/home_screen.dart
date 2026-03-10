// lib/screens/home_screen.dart
// Main task list screen

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../providers/todo_provider.dart';
import '../models/todo_model.dart';
import '../utils/app_theme.dart';
import '../widgets/todo_card.dart';
import '../widgets/add_edit_todo_sheet.dart';
import '../widgets/stats_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/filter_chip_row.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TodoProvider>().fetchTodos();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showAddTodoSheet([TodoModel? todo]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditTodoSheet(existingTodo: todo),
    );
  }

  Future<void> _showSignOutDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Sign Out',
          style: GoogleFonts.poppins(
              color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style:
              GoogleFonts.poppins(color: AppTheme.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.priorityHigh,
              minimumSize: const Size(90, 40),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      context.read<TodoProvider>().clearTodos();
      context.read<AuthProvider>().signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final todoProvider = context.watch<TodoProvider>();
    final user = auth.user;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.center,
            colors: [Color(0xFF1A0533), AppTheme.bgDark],
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── App Bar ────────────────────────────────────
              _buildAppBar(user?.displayName ?? 'User', user?.photoURL),
              // ── Search Bar ─────────────────────────────────
              _buildSearchBar(todoProvider),
              // ── Stats Header ────────────────────────────────
              StatsHeader(provider: todoProvider),
              // ── Filter Chips ────────────────────────────────
              FilterChipRow(provider: todoProvider),
              const SizedBox(height: 8),
              // ── Task List ──────────────────────────────────
              Expanded(
                child: _buildTaskList(todoProvider),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildAppBar(String name, String? photoUrl) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: GoogleFonts.poppins(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _showSignOutDialog,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryDark],
                ),
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundImage:
                    photoUrl != null ? NetworkImage(photoUrl) : null,
                backgroundColor: AppTheme.bgCard,
                child: photoUrl == null
                    ? Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(TodoProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: TextField(
        controller: _searchCtrl,
        onChanged: provider.setSearchQuery,
        decoration: InputDecoration(
          hintText: 'Search tasks...',
          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded,
                      color: AppTheme.textSecondary),
                  onPressed: () {
                    _searchCtrl.clear();
                    provider.setSearchQuery('');
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildTaskList(TodoProvider provider) {
    if (provider.status == TodoStatus.loading &&
        provider.todos.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    if (provider.status == TodoStatus.error) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded,
                color: AppTheme.priorityHigh, size: 48),
            const SizedBox(height: 16),
            Text(
              provider.errorMessage ?? 'Something went wrong',
              style: GoogleFonts.poppins(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: provider.fetchTodos,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(150, 46)),
            ),
          ],
        ),
      );
    }

    final todos = provider.todos;

    if (todos.isEmpty) {
      return EmptyState(filter: provider.filter);
    }

    return RefreshIndicator(
      color: AppTheme.primary,
      backgroundColor: AppTheme.bgCard,
      onRefresh: provider.fetchTodos,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        itemCount: todos.length,
        itemBuilder: (ctx, i) {
          return TodoCard(
            todo: todos[i],
            onTap: () => _showAddTodoSheet(todos[i]),
            onToggle: () =>
                context.read<TodoProvider>().toggleCompletion(todos[i].id),
            onDelete: () =>
                context.read<TodoProvider>().deleteTodo(todos[i].id),
          );
        },
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => _showAddTodoSheet(),
      icon: const Icon(Icons.add_rounded),
      label: Text(
        'Add Task',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      backgroundColor: AppTheme.primary,
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning 🌅';
    if (hour < 17) return 'Good afternoon ☀️';
    return 'Good evening 🌙';
  }
}
