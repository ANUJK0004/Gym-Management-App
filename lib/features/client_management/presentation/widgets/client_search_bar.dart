import 'package:flutter/material.dart';

class ClientSearchBar extends StatefulWidget {
  const ClientSearchBar({
    super.key,
    required this.onChanged,
    this.initialValue = '',
  });

  final ValueChanged<String> onChanged;
  final String initialValue;

  @override
  State<ClientSearchBar> createState() => _ClientSearchBarState();
}

class _ClientSearchBarState extends State<ClientSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161922),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF262C3A),
          width: 0.8,
        ),
      ),
      child: TextField(
        controller: _controller,
        onChanged: (val) {
          setState(() {});
          widget.onChanged(val);
        },
        cursorColor: const Color(0xFF38BDF8),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14.5,
        ),
        decoration: InputDecoration(
          hintText: 'Search clients...',
          hintStyle: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF64748B),
            size: 20,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _controller.clear();
                    setState(() {});
                    widget.onChanged('');
                  },
                  child: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF64748B),
                    size: 18,
                  ),
                )
              : null,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
        ),
      ),
    );
  }
}
