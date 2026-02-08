import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../providers/providers.dart';
import '../models/destination.dart';

class SearchBarWidget extends ConsumerStatefulWidget {
  final void Function(Destination destination) onDestinationSelected;

  const SearchBarWidget({super.key, required this.onDestinationSelected});

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends ConsumerState<SearchBarWidget> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _showResults = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchResultsProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Search field
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              const Icon(Icons.train, color: AppTheme.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    hintText: 'Search destinations...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.grey),
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                  onChanged: (value) {
                    ref.read(searchQueryProvider.notifier).state = value;
                    setState(() => _showResults = value.isNotEmpty);
                  },
                ),
              ),
              if (_controller.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _controller.clear();
                    ref.read(searchQueryProvider.notifier).state = '';
                    setState(() => _showResults = false);
                    _focusNode.unfocus();
                  },
                ),
              Container(
                margin: const EdgeInsets.all(6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.secondary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '€63',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Search results dropdown
        if (_showResults)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 250),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.97),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: searchResults.when(
              data: (destinations) {
                if (destinations.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No destinations found',
                        style: TextStyle(color: Colors.grey)),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: destinations.length,
                  separatorBuilder: (_, __) =>
                      Divider(height: 1, color: Colors.grey.shade200),
                  itemBuilder: (context, index) {
                    final dest = destinations[index];
                    return ListTile(
                      dense: true,
                      leading: Icon(Icons.location_city,
                          color: AppTheme.getTimeColor(
                              dest.travelTimeMinutes)),
                      title: Text(dest.city,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(dest.state,
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600)),
                      trailing: Text(
                        dest.formattedTime,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              AppTheme.getTimeColor(dest.travelTimeMinutes),
                        ),
                      ),
                      onTap: () {
                        widget.onDestinationSelected(dest);
                        _controller.clear();
                        ref.read(searchQueryProvider.notifier).state = '';
                        setState(() => _showResults = false);
                        _focusNode.unfocus();
                      },
                    );
                  },
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Error: $e',
                    style: const TextStyle(color: Colors.red)),
              ),
            ),
          ),
      ],
    );
  }
}
