import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';
import '../providers/providers.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  static const String _ticketUrl = 'https://www.deutschlandticket.de';

  Future<void> _openTicketUrl() async {
    try {
      await launchUrl(Uri.parse(_ticketUrl));
    } catch (_) {
      // Could not launch URL
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coverageAsync = ref.watch(coverageProvider);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeroHeader(context),
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'What\'s Included'),
            const SizedBox(height: 12),
            _buildTransportGrid(context),
            const SizedBox(height: 28),
            _buildSectionTitle(context, 'How Far Can You Go?'),
            const SizedBox(height: 12),
            _buildCompassCard(context),
            const SizedBox(height: 28),
            _buildQuickStats(context, coverageAsync),
            const SizedBox(height: 28),
            _buildNotIncludedCard(context),
            const SizedBox(height: 28),
            _buildBuyTicketSection(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 1. Hero Header
  // ---------------------------------------------------------------------------
  Widget _buildHeroHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary,
            Color(0xFF283593),
            Color(0xFF3949AB),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row with train icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.train,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Deutschlandticket',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Price badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.secondary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'All of Germany for \u20AC63/month',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'Unlimited travel on all regional trains (RE/RB), '
                'S-Bahn, U-Bahn, trams, and buses across Germany.',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Buy button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openTicketUrl,
                  icon: const Icon(Icons.open_in_new, size: 20),
                  label: const Text(
                    'Buy Your Ticket',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Section title helper
  // ---------------------------------------------------------------------------
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppTheme.primary,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. What's Included -- transport grid
  // ---------------------------------------------------------------------------
  Widget _buildTransportGrid(BuildContext context) {
    final items = <_TransportItem>[
      _TransportItem(
        type: 'RE',
        name: 'Regional Express',
        description: 'Fast regional trains across states',
        icon: Icons.train,
        color: AppTheme.getTransportColor('RE'),
      ),
      _TransportItem(
        type: 'RB',
        name: 'Regionalbahn',
        description: 'Local trains connecting nearby cities',
        icon: Icons.directions_railway,
        color: AppTheme.getTransportColor('RB'),
      ),
      _TransportItem(
        type: 'S_BAHN',
        name: 'S-Bahn',
        description: 'Suburban rail in metro areas',
        icon: Icons.directions_transit,
        color: AppTheme.getTransportColor('S_BAHN'),
      ),
      _TransportItem(
        type: 'U_BAHN',
        name: 'U-Bahn',
        description: 'Underground metro in major cities',
        icon: Icons.subway,
        color: AppTheme.getTransportColor('U_BAHN'),
      ),
      _TransportItem(
        type: 'TRAM',
        name: 'Tram',
        description: 'Streetcars throughout urban areas',
        icon: Icons.tram,
        color: AppTheme.getTransportColor('TRAM'),
      ),
      _TransportItem(
        type: 'BUS',
        name: 'Bus',
        description: 'City and regional bus networks',
        icon: Icons.directions_bus,
        color: AppTheme.getTransportColor('BUS'),
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.55,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildTransportCard(item);
        },
      ),
    );
  }

  Widget _buildTransportCard(_TransportItem item) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: item.color.withOpacity(0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: item.color, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppTheme.getTransportLabel(item.type),
                        style: TextStyle(
                          color: item.color,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              item.description,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Compass card -- coverage extent
  // ---------------------------------------------------------------------------
  Widget _buildCompassCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
          child: Column(
            children: [
              // North
              _buildCompassDirection(
                icon: Icons.north,
                direction: 'North',
                cities: 'Kiel / Stralsund',
                color: AppTheme.primary,
              ),
              const SizedBox(height: 16),

              // East & West row
              Row(
                children: [
                  Expanded(
                    child: _buildCompassDirection(
                      icon: Icons.west,
                      direction: 'West',
                      cities: 'Aachen / Trier',
                      color: AppTheme.primary,
                      alignment: CrossAxisAlignment.start,
                    ),
                  ),
                  // Center compass icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.primary, Color(0xFF3949AB)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.explore,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  Expanded(
                    child: _buildCompassDirection(
                      icon: Icons.east,
                      direction: 'East',
                      cities: 'Dresden / Passau',
                      color: AppTheme.primary,
                      alignment: CrossAxisAlignment.end,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // South
              _buildCompassDirection(
                icon: Icons.south,
                direction: 'South',
                cities: 'Garmisch / Konstanz',
                color: AppTheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompassDirection({
    required IconData icon,
    required String direction,
    required String cities,
    required Color color,
    CrossAxisAlignment alignment = CrossAxisAlignment.center,
  }) {
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          direction,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          cities,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 4. Quick Stats
  // ---------------------------------------------------------------------------
  Widget _buildQuickStats(
      BuildContext context, AsyncValue<Map<String, dynamic>> coverageAsync) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.location_city,
              value: '52+',
              label: 'Cities',
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.route,
              value: '110+',
              label: 'Connections',
              color: AppTheme.accent,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.map,
              value: 'All 16',
              label: 'States',
              color: AppTheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 5. NOT Included warning card
  // ---------------------------------------------------------------------------
  Widget _buildNotIncludedCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.secondary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.secondary.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.secondary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
                      color: AppTheme.secondary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'NOT Included',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildExclusionItem(
                icon: Icons.speed,
                text: 'ICE, IC, EC long-distance trains',
              ),
              const SizedBox(height: 10),
              _buildExclusionItem(
                icon: Icons.directions_bus_filled,
                text: 'FlixBus / FlixTrain',
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'These require separate tickets.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.secondary.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExclusionItem({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        const Icon(Icons.close, color: AppTheme.secondary, size: 18),
        const SizedBox(width: 10),
        Icon(icon, color: Colors.grey.shade600, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 6. Buy Ticket section
  // ---------------------------------------------------------------------------
  Widget _buildBuyTicketSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primary,
              Color(0xFF283593),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.confirmation_number,
                color: Colors.white,
                size: 40,
              ),
              const SizedBox(height: 16),
              const Text(
                'Get Your Deutschlandticket',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Available at all DB ticket machines and the DB Navigator app.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openTicketUrl,
                  icon: const Icon(Icons.language, size: 20),
                  label: const Text(
                    'deutschlandticket.de',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private data class for transport grid items
// ---------------------------------------------------------------------------
class _TransportItem {
  final String type;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  const _TransportItem({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
}
