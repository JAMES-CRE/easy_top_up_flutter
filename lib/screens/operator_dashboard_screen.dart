
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
  static const Color _brandGreenDark = Color(0xFF1B5E20);

  Map<String, dynamic>? _station;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _station = widget.station;
  }

  // HELPERS 
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

  // PRICE DISPLAY 
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
    return Container(
      margin: const EdgeInsets.only(left: 8, top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E7D32),
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (inStock ? Colors.green : Colors.red).withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  inStock ? Icons.check_circle : Icons.cancel,
                  size: 12,
                  color: inStock ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 3),
                Text(
                  inStock ? 'In stock' : 'Out',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: inStock ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
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
        ...chargingPoints.map((point) {
          final available = point['available'] == true;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.ev_station,
                          size: 18, color: Colors.green.shade600),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${point['connector'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${point['power_kw'] ?? 0} kW',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'GH₵ ${point['price_per_kwh'] ?? 0}/kWh',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF2E7D32),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: (available ? Colors.green : Colors.red)
                            .withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        available ? 'Available' : 'Busy',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: available ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: Row(
            children: [
              Icon(Icons.local_fire_department,
                  color: Colors.blue.shade600, size: 22),
              const SizedBox(width: 10),
              Text(
                station['price'] ?? 'Not set',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ],
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

  // REFRESH STATION 
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


// SHOW DELETE CONFIRMATION 
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
        
        content: Container(
          width:
              MediaQuery.of(context).size.width * 0.85, 
          constraints: const BoxConstraints(
            maxWidth: 400, // Maximum width
            minWidth: 280, // Minimum width
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

  // DELETE STATION 
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

  // BUILD 
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
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_brandGreen, _brandGreenDark],
            ),
          ),
        ),
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
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.amber.shade50],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.hourglass_top,
                color: Colors.orange.shade800, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pending Approval',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.orange.shade900,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Your station will appear on the map once approved.',
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ],
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
    final fuelColor = _fuelColor(stationType);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with subtle gradient tinted by fuel color
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  fuelColor.withOpacity(0.10),
                  fuelColor.withOpacity(0.02),
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: fuelColor.withOpacity(0.15),
                    border: Border.all(
                      color: fuelColor.withOpacity(0.25),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    _fuelIcon(stationType),
                    color: fuelColor,
                    size: 26,
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
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(_fuelIcon(stationType),
                              size: 13, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Text(
                            stationType,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildStatusPill(stationStatus, isOpen),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 20),
                _buildFuelPricesSection(_station!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPill(String status, bool isOpen) {
    final color = isOpen ? Colors.green : Colors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
            ],
          ),
        ),
      ),
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
