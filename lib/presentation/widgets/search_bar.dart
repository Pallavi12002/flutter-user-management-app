import 'dart:async';

import 'package:flutter/material.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final String? hintText;
  final Duration debounceDuration;

  const CustomSearchBar({
    Key? key,
    required this.controller,
    required this.onChanged,
    this.hintText,
    this.debounceDuration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  bool _hasFocus = false;
  late FocusNode _focusNode;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
    widget.controller.addListener(_handleTextChange);
  }

  void _handleFocusChange() {
    setState(() => _hasFocus = _focusNode.hasFocus);
  }

  void _handleTextChange() {
    // Cancel previous timer if it exists
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }

    // Start new debounce timer
    _debounceTimer = Timer(widget.debounceDuration, () {
      if (mounted) {
        widget.onChanged(widget.controller.text.trim());
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _focusNode.removeListener(_handleFocusChange);
    widget.controller.removeListener(_handleTextChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _hasFocus
                ? Colors.blue.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            spreadRadius: _hasFocus ? 2 : 1,
            blurRadius: _hasFocus ? 8 : 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: (_) {}, // Empty callback - handled by listener
        style: const TextStyle(fontSize: 16),
        textInputAction: TextInputAction.search,
        onSubmitted: (query) {
          widget.onChanged(query.trim());
          _focusNode.unfocus();
        },
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'Search users by name, email...',
          hintStyle: TextStyle(
            color: Colors.grey[400],
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: _hasFocus ? Colors.blue : Colors.grey[400],
          ),
          suffixIcon: widget.controller.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: Colors.grey),
            onPressed: _clearSearch,
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Colors.blue,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  void _clearSearch() {
    widget.controller.clear();
    widget.onChanged('');
    _focusNode.unfocus();
  }
}