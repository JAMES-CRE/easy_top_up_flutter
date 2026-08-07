import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'api_service.dart';
import 'auth_state.dart';
import '../services/station_cache_service.dart';

class StationReportsScreen extends StatefulWidget {
  final String stationId;
  final String stationName;

  const StationReportsScreen({
    super.key,
    required this.stationId,
    required this.stationName,
  });

  @override
  State<StationReportsScreen> createState() => _StationReportsScreenState();
}

class _StationReportsScreenState extends State<StationReportsScreen> {
  static const Color _brandGreen = Color(0xFF2E7D32);

  List<Map<String, dynamic>> _reports = [];
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = AuthState.instance.token ?? '';

      final hasCache = await StationCacheService.hasCachedReports(widget.stationId);
      
      if (hasCache) {
        final cachedReports = await StationCacheService.loadReports(widget.stationId);
        setState(() {
          _reports = cachedReports;
          _isLoading = false;
        });
        print(' Loaded ${cachedReports.length} reports from cache');
      }
      final response = await ApiService.getStationReports(
        stationId: widget.stationId,
        token: token,
      );

      List<Map<String, dynamic>> reportsList = [];
      if (response is List) {
        reportsList = response.cast<Map<String, dynamic>>();
      } else if (response is Map) {
        reportsList = [response.cast<String, dynamic>()];
      }

      if (reportsList.isNotEmpty) {
        await StationCacheService.saveReports(widget.stationId, reportsList);

        setState(() {
          _reports = reportsList;
          _isLoading = false;
        });
        print('✅ Updated with ${reportsList.length} fresh reports');
      }

      // Scroll to bottom after loading
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });

    } catch (e) {
      if (!await StationCacheService.hasCachedReports(widget.stationId)) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
      print('❌ Error loading reports: $e');
    }
  }

  String _getIssueLabel(String issueType) {
    final Map<String, String> labels = {
      'unusual_price': 'Unusual Price',
      'poor_quality': 'Poor Fuel Quality',
      'fuel_shortage': 'Fuel Shortage',
      'charger_not_working': 'Charger Not Working',
      'wrong_connector': 'Wrong Connector Type',
      'slow_charging': 'Slow Charging Speed',
      'price_higher': 'Price Higher Than Listed',
      'damaged_charger': 'Charger Damaged',
      'stopped_unexpectedly': 'Charging Stopped',
      'no_backup': 'No Backup Generator',
      'leakage': 'Suspected Gas Leakage',
      'underfilling': 'Underfilling of Cylinders',
      'long_queue': 'Long Queue',
      'slow_service': 'Slow Refill Service',
      'cylinder_not_available': 'Cylinder Size Not Available',
      'other': 'Other',
    };
    return labels[issueType] ?? 'Other';
  }

  String _formatTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      
      if (diff.inDays == 0) {
        final hour = date.hour > 12 ? date.hour - 12 : date.hour;
        final period = date.hour >= 12 ? 'PM' : 'AM';
        return '${hour == 0 ? 12 : hour}:${date.minute.toString().padLeft(2, '0')} $period';
      }
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
      return '${(diff.inDays / 30).floor()}mo ago';
    } catch (e) {
      return dateStr;
    }
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          children: [
            Center(
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: InteractiveViewer(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    if (_isSending) return;

    final messageText = _messageController.text.trim();
    
    // Find the first unresolved report
    final unresolvedReport = _reports.firstWhere(
      (r) => !r['has_reply'] && r['status'] == 'pending',
      orElse: () => _reports.isNotEmpty ? _reports.last : {},
    );

    if (unresolvedReport.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No reports to reply to'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSending = true;
      _messageController.clear();
    });

    try {
      final token = AuthState.instance.token ?? '';
      await ApiService.replyToReport(
        token: token,
        reportId: unresolvedReport['id'].toString(),
        reply: messageText,
      );

      if (!mounted) return;
      
      await _loadReports();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reply sent successfully!'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      // Scroll to bottom after sending
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send: ${e.toString().replaceAll('Exception: ', '')}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  Widget _buildChatBubble(Map<String, dynamic> report) {
    final userName = report['user_name'] ?? 'Anonymous';
    final notes = report['notes'] ?? '';
    final issueType = report['issue_type'] ?? 'other';
    final createdAt = report['created_at'] ?? '';
    final hasReply = report['has_reply'] == true;
    final operatorReply = report['operator_reply'] ?? '';
    final repliedByName = report['replied_by_name'] ?? 'Operator';
    final photoUrl = report['photo_url'] as String?;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User's report message (left-aligned)
        Padding(
          padding: const EdgeInsets.only(right: 48, bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                  ),
                ),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.transparent,
                  child: Text(
                    userName[0].toUpperCase(),
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Message bubble
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and time
                    Row(
                      children: [
                        Text(
                          userName,
                          style: GoogleFonts.poppins(
                            textStyle: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Message content
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(18),
                          bottomLeft: Radius.circular(18),
                          bottomRight: Radius.circular(18),
                        ),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Issue type badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _getIssueLabel(issueType),
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blue.shade700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                          if (notes.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              notes,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                                height: 1.45,
                              ),
                            ),
                          ],
                          // Photo evidence
                          if (photoUrl != null && photoUrl.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () => _showFullScreenImage(context, photoUrl),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  photoUrl,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      height: 150,
                                      color: Colors.grey.shade200,
                                      child: const Center(
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      height: 150,
                                      color: Colors.grey.shade200,
                                      child: const Center(
                                        child: Icon(Icons.broken_image, color: Colors.grey),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Operator's reply (right-aligned)
        if (hasReply) ...[
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.only(left: 48, bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Name and time
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            repliedByName,
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Reply bubble
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _brandGreen,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(18),
                            bottomLeft: Radius.circular(18),
                            bottomRight: Radius.circular(18),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _brandGreen.withOpacity(0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                operatorReply,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Operator avatar
                CircleAvatar(
                  radius: 18,
                  backgroundColor: _brandGreen.withOpacity(0.15),
                  child: const Icon(
                    Icons.storefront,
                    size: 16,
                    color: _brandGreen,
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 16),
      ],
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   final isOperator = AuthState.instance.isOperator;
  //   final hasUnrepliedReports = _reports.any((r) => !r['has_reply'] && r['status'] == 'pending');

  //   return Scaffold(
  //     backgroundColor: const Color(0xFFF5F6F8),
  //     appBar: AppBar(
  //       backgroundColor: _brandGreen,
  //       foregroundColor: Colors.white,
  //       elevation: 0,
  //       titleSpacing: 0,
  //       title: Row(
  //         children: [
  //           Container(
  //             width: 38,
  //             height: 38,
  //             decoration: BoxDecoration(
  //               color: Colors.white.withOpacity(0.15),
  //               shape: BoxShape.circle,
  //             ),
  //             child: const Icon(Icons.local_gas_station, color: Colors.white, size: 20),
  //           ),
  //           const SizedBox(width: 10),
  //           Expanded(
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 Text(
  //                   widget.stationName,
  //                   overflow: TextOverflow.ellipsis,
  //                   style: GoogleFonts.poppins(
  //                     textStyle: const TextStyle(
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.w600,
  //                       color: Colors.white,
  //                     ),
  //                   ),
  //                 ),
  //                 Text(
  //                   '${_reports.length} ${_reports.length == 1 ? 'report' : 'reports'}',
  //                   style: const TextStyle(
  //                     fontSize: 12,
  //                     color: Colors.white70,
  //                     fontWeight: FontWeight.normal,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //       actions: [
  //         IconButton(
  //           icon: const Icon(Icons.refresh),
  //           onPressed: _loadReports,
  //           tooltip: 'Refresh',
  //         ),
  //         IconButton(
  //           icon: const Icon(Icons.close),
  //           onPressed: () => Navigator.pop(context),
  //         ),
  //       ],
  //     ),
  //     body: _isLoading
  //         ? const Center(child: CircularProgressIndicator(color: _brandGreen))
  //         : _errorMessage != null
  //             ? Center(
  //                 child: Column(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   children: [
  //                     const Icon(Icons.error_outline, size: 48, color: Colors.grey),
  //                     const SizedBox(height: 16),
  //                     Text(_errorMessage!),
  //                     const SizedBox(height: 16),
  //                     ElevatedButton(
  //                       onPressed: _loadReports,
  //                       style: ElevatedButton.styleFrom(
  //                         backgroundColor: _brandGreen,
  //                         foregroundColor: Colors.white,
  //                       ),
  //                       child: const Text('Retry'),
  //                     ),
  //                   ],
  //                 ),
  //               )
  //             : Column(
  //                 children: [
  //                   // Chat messages area
  //                   Expanded(
  //                     child: _reports.isEmpty
  //                         ? Center(
  //                             child: Column(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 Container(
  //                                   padding: const EdgeInsets.all(24),
  //                                   decoration: BoxDecoration(
  //                                     color: Colors.white,
  //                                     shape: BoxShape.circle,
  //                                     boxShadow: [
  //                                       BoxShadow(
  //                                         color: Colors.black.withOpacity(0.04),
  //                                         blurRadius: 12,
  //                                       ),
  //                                     ],
  //                                   ),
  //                                   child: Icon(Icons.chat_bubble_outline,
  //                                     size: 56,
  //                                     color: Colors.grey[300],
  //                                   ),
  //                                 ),
  //                                 const SizedBox(height: 20),
  //                                 Text(
  //                                   'No reports yet',
  //                                   style: GoogleFonts.poppins(
  //                                     textStyle: TextStyle(
  //                                       fontSize: 18,
  //                                       fontWeight: FontWeight.w600,
  //                                       color: Colors.grey[500],
  //                                     ),
  //                                   ),
  //                                 ),
  //                                 const SizedBox(height: 8),
  //                                 Text(
  //                                   'Reports will appear here as conversations',
  //                                   style: TextStyle(
  //                                     fontSize: 14,
  //                                     color: Colors.grey[400],
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           )
  //                         : RefreshIndicator(
  //                             onRefresh: _loadReports,
  //                             child: ListView.builder(
  //                               controller: _scrollController,
  //                               padding: const EdgeInsets.all(16),
  //                               itemCount: _reports.length,
  //                               itemBuilder: (context, index) {
  //                                 return _buildChatBubble(_reports[index]);
  //                               },
  //                             ),
  //                           ),
  //                   ),

  //                   // Message input area (only for operators with unreplied reports)
  //                   if (isOperator && hasUnrepliedReports)
  //                     Container(
  //                       decoration: BoxDecoration(
  //                         color: Colors.white,
  //                         border: Border(
  //                           top: BorderSide(color: Colors.grey.shade200),
  //                         ),
  //                         boxShadow: [
  //                           BoxShadow(
  //                             color: Colors.black.withOpacity(0.05),
  //                             blurRadius: 10,
  //                             offset: const Offset(0, -2),
  //                           ),
  //                         ],
  //                       ),
  //                       padding: EdgeInsets.only(
  //                         left: 16,
  //                         right: 16,
  //                         top: 12,
  //                         bottom: MediaQuery.of(context).viewInsets.bottom + 12,
  //                       ),
  //                       child: Row(
  //                         children: [
  //                           Expanded(
  //                             child: TextField(
  //                               controller: _messageController,
  //                               enabled: !_isSending,
  //                               maxLines: null,
  //                               textCapitalization: TextCapitalization.sentences,
  //                               decoration: InputDecoration(
  //                                 hintText: 'Type your reply...',
  //                                 hintStyle: TextStyle(color: Colors.grey[400]),
  //                                 filled: true,
  //                                 fillColor: Colors.grey[100],
  //                                 border: OutlineInputBorder(
  //                                   borderRadius: BorderRadius.circular(24),
  //                                   borderSide: BorderSide.none,
  //                                 ),
  //                                 contentPadding: const EdgeInsets.symmetric(
  //                                   horizontal: 20,
  //                                   vertical: 12,
  //                                 ),
  //                               ),
  //                             ),
  //                           ),
  //                           const SizedBox(width: 12),
  //                           Container(
  //                             decoration: BoxDecoration(
  //                               color: _brandGreen,
  //                               shape: BoxShape.circle,
  //                               boxShadow: [
  //                                 BoxShadow(
  //                                   color: _brandGreen.withOpacity(0.3),
  //                                   blurRadius: 8,
  //                                   offset: const Offset(0, 2),
  //                                 ),
  //                               ],
  //                             ),
  //                             child: IconButton(
  //                               icon: _isSending
  //                                   ? const SizedBox(
  //                                       width: 20,
  //                                       height: 20,
  //                                       child: CircularProgressIndicator(
  //                                         strokeWidth: 2,
  //                                         color: Colors.white,
  //                                       ),
  //                                     )
  //                                   : const Icon(Icons.send_rounded, color: Colors.white),
  //                               onPressed: _isSending ? null : _sendMessage,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),

  //                   // Info message when all reports are replied
  //                   if (isOperator && !hasUnrepliedReports && _reports.isNotEmpty)
  //                     Container(
  //                       padding: const EdgeInsets.all(16),
  //                       decoration: BoxDecoration(
  //                         color: Colors.green.shade50,
  //                         border: Border(
  //                           top: BorderSide(color: Colors.green.shade200),
  //                         ),
  //                       ),
  //                       child: Row(
  //                         children: [
  //                           Icon(Icons.check_circle, 
  //                             color: Colors.green.shade700, 
  //                             size: 20
  //                           ),
  //                           const SizedBox(width: 12),
  //                           Expanded(
  //                             child: Text(
  //                               'All reports have been addressed',
  //                               style: TextStyle(
  //                                 color: Colors.green.shade700,
  //                                 fontSize: 14,
  //                                 fontWeight: FontWeight.w500,
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                 ],
  //               ),
  //   );
  // }

  @override
Widget build(BuildContext context) {
  final isOperator = AuthState.instance.isOperator;
  final hasUnrepliedReports = _reports.any((r) => !r['has_reply'] && r['status'] == 'pending');

  return Scaffold(
    backgroundColor: const Color(0xFFF5F6F8),
    appBar: AppBar(
      backgroundColor: _brandGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      title: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_gas_station, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.stationName,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  '${_reports.length} ${_reports.length == 1 ? 'report' : 'reports'}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadReports,
          tooltip: 'Refresh',
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
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
                      onPressed: _loadReports,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _brandGreen,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    children: [
                      // ─── CHAT MESSAGES AREA ───
                      Expanded(
                        child: _reports.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(24),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.04),
                                            blurRadius: 12,
                                          ),
                                        ],
                                      ),
                                      child: Icon(Icons.chat_bubble_outline,
                                        size: 56,
                                        color: Colors.grey[300],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'No reports yet',
                                      style: GoogleFonts.poppins(
                                        textStyle: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Reports will appear here as conversations',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : RefreshIndicator(
                                onRefresh: _loadReports,
                                child: ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _reports.length,
                                  itemBuilder: (context, index) {
                                    return _buildChatBubble(_reports[index]);
                                  },
                                ),
                              ),
                      ),

                      // ─── MESSAGE INPUT AREA ───
                      if (isOperator && hasUnrepliedReports)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border(
                              top: BorderSide(color: Colors.grey.shade200),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 12,
                            bottom: MediaQuery.of(context).viewInsets.bottom + 12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  enabled: !_isSending,
                                  maxLines: null,
                                  textCapitalization: TextCapitalization.sentences,
                                  decoration: InputDecoration(
                                    hintText: 'Type your reply...',
                                    hintStyle: TextStyle(color: Colors.grey[400]),
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(24),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                decoration: BoxDecoration(
                                  color: _brandGreen,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: _brandGreen.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: IconButton(
                                  icon: _isSending
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.send_rounded, color: Colors.white),
                                  onPressed: _isSending ? null : _sendMessage,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // ─── INFO MESSAGE WHEN ALL REPORTS ARE REPLIED ───
                      if (isOperator && !hasUnrepliedReports && _reports.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            border: Border(
                              top: BorderSide(color: Colors.green.shade200),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, 
                                color: Colors.green.shade700, 
                                size: 20
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'All reports have been addressed',
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
  );
}
}
