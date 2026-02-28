import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/transport_line.dart';
import '../providers/providers.dart';

class TransportLinesScreen extends ConsumerStatefulWidget {
  final String transportType;
  final String transportName;
  final IconData icon;
  final Color color;

  const TransportLinesScreen({
    super.key,
    required this.transportType,
    required this.transportName,
    required this.icon,
    required this.color,
  });

  @override
  ConsumerState<TransportLinesScreen> createState() =>
      _TransportLinesScreenState();
}

class _TransportLinesScreenState extends ConsumerState<TransportLinesScreen> {
  String _selectedCity = '';

  @override
  Widget build(BuildContext context) {
    final linesAsync = ref.watch(transportLinesProvider(
        (type: widget.transportType, city: _selectedCity)));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(widget.icon, size: 24),
            const SizedBox(width: 8),
            Text(widget.transportName),
          ],
        ),
        backgroundColor: widget.color,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // City filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: widget.color.withOpacity(0.05),
            child: Row(
              children: [
                const Icon(Icons.filter_list, size: 20),
                const SizedBox(width: 8),
                const Text('City: ', style: TextStyle(fontWeight: FontWeight.w600)),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _CityChip(
                          label: 'All',
                          isSelected: _selectedCity.isEmpty,
                          color: widget.color,
                          onTap: () => setState(() => _selectedCity = ''),
                        ),
                        for (final city in [
                          'Berlin', 'Munich', 'Hamburg', 'Frankfurt',
                          'Cologne', 'Leipzig', 'Dresden', 'Freiburg'
                        ])
                          _CityChip(
                            label: city,
                            isSelected: _selectedCity == city,
                            color: widget.color,
                            onTap: () => setState(() => _selectedCity = city),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lines list
          Expanded(
            child: linesAsync.when(
              data: (lines) {
                if (lines.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(widget.icon,
                            size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          'No ${widget.transportName} lines found',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                        if (_selectedCity.isNotEmpty)
                          TextButton(
                            onPressed: () =>
                                setState(() => _selectedCity = ''),
                            child: const Text('Show all cities'),
                          ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: lines.length,
                  itemBuilder: (context, index) =>
                      _LineCard(line: lines[index], color: widget.color),
                );
              },
              loading: () => Center(
                child: CircularProgressIndicator(color: widget.color),
              ),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text('Could not load lines', style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CityChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _CityChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : color,
            fontWeight: FontWeight.w600,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.white,
        selectedColor: color,
        showCheckmark: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
    );
  }
}

class _LineCard extends StatelessWidget {
  final TransportLine line;
  final Color color;

  const _LineCard({required this.line, required this.color});

  @override
  Widget build(BuildContext context) {
    final lineColor = line.color != null
        ? Color(int.parse(line.color!.replaceFirst('#', '0xFF')))
        : color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: lineColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Line badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: lineColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                line.lineName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.city,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    line.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.place, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        '${line.stops.length} stops',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (line.isCircular) ...[
                        const SizedBox(width: 10),
                        Icon(Icons.loop, size: 14, color: lineColor),
                        const SizedBox(width: 4),
                        Text(
                          'Ring line',
                          style: TextStyle(
                            fontSize: 11,
                            color: lineColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
