
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_state.dart';
import 'api_service.dart';
import 'add_station_screen.dart';
import 'edit_station_screen.dart';




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
  final TextEditingController _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _station = widget.station;
  }

  // REFRESH 
  Future<void> _refresh() async {
    setState(() {});
  }

  // FUEL COLOR 
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

  //  FUEL ICON 
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

  // GET SAFE STRING VALUE 
  //String _getSafeString(String? value, {String defaultValue = ''}) {
   // return value ?? defaultValue;
 // }

  // UPDATE PRICE DIALOG 
  void _showUpdatePriceDialog() {
    _priceController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Update Price',
            style: GoogleFonts.poppins(
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current: ${_station!['price'] ?? 'N/A'}',
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Enter new price e.g. 15.50',
                  suffixText: _station!['type'] == 'EV'
                      ? 'GH₵/kWh'
                      : _station!['type'] == 'LPG'
                          ? 'GH₵/kg'
                          : 'GH₵/L',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: _brandGreen, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final newPrice = _priceController.text.trim();
                if (newPrice.isEmpty) return;

                Navigator.pop(context);
                setState(() => _isLoading = true);

                try {
                  final unit = _station!['type'] == 'EV'
                      ? '/kWh'
                      : _station!['type'] == 'LPG'
                          ? '/kg'
                          : '/L';
                  final formattedPrice = 'GH₵ $newPrice$unit';
                  final token = AuthState.instance.token ?? '';

                  await ApiService.updatePrice(
                    token: token,
                    stationId: _station!['id'],
                    price: formattedPrice,
                  );

                  setState(() {
                    _station!['price'] = formattedPrice;
                  });

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Price updated successfully'),
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
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _brandGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  //  TOGGLE STATUS 
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

  // UPDATE POWER OUTPUT DIALOG 
  void _showUpdatePowerDialog() {
    String? selected = _station!['power_output'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                'Update Power Output',
                style: GoogleFonts.poppins(
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select your charger power rating:',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      '7.4 kW', '11 kW', '22 kW', '50 kW',
                      '100 kW', '150 kW', '350 kW',
                    ].map((power) {
                      final isSelected = selected == power;
                      return ChoiceChip(
                        avatar: Icon(Icons.bolt,
                            size: 14,
                            color: isSelected ? Colors.white : Colors.green.shade600),
                        label: Text(power),
                        selected: isSelected,
                        selectedColor: Colors.green.shade600,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        onSelected: (_) => setDialogState(() => selected = power),
                      );
                    }).toList(),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: selected == null
                      ? null
                      : () async {
                          Navigator.pop(context);
                          setState(() => _isLoading = true);

                          try {
                            final token = AuthState.instance.token ?? '';
                            await ApiService.updatePowerOutput(
                              token: token,
                              stationId: _station!['id'],
                              powerOutput: selected!,
                            );

                            setState(() {
                              _station!['power_output'] = selected;
                            });

                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Power output updated'),
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
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Safely get values with null handling
    final stationPrice = _station != null ? (_station!['price'] ?? 'Not set') : 'Not set';
    final stationStatus = _station != null ? (_station!['status'] ?? 'Unknown') : 'Unknown';
    final stationType = _station != null ? (_station!['type'] ?? 'Unknown') : 'Unknown';
    final stationPowerOutput = _station != null ? (_station!['power_output'] ?? 'Not set') : 'Not set';
    final stationName = _station != null ? (_station!['name'] ?? 'Unknown') : 'Unknown';
    final isPending = _station != null && (_station!['verified'] == false || _station!['pending'] == true);

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

                    //  NO STATION YET 
                    if (_station == null) ...[
                      _buildNoStationWidget(),
                    ] else ...[
                      //  PENDING APPROVAL BANNER
                      if (isPending)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade300, width: 1),
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
                        ),

                      // STATION INFO CARD
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
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
                                            fontSize: 17,
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
                              ],
                            ),
                            const Divider(height: 28),
                            _infoRow(Icons.sell_outlined, 'Current Price', stationPrice),
                            const SizedBox(height: 12),
                            _infoRow(
                              Icons.circle,
                              'Status',
                              stationStatus,
                              valueColor: (stationStatus == 'Open' || stationStatus == 'Available')
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            if (stationType == 'EV') ...[
                              const SizedBox(height: 12),
                              _infoRow(Icons.bolt, 'Power Output', stationPowerOutput),
                            ],
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  /*Widget _buildActionsCard() {
    final stationType = _station != null ? (_station!['type'] ?? '') : '';
    final stationStatus = _station != null ? (_station!['status'] ?? '') : '';
    final isOpenOrAvailable = (stationStatus == 'Open' || stationStatus == 'Available');

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
          icon: Icons.sell_outlined,
          iconColor: _brandGreen,
          title: 'Update Price',
          subtitle: 'Change your current fuel price',
          onTap: _showUpdatePriceDialog,
        ),
        const Divider(height: 1, indent: 56),
        _actionTile(
          icon: isOpenOrAvailable ? Icons.lock_outline : Icons.lock_open_outlined,
          iconColor: isOpenOrAvailable ? Colors.red : Colors.green,
          title: isOpenOrAvailable ? 'Mark as Closed' : 'Mark as Open',
          subtitle: 'Update your station availability',
          onTap: _toggleStatus,
        ),
        if (stationType == 'EV') ...[
          const Divider(height: 1, indent: 56),
          _actionTile(
            icon: Icons.bolt,
            iconColor: Colors.green.shade600,
            title: 'Update Power Output',
            subtitle: 'Change your charger power rating',
            onTap: _showUpdatePowerDialog,
          ),
        ],
        const Divider(height: 1, indent: 56),
        _actionTile(
          icon: Icons.edit_outlined,
          iconColor: Colors.blue.shade600,
          title: 'Edit Station Details',
          subtitle: 'Update name, phone, fuel types',
          onTap: () async {
            if (_station != null) {
              final updatedData = await Navigator.push<Map<String, dynamic>>(
                context,
                MaterialPageRoute(
                  builder: (_) => EditStationScreen(station: _station!),
                ),
              );
              if (updatedData != null && mounted) {
                setState(() {
                  _station = updatedData as Map<String, dynamic>?;
                });
              }
            }
          },
        ),
      ]),
    );
  }*/



Widget _buildActionsCard() {
  final stationStatus = _station != null ? (_station!['status'] ?? '') : '';
  final isOpenOrAvailable = (stationStatus == 'Open' || stationStatus == 'Available');

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
        icon: isOpenOrAvailable ? Icons.lock_outline : Icons.lock_open_outlined,
        iconColor: isOpenOrAvailable ? Colors.red : Colors.green,
        title: isOpenOrAvailable ? 'Mark as Closed' : 'Mark as Open',
        subtitle: 'Update your station availability',
        onTap: _toggleStatus,
      ),
      
      const Divider(height: 1, indent: 56),
      
      // EDIT STATION DETAILS (This now includes all fuel price editing)
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
              setState(() {
                _station = updatedData as Map<String, dynamic>?;
              });
            }
          }
        },
      ),
    ]),
  );
}


  Widget _infoRow(IconData icon, String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 10),
        Text('$label: ', style: const TextStyle(fontSize: 14, color: Colors.grey)),
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
      title: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Colors.black87)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
      onTap: onTap,
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }
}
