/*import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_state.dart';
import 'api_service.dart';
import 'add_station_screen.dart';
import 'edit_station_screen.dart';
import 'station_reports_screen.dart';

class OperatorDashboardScreen extends StatefulWidget {
  final Map<String, dynamic>? station;

  const OperatorDashboardScreen({super.key, this.station});

  @override
  State<OperatorDashboardScreen> createState() =>
      _OperatorDashboardScreenState();
}

class _OperatorDashboardScreenState extends State<OperatorDashboardScreen> {
  static const Color _brandGreen = Color(0xFF2E7D32);

  Map<String, dynamic>? _station;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _station = widget.station;
  }

  Future<void> _refresh() async {
    setState(() {});
  }

  Color _fuelColor(String type) {
    switch (type) {
      case 'Petrol/Diesel':
        return Colors.amber.shade700;
      case 'LPG':
        return Colors.blue.shade600;
      case 'EV':
        return Colors.green.shade600;
      default:
        return Colors.grey;
    }
  }

  IconData _fuelIcon(String type) {
    switch (type) {
      case 'Petrol/Diesel':
        return Icons.local_gas_station;
      case 'LPG':
        return Icons.gas_meter;
      case 'EV':
        return Icons.electric_bolt;
      default:
        return Icons.help_outline;
    }
  }

  // PRICE DISPLAY METHODS
  Widget _buildFuelPricesSection(Map<String, dynamic> station) {
    final type = station['type'];

    if (type == 'Petrol/Diesel') {
      final petrolData = station['petrol'];
      final dieselData = station['diesel'];

      List<Widget> priceWidgets = [];

      if (petrolData != null && petrolData is Map) {
        final octanes = petrolData['octane_ratings'];
        if (octanes != null && octanes is List && octanes.isNotEmpty) {
          priceWidgets.add(const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 4),
            child: Text('PETROL',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.amber)),
          ));
          for (var octane in octanes) {
            priceWidgets.add(Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(octane['name'] ?? 'N/A'),
                  Row(
                    children: [
                      Text('GH₵ ${octane['price']}/L',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green)),
                      const SizedBox(width: 8),
                      Icon(
                        octane['in_stock'] == true
                            ? Icons.check_circle
                            : Icons.cancel,
                        size: 14,
                        color: octane['in_stock'] == true
                            ? Colors.green
                            : Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ));
          }
        }
      }

      // Add diesel prices if they exist
      if (dieselData != null && dieselData is Map) {
        final diesels = dieselData['diesel_types'];
        if (diesels != null && diesels is List && diesels.isNotEmpty) {
          priceWidgets.add(const Padding(
            padding: EdgeInsets.only(top: 8, bottom: 4),
            child: Text('DIESEL',
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.amber)),
          ));
          for (var diesel in diesels) {
            priceWidgets.add(Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(diesel['name'] ?? 'N/A'),
                  Row(
                    children: [
                      Text('GH₵ ${diesel['price']}/L',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green)),
                      const SizedBox(width: 8),
                      Icon(
                        diesel['in_stock'] == true
                            ? Icons.check_circle
                            : Icons.cancel,
                        size: 14,
                        color: diesel['in_stock'] == true
                            ? Colors.green
                            : Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ));
          }
        }
      }

      // Fallback: show simple price if no structured data
      if (priceWidgets.isEmpty && station['price'] != null) {
        priceWidgets.add(Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(station['price'],
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green)),
        ));
      }

      if (priceWidgets.isEmpty) {
        priceWidgets.add(const Padding(
          padding: EdgeInsets.only(top: 8),
          child: Text('No prices set', style: TextStyle(color: Colors.grey)),
        ));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FUEL PRICES',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                letterSpacing: 1.2),
          ),
          ...priceWidgets,
        ],
      );
    }

    if (type == 'EV') {
      final chargingPoints = station['charging_points'];

      List<Widget> evWidgets = [];

      if (chargingPoints != null &&
          chargingPoints is List &&
          chargingPoints.isNotEmpty) {
        for (var point in chargingPoints) {
          evWidgets.add(Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${point['connector'] ?? 'N/A'}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 14)),
                    Text('${point['power_kw'] ?? 0} kW',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('GH₵ ${point['price_per_kwh'] ?? 0}/kWh',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 14)),
                    Text(
                      point['available'] == true ? 'Available' : 'Busy',
                      style: TextStyle(
                          fontSize: 12,
                          color: point['available'] == true
                              ? Colors.green
                              : Colors.red),
                    ),
                  ],
                ),
              ],
            ),
          ));
        }
      } else if (station['price'] != null) {
        evWidgets.add(Text(station['price'],
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green)));
      } else {
        evWidgets.add(const Text('No charging prices set',
            style: TextStyle(color: Colors.grey)));
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CONNECTORS AT STATION',
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          ...evWidgets,
        ],
      );
    }

    // LPG  price
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        // Show LPG type as well
        if (station['lpg_type'] != null &&
            (station['lpg_type'] as List).isNotEmpty)
          Wrap(
            spacing: 8,
            children: (station['lpg_type'] as List)
                .map((type) => Chip(
                      label: Text(type, style: const TextStyle(fontSize: 12)),
                      backgroundColor: Colors.blue.shade50,
                    ))
                .toList(),
          ),
        const SizedBox(height: 8),
        Text(station['price'] ?? 'Not set',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green)),
        if (station['delivery_available'] == true)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.delivery_dining,
                    size: 16, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                const Text('Home Delivery Available',
                    style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
      ],
    );
  }

  // TOGGLE STATUS 
  Future<void> _toggleStatus() async {
    setState(() => _isLoading = true);

    try {
      final current = _station!['status'];
      final newStatus = current == 'Open' ? 'Closed' : 'Open';

      final token = AuthState.instance.token ?? '';
      await ApiService.updateStatus(
        token: token,
        stationId: _station!['id'],
        status: newStatus,
      );

      setState(() => _station!['status'] = newStatus);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Station marked as $newStatus'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stationName =
        _station != null ? (_station!['name'] ?? 'Unknown') : 'Unknown';
    final stationType =
        _station != null ? (_station!['type'] ?? 'Unknown') : 'Unknown';
    final stationStatus =
        _station != null ? (_station!['status'] ?? 'Unknown') : 'Unknown';
    final isPending = _station != null &&
        (_station!['verified'] == false || _station!['pending'] == true);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Station',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _brandGreen))
          : RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    if (_station == null) ...[
                      _buildNoStationWidget(),
                    ] else ...[
                      // PENDING APPROVAL BANNER
                      if (isPending)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Colors.orange.shade300, width: 1),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.hourglass_top,
                                  color: Colors.orange.shade700, size: 20),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  'Your station is pending approval. It will appear on the map once approved.',
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // STATION INFO CARD
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 8,
                                offset: Offset(0, 2)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _fuelColor(stationType)
                                        .withOpacity(0.15),
                                  ),
                                  child: Icon(
                                    _fuelIcon(stationType),
                                    color: _fuelColor(stationType),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        stationName,
                                        style: GoogleFonts.poppins(
                                          textStyle: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        stationType,
                                        style: const TextStyle(
                                            fontSize: 13, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 28),

                            // STATUS (Always show)
                            _infoRow(Icons.circle, 'Status', stationStatus,
                                valueColor: (stationStatus == 'Open' ||
                                        stationStatus == 'Available')
                                    ? Colors.green
                                    : Colors.red),

                            const SizedBox(height: 14),

                            // FUEL PRICES SECTION 
                            _buildFuelPricesSection(_station!),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      _sectionLabel('Actions'),
                      const SizedBox(height: 10),
                      _buildActionsCard(),
                      const SizedBox(height: 32),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildNoStationWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.add_business_outlined, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No station added yet',
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your station so drivers can find you on the map',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_location_alt),
              label: const Text('Add My Station'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final newStation = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(builder: (_) => const AddStationScreen()),
                );
                if (newStation != null && mounted) {
                  setState(() {
                    _station = newStation;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard() {
    final stationStatus = _station != null ? (_station!['status'] ?? '') : '';
    final isOpenOrAvailable =
        (stationStatus == 'Open' || stationStatus == 'Available');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(children: [
        _actionTile(
          icon:
              isOpenOrAvailable ? Icons.lock_outline : Icons.lock_open_outlined,
          iconColor: isOpenOrAvailable ? Colors.red : Colors.green,
          title: isOpenOrAvailable ? 'Mark as Closed' : 'Mark as Open',
          subtitle: 'Update your station availability',
          onTap: _toggleStatus,
        ),
        _actionTile(
          icon: Icons.flag,
          iconColor: Colors.orange,
          title: 'View Reports',
          subtitle: 'See all reports for this station',
          onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => StationReportsScreen(
                stationId: _station!['id'],
                stationName: _station!['name'],
              ),
            ),
          );
        },
      ),
      const Divider(height: 1, indent: 56),
        const Divider(height: 1, indent: 56),
        _actionTile(
          icon: Icons.edit_outlined,
          iconColor: Colors.blue.shade600,
          title: 'Edit Station Details',
          subtitle: 'Update name, phone, fuel types & prices',
          onTap: () async {
            if (_station != null) {
              final updatedData = await Navigator.push<Map<String, dynamic>>(
                context,
                MaterialPageRoute(
                  builder: (_) => EditStationScreen(station: _station!),
                ),
              );
              if (updatedData != null && mounted) {
                // Refresh the station data from API
                await _refreshStation();
                setState(() {});
              }
            }
          },
        ),
      ]),
    );
  }

Future<void> _refreshStation() async {
  try {
    final token = AuthState.instance.token ?? '';
    final stations = await ApiService.getMyStations(token: token);
    final updatedStation = stations.firstWhere(
      (s) => s['id'] == _station!['id'],
      orElse: () => _station!,
    );
    setState(() {
      _station = updatedStation;
    });
  } catch (e) {
    print("Error refreshing station: $e");
  }
}


  Widget _infoRow(IconData icon, String label, String value,
      {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 10),
        Text('$label: ',
            style: const TextStyle(fontSize: 14, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.black87)),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }
}*/

/*import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_state.dart';
import 'api_service.dart';
import 'add_station_screen.dart';
import 'edit_station_screen.dart';
import 'station_reports_screen.dart';
import 'package:easy_top_up/main.dart'; 

class OperatorDashboardScreen extends StatefulWidget {
  final Map<String, dynamic>? station;

  const OperatorDashboardScreen({super.key, this.station});

  @override
  State<OperatorDashboardScreen> createState() =>
      _OperatorDashboardScreenState();
}

class _OperatorDashboardScreenState extends State<OperatorDashboardScreen> with RouteAware{
  static const Color _brandGreen = Color(0xFF2E7D32);

  Map<String, dynamic>? _station;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _station = widget.station;
    //_fetchMyStation
  }



@override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ── Subscribe to route changes ──
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    // ── Unsubscribe when screen is removed ──
    routeObserver.unsubscribe(this);
   // _priceController.dispose();
    super.dispose();
  }

  
  @override
  void didPopNext() {
    print('✅ Dashboard back in focus — refreshing...');
   // _fetchMyStation();
  }

  // ─── HELPERS ───
  Color _fuelColor(String type) {
    switch (type) {
      case 'Petrol/Diesel':
        return Colors.amber.shade700;
      case 'LPG':
        return Colors.blue.shade600;
      case 'EV':
        return Colors.green.shade600;
      default:
        return Colors.grey;
    }
  }

  IconData _fuelIcon(String type) {
    switch (type) {
      case 'Petrol/Diesel':
        return Icons.local_gas_station;
      case 'LPG':
        return Icons.gas_meter;
      case 'EV':
        return Icons.electric_bolt;
      default:
        return Icons.help_outline;
    }
  }

  // ─── PRICE DISPLAY ───
  Widget _buildFuelPricesSection(Map<String, dynamic> station) {
    final type = station['type'];

    if (type == 'Petrol/Diesel') {
      return _buildPetrolDieselPrices(station);
    }

    if (type == 'EV') {
      return _buildEvPrices(station);
    }

    // LPG
    return _buildLpgPrices(station);
  }

  Widget _buildPetrolDieselPrices(Map<String, dynamic> station) {
    final widgets = <Widget>[];
    final petrolData = station['petrol'];
    final dieselData = station['diesel'];

    // PETROL
    if (petrolData != null) {
      final octanes = petrolData['octane_ratings'] as List?;
      if (octanes != null && octanes.isNotEmpty) {
        widgets.add(const Padding(
          padding: EdgeInsets.only(top: 8, bottom: 4),
          child: Text(
            'PETROL',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.amber,
              fontSize: 13,
            ),
          ),
        ));
        for (var octane in octanes) {
          widgets.add(_buildPriceRow(
            label: octane['name'] ?? 'N/A',
            price: 'GH₵ ${octane['price']}/L',
            inStock: octane['in_stock'] == true,
          ));
        }
      }
    }

    // DIESEL
    if (dieselData != null) {
      final diesels = dieselData['diesel_types'] as List?;
      if (diesels != null && diesels.isNotEmpty) {
        widgets.add(const Padding(
          padding: EdgeInsets.only(top: 12, bottom: 4),
          child: Text(
            'DIESEL',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.amber,
              fontSize: 13,
            ),
          ),
        ));
        for (var diesel in diesels) {
          widgets.add(_buildPriceRow(
            label: diesel['name'] ?? 'N/A',
            price: 'GH₵ ${diesel['price']}/L',
            inStock: diesel['in_stock'] == true,
          ));
        }
      }
    }

    if (widgets.isEmpty) {
      widgets.add(const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text(
          'No prices set',
          style: TextStyle(color: Colors.grey),
        ),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'FUEL PRICES',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
        ...widgets,
      ],
    );
  }

  Widget _buildPriceRow({
    required String label,
    required String price,
    required bool inStock,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Row(
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                inStock ? Icons.check_circle : Icons.cancel,
                size: 16,
                color: inStock ? Colors.green : Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEvPrices(Map<String, dynamic> station) {
    final chargingPoints = station['charging_points'] as List?;

    if (chargingPoints == null || chargingPoints.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CHARGING PRICES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No charging prices set',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CHARGING PRICES',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        ...chargingPoints.map((point) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${point['connector'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${point['power_kw'] ?? 0} kW',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'GH₵ ${point['price_per_kwh'] ?? 0}/kWh',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        point['available'] == true ? 'Available' : 'Busy',
                        style: TextStyle(
                          fontSize: 12,
                          color: point['available'] == true
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildLpgPrices(Map<String, dynamic> station) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LPG PRICE PER KG',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          station['price'] ?? 'Not set',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        if (station['lpg_type'] != null &&
            (station['lpg_type'] as List).isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              children: (station['lpg_type'] as List)
                  .map((type) => Chip(
                        label: Text(type, style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.blue.shade50,
                        side: BorderSide.none,
                      ))
                  .toList(),
            ),
          ),
        if (station['delivery_available'] == true)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.delivery_dining,
                    size: 16, color: Colors.blue.shade700),
                const SizedBox(width: 6),
                const Text(
                  'Home Delivery Available',
                  style: TextStyle(fontSize: 13, color: Colors.blue),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ─── TOGGLE STATUS ───
  Future<void> _toggleStatus() async {
    setState(() => _isLoading = true);

    try {
      final current = _station!['status'];
      final newStatus = current == 'Open' ? 'Closed' : 'Open';

      final token = AuthState.instance.token ?? '';
      await ApiService.updateStatus(
        token: token,
        stationId: _station!['id'],
        status: newStatus,
      );

      setState(() => _station!['status'] = newStatus);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Station marked as $newStatus'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── REFRESH STATION ───
  Future<void> _refreshStation() async {
    try {
      final token = AuthState.instance.token ?? '';
      final stations = await ApiService.getMyStations(token: token);
      final updatedStation = stations.firstWhere(
        (s) => s['id'] == _station!['id'],
        orElse: () => _station!,
      );
      if (mounted) {
        setState(() {
          _station = updatedStation;
        });
      }
    } catch (e) {
      // Silently handle error
    }
  }

  // ─── BUILD ───
  @override
  Widget build(BuildContext context) {
    final stationName =
        _station != null ? (_station!['name'] ?? 'Unknown') : 'Unknown';
    final stationType =
        _station != null ? (_station!['type'] ?? 'Unknown') : 'Unknown';
    final stationStatus =
        _station != null ? (_station!['status'] ?? 'Unknown') : 'Unknown';
    final isPending = _station != null && (_station!['verified'] == false);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Station',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshStation(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _brandGreen),
            )
          : _station == null
              ? _buildNoStationWidget()
              : RefreshIndicator(
                  onRefresh: _refreshStation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ─── PENDING BANNER ───
                        if (isPending) _buildPendingBanner(),

                        // ─── STATION INFO CARD ───
                        _buildStationInfoCard(),
                        const SizedBox(height: 24),

                        // ─── ACTIONS ───
                        _sectionLabel('Actions'),
                        const SizedBox(height: 10),
                        _buildActionsCard(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildPendingBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.hourglass_top, color: Colors.orange.shade700, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Your station is pending approval. It will appear on the map once approved.',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationInfoCard() {
    final stationName = _station!['name'] ?? 'Unknown';
    final stationType = _station!['type'] ?? 'Unknown';
    final stationStatus = _station!['status'] ?? 'Unknown';
    final isOpen = stationStatus == 'Open' || stationStatus == 'Available';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _fuelColor(stationType).withOpacity(0.15),
                ),
                child: Icon(
                  _fuelIcon(stationType),
                  color: _fuelColor(stationType),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stationName,
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      stationType,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isOpen
                      ? Colors.green.withOpacity(0.12)
                      : Colors.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: isOpen ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      stationStatus,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isOpen ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28),
          _buildFuelPricesSection(_station!),
        ],
      ),
    );
  }

  Widget _buildNoStationWidget() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_business_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Station Added',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your station so drivers can find you',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_location_alt),
                label: const Text('Add My Station'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brandGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final newStation = await Navigator.push<Map<String, dynamic>>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddStationScreen(),
                    ),
                  );
                  if (newStation != null && mounted) {
                    setState(() => _station = newStation);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard() {
    final stationStatus = _station != null ? (_station!['status'] ?? '') : '';
    final isOpen = stationStatus == 'Open' || stationStatus == 'Available';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _actionTile(
            icon: isOpen ? Icons.lock_open : Icons.lock,
            iconColor: isOpen ? Colors.green : Colors.red,
            title: isOpen ? 'Mark as Closed' : 'Mark as Open',
            subtitle: 'Update station availability',
            onTap: _toggleStatus,
          ),
          const Divider(height: 1, indent: 56),
          _actionTile(
            icon: Icons.flag,
            iconColor: Colors.orange,
            title: 'View Reports',
            subtitle: 'See all reports for this station',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StationReportsScreen(
                    stationId: _station!['id'],
                    stationName: _station!['name'],
                  ),
                ),
              );
            },
          ),
          const Divider(height: 1, indent: 56),
          _actionTile(
            icon: Icons.edit_outlined,
            iconColor: Colors.blue.shade600,
            title: 'Edit Station',
            subtitle: 'Update name, fuel types & prices',
            onTap: () async {
              if (_station != null) {
                final result = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditStationScreen(station: _station!),
                  ),
                );
                if (result != null && mounted) {
                  await _refreshStation();
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
        letterSpacing: 1.2,
      ),
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_state.dart';
import 'api_service.dart';
import 'add_station_screen.dart';
import 'edit_station_screen.dart';
import 'station_reports_screen.dart';
import 'operator_home_screen.dart';

class OperatorDashboardScreen extends StatefulWidget {
  final Map<String, dynamic>? station;

  const OperatorDashboardScreen({super.key, this.station});

  @override
  State<OperatorDashboardScreen> createState() =>
      _OperatorDashboardScreenState();
}

class _OperatorDashboardScreenState extends State<OperatorDashboardScreen> {
  static const Color _brandGreen = Color(0xFF2E7D32);

  Map<String, dynamic>? _station;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _station = widget.station;
  }

  // ─── HELPERS ───
  Color _fuelColor(String type) {
    switch (type) {
      case 'Petrol/Diesel':
        return Colors.amber.shade700;
      case 'LPG':
        return Colors.blue.shade600;
      case 'EV':
        return Colors.green.shade600;
      default:
        return Colors.grey;
    }
  }

  IconData _fuelIcon(String type) {
    switch (type) {
      case 'Petrol/Diesel':
        return Icons.local_gas_station;
      case 'LPG':
        return Icons.gas_meter;
      case 'EV':
        return Icons.electric_bolt;
      default:
        return Icons.help_outline;
    }
  }

  // ─── PRICE DISPLAY ───
  Widget _buildFuelPricesSection(Map<String, dynamic> station) {
    final type = station['type'];

    if (type == 'Petrol/Diesel') {
      return _buildPetrolDieselPrices(station);
    }

    if (type == 'EV') {
      return _buildEvPrices(station);
    }

    return _buildLpgPrices(station);
  }

  Widget _buildPetrolDieselPrices(Map<String, dynamic> station) {
    final widgets = <Widget>[];
    final petrolData = station['petrol'];
    final dieselData = station['diesel'];

    if (petrolData != null) {
      final octanes = petrolData['octane_ratings'] as List?;
      if (octanes != null && octanes.isNotEmpty) {
        widgets.add(const Padding(
          padding: EdgeInsets.only(top: 8, bottom: 4),
          child: Text(
            'PETROL',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.amber,
              fontSize: 13,
            ),
          ),
        ));
        for (var octane in octanes) {
          widgets.add(_buildPriceRow(
            label: octane['name'] ?? 'N/A',
            price: 'GH₵ ${octane['price']}/L',
            inStock: octane['in_stock'] == true,
          ));
        }
      }
    }

    if (dieselData != null) {
      final diesels = dieselData['diesel_types'] as List?;
      if (diesels != null && diesels.isNotEmpty) {
        widgets.add(const Padding(
          padding: EdgeInsets.only(top: 12, bottom: 4),
          child: Text(
            'DIESEL',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.brown,
              fontSize: 13,
            ),
          ),
        ));
        for (var diesel in diesels) {
          widgets.add(_buildPriceRow(
            label: diesel['name'] ?? 'N/A',
            price: 'GH₵ ${diesel['price']}/L',
            inStock: diesel['in_stock'] == true,
          ));
        }
      }
    }

    if (widgets.isEmpty) {
      widgets.add(const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Text(
          'No prices set',
          style: TextStyle(color: Colors.grey),
        ),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'FUEL PRICES',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
        ...widgets,
      ],
    );
  }

  Widget _buildPriceRow({
    required String label,
    required String price,
    required bool inStock,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Row(
            children: [
              Text(
                price,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                inStock ? Icons.check_circle : Icons.cancel,
                size: 16,
                color: inStock ? Colors.green : Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEvPrices(Map<String, dynamic> station) {
    final chargingPoints = station['charging_points'] as List?;

    if (chargingPoints == null || chargingPoints.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CHARGING PRICES',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'No charging prices set',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CHARGING PRICES',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        ...chargingPoints.map((point) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${point['connector'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${point['power_kw'] ?? 0} kW',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'GH₵ ${point['price_per_kwh'] ?? 0}/kWh',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        point['available'] == true ? 'Available' : 'Busy',
                        style: TextStyle(
                          fontSize: 12,
                          color: point['available'] == true
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildLpgPrices(Map<String, dynamic> station) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'LPG PRICE PER KG',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          station['price'] ?? 'Not set',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
        if (station['lpg_type'] != null &&
            (station['lpg_type'] as List).isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 8,
              children: (station['lpg_type'] as List)
                  .map((type) => Chip(
                        label: Text(type, style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.blue.shade50,
                        side: BorderSide.none,
                      ))
                  .toList(),
            ),
          ),
        if (station['delivery_available'] == true)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                Icon(Icons.delivery_dining,
                    size: 16, color: Colors.blue.shade700),
                const SizedBox(width: 6),
                const Text(
                  'Home Delivery Available',
                  style: TextStyle(fontSize: 13, color: Colors.blue),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ─── TOGGLE STATUS ───
  Future<void> _toggleStatus() async {
    setState(() => _isLoading = true);

    try {
      final current = _station!['status'];
      final newStatus = current == 'Open' ? 'Closed' : 'Open';

      final token = AuthState.instance.token ?? '';
      await ApiService.updateStatus(
        token: token,
        stationId: _station!['id'],
        status: newStatus,
      );

      setState(() => _station!['status'] = newStatus);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Station marked as $newStatus'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── REFRESH STATION ───
  Future<void> _refreshStation() async {
    try {
      final token = AuthState.instance.token ?? '';
      final stations = await ApiService.getMyStations(token: token);
      final updatedStation = stations.firstWhere(
        (s) => s['id'] == _station!['id'],
        orElse: () => _station!,
      );
      if (mounted) {
        setState(() {
          _station = updatedStation;
        });
      }
    } catch (e) {
      // Silently handle error
    }
  }

  // // ─── SHOW DELETE CONFIRMATION ───
  // void _showDeleteConfirmation() {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => AlertDialog(
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(20),
  //       ),
  //       title: Row(
  //         children: [
  //           Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
  //           const SizedBox(width: 10),
  //           const Text('Delete Station'),
  //         ],
  //       ),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             'Are you sure you want to delete "${_station!['name']}"?',
  //             style: const TextStyle(
  //               fontSize: 16,
  //               fontWeight: FontWeight.w600,
  //             ),
  //           ),
  //           const SizedBox(height: 12),
  //           const Text(
  //             'This action will permanently remove:',
  //             style: TextStyle(fontSize: 14),
  //           ),
  //           const SizedBox(height: 8),
  //           _bulletPoint('The station from the platform'),
  //           _bulletPoint('All reports submitted for this station'),
  //           _bulletPoint('All reviews and ratings'),
  //           _bulletPoint('This station from all users\' favorites'),
  //           const SizedBox(height: 8),
  //           Container(
  //             padding: const EdgeInsets.all(10),
  //             decoration: BoxDecoration(
  //               color: Colors.red.shade50,
  //               borderRadius: BorderRadius.circular(8),
  //               border: Border.all(color: Colors.red.shade200),
  //             ),
  //             child: Row(
  //               children: [
  //                 Icon(Icons.error_outline, color: Colors.red.shade700, size: 18),
  //                 const SizedBox(width: 8),
  //                 Text(
  //                   'This action cannot be undone!',
  //                   style: TextStyle(
  //                     fontSize: 13,
  //                     fontWeight: FontWeight.w600,
  //                     color: Colors.red.shade700,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.pop(context),
  //           child: Text(
  //             'Cancel',
  //             style: TextStyle(color: Colors.grey[600]),
  //           ),
  //         ),
  //         ElevatedButton(
  //           onPressed: () async {
  //             Navigator.pop(context);
  //             await _deleteStation();
  //           },
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: Colors.red,
  //             foregroundColor: Colors.white,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(10),
  //             ),
  //           ),
  //           child: const Text('Delete Station'),
  //         ),
  //       ],
  //     ),
  //   );
  // }

// ─── SHOW DELETE CONFIRMATION ───
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            const SizedBox(width: 10),
            const Text('Delete Station'),
          ],
        ),
        // ─── FIX: Add constraints to prevent overflow ───
        content: Container(
          width:
              MediaQuery.of(context).size.width * 0.85, // 85% of screen width
          constraints: const BoxConstraints(
            maxWidth: 400, // Maximum width
            minWidth: 280, // Minimum width
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── FIX: Station name with proper wrapping ───
              Wrap(
                children: [
                  const Text(
                    'Are you sure you want to delete ',
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    '"${_station!['name']}"',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Text(
                    '?',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'This action will permanently remove:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              _bulletPoint('The station from the platform'),
              _bulletPoint('All reports submitted for this station'),
              _bulletPoint('All reviews and ratings'),
              _bulletPoint('This station from all users\' favorites'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This action cannot be undone!',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // actions: [
        //   TextButton(
        //     onPressed: () => Navigator.pop(context),
        //     child: Text(
        //       'Cancel',
        //       style: TextStyle(color: Colors.grey[600]),
        //     ),
        //   ),
        //   ElevatedButton(
        //     onPressed: () async {
        //       Navigator.pop(context);
        //       await _deleteStation();
        //     },
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: Colors.red,
        //       foregroundColor: Colors.white,
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(10),
        //       ),
        //     ),
        //     child: const Text('Delete Station'),
        //   ),
        // ],
        actions: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.end, 
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.grey[600], fontSize: 15),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _deleteStation();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Delete Station',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        children: [
          const Text('• ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  // ─── DELETE STATION ───
  Future<void> _deleteStation() async {
    setState(() => _isLoading = true);

    try {
      final token = AuthState.instance.token ?? '';
      await ApiService.deleteStation(
        token: token,
        stationId: _station!['id'],
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Station deleted successfully'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const OperatorHomeScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Failed to delete station: ${e.toString().replaceAll('Exception: ', '')}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── BUILD ───
  @override
  Widget build(BuildContext context) {
    final stationName =
        _station != null ? (_station!['name'] ?? 'Unknown') : 'Unknown';
    final stationType =
        _station != null ? (_station!['type'] ?? 'Unknown') : 'Unknown';
    final stationStatus =
        _station != null ? (_station!['status'] ?? 'Unknown') : 'Unknown';
    final isPending = _station != null && (_station!['verified'] == false);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Station',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshStation(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _brandGreen),
            )
          : _station == null
              ? _buildNoStationWidget()
              : RefreshIndicator(
                  onRefresh: _refreshStation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isPending) _buildPendingBanner(),
                        _buildStationInfoCard(),
                        const SizedBox(height: 24),
                        _sectionLabel('Actions'),
                        const SizedBox(height: 10),
                        _buildActionsCard(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildPendingBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.hourglass_top, color: Colors.orange.shade700, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Your station is pending approval. It will appear on the map once approved.',
              style: TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationInfoCard() {
    final stationName = _station!['name'] ?? 'Unknown';
    final stationType = _station!['type'] ?? 'Unknown';
    final stationStatus = _station!['status'] ?? 'Unknown';
    final isOpen = stationStatus == 'Open' || stationStatus == 'Available';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _fuelColor(stationType).withOpacity(0.15),
                ),
                child: Icon(
                  _fuelIcon(stationType),
                  color: _fuelColor(stationType),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stationName,
                      style: GoogleFonts.poppins(
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      stationType,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isOpen
                      ? Colors.green.withOpacity(0.12)
                      : Colors.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.circle,
                      size: 8,
                      color: isOpen ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      stationStatus,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isOpen ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28),
          _buildFuelPricesSection(_station!),
        ],
      ),
    );
  }

  Widget _buildNoStationWidget() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(32),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_business_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Station Added',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your station so drivers can find you',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add_location_alt),
                label: const Text('Add My Station'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brandGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final newStation = await Navigator.push<Map<String, dynamic>>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddStationScreen(),
                    ),
                  );
                  if (newStation != null && mounted) {
                    setState(() => _station = newStation);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsCard() {
    final stationStatus = _station != null ? (_station!['status'] ?? '') : '';
    final isOpen = stationStatus == 'Open' || stationStatus == 'Available';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _actionTile(
            icon: isOpen ? Icons.lock_open : Icons.lock,
            iconColor: isOpen ? Colors.green : Colors.red,
            title: isOpen ? 'Mark as Closed' : 'Mark as Open',
            subtitle: 'Update station availability',
            onTap: _toggleStatus,
          ),
          const Divider(height: 1, indent: 56),
          _actionTile(
            icon: Icons.flag,
            iconColor: Colors.orange,
            title: 'View Reports',
            subtitle: 'See all reports for this station',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StationReportsScreen(
                    stationId: _station!['id'],
                    stationName: _station!['name'],
                  ),
                ),
              );
            },
          ),
          const Divider(height: 1, indent: 56),
          _actionTile(
            icon: Icons.edit_outlined,
            iconColor: Colors.blue.shade600,
            title: 'Edit Station',
            subtitle: 'Update name, fuel types & prices',
            onTap: () async {
              if (_station != null) {
                final result = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditStationScreen(station: _station!),
                  ),
                );
                if (result != null && mounted) {
                  await _refreshStation();
                }
              }
            },
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 24, thickness: 1, color: Colors.grey),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                /*Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    'DANGER',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 247, 118, 118),
                      letterSpacing: 1,
                    ),
                  ),
                ),*/
                const SizedBox(width: 8),
                Text(
                  'Permanent actions',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          _actionTile(
            icon: Icons.delete_outline,
            iconColor: Colors.red,
            title: 'Delete Station',
            subtitle: 'Permanently remove this station',
            titleColor: Colors.black,
            onTap: _showDeleteConfirmation,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color titleColor = Colors.black87,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: titleColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
        letterSpacing: 1.2,
      ),
    );
  }
}
