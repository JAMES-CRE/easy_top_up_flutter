
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_state.dart';
import 'api_service.dart';
import 'stations_list_screen.dart';
import 'add_station_screen.dart';
import 'operator_dashboard_screen.dart';
import 'main_map_screen.dart';
import 'profile_screen.dart';
import '../main.dart';

class OperatorHomeScreen extends StatefulWidget {
  const OperatorHomeScreen({super.key});

  @override
  State<OperatorHomeScreen> createState() => _OperatorHomeScreenState();
}

class _OperatorHomeScreenState extends State<OperatorHomeScreen> with RouteAware{
  static const Color _brandGreen = Color(0xFF2E7D32);
  
  List<Map<String, dynamic>> _stations = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  int _pendingCount = 0;
  int _totalReports = 0;
  final Map<String, int> _reportsByStation = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }


@override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  
  @override
  void didPopNext() {
    print('✅ Home screen back in focus — refreshing...');
    _loadData();
  }


  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = AuthState.instance.token ?? '';
      final stations = await ApiService.getMyStations(token: token);
      
      _pendingCount = stations.where((s) => s['verified'] == false).length;
      
      int totalPendingReports = 0;
      _reportsByStation.clear();
      for (var station in stations) {
        try {
          final reports = await ApiService.getStationReports(
            stationId: station['id'],
            token: token,
          );
          if (reports is List) {
            // Only count reports that are pending (not yet replied/resolved)
            final pending = reports.where((r) {
              if (r is Map) {
                final status = r['status'];
                final hasReply = r['has_reply'] == true;
                return status == 'pending' && !hasReply;
              }
              return false;
            }).length;
            totalPendingReports += pending;
            _reportsByStation[station['id'].toString()] = pending;
          }
        } catch (e) {
          // Ignore errors for individual station reports
        }
      }
      _totalReports = totalPendingReports;
      
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

  Color _getStatusColor(bool verified, String status) {
    if (!verified) return Colors.orange;
    if (status == 'Open') return Colors.green;
    if (status == 'Closed') return Colors.red;
    return Colors.grey;
  }

  String _getStatusText(bool verified, String status) {
    if (!verified) return 'Pending';
    if (status == 'Open') return 'Open';
    if (status == 'Closed') return 'Closed';
    return 'Unknown';
  }

  IconData _getFuelIcon(String type) {
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

  Color _getFuelColor(String type) {
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

  @override
  Widget build(BuildContext context) {
    final userName = AuthState.instance.userName ?? 'Operator';

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
              colors: [_brandGreen, Color(0xFF1B5E20)],
            ),
          ),
        ),
        title: Text(
          'Operator Dashboard',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            tooltip: 'Profile',
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
                        onPressed: _loadData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _brandGreen,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // WELCOME
                        Text(
                          'Welcome, $userName',
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _brandGreen.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Station Operator',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: _brandGreen,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // QUICK STATS 
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.store,
                                value: '${_stations.length}',
                                label: 'Stations',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.pending_actions,
                                value: '$_pendingCount',
                                label: 'Pending',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                icon: Icons.flag,
                                value: '$_totalReports',
                                label: 'Pending Reports',
                                highlight: _totalReports > 0,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // ACTION BUTTONS
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                icon: Icons.add_location_alt,
                                label: 'Add Station',
                                color: _brandGreen,
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const AddStationScreen(),
                                    ),
                                  );
                                  if (result != null && mounted) {
                                    _loadData();
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionButton(
                                icon: Icons.map,
                                label: 'View Map',
                                color: Colors.blue.shade600,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const MainMapScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // MY STATIONS 
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'My Stations',
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            if (_stations.isNotEmpty)
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const StationsListScreen(),
                                    ),
                                  );
                                },
                                child: const Text('View All',
                                style: TextStyle(color:Colors.black87),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (_stations.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.add_business_outlined,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No stations yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap "Add Station" to get started',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ..._stations.take(3).map((station) {
                            final isVerified = station['verified'] == true;
                            final status = station['status'] ?? 'Open';
                            final name = station['name'] ?? 'Unknown';
                            final type = station['type'] ?? 'Unknown';
                            final reportCount =
                                _reportsByStation[station['id'].toString()] ?? 0;
                            final hasReports = reportCount > 0;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: hasReports
                                    ? Border.all(
                                        color: Colors.red.shade200, width: 1.5)
                                    : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: hasReports
                                        ? Colors.red.withOpacity(0.08)
                                        : Colors.black.withOpacity(0.03),
                                    blurRadius: hasReports ? 8 : 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => OperatorDashboardScreen(
                                        station: station,
                                      ),
                                    ),
                                  ).then((_) => _loadData());
                                },
                                child: Row(
                                  children: [
                                    Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: _getFuelColor(type)
                                                .withOpacity(0.15),
                                          ),
                                          child: Icon(
                                            _getFuelIcon(type),
                                            color: _getFuelColor(type),
                                            size: 20,
                                          ),
                                        ),
                                        if (hasReports)
                                          Positioned(
                                            right: -4,
                                            top: -4,
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              constraints: const BoxConstraints(
                                                minWidth: 18,
                                                minHeight: 18,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: Colors.white,
                                                  width: 2,
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '$reportCount',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: _getStatusColor(isVerified, status),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                _getStatusText(isVerified, status),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: _getStatusColor(isVerified, status),
                                                ),
                                              ),
                                              if (hasReports) ...[
                                                const SizedBox(width: 8),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 8,
                                                          vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red.shade50,
                                                    borderRadius:
                                                        BorderRadius.circular(6),
                                                    border: Border.all(
                                                        color:
                                                            Colors.red.shade200),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(Icons.flag,
                                                          size: 10,
                                                          color: Colors
                                                              .red.shade600),
                                                      const SizedBox(width: 3),
                                                      Text(
                                                        '$reportCount report${reportCount > 1 ? 's' : ''}',
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: Colors
                                                              .red.shade600,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),

                        if (_stations.length > 3)
                          Center(
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const StationsListScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                'View all ${_stations.length} stations',
                                style: TextStyle(color: _brandGreen),
                              ),
                            ),
                          ),
                        
                        const SizedBox(height: 30),
                        
                        
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    bool highlight = false,
  }) {
    final accent = highlight ? Colors.red : Colors.grey.shade600;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: highlight ? Colors.red.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: highlight
            ? Border.all(color: Colors.red.shade200)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: accent, size: 22),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: highlight ? Colors.red.shade700 : Colors.black87,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: highlight ? Colors.red.shade400 : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  
}