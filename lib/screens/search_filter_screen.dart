/*import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';



class SearchFilterScreen extends StatefulWidget {
  final List<Map<String, dynamic>> stations;

  const SearchFilterScreen({
    super.key,
    required this.stations,
  });

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {

  static const Color _brandGreen = Color(0xFF2E7D32);

  //  FILTER STATE 
  String _searchQuery = '';
  final Set<String> _selectedFuelTypes = {};

  // PETROL 
  String _selectedOctane = 'Any';

  // LPG 
  String? _selectedLpgType;

  // EV 
  final Set<String> _selectedEVConnector = {};
  String? _selectedPowerOutput;

  //  FILTERED RESULTS
  List<Map<String, dynamic>> get _filteredStations {
    return widget.stations.where((station) {

      // Search by name
      if (_searchQuery.isNotEmpty &&
          !station['name']
              .toLowerCase()
              .contains(_searchQuery.toLowerCase())) {
        return false;
      }

      // Filter by fuel type
      if (_selectedFuelTypes.isNotEmpty &&
          !_selectedFuelTypes.contains(station['type'])) {
        return false;
      }

      // Filter by octane
      if (_selectedFuelTypes.contains('Petrol/Diesel') &&
          _selectedOctane != 'Any' &&
          station['octane'] != _selectedOctane) {
        return false;
      }

      // Filter by EV connector
      if (_selectedFuelTypes.contains('EV') &&
          _selectedEVConnector.isNotEmpty &&
          !_selectedEVConnector.contains(station['connector'])) {
        return false;
      }

      // Filter by power output
      if (_selectedFuelTypes.contains('EV') &&
          _selectedPowerOutput != null &&
          station['power_output'] != _selectedPowerOutput) {
        return false;
      }

      // Filter by LPG type
      if (_selectedFuelTypes.contains('LPG') &&
          _selectedLpgType != null &&
          station['lpg_type'] != null &&
          !(station['lpg_type'] as List).contains(_selectedLpgType)) {
        return false;
      }

      return true;
    }).toList();
  }

  // CLEAR ALL FILTERS 
  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedFuelTypes.clear();
      _selectedOctane = 'Any';
      _selectedEVConnector.clear();
      _selectedPowerOutput = null;
      _selectedLpgType = null;
    });
  }

  // FUEL TYPE ICON 
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

  // FUEL TYPE COLOR 
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

  //  CONNECTOR IMAGE WIDGET 
  Widget _connectorCard(String connector) {
    final isSelected = _selectedEVConnector.contains(connector);

    // Icon and color per connector type
    IconData icon;
    Color color;
    String label;

    switch (connector) {
      case 'CCS':
        icon = Icons.power;
        color = Colors.blue.shade700;
        label = 'CCS\nCombo';
        break;
      case 'Type 2':
        icon = Icons.electrical_services;
        color = Colors.teal.shade600;
        label = 'Type 2\nMennekes';
        break;
      case 'CHAdeMO':
        icon = Icons.bolt;
        color = Colors.orange.shade700;
        label = 'CHAdeMO\nJapanese';
        break;
      case 'Tesla':
        icon = Icons.electric_car;
        color = Colors.red.shade600;
        label = 'Tesla\nPropriet.';
        break;
      case 'Type 1':
        icon = Icons.power_input;
        color = Colors.purple.shade600;
        label = 'Type 1\nJ1772';
        break;
      case 'GB/T':
        icon = Icons.settings_input_component;
        color = Colors.green.shade700;
        label = 'GB/T\nChinese';
        break;
      default:
        icon = Icons.power;
        color = Colors.grey;
        label = connector;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedEVConnector.remove(connector);
          } else {
            _selectedEVConnector.add(connector);
          }
        });
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Connector icon in colored circle
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? color
                    : color.withValues(alpha: 0.1),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : color,
                size: 22,
              ),
            ),
            const SizedBox(height: 6),
            // Connector name
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : Colors.black87,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SUBTITLE BUILDER 
  String _buildSubtitle(Map<String, dynamic> station) {
    final type = station['type'] as String;
    final status = station['status'] as String;

    if (type == 'EV') {
      final connector = station['connector'] ?? '';
      final power = station['power_output'] ?? '';
      if (connector.isNotEmpty && power.isNotEmpty) {
        return '$connector  •  $power  •  $status';
      }
      if (connector.isNotEmpty) {
        return '$connector  •  $status';
      }
    }

    if (type == 'Petrol/Diesel' && station['octane'] != null) {
      return '${station['octane']}  •  $status';
    }

    if (type == 'LPG' && station['lpg_type'] != null) {
      final lpgTypes = (station['lpg_type'] as List).join(' & ');
      return '$lpgTypes  •  $status';
    }

    return '$type  •  $status';
  }

  // SECTION LABEL 
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

  

  @override
  Widget build(BuildContext context) {
    final results = _filteredStations;

    return Scaffold(

      // APP BAR 
      appBar: AppBar(
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Search & Filter',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${results.length} result${results.length == 1 ? '' : 's'}',
                style: const TextStyle(
                    fontSize: 14, color: Colors.white70),
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [

          // SEARCH BAR 
          Container(
            color: _brandGreen,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: (value) =>
                  setState(() => _searchQuery = value),
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Search station name...',
                prefixIcon:
                    const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear,
                            color: Colors.grey),
                        onPressed: () =>
                            setState(() => _searchQuery = ''),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // FILTERS + RESULTS 
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [

                // FILTER HEADER 
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionLabel('Filters'),
                    if (_selectedFuelTypes.isNotEmpty ||
                        _selectedOctane != 'Any' ||
                        _selectedEVConnector.isNotEmpty ||
                        _selectedPowerOutput != null ||
                        _selectedLpgType != null)
                      TextButton(
                        onPressed: _clearFilters,
                        child: const Text(
                          'Clear all',
                          style: TextStyle(
                              color: Colors.red, fontSize: 13),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                //  FUEL TYPE CHIPS 
                _sectionLabel('Fuel Type'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      ['Petrol/Diesel', 'LPG', 'EV'].map((type) {
                    final isSelected =
                        _selectedFuelTypes.contains(type);
                    return FilterChip(
                      avatar: Icon(
                        _fuelIcon(type),
                        size: 16,
                        color: isSelected
                            ? Colors.white
                            : _fuelColor(type),
                      ),
                      label: Text(type),
                      selected: isSelected,
                      selectedColor: _fuelColor(type),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      checkmarkColor: Colors.white,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedFuelTypes.add(type);
                          } else {
                            _selectedFuelTypes.remove(type);
                            if (type == 'LPG') {
                              _selectedLpgType = null;
                            }
                            if (type == 'EV') {
                              _selectedEVConnector.clear();
                              _selectedPowerOutput = null;
                            }
                            if (type == 'Petrol/Diesel') {
                              _selectedOctane = 'Any';
                            }
                          }
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                //  LPG TYPE FILTER 
                if (_selectedFuelTypes.contains('LPG')) ...[
                  _sectionLabel('LPG Type'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Autogas', 'Cylinder Refill', 'Any']
                        .map((lpgType) {
                      final isSelected = lpgType == 'Any'
                          ? _selectedLpgType == null
                          : _selectedLpgType == lpgType;
                      return ChoiceChip(
                        avatar: Icon(
                          lpgType == 'Autogas'
                              ? Icons.directions_car
                              : lpgType == 'Cylinder Refill'
                                  ? Icons.propane_tank
                                  : Icons.all_inclusive,
                          size: 16,
                          color: isSelected
                              ? Colors.white
                              : Colors.blue.shade600,
                        ),
                        label: Text(lpgType),
                        selected: isSelected,
                        selectedColor: Colors.blue.shade600,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        onSelected: (_) {
                          setState(() {
                            _selectedLpgType =
                                lpgType == 'Any' ? null : lpgType;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                // OCTANE FILTER (updated names) 
                if (_selectedFuelTypes
                    .contains('Petrol/Diesel')) ...[
                  _sectionLabel('Fuel Grade'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Super (RON 91)',
                      'Super (RON 95)',
                      'V-Power',
                      'Excellium',
                      'Any',
                    ].map((o) {
                      final isSelected = _selectedOctane == o;
                      return ChoiceChip(
                        label: Text(o),
                        selected: isSelected,
                        selectedColor: _brandGreen,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        onSelected: (_) =>
                            setState(() => _selectedOctane = o),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                // EV CONNECTOR FILTER (image style) 
                if (_selectedFuelTypes.contains('EV')) ...[
                  _sectionLabel('Connector Type'),
                  const SizedBox(height: 10),
                  // Horizontal scrollable row of connector cards
                  SizedBox(
                    height: 110,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        'CCS',
                        'Type 2',
                        'CHAdeMO',
                        'Tesla',
                        'Type 1',
                        'GB/T',
                      ].map(_connectorCard).toList(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // POWER OUTPUT FILTER 
                  _sectionLabel('Power Output'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      '7.4 kW',
                      '11 kW',
                      '22 kW',
                      '50 kW',
                      '100 kW',
                      '150 kW',
                      '350 kW',
                      'Any',
                    ].map((power) {
                      final isSelected = power == 'Any'
                          ? _selectedPowerOutput == null
                          : _selectedPowerOutput == power;
                      return ChoiceChip(
                        // Lightning bolt icon for power
                        avatar: Icon(
                          Icons.bolt,
                          size: 14,
                          color: isSelected
                              ? Colors.white
                              : Colors.green.shade600,
                        ),
                        label: Text(power),
                        selected: isSelected,
                        selectedColor: Colors.green.shade600,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        onSelected: (_) {
                          setState(() {
                            _selectedPowerOutput =
                                power == 'Any' ? null : power;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                const SizedBox(height: 8),

                // RESULTS HEADER 
                _sectionLabel('Results  •  ${results.length} found'),
                const SizedBox(height: 10),

                // EMPTY STATE
                if (results.isEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.search_off,
                            size: 52, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'No stations match your filters',
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[500]),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _clearFilters,
                          child: const Text('Clear filters'),
                        ),
                      ],
                    ),
                  ),

                // RESULTS LIST 
                ...results.map((station) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2)),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _fuelColor(station['type'])
                              .withValues(alpha: 0.15),
                        ),
                        child: Icon(
                          _fuelIcon(station['type']),
                          color: _fuelColor(station['type']),
                          size: 22,
                        ),
                      ),
                      title: Text(
                        station['name'],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          _buildSubtitle(station),
                          style: const TextStyle(
                              fontSize: 13, color: Colors.grey),
                        ),
                      ),
                      trailing: Text(
                        station['price'],
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _brandGreen,
                        ),
                      ),
                      onTap: () =>
                          Navigator.pop(context, station),
                    ),
                  );
                }),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}*/

/*import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'auth_state.dart';

class SearchFilterScreen extends StatefulWidget {
  final List<Map<String, dynamic>> stations;

  const SearchFilterScreen({
    super.key,
    required this.stations,
  });

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  static const Color _brandGreen = Color(0xFF2E7D32);

  // FILTER STATE
  String _searchQuery = '';
  final Set<String> _selectedFuelTypes = {};

  // PETROL
  String _selectedOctane = 'Any';

  // LPG
  String? _selectedLpgType;

  // EV
  final Set<String> _selectedEVConnector = {};
  String? _selectedPowerOutput;

  // FILTERED RESULTS with null safety
  List<Map<String, dynamic>> get _filteredStations {
    return widget.stations.where((station) {
      // Search by name (null safe)
      final name = station['name'] ?? '';
      if (_searchQuery.isNotEmpty &&
          !name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }

      // Filter by fuel type (null safe)
      final type = station['type'] ?? '';
      if (_selectedFuelTypes.isNotEmpty && !_selectedFuelTypes.contains(type)) {
        return false;
      }

      // Filter by octane (for Petrol/Diesel) - check premium petrol data first
      if (_selectedFuelTypes.contains('Petrol/Diesel')) {
        // Check premium petrol data
        final petrol = station['petrol'];
        if (petrol != null && petrol['octane_ratings'] != null) {
          final octanes = petrol['octane_ratings'] as List;
          if (_selectedOctane != 'Any') {
            // Check if any octane rating matches
            bool hasMatchingOctane = octanes.any((o) =>
                o['name']?.toString().contains(_selectedOctane) == true ||
                o['name'] == _selectedOctane);
            if (!hasMatchingOctane) return false;
          }
        } else {
          // Fallback to old octane field
          final octane = station['octane'] ?? '';
          if (_selectedOctane != 'Any' && octane != _selectedOctane) {
            return false;
          }
        }
      }

      // Filter by EV connector (premium)
      if (_selectedFuelTypes.contains('EV')) {
        // Check premium charging points
        final chargingPoints = station['charging_points'];
        if (chargingPoints != null &&
            chargingPoints is List &&
            chargingPoints.isNotEmpty) {
          if (_selectedEVConnector.isNotEmpty) {
            bool hasMatchingConnector = chargingPoints.any(
                (point) => _selectedEVConnector.contains(point['connector']));
            if (!hasMatchingConnector) return false;
          }
          if (_selectedPowerOutput != null) {
            bool hasMatchingPower = chargingPoints.any((point) =>
                point['power_kw']?.toString() == _selectedPowerOutput);
            if (!hasMatchingPower) return false;
          }
        } else {
          // Fallback to old fields
          final connector = station['connector'] ?? '';
          if (_selectedEVConnector.isNotEmpty &&
              !_selectedEVConnector.contains(connector)) {
            return false;
          }
          final powerOutput = station['power_output'] ?? '';
          if (_selectedPowerOutput != null &&
              powerOutput != _selectedPowerOutput) {
            return false;
          }
        }
      }

      // Filter by LPG type
      if (_selectedFuelTypes.contains('LPG')) {
        final lpgType = station['lpg_type'];
        if (_selectedLpgType != null && lpgType != null && lpgType is List) {
          if (!lpgType.contains(_selectedLpgType)) {
            return false;
          }
        }
      }

      return true;
    }).toList();
  }

  // CLEAR ALL FILTERS
  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedFuelTypes.clear();
      _selectedOctane = 'Any';
      _selectedEVConnector.clear();
      _selectedPowerOutput = null;
      _selectedLpgType = null;
    });
  }

  // FUEL TYPE ICON
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

  // FUEL TYPE COLOR
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

  // SUBTITLE BUILDER (null safe)
  String _buildSubtitle(Map<String, dynamic> station) {
    final type = station['type'] as String? ?? 'Unknown';
    final status = station['status'] as String? ?? 'Unknown';

    // EV with premium data
    if (type == 'EV') {
      final chargingPoints = station['charging_points'];
      if (chargingPoints != null &&
          chargingPoints is List &&
          chargingPoints.isNotEmpty) {
        final connectors =
            chargingPoints.map((p) => p['connector'] ?? 'N/A').join(', ');
        return '$connectors  •  $status';
      }
      // Fallback to old fields
      final connector = station['connector'] ?? '';
      final power = station['power_output'] ?? '';
      if (connector.isNotEmpty && power.isNotEmpty) {
        return '$connector  •  $power  •  $status';
      }
      if (connector.isNotEmpty) {
        return '$connector  •  $status';
      }
    }

    // Petrol/Diesel with premium data
    if (type == 'Petrol/Diesel') {
      final petrol = station['petrol'];
      if (petrol != null && petrol['octane_ratings'] != null) {
        final octanes = petrol['octane_ratings'] as List;
        if (octanes.isNotEmpty) {
          final octaneNames = octanes.map((o) => o['name'] ?? 'N/A').join(', ');
          return '$octaneNames  •  $status';
        }
      }
      // Fallback to old octane field
      final octane = station['octane'];
      if (octane != null && octane.toString().isNotEmpty) {
        return '${octane}  •  $status';
      }
    }

    // LPG
    if (type == 'LPG') {
      final lpgType = station['lpg_type'];
      if (lpgType != null && lpgType is List && lpgType.isNotEmpty) {
        return '${lpgType.join(' & ')}  •  $status';
      }
    }

    return '$type  •  $status';
  }

  // GET DISPLAY PRICE (null safe)
  String _getDisplayPrice(Map<String, dynamic> station) {
    try {
      if (station['type'] == 'Petrol/Diesel') {
        final petrol = station['petrol'];
        if (petrol != null && petrol['octane_ratings'] != null) {
          final octanes = petrol['octane_ratings'] as List;
          if (octanes.isNotEmpty && octanes[0]['price'] != null) {
            return 'GH₵ ${octanes[0]['price']}/L';
          }
        }
      }

      if (station['type'] == 'EV') {
        final points = station['charging_points'];
        if (points != null && points is List && points.isNotEmpty) {
          final price = points[0]['price_per_kwh'];
          if (price != null) {
            return 'GH₵ $price/kWh';
          }
        }
      }

      final price = station['price'];
      if (price != null && price.toString().isNotEmpty) {
        return price.toString();
      }

      return 'N/A';
    } catch (e) {
      return 'N/A';
    }
  }

  // CONNECTOR CARD WIDGET
  Widget _connectorCard(String connector) {
    final isSelected = _selectedEVConnector.contains(connector);

    IconData icon;
    Color color;
    String label;

    switch (connector) {
      case 'CCS':
        icon = Icons.power;
        color = Colors.blue.shade700;
        label = 'CCS\nCombo';
        break;
      case 'Type 2':
        icon = Icons.electrical_services;
        color = Colors.teal.shade600;
        label = 'Type 2\nMennekes';
        break;
      case 'CHAdeMO':
        icon = Icons.bolt;
        color = Colors.orange.shade700;
        label = 'CHAdeMO\nJapanese';
        break;
      case 'Tesla':
        icon = Icons.electric_car;
        color = Colors.red.shade600;
        label = 'Tesla\nPropriet.';
        break;
      case 'Type 1':
        icon = Icons.power_input;
        color = Colors.purple.shade600;
        label = 'Type 1\nJ1772';
        break;
      case 'GB/T':
        icon = Icons.settings_input_component;
        color = Colors.green.shade700;
        label = 'GB/T\nChinese';
        break;
      default:
        icon = Icons.power;
        color = Colors.grey;
        label = connector;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedEVConnector.remove(connector);
          } else {
            _selectedEVConnector.add(connector);
          }
        });
      },
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? color : color.withValues(alpha: 0.1),
              ),
              child: Icon(icon,
                  color: isSelected ? Colors.white : color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : Colors.black87,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // SECTION LABEL
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

  @override
  Widget build(BuildContext context) {
    final results = _filteredStations;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Search & Filter',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${results.length} result${results.length == 1 ? '' : 's'}',
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Container(
            color: _brandGreen,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Search station name...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: .isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // In the build method, after the search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFuelPriceChip('Petrol', 'petrol'),
                  const SizedBox(width: 8),
                  _buildFuelPriceChip('Diesel', 'diesel'),
                  const SizedBox(width: 8),
                  _buildFuelPriceChip('LPG', 'lpg'),
                ],
              ),
            ),
          ),

          // FILTERS + RESULTS
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // FILTER HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _sectionLabel('Filters'),
                    if (_selectedFuelTypes.isNotEmpty ||
                        _selectedOctane != 'Any' ||
                        _selectedEVConnector.isNotEmpty ||
                        _selectedPowerOutput != null ||
                        _selectedLpgType != null)
                      TextButton(
                        onPressed: _clearFilters,
                        child: const Text(
                          'Clear all',
                          style: TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // FUEL TYPE CHIPS
                _sectionLabel('Fuel Type'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['Petrol/Diesel', 'LPG', 'EV'].map((type) {
                    final isSelected = _selectedFuelTypes.contains(type);
                    return FilterChip(
                      avatar: Icon(
                        _fuelIcon(type),
                        size: 16,
                        color: isSelected ? Colors.white : _fuelColor(type),
                      ),
                      label: Text(type),
                      selected: isSelected,
                      selectedColor: _fuelColor(type),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                      checkmarkColor: Colors.white,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedFuelTypes.add(type);
                          } else {
                            _selectedFuelTypes.remove(type);
                            if (type == 'LPG') _selectedLpgType = null;
                            if (type == 'EV') {
                              _selectedEVConnector.clear();
                              _selectedPowerOutput = null;
                            }
                            if (type == 'Petrol/Diesel')
                              _selectedOctane = 'Any';
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // LPG TYPE FILTER
                if (_selectedFuelTypes.contains('LPG')) ...[
                  _sectionLabel('LPG Type'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        ['Autogas', 'Cylinder Refill', 'Any'].map((lpgType) {
                      final isSelected = lpgType == 'Any'
                          ? _selectedLpgType == null
                          : _selectedLpgType == lpgType;
                      return ChoiceChip(
                        avatar: Icon(
                          lpgType == 'Autogas'
                              ? Icons.directions_car
                              : lpgType == 'Cylinder Refill'
                                  ? Icons.propane_tank
                                  : Icons.all_inclusive,
                          size: 16,
                          color:
                              isSelected ? Colors.white : Colors.blue.shade600,
                        ),
                        label: Text(lpgType),
                        selected: isSelected,
                        selectedColor: Colors.blue.shade600,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        onSelected: (_) {
                          setState(() {
                            _selectedLpgType =
                                lpgType == 'Any' ? null : lpgType;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                // OCTANE FILTER
                if (_selectedFuelTypes.contains('Petrol/Diesel')) ...[
                  _sectionLabel('Fuel Grade'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'Super (RON 91)',
                      'Super (RON 95)',
                      'V-Power',
                      'Excellium',
                      'Any'
                    ].map((o) {
                      final isSelected = _selectedOctane == o;
                      return ChoiceChip(
                        label: Text(o),
                        selected: isSelected,
                        selectedColor: _brandGreen,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        onSelected: (_) => setState(() => _selectedOctane = o),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                // EV CONNECTOR FILTER
                if (_selectedFuelTypes.contains('EV')) ...[
                  _sectionLabel('Connector Type'),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 110,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        'CCS',
                        'Type 2',
                        'CHAdeMO',
                        'Tesla',
                        'Type 1',
                        'GB/T'
                      ].map(_connectorCard).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // POWER OUTPUT FILTER
                  _sectionLabel('Power Output'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      '7.4 kW',
                      '11 kW',
                      '22 kW',
                      '50 kW',
                      '100 kW',
                      '150 kW',
                      '350 kW',
                      'Any'
                    ].map((power) {
                      final isSelected = power == 'Any'
                          ? _selectedPowerOutput == null
                          : _selectedPowerOutput == power;
                      return ChoiceChip(
                        avatar: Icon(
                          Icons.bolt,
                          size: 14,
                          color:
                              isSelected ? Colors.white : Colors.green.shade600,
                        ),
                        label: Text(power),
                        selected: isSelected,
                        selectedColor: Colors.green.shade600,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        onSelected: (_) {
                          setState(() {
                            _selectedPowerOutput =
                                power == 'Any' ? null : power;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],

                const SizedBox(height: 8),

                // RESULTS HEADER
                _sectionLabel('Results  •  ${results.length} found'),
                const SizedBox(height: 10),

                // EMPTY STATE
                if (results.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.search_off,
                            size: 52, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'No stations match your filters',
                          style:
                              TextStyle(fontSize: 15, color: Colors.grey[500]),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _clearFilters,
                          child: const Text('Clear filters'),
                        ),
                      ],
                    ),
                  ),

                // RESULTS LIST with null safety
                ...results.map((station) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2)),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _fuelColor(station['type'] ?? 'Unknown')
                              .withValues(alpha: 0.15),
                        ),
                        child: Icon(
                          _fuelIcon(station['type'] ?? 'Unknown'),
                          color: _fuelColor(station['type'] ?? 'Unknown'),
                          size: 22,
                        ),
                      ),
                      title: Text(
                        station['name'] ?? 'Unknown Station',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          _buildSubtitle(station),
                          style:
                              const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ),
                      trailing: Text(
                        _getDisplayPrice(station),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _brandGreen,
                        ),
                      ),
                      onTap: () => Navigator.pop(context, station),
                    ),
                  );
                }),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildFuelPriceChip(String label, String fuelType) {
  final price = AuthState.instance.getFormattedFuelPrice(fuelType);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Text(
      '$label: $price',
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    ),
  );
}*/

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'auth_state.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';

class SearchFilterScreen extends StatefulWidget {
  final List<Map<String, dynamic>> stations;
  final Position? currentPosition;

  const SearchFilterScreen({
    super.key,
    required this.stations,
    this.currentPosition,
  });

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  static const Color _brandGreen = Color(0xFF2E7D32);

  // ─── SEARCH ───
  String _searchQuery = '';

  // ─── FUEL TYPE ───
  String? _selectedFuelType; // null = All

  // ─── PETROL GRADES ───
  String? _selectedPetrolGrade; // null = Any

  // ─── DIESEL TYPES ───
  String? _selectedDieselType; // null = Any

  // ─── LPG TYPES ───
  String? _selectedLpgType; // null = Any

  // ─── EV CONNECTORS ───
  String? _selectedEvConnector; // null = Any

// ─── EV POWER OUTPUT ───
  double _powerOutputValue = 0.0; // Default: Any (0 kW = no filter)
  bool _powerOutputEnabled = false;

  // ─── DISTANCE SLIDER ───
  double _distanceValue = 50000; // Default: Any (50km)
  bool _distanceEnabled = false;

  // ─── STATION STATUS ───
  String? _selectedStatus; // null = Any

// open google place
  Future<void> _openGooglePlace(Map<String, dynamic> station) async {
    final lat = station['lat'];
    final lng = station['lng'];

    // ── Use coordinates — always works ──
    final Uri url = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=$lat,$lng',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // ─── AVAILABLE OCTANE OPTIONS (dynamic) ───
  List<String> get _availablePetrolGrades {
    final grades = <String>{};
    for (var station in widget.stations) {
      final petrol = station['petrol'];
      if (petrol != null && petrol['octane_ratings'] != null) {
        final octanes = petrol['octane_ratings'] as List;
        for (var octane in octanes) {
          final name = octane['name']?.toString();
          if (name != null && name.isNotEmpty) {
            grades.add(name);
          }
        }
      }
    }
    return grades.toList()..sort();
  }

  // ─── AVAILABLE DIESEL OPTIONS (dynamic) ───
  List<String> get _availableDieselTypes {
    final types = <String>{};
    for (var station in widget.stations) {
      final diesel = station['diesel'];
      if (diesel != null && diesel['diesel_types'] != null) {
        final dieselList = diesel['diesel_types'] as List;
        for (var dieselType in dieselList) {
          final name = dieselType['name']?.toString();
          if (name != null && name.isNotEmpty) {
            types.add(name);
          }
        }
      }
    }
    return types.toList()..sort();
  }

  // ─── AVAILABLE LPG OPTIONS ───
  List<String> get _availableLpgTypes {
    final types = <String>{};
    for (var station in widget.stations) {
      final lpgType = station['lpg_type'];
      if (lpgType != null && lpgType is List) {
        for (var type in lpgType) {
          final name = type?.toString();
          if (name != null && name.isNotEmpty) {
            types.add(name);
          }
        }
      }
    }
    return types.toList()..sort();
  }

  // ─── DISTANCE CALCULATOR ───
  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadius = 6371;
    double dLat = (lat2 - lat1) * pi / 180;
    double dLng = (lng2 - lng1) * pi / 180;
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLng / 2) *
            sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  // ─── FILTERED RESULTS ───
  List<Map<String, dynamic>> get _filteredStations {
    return widget.stations.where((station) {
      // ── SMART SEARCH ──
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase().trim();
        bool matches = false;

        // 1. Search by station name
        final name = station['name']?.toString().toLowerCase() ?? '';
        if (name.contains(query)) {
          matches = true;
        }

        // 2. Search by fuel type
        if (!matches) {
          final type = station['type']?.toString().toLowerCase() ?? '';
          if (type.contains(query)) {
            matches = true;
          }
        }

        // 3. Search by station address/location (if available)
        if (!matches) {
          final address = station['address']?.toString().toLowerCase() ?? '';
          if (address.contains(query)) {
            matches = true;
          }
        }

        // 4. Search by petrol octane ratings
        if (!matches) {
          final petrol = station['petrol'];
          if (petrol != null) {
            final octanes = petrol['octane_ratings'] as List?;
            if (octanes != null) {
              for (var octane in octanes) {
                final name = octane['name']?.toString().toLowerCase() ?? '';
                if (name.contains(query)) {
                  matches = true;
                  break;
                }
              }
            }
          }
        }

        // 5. Search by diesel types
        if (!matches) {
          final diesel = station['diesel'];
          if (diesel != null) {
            final types = diesel['diesel_types'] as List?;
            if (types != null) {
              for (var type in types) {
                final name = type['name']?.toString().toLowerCase() ?? '';
                if (name.contains(query)) {
                  matches = true;
                  break;
                }
              }
            }
          }
        }

        // 6. Search by EV connector types
        if (!matches) {
          final chargingPoints = station['charging_points'] as List?;
          if (chargingPoints != null) {
            for (var point in chargingPoints) {
              final connector =
                  point['connector']?.toString().toLowerCase() ?? '';
              if (connector.contains(query)) {
                matches = true;
                break;
              }
            }
          }
        }

        // 7. Search by LPG types
        if (!matches) {
          final lpgTypes = station['lpg_type'] as List?;
          if (lpgTypes != null) {
            for (var type in lpgTypes) {
              final name = type?.toString().toLowerCase() ?? '';
              if (name.contains(query)) {
                matches = true;
                break;
              }
            }
          }
        }

        // 8. Search by phone number (if available)
        if (!matches) {
          final phone = station['phone']?.toString() ?? '';
          if (phone.contains(query)) {
            matches = true;
          }
        }

        // 9. Search by WhatsApp number (if available)
        if (!matches) {
          final whatsapp = station['whatsapp']?.toString() ?? '';
          if (whatsapp.contains(query)) {
            matches = true;
          }
        }

        if (!matches) return false;
      }

      // ── FUEL TYPE ──
      if (_selectedFuelType != null) {
        final type = station['type']?.toString() ?? '';
        if (type != _selectedFuelType) {
          return false;
        }
      }

      // ── PETROL GRADE ──
      if (_selectedPetrolGrade != null) {
        final petrol = station['petrol'];
        if (petrol == null) return false;
        final octanes = petrol['octane_ratings'] as List?;
        if (octanes == null) return false;
        bool hasGrade =
            octanes.any((o) => o['name']?.toString() == _selectedPetrolGrade);
        if (!hasGrade) return false;
      }

      // ── DIESEL TYPE ──
      if (_selectedDieselType != null) {
        final diesel = station['diesel'];
        if (diesel == null) return false;
        final types = diesel['diesel_types'] as List?;
        if (types == null) return false;
        bool hasType =
            types.any((t) => t['name']?.toString() == _selectedDieselType);
        if (!hasType) return false;
      }

      // ── LPG TYPE ──
      if (_selectedLpgType != null) {
        final lpgType = station['lpg_type'] as List?;
        if (lpgType == null) return false;
        if (!lpgType.contains(_selectedLpgType)) return false;
      }

      // ── EV CONNECTOR ──
      if (_selectedEvConnector != null) {
        final chargingPoints = station['charging_points'] as List?;
        if (chargingPoints == null) return false;
        bool hasConnector = chargingPoints
            .any((c) => c['connector']?.toString() == _selectedEvConnector);
        if (!hasConnector) return false;

        // ── EV POWER OUTPUT ──
        if (_powerOutputEnabled && _powerOutputValue > 0) {
          final chargingPoints = station['charging_points'] as List?;
          if (chargingPoints == null || chargingPoints.isEmpty) return false;

          bool hasSufficientPower = chargingPoints.any((point) {
            final power = point['power_kw'] as num?;
            return power != null && power >= _powerOutputValue;
          });

          if (!hasSufficientPower) return false;
        }

        // ── DISTANCE ──
        if (_distanceEnabled && widget.currentPosition != null) {
          final lat = station['lat'] as double?;
          final lng = station['lng'] as double?;
          if (lat == null || lng == null) return false;
          double distance = _calculateDistance(
            widget.currentPosition!.latitude,
            widget.currentPosition!.longitude,
            lat,
            lng,
          );
          if (distance > _distanceValue) return false;
        }
      }

      // ── STATUS ──
      if (_selectedStatus != null) {
        final status = station['status']?.toString() ?? '';
        if (status != _selectedStatus) return false;
      }

      return true;
    }).toList();
  }

  // ─── RESET ALL FILTERS ───
  void _resetFilters() {
    setState(() {
      _searchQuery = '';
      _selectedFuelType = null;
      _selectedPetrolGrade = null;
      _selectedDieselType = null;
      _selectedLpgType = null;
      _selectedEvConnector = null;
      _distanceValue = 200.0;
      _distanceEnabled = false;
      _powerOutputValue = 0.0;
      _powerOutputEnabled = false;
      _selectedStatus = null;
    });
  }

  bool get _hasActiveFilters {
    return _selectedFuelType != null ||
        _selectedPetrolGrade != null ||
        _selectedDieselType != null ||
        _selectedLpgType != null ||
        _selectedEvConnector != null ||
        (_distanceEnabled && _distanceValue < 200) ||
        (_powerOutputEnabled && _powerOutputValue > 0) ||
        _selectedStatus != null ||
        _searchQuery.isNotEmpty;
  }

  // ─── GET DISPLAY PRICE ───
  String _getDisplayPrice(Map<String, dynamic> station) {
    try {
      if (station['type'] == 'Petrol/Diesel') {
        final petrol = station['petrol'];
        if (petrol != null && petrol['octane_ratings'] != null) {
          final octanes = petrol['octane_ratings'] as List;
          if (octanes.isNotEmpty && octanes[0]['price'] != null) {
            return 'GH₵ ${octanes[0]['price']}/L';
          }
        }
      }
      if (station['type'] == 'EV') {
        final points = station['charging_points'];
        if (points != null && points is List && points.isNotEmpty) {
          final price = points[0]['price_per_kwh'];
          if (price != null) {
            return 'GH₵ $price/kWh';
          }
        }
      }
      final price = station['price'];
      if (price != null && price.toString().isNotEmpty) {
        return price.toString();
      }
      return 'N/A';
    } catch (e) {
      return 'N/A';
    }
  }

  // ─── GET SUBTITLE ───
  /*String _buildSubtitle(Map<String, dynamic> station) {
    final type = station['type'] as String? ?? 'Unknown';
    final status = station['status'] as String? ?? 'Unknown';

    // EV with premium data
    if (type == 'EV') {
      final chargingPoints = station['charging_points'];
      if (chargingPoints != null &&
          chargingPoints is List &&
          chargingPoints.isNotEmpty) {
        final connectors =
            chargingPoints.map((p) => p['connector'] ?? 'N/A').join(', ');
        return '$connectors  •  $status';
      }
      final connector = station['connector'] ?? '';
      final power = station['power_output'] ?? '';
      if (connector.isNotEmpty && power.isNotEmpty) {
        return '$connector  •  $power  •  $status';
      }
      if (connector.isNotEmpty) {
        return '$connector  •  $status';
      }
    }

    // Petrol/Diesel with premium data
    if (type == 'Petrol/Diesel') {
      final petrol = station['petrol'];
      if (petrol != null && petrol['octane_ratings'] != null) {
        final octanes = petrol['octane_ratings'] as List;
        if (octanes.isNotEmpty) {
          final octaneNames = octanes.map((o) => o['name'] ?? 'N/A').join(', ');
          return '$octaneNames  •  $status';
        }
      }
      final octane = station['octane'];
      if (octane != null && octane.toString().isNotEmpty) {
        return '${octane}  •  $status';
      }
    }

    // LPG
    if (type == 'LPG') {
      final lpgType = station['lpg_type'];
      if (lpgType != null && lpgType is List && lpgType.isNotEmpty) {
        return '${lpgType.join(' & ')}  •  $status';
      }
    }

    return '$type  •  $status';
  }*/

  String _buildSubtitle(Map<String, dynamic> station) {
    final type = station['type'] as String? ?? 'Unknown';
    final isGoogle = station['isGooglePlace'] == true;

    // ── Google stations ──
    if (isGoogle) {
      return '$type  •  Opens in Google Maps ↗';
    }

    // ── Your stations — existing logic ──
    final status = station['status'] as String? ?? 'Unknown';

    if (type == 'EV') {
      final chargingPoints = station['charging_points'];
      if (chargingPoints != null &&
          chargingPoints is List &&
          chargingPoints.isNotEmpty) {
        final connectors =
            chargingPoints.map((p) => p['connector'] ?? 'N/A').join(', ');
        return '$connectors  •  $status';
      }
      final connector = station['connector'] ?? '';
      final power = station['power_output'] ?? '';
      if (connector.isNotEmpty && power.isNotEmpty) {
        return '$connector  •  $power  •  $status';
      }
    }

    if (type == 'Petrol/Diesel') {
      final petrol = station['petrol'];
      if (petrol != null && petrol['octane_ratings'] != null) {
        final octanes = petrol['octane_ratings'] as List;
        if (octanes.isNotEmpty) {
          final names = octanes.map((o) => o['name'] ?? 'N/A').join(', ');
          return '$names  •  $status';
        }
      }
      final octane = station['octane'];
      if (octane != null && octane.toString().isNotEmpty) {
        return '$octane  •  $status';
      }
    }

    if (type == 'LPG') {
      final lpgType = station['lpg_type'];
      if (lpgType != null && lpgType is List && lpgType.isNotEmpty) {
        return '${lpgType.join(' & ')}  •  $status';
      }
    }

    return '$type  •  $status';
  }

// ─── GET ALL UNIQUE CONNECTOR TYPES (including custom) ───
  Set<String> _getAllConnectorTypes() {
    final types = <String>{};
    for (var station in widget.stations) {
      // Check premium EV data (charging_points)
      final chargingPoints = station['charging_points'] as List?;
      if (chargingPoints != null) {
        for (var point in chargingPoints) {
          final connector = point['connector']?.toString();
          if (connector != null && connector.isNotEmpty) {
            types.add(connector);
          }
        }
      }
      // Fallback: check old connector field
      final connector = station['connector']?.toString();
      if (connector != null && connector.isNotEmpty) {
        types.add(connector);
      }
    }
    return types;
  }

  // ─── FUEL COLOR ───
  Color _fuelColor(String type) {
    switch (type) {
      case 'Petrol/Diesel':
        return Colors.amber.shade700;
      case 'Diesel':
        return Colors.brown.shade700;
      case 'LPG':
        return Colors.blue.shade600;
      case 'EV':
        return Colors.green.shade600;
      default:
        return Colors.grey;
    }
  }

  // ─── FUEL ICON ───
  IconData _fuelIcon(String type) {
    switch (type) {
      case 'Petrol/Diesel':
        return Icons.local_gas_station;
      case 'Diesel':
        return Icons.local_gas_station;
      case 'LPG':
        return Icons.gas_meter;
      case 'EV':
        return Icons.electric_bolt;
      default:
        return Icons.help_outline;
    }
  }

  // ─── SECTION LABEL ───
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

  // ─── FILTER CHIP ───
  Widget _filterChip<T>({
    required String label,
    required T value,
    required T? selectedValue,
    required ValueChanged<T?> onSelected,
    Color? color,
  }) {
    final isSelected = selectedValue == value;
    return GestureDetector(
      onTap: () {
        onSelected(isSelected ? null : value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        margin: const EdgeInsets.only(right: 8, bottom: 8),
        decoration: BoxDecoration(
          color: isSelected ? (_color ?? _brandGreen) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? (_color ?? _brandGreen) : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Color? _color;

  @override
  Widget build(BuildContext context) {
    final results = _filteredStations;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Search & Filter',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                '${results.length} result${results.length == 1 ? '' : 's'}',
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ─── SEARCH BAR ───
          Container(
            color: _brandGreen,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: (value) => setState(() => _searchQuery = value),
              style: const TextStyle(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Search by ...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          const SizedBox(height: 8),
          // In the build method, after the search bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFuelPriceChip('Petrol', 'petrol'),
                  const SizedBox(width: 8),
                  _buildFuelPriceChip('Diesel', 'diesel'),
                  const SizedBox(width: 8),
                  _buildFuelPriceChip('LPG', 'lpg'),
                ],
              ),
            ),
          ),

          // ─── FILTERS + RESULTS ───
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── FILTER HEADER ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //_sectionLabel('Filters'),
                    if (_hasActiveFilters)
                      TextButton(
                        onPressed: _resetFilters,
                        child: const Text(
                          'Clear all',
                          style: TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // ── FUEL TYPE ──
                _sectionLabel('Fuel Type'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    /*_filterChip(
                      label: 'All',
                      value: null,
                      selectedValue: _selectedFuelType,
                      onSelected: (val) => setState(() {
                        _selectedFuelType = val;
                        _selectedPetrolGrade = null;
                        _selectedDieselType = null;
                        _selectedLpgType = null;
                        _selectedEvConnector = null;
                      }),
                    ),*/
                    _filterChip(
                      label: 'Petrol/Diesel',
                      value: 'Petrol/Diesel',
                      selectedValue: _selectedFuelType,
                      onSelected: (val) => setState(() {
                        _selectedFuelType = val;
                        _selectedPetrolGrade = null;
                        _selectedDieselType = null;
                      }),
                      color: Colors.amber.shade700,
                    ),
                    _filterChip(
                      label: 'LPG',
                      value: 'LPG',
                      selectedValue: _selectedFuelType,
                      onSelected: (val) => setState(() {
                        _selectedFuelType = val;
                        _selectedLpgType = null;
                      }),
                      color: Colors.blue.shade600,
                    ),
                    _filterChip(
                      label: 'EV',
                      value: 'EV',
                      selectedValue: _selectedFuelType,
                      onSelected: (val) => setState(() {
                        _selectedFuelType = val;
                        _selectedEvConnector = null;
                      }),
                      color: Colors.green.shade600,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── PETROL GRADES ──
                if (_selectedFuelType == 'Petrol/Diesel' ||
                    _selectedFuelType == null)
                  if (_availablePetrolGrades.isNotEmpty) ...[
                    _sectionLabel('Petrol Grades'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _filterChip(
                          label: 'Any',
                          value: null,
                          selectedValue: _selectedPetrolGrade,
                          onSelected: (val) => setState(() {
                            _selectedPetrolGrade = val;
                          }),
                        ),
                        ..._availablePetrolGrades.map((grade) {
                          return _filterChip(
                            label: grade,
                            value: grade,
                            selectedValue: _selectedPetrolGrade,
                            onSelected: (val) => setState(() {
                              _selectedPetrolGrade = val;
                            }),
                            color: Colors.amber.shade700,
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                // ── DIESEL TYPES ──
                if (_selectedFuelType == 'Diesel' ||
                    _selectedFuelType == 'Petrol/Diesel' ||
                    _selectedFuelType == null)
                  if (_availableDieselTypes.isNotEmpty) ...[
                    _sectionLabel('Diesel Grades'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _filterChip(
                          label: 'Any',
                          value: null,
                          selectedValue: _selectedDieselType,
                          onSelected: (val) => setState(() {
                            _selectedDieselType = val;
                          }),
                        ),
                        ..._availableDieselTypes.map((type) {
                          return _filterChip(
                            label: type,
                            value: type,
                            selectedValue: _selectedDieselType,
                            onSelected: (val) => setState(() {
                              _selectedDieselType = val;
                            }),
                            color: Colors.brown.shade700,
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                // ── LPG TYPES ──
                if (_selectedFuelType == 'LPG' || _selectedFuelType == null)
                  if (_availableLpgTypes.isNotEmpty) ...[
                    _sectionLabel('LPG Type'),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _filterChip(
                          label: 'Any',
                          value: null,
                          selectedValue: _selectedLpgType,
                          onSelected: (val) => setState(() {
                            _selectedLpgType = val;
                          }),
                        ),
                        ..._availableLpgTypes.map((type) {
                          return _filterChip(
                            label: type,
                            value: type,
                            selectedValue: _selectedLpgType,
                            onSelected: (val) => setState(() {
                              _selectedLpgType = val;
                            }),
                            color: Colors.blue.shade600,
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                // ── EV CONNECTOR ──
                /*if (_selectedFuelType == 'EV' || _selectedFuelType == null) ...[
                  _sectionLabel('EV Connector'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _filterChip(
                        label: 'Any',
                        value: null,
                        selectedValue: _selectedEvConnector,
                        onSelected: (val) => setState(() {
                          _selectedEvConnector = val;
                        }),
                      ),
                      _filterChip(
                        label: 'CCS',
                        value: 'CCS',
                        selectedValue: _selectedEvConnector,
                        onSelected: (val) => setState(() {
                          _selectedEvConnector = val;
                        }),
                        color: Colors.green.shade600,
                      ),
                      _filterChip(
                        label: 'Type 2',
                        value: 'Type 2',
                        selectedValue: _selectedEvConnector,
                        onSelected: (val) => setState(() {
                          _selectedEvConnector = val;
                        }),
                        color: Colors.green.shade600,
                      ),
                      _filterChip(
                        label: 'CHAdeMO',
                        value: 'CHAdeMO',
                        selectedValue: _selectedEvConnector,
                        onSelected: (val) => setState(() {
                          _selectedEvConnector = val;
                        }),
                        color: Colors.green.shade600,
                      ),
                      _filterChip(
                        label: 'Tesla',
                        value: 'Tesla',
                        selectedValue: _selectedEvConnector,
                        onSelected: (val) => setState(() {
                          _selectedEvConnector = val;
                        }),
                        color: Colors.green.shade600,
                      ),
                      _filterChip(
                        label: 'Type 1',
                        value: 'Type 1',
                        selectedValue: _selectedEvConnector,
                        onSelected: (val) => setState(() {
                          _selectedEvConnector = val;
                        }),
                        color: Colors.green.shade600,
                      ),
                      _filterChip(
                        label: 'GB/T',
                        value: 'GB/T',
                        selectedValue: _selectedEvConnector,
                        onSelected: (val) => setState(() {
                          _selectedEvConnector = val;
                        }),
                        color: Colors.green.shade600,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],*/

                // ── EV POWER OUTPUT ──
                /*if (_selectedFuelType == 'EV' || _selectedFuelType == null) ...[
                  _sectionLabel('⚡ Power Output (min)'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _powerOutputValue,
                          min: 0,
                          max: 2000,
                          divisions: 35, // 10kW increments
                          label: _powerOutputValue == 0
                              ? 'Any'
                              : '${_powerOutputValue.round()} kW',
                          onChanged: (value) {
                            setState(() {
                              _powerOutputValue = value;
                              _powerOutputEnabled = true;
                            });
                          },
                          activeColor: Colors.green.shade600,
                          inactiveColor: Colors.grey.shade300,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade600.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _powerOutputValue == 0
                              ? 'Any'
                              : '${_powerOutputValue.round()} kW',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_powerOutputEnabled && _powerOutputValue == 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Showing all EV stations regardless of power output',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ),
                  const SizedBox(height: 20),
                ],*/

                // ── EV CONNECTOR ──
                // ── EV CONNECTOR (Dynamic - includes custom connectors) ──
                if (_selectedFuelType == 'EV' || _selectedFuelType == null) ...[
                  _sectionLabel('EV Connector'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _filterChip(
                        label: 'Any',
                        value: null,
                        selectedValue: _selectedEvConnector,
                        onSelected: (val) => setState(() {
                          _selectedEvConnector = val;
                        }),
                      ),
                      ..._getAllConnectorTypes().map((connector) {
                        return _filterChip(
                          label: connector,
                          value: connector,
                          selectedValue: _selectedEvConnector,
                          onSelected: (val) => setState(() {
                            _selectedEvConnector = val;
                          }),
                          color: Colors.green.shade600,
                        );
                      }).toList(),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── EV POWER OUTPUT SLIDER ──
                  _sectionLabel('Power Output (min)'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: _powerOutputValue,
                          min: 0,
                          max: 2000,
                          divisions: 35,
                          label: _powerOutputValue == 0
                              ? 'Any'
                              : '${_powerOutputValue.round()} kW',
                          onChanged: (value) {
                            setState(() {
                              _powerOutputValue = value;
                              _powerOutputEnabled = true;
                            });
                          },
                          activeColor: Colors.green.shade600,
                          inactiveColor: Colors.grey.shade300,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade600.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _powerOutputValue == 0
                              ? 'Any'
                              : '${_powerOutputValue.round()} kW',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_powerOutputEnabled && _powerOutputValue == 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Showing all EV stations regardless of power output',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ),
                  const SizedBox(height: 20),
                ],
                // ── DISTANCE ──
                _sectionLabel('Distance'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _distanceValue,
                        min: 1,
                        max: 50000,
                        divisions: 49999,
                        label: _distanceValue == 50000
                            ? 'Any'
                            : '${_distanceValue.round()} km',
                        onChanged: (value) {
                          setState(() {
                            _distanceValue = value;
                            _distanceEnabled = true;
                          });
                        },
                        activeColor: _brandGreen,
                        inactiveColor: Colors.grey.shade300,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _brandGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _distanceValue == 50000
                            ? 'Any'
                            : '${_distanceValue.round()} km',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: _brandGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_distanceEnabled && _distanceValue == 50000)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Showing all stations regardless of distance',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ),
                const SizedBox(height: 8),

                const SizedBox(height: 20),

                // ── STATUS ──
                _sectionLabel('Station Status'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _filterChip(
                      label: 'Any',
                      value: null,
                      selectedValue: _selectedStatus,
                      onSelected: (val) => setState(() {
                        _selectedStatus = val;
                      }),
                    ),
                    _filterChip(
                      label: '🟢 Open',
                      value: 'Open',
                      selectedValue: _selectedStatus,
                      onSelected: (val) => setState(() {
                        _selectedStatus = val;
                      }),
                      color: Colors.green,
                    ),
                    _filterChip(
                      label: '🔴 Closed',
                      value: 'Closed',
                      selectedValue: _selectedStatus,
                      onSelected: (val) => setState(() {
                        _selectedStatus = val;
                      }),
                      color: Colors.red,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // ── RESET BUTTON ──
                if (_hasActiveFilters)
                  Center(
                    child: TextButton.icon(
                      onPressed: _resetFilters,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Reset All Filters'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // ── RESULTS HEADER ──
                _sectionLabel('Results  •  ${results.length} found'),
                const SizedBox(height: 10),

                // ── EMPTY STATE ──
                if (results.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(
                      children: [
                        Icon(Icons.search_off,
                            size: 52, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'No stations match your filters',
                          style:
                              TextStyle(fontSize: 15, color: Colors.grey[500]),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _resetFilters,
                          child: const Text('Clear filters'),
                        ),
                      ],
                    ),
                  ),

                // ── RESULTS LIST ──
                /*...results.map((station) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _fuelColor(station['type'] ?? 'Unknown')
                              .withOpacity(0.15),
                        ),
                        child: Icon(
                          _fuelIcon(station['type'] ?? 'Unknown'),
                          color: _fuelColor(station['type'] ?? 'Unknown'),
                          size: 22,
                        ),
                      ),
                      title: Text(
                        station['name'] ?? 'Unknown Station',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          _buildSubtitle(station),
                          style:
                              const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ),
                      trailing: Text(
                        _getDisplayPrice(station),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _brandGreen,
                        ),
                      ),
                      onTap: () => Navigator.pop(context, station),
                    ),
                  );
                }),*/

                ...results.map((station) {
                  final isGoogle = station['isGooglePlace'] == true;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 2)),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _fuelColor(station['type'] ?? 'Unknown')
                              .withOpacity(0.15),
                        ),
                        child: Icon(
                          _fuelIcon(station['type'] ?? 'Unknown'),
                          color: _fuelColor(station['type'] ?? 'Unknown'),
                          size: 22,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              station['name'] ?? 'Unknown Station',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (isGoogle)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.map,
                                      size: 10, color: Colors.blue.shade600),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Google',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: Colors.blue.shade600,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          _buildSubtitle(station),
                          style:
                              const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ),
                      trailing: isGoogle
                          ? Icon(Icons.open_in_new,
                              size: 16, color: Colors.blue.shade400)
                          : Text(
                              _getDisplayPrice(station),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _brandGreen,
                              ),
                            ),
                      onTap: () {
                        if (isGoogle) {
                          _openGooglePlace(station);
                        } else {
                          Navigator.pop(context, station);
                        }
                      },
                    ),
                  );
                }),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildFuelPriceChip(String label, String fuelType) {
  final price = AuthState.instance.getFormattedFuelPrice(fuelType);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: Text(
      '$label: $price',
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    ),
  );
}
