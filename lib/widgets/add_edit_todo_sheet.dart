// lib/widgets/add_edit_todo_sheet.dart
// Bottom sheet for adding or editing a task

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/todo_model.dart';
import '../providers/todo_provider.dart';
import '../utils/app_theme.dart';

class AddEditTodoSheet extends StatefulWidget {
  final TodoModel? existingTodo;

  const AddEditTodoSheet({super.key, this.existingTodo});

  @override
  State<AddEditTodoSheet> createState() => _AddEditTodoSheetState();
}

class _AddEditTodoSheetState extends State<AddEditTodoSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _priority = 'medium';
  bool _isLoading = false;

  bool get _isEditing => widget.existingTodo != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleCtrl.text = widget.existingTodo!.title;
      _descCtrl.text = widget.existingTodo!.description;
      _priority = widget.existingTodo!.priority ?? 'medium';
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final provider = context.read<TodoProvider>();

    bool success;
    if (_isEditing) {
      final updated = widget.existingTodo!.copyWith(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        priority: _priority,
      );
      success = await provider.updateTodo(updated);
    } else {
      success = await provider.addTodo(
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        priority: _priority,
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'Task updated!' : 'Task added!'),
            backgroundColor: AppTheme.accent,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Something went wrong'),
            backgroundColor: AppTheme.priorityHigh,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Handle ───────────────────────────────────────
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textHint,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // ── Title ─────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _isEditing ? Icons.edit_rounded : Icons.add_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _isEditing ? 'Edit Task' : 'New Task',
                  style: GoogleFonts.poppins(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // ── Task Title ─────────────────────────────────────
            TextFormField(
              controller: _titleCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Task Title *',
                prefixIcon: Icon(Icons.title_rounded, color: AppTheme.primary),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 16),
            // ── Description ──────────────────────────────────
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                prefixIcon:
                    Icon(Icons.notes_rounded, color: AppTheme.primary),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),
            // ── Priority ──────────────────────────────────────
            Text(
              'Priority',
              style: GoogleFonts.poppins(
                color: AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            _buildPrioritySelector(),
            const SizedBox(height: 28),
            // ── Submit Button ────────────────────────────────
            ElevatedButton(
              onPressed: _isLoading ? null : _handleSubmit,
              child: _isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(_isEditing ? 'Update Task' : 'Add Task'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrioritySelector() {
    final priorities = [
      ('low', 'Low', AppTheme.priorityLow),
      ('medium', 'Medium', AppTheme.priorityMedium),
      ('high', 'High', AppTheme.priorityHigh),
    ];

    return Row(
      children: priorities.map((p) {
        final isSelected = _priority == p.$1;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _priority = p.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? p.$3.withAlpha(40) : AppTheme.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? p.$3 : const Color(0xFF2A2A4E),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    AppTheme.priorityIcon(p.$1),
                    color: isSelected ? p.$3 : AppTheme.textHint,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    p.$2,
                    style: GoogleFonts.poppins(
                      color: isSelected ? p.$3 : AppTheme.textHint,
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
