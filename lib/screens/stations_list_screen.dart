/*import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'api_service.dart';        // ← Fix this path
import 'auth_state.dart';         // ← Fix this path
import 'operator_dashboard_screen.dart';
import 'add_station_screen.dart';

class StationsListScreen extends StatefulWidget {
  const StationsListScreen({super.key});

  @override
  State<StationsListScreen> createState() => _StationsListScreenState();
}

class _StationsListScreenState extends State<StationsListScreen> {
  static const Color _brandGreen = Color(0xFF2E7D32);
  
  List<Map<String, dynamic>> _stations = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = AuthState.instance.token ?? '';
      final stations = await ApiService.getMyStations(token: token);
      
      setState(() {
        _stations = stations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Color _fuelColor(String type) {
    switch (type) {
      case 'Petrol/Diesel': return Colors.amber.shade700;
      case 'LPG': return Colors.blue.shade600;
      case 'EV': return Colors.green.shade600;
      default: return Colors.grey;
    }
  }

  IconData _fuelIcon(String type) {
    switch (type) {
      case 'Petrol/Diesel': return Icons.local_gas_station;
      case 'LPG': return Icons.gas_meter;
      case 'EV': return Icons.electric_bolt;
      default: return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Your Stations',
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
            icon: const Icon(Icons.add),
            onPressed: () async {
              final newStation = await Navigator.push<Map<String, dynamic>>(
                context,
                MaterialPageRoute(builder: (_) => const AddStationScreen()),
              );
              if (newStation != null && mounted) {
                _loadStations();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStations,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _brandGreen))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadStations,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _stations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_business_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          const Text('No stations added yet'),
                          const SizedBox(height: 8),
                          const Text('Tap + to add your first station'),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadStations,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _stations.length,
                        itemBuilder: (context, index) {
                          final station = _stations[index];
                          final isPending = station['verified'] == false;
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => OperatorDashboardScreen(station: station),
                                  ),
                                ).then((_) => _loadStations());
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 50,
                                      height: 50,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _fuelColor(station['type']).withOpacity(0.15),
                                      ),
                                      child: Icon(
                                        _fuelIcon(station['type']),
                                        color: _fuelColor(station['type']),
                                        size: 26,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            station['name'],
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${station['type']} • ${station['price'] ?? 'Price not set'}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          if (isPending)
                                            Container(
                                              margin: const EdgeInsets.only(top: 6),
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.orange.shade100,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                'Pending Approval',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.orange.shade700,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'api_service.dart';        
import 'auth_state.dart';         
import 'operator_dashboard_screen.dart';
import 'add_station_screen.dart';

class StationsListScreen extends StatefulWidget {
  const StationsListScreen({super.key});

  @override
  State<StationsListScreen> createState() => _StationsListScreenState();
}

class _StationsListScreenState extends State<StationsListScreen> {
  static const Color _brandGreen = Color(0xFF2E7D32);
  
  List<Map<String, dynamic>> _stations = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStations();
  }

  Future<void> _loadStations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = AuthState.instance.token ?? '';
      final stations = await ApiService.getMyStations(token: token);
      
      setState(() {
        _stations = stations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Color _fuelColor(String type) {
    switch (type) {
      case 'Petrol/Diesel': return Colors.amber.shade700;
      case 'LPG': return Colors.blue.shade600;
      case 'EV': return Colors.green.shade600;
      default: return Colors.grey;
    }
  }

  IconData _fuelIcon(String type) {
    switch (type) {
      case 'Petrol/Diesel': return Icons.local_gas_station;
      case 'LPG': return Icons.gas_meter;
      case 'EV': return Icons.electric_bolt;
      default: return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Your Stations',
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
            icon: const Icon(Icons.add),
            onPressed: () async {
              final newStation = await Navigator.push<Map<String, dynamic>>(
                context,
                MaterialPageRoute(builder: (_) => const AddStationScreen()),
              );
              if (newStation != null && mounted) {
                _loadStations();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStations,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _brandGreen))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadStations,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _stations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_business_outlined, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          const Text('No stations added yet'),
                          const SizedBox(height: 8),
                          const Text('Tap + to add your first station'),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadStations,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _stations.length,
                        separatorBuilder: (context, index) => const Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Colors.grey,
                          indent: 72,  // Aligns with the text, not the icon
                        ),
                        itemBuilder: (context, index) {
                          final station = _stations[index];
                          final isPending = station['verified'] == false;
                          
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OperatorDashboardScreen(station: station),
                                ),
                              ).then((_) => _loadStations());
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _fuelColor(station['type']).withOpacity(0.15),
                                    ),
                                    child: Icon(
                                      _fuelIcon(station['type']),
                                      color: _fuelColor(station['type']),
                                      size: 26,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          station['name'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${station['type']} • ${station['price'] ?? 'Price not set'}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        if (isPending)
                                          Container(
                                            margin: const EdgeInsets.only(top: 6),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.shade100,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'Pending Approval',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.orange.shade700,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right, color: Colors.grey),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
