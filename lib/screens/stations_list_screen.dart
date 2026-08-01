
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'api_service.dart';
import 'auth_state.dart';
import 'operator_dashboard_screen.dart';
import 'add_station_screen.dart';
import '../main.dart';
class StationsListScreen extends StatefulWidget {
  const StationsListScreen({super.key});

  @override
  State<StationsListScreen> createState() => _StationsListScreenState();
}

class _StationsListScreenState extends State<StationsListScreen> with RouteAware {
  static const Color _brandGreen = Color(0xFF2E7D32);
  
  List<Map<String, dynamic>> _stations = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStations();
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
    _loadStations(); // 
  }



  Future<void> _loadStations() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = AuthState.instance.token ?? '';
      final stations = await ApiService.getMyStations(token: token);
      
      if (!mounted) return;
      
      setState(() {
        _stations = stations;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
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

  String _getStatusText(Map<String, dynamic> station) {
    final isPending = station['verified'] == false;
    if (isPending) return 'Pending Approval';
    return station['status'] ?? 'Open';
  }

  Color _getStatusColor(Map<String, dynamic> station) {
    final isPending = station['verified'] == false;
    if (isPending) return Colors.orange;
    final status = station['status'] ?? 'Open';
    return status == 'Open' ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Stations',
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
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              final newStation = await Navigator.push<Map<String, dynamic>>(
                context,
                MaterialPageRoute(builder: (_) => const AddStationScreen()),
              );
              if (newStation != null && mounted) {
                _loadStations();
              }
            },
            tooltip: 'Add Station',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadStations,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: _brandGreen),
            )
          : _errorMessage != null
              ? _buildErrorState()
              : _stations.isEmpty
                  ? _buildEmptyState()
                  : _buildStationList(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStations,
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              'No Stations Added',
              style: GoogleFonts.poppins(
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add your first station',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationList() {
    return RefreshIndicator(
      onRefresh: _loadStations,
      color: _brandGreen,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _stations.length,
        separatorBuilder: (context, index) => const Divider(
          height: 1,
          thickness: 0.5,
          color: Colors.grey,
          indent: 76,
        ),
        itemBuilder: (context, index) {
          final station = _stations[index];
          final statusText = _getStatusText(station);
          final statusColor = _getStatusColor(station);
          final type = station['type'] ?? 'Unknown';
          final name = station['name'] ?? 'Unknown Station';

          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OperatorDashboardScreen(station: station),
                ),
              ).then((_) => _loadStations());
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _fuelColor(type).withOpacity(0.12),
                    ),
                    child: Icon(
                      _fuelIcon(type),
                      color: _fuelColor(type),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: statusColor,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 13,
                                color: statusColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              station['price'] ?? 'Price not set',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
                    size: 22,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}