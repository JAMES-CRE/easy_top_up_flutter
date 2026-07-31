// // lib/screens/station_reports_screen.dart
// /*import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'api_service.dart';
// import 'auth_state.dart';

// class StationReportsScreen extends StatefulWidget {
//   final String stationId;
//   final String stationName;

//   const StationReportsScreen({
//     super.key,
//     required this.stationId,
//     required this.stationName,
//   });

//   @override
//   State<StationReportsScreen> createState() => _StationReportsScreenState();
// }

// class _StationReportsScreenState extends State<StationReportsScreen> {
//   static const Color _brandGreen = Color(0xFF2E7D32);
  
//   List<Map<String, dynamic>> _reports = [];
//   bool _isLoading = true;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _loadReports();
//   }

//   Future<void> _loadReports() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       final token = AuthState.instance.token ?? '';
//       final response = await ApiService.getStationReports(
//         stationId: widget.stationId,
//         token: token,
//       );

//       print('=== STATION REPORTS RESPONSE ===');
//       print(response);
      
//       // Handle both List and Map responses
//       List<Map<String, dynamic>> reportsList = [];
//       if (response is List) {
//         reportsList = response.cast<Map<String, dynamic>>();
//       } else if (response is Map) {
//         reportsList = [response.cast<String, dynamic>()];
//       }
      
//       setState(() {
//         _reports = reportsList;
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Error loading reports: $e');
//       setState(() {
//         _errorMessage = e.toString().replaceAll('Exception: ', '');
//         _isLoading = false;
//       });
//     }
//   }

//   String _getIssueLabel(String issueType) {
//     final Map<String, String> labels = {
//       'unusual_price': 'Unusual Price',
//       'poor_quality': 'Poor Fuel Quality',
//       'fuel_shortage': 'Fuel Shortage',
//       'charger_not_working': 'Charger Not Working',
//       'wrong_connector': 'Wrong Connector Type',
//       'slow_charging': 'Slow Charging Speed',
//       'price_higher': 'Price Higher Than Listed',
//       'damaged_charger': 'Charger Damaged',
//       'stopped_unexpectedly': 'Charging Stopped',
//       'no_backup': 'No Backup Generator',
//       'leakage': 'Suspected Gas Leakage',
//       'underfilling': 'Underfilling of Cylinders',
//       'long_queue': 'Long Queue',
//       'slow_service': 'Slow Refill Service',
//       'cylinder_not_available': 'Cylinder Size Not Available',
//       'other': 'Other',
//     };
//     return labels[issueType] ?? 'Other';
//   }

//   String _formatDate(String dateStr) {
//     try {
//       final date = DateTime.parse(dateStr);
//       final now = DateTime.now();
//       final diff = now.difference(date);
//       if (diff.inDays == 0) return 'Today';
//       if (diff.inDays == 1) return 'Yesterday';
//       if (diff.inDays < 7) return '${diff.inDays} days ago';
//       if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
//       if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} months ago';
//       return '${(diff.inDays / 365).floor()} years ago';
//     } catch (e) {
//       return dateStr;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       appBar: AppBar(
//         backgroundColor: _brandGreen,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         title: Text(
//           'Reports for ${widget.stationName}',
//           style: GoogleFonts.poppins(
//             textStyle: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.close),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator(color: _brandGreen))
//           : _errorMessage != null
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(Icons.error_outline, size: 48, color: Colors.grey),
//                       const SizedBox(height: 16),
//                       Text(_errorMessage!),
//                       const SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: _loadReports,
//                         child: const Text('Retry'),
//                       ),
//                     ],
//                   ),
//                 )
//               : RefreshIndicator(
//                   onRefresh: _loadReports,
//                   child: CustomScrollView(
//                     slivers: [
//                       // ─── Summary Card ───
//                       SliverToBoxAdapter(
//                         child: Container(
//                           margin: const EdgeInsets.all(16),
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(12),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.04),
//                                 blurRadius: 8,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 Icons.flag,
//                                 color: Colors.orange,
//                                 size: 20,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 'Total Reports: ${_reports.length}',
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),

//                       // ─── Reports List ───
//                       if (_reports.isEmpty)
//                         SliverFillRemaining(
//                           child: Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(Icons.flag_outlined, size: 48, color: Colors.grey[400]),
//                                 const SizedBox(height: 16),
//                                 Text(
//                                   'No reports yet',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     color: Colors.grey[500],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         )
//                       else
//                         SliverList(
//                           delegate: SliverChildBuilderDelegate(
//                             (context, index) {
//                               final report = _reports[index];
//                               final userName = report['user_name'] ?? 'Anonymous';
//                               final notes = report['notes'] ?? '';
//                               final issueType = report['issue_type'] ?? 'other';
//                               final createdAt = report['created_at'] ?? '';

//                               return Container(
//                                 margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//                                 padding: const EdgeInsets.all(16),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(12),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.03),
//                                       blurRadius: 4,
//                                       offset: const Offset(0, 1),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       _getIssueLabel(issueType),
//                                       style: const TextStyle(
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w600,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Row(
//                                       children: [
//                                         Icon(Icons.person_outline, size: 14, color: Colors.grey[500]),
//                                         const SizedBox(width: 4),
//                                         Text(
//                                           userName,
//                                           style: TextStyle(
//                                             fontSize: 13,
//                                             color: Colors.grey[600],
//                                           ),
//                                         ),
//                                         const SizedBox(width: 12),
//                                         Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
//                                         const SizedBox(width: 4),
//                                         Text(
//                                           _formatDate(createdAt),
//                                           style: TextStyle(
//                                             fontSize: 13,
//                                             color: Colors.grey[600],
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     if (notes.isNotEmpty) ...[
//                                       const SizedBox(height: 8),
//                                       Text(
//                                         notes,
//                                         style: TextStyle(
//                                           fontSize: 13,
//                                           color: Colors.grey[700],
//                                         ),
//                                       ),
//                                     ],
//                                   ],
//                                 ),
//                               );
//                             },
//                             childCount: _reports.length,
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//     );
//   }
// }*/


// // lib/screens/station_reports_screen.dart
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'api_service.dart';
// import 'auth_state.dart';

// class StationReportsScreen extends StatefulWidget {
//   final String stationId;
//   final String stationName;

//   const StationReportsScreen({
//     super.key,
//     required this.stationId,
//     required this.stationName,
//   });

//   @override
//   State<StationReportsScreen> createState() => _StationReportsScreenState();
// }

// class _StationReportsScreenState extends State<StationReportsScreen> {
//   static const Color _brandGreen = Color(0xFF2E7D32);

//   List<Map<String, dynamic>> _reports = [];
//   bool _isLoading = true;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _loadReports();
//   }

//   Future<void> _loadReports() async {
//     setState(() {
//       _isLoading = true;
//       _errorMessage = null;
//     });

//     try {
//       final token = AuthState.instance.token ?? '';
//       final response = await ApiService.getStationReports(
//         stationId: widget.stationId,
//         token: token,
//       );

//       List<Map<String, dynamic>> reportsList = [];
//       if (response is List) {
//         reportsList = response.cast<Map<String, dynamic>>();
//       } else if (response is Map) {
//         reportsList = [response.cast<String, dynamic>()];
//       }

//       setState(() {
//         _reports = reportsList;
//         _isLoading = false;
//       });
//     } catch (e) {
//       print('Error loading reports: $e');
//       setState(() {
//         _errorMessage = e.toString().replaceAll('Exception: ', '');
//         _isLoading = false;
//       });
//     }
//   }

//   String _getIssueLabel(String issueType) {
//     final Map<String, String> labels = {
//       'unusual_price': 'Unusual Price',
//       'poor_quality': 'Poor Fuel Quality',
//       'fuel_shortage': 'Fuel Shortage',
//       'charger_not_working': 'Charger Not Working',
//       'wrong_connector': 'Wrong Connector Type',
//       'slow_charging': 'Slow Charging Speed',
//       'price_higher': 'Price Higher Than Listed',
//       'damaged_charger': 'Charger Damaged',
//       'stopped_unexpectedly': 'Charging Stopped',
//       'no_backup': 'No Backup Generator',
//       'leakage': 'Suspected Gas Leakage',
//       'underfilling': 'Underfilling of Cylinders',
//       'long_queue': 'Long Queue',
//       'slow_service': 'Slow Refill Service',
//       'cylinder_not_available': 'Cylinder Size Not Available',
//       'other': 'Other',
//     };
//     return labels[issueType] ?? 'Other';
//   }

//   String _getStatusLabel(String status) {
//     switch (status) {
//       case 'pending':
//         return 'Pending';
//       case 'resolved':
//         return 'Resolved';
//       case 'verified':
//         return 'Verified';
//       case 'rejected':
//         return 'Rejected';
//       default:
//         return status;
//     }
//   }

//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'pending':
//         return Colors.orange;
//       case 'resolved':
//         return Colors.green;
//       case 'verified':
//         return Colors.blue;
//       case 'rejected':
//         return Colors.red;
//       default:
//         return Colors.grey;
//     }
//   }

//   String _formatDate(String dateStr) {
//     try {
//       final date = DateTime.parse(dateStr);
//       final now = DateTime.now();
//       final diff = now.difference(date);
//       if (diff.inDays == 0) return 'Today';
//       if (diff.inDays == 1) return 'Yesterday';
//       if (diff.inDays < 7) return '${diff.inDays} days ago';
//       if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
//       if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} months ago';
//       return '${(diff.inDays / 365).floor()} years ago';
//     } catch (e) {
//       return dateStr;
//     }
//   }

//   // ─── REPLY DIALOG ───
//   void _showReplyDialog(Map<String, dynamic> report) {
//     final replyController = TextEditingController();

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => StatefulBuilder(
//         builder: (context, setDialogState) {
//           return AlertDialog(
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(20),
//             ),
//             title: const Text('Reply to Report'),
//             content: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Report: ${_getIssueLabel(report['issue_type'])}',
//                   style: const TextStyle(fontSize: 14),
//                 ),
//                 Text(
//                   'Station: ${report['station_name'] ?? 'Unknown'}',
//                   style: const TextStyle(fontSize: 14, color: Colors.grey),
//                 ),
//                 const SizedBox(height: 12),
//                 TextField(
//                   controller: replyController,
//                   maxLines: 4,
//                   maxLength: 500,
//                   decoration: InputDecoration(
//                     hintText: 'Type your reply...',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(color: _brandGreen, width: 2),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   padding: const EdgeInsets.all(10),
//                   decoration: BoxDecoration(
//                     color: Colors.green.shade50,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: Colors.green.shade200),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.check_circle,
//                         size: 18,
//                         color: Colors.green.shade700,
//                       ),
//                       const SizedBox(width: 8),
//                       Text(
//                         'This report will be marked as resolved',
//                         style: TextStyle(
//                           fontSize: 13,
//                           color: Colors.green.shade700,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: const Text('Cancel'),
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   if (replyController.text.trim().isEmpty) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Please enter a reply'),
//                         behavior: SnackBarBehavior.floating,
//                         backgroundColor: Colors.orange,
//                       ),
//                     );
//                     return;
//                   }

//                   try {
//                     final token = AuthState.instance.token ?? '';
//                     await ApiService.replyToReport(
//                       token: token,
//                       reportId: report['id'].toString(),
//                       reply: replyController.text.trim(),
//                     );

//                     if (!mounted) return;
//                     Navigator.pop(context);
//                     _loadReports();

//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Reply sent successfully!'),
//                         behavior: SnackBarBehavior.floating,
//                         backgroundColor: Colors.green,
//                       ),
//                     );
//                   } catch (e) {
//                     if (!mounted) return;
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(
//                         content: Text('Failed to send reply: ${e.toString().replaceAll('Exception: ', '')}'),
//                         behavior: SnackBarBehavior.floating,
//                         backgroundColor: Colors.red,
//                       ),
//                     );
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: _brandGreen,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 child: const Text('Send Reply'),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isOperator = AuthState.instance.isOperator;

//     return Scaffold(
//       backgroundColor: Colors.grey.shade50,
//       appBar: AppBar(
//         backgroundColor: _brandGreen,
//         foregroundColor: Colors.white,
//         elevation: 0,
//         title: Text(
//           'Reports for ${widget.stationName}',
//           style: GoogleFonts.poppins(
//             textStyle: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.close),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator(color: _brandGreen))
//           : _errorMessage != null
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(Icons.error_outline, size: 48, color: Colors.grey),
//                       const SizedBox(height: 16),
//                       Text(_errorMessage!),
//                       const SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: _loadReports,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: _brandGreen,
//                           foregroundColor: Colors.white,
//                         ),
//                         child: const Text('Retry'),
//                       ),
//                     ],
//                   ),
//                 )
//               : RefreshIndicator(
//                   onRefresh: _loadReports,
//                   child: CustomScrollView(
//                     slivers: [
//                       // ─── Summary Card ───
//                       SliverToBoxAdapter(
//                         child: Container(
//                           margin: const EdgeInsets.all(16),
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(12),
//                             boxShadow: [
//                               BoxShadow(
//                                 color: Colors.black.withOpacity(0.04),
//                                 blurRadius: 8,
//                                 offset: const Offset(0, 2),
//                               ),
//                             ],
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               /*Icon(
//                                 Icons.flag,
//                                 color: Colors.orange,
//                                 size: 20,
//                               ),*/
//                               const SizedBox(width: 8),
//                               Text(
//                                 'Total Reports',
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),

//                       // ─── Reports List ───
//                       if (_reports.isEmpty)
//                         SliverFillRemaining(
//                           child: Center(
//                             child: Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Icon(Icons.flag_outlined, size: 48, color: Colors.grey[400]),
//                                 const SizedBox(height: 16),
//                                 Text(
//                                   'No reports yet',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     color: Colors.grey[500],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         )
//                       else
//                         SliverList(
//                           delegate: SliverChildBuilderDelegate(
//                             (context, index) {
//                               final report = _reports[index];
//                               final userName = report['user_name'] ?? 'Anonymous';
//                               final notes = report['notes'] ?? '';
//                               final issueType = report['issue_type'] ?? 'other';
//                               final status = report['status'] ?? 'pending';
//                               final createdAt = report['created_at'] ?? '';
//                               final hasReply = report['has_reply'] == true;
//                               final operatorReply = report['operator_reply'] ?? '';
//                               final repliedByName = report['replied_by_name'] ?? 'Operator';
//                               final isResolved = status == 'resolved';

//                               return Container(
//                                 margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//                                 padding: const EdgeInsets.all(16),
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(12),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.03),
//                                       blurRadius: 4,
//                                       offset: const Offset(0, 1),
//                                     ),
//                                   ],
//                                   border: Border.all(
//                                     color: isResolved ? Colors.green.shade100 : Colors.transparent,
//                                     width: 1,
//                                   ),
//                                 ),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     // ─── Header ───
//                                     Row(
//                                       children: [
//                                         // Status dot
//                                         Container(
//                                           width: 8,
//                                           height: 8,
//                                           decoration: BoxDecoration(
//                                             shape: BoxShape.circle,
//                                             color: _getStatusColor(status),
//                                           ),
//                                         ),
//                                         const SizedBox(width: 8),
//                                         Text(
//                                           _getStatusLabel(status),
//                                           style: TextStyle(
//                                             fontSize: 12,
//                                             fontWeight: FontWeight.w600,
//                                             color: _getStatusColor(status),
//                                           ),
//                                         ),
//                                         const SizedBox(width: 12),
//                                         Text(
//                                           _getIssueLabel(issueType),
//                                           style: const TextStyle(
//                                             fontSize: 14,
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                       ],
//                                     ),

//                                     const SizedBox(height: 4),

//                                     // ─── Meta ───
//                                     Row(
//                                       children: [
//                                         Text(
//                                           'By $userName',
//                                           style: TextStyle(
//                                             fontSize: 13,
//                                             color: Colors.grey[600],
//                                           ),
//                                         ),
//                                         const SizedBox(width: 12),
//                                         Text(
//                                           _formatDate(createdAt),
//                                           style: TextStyle(
//                                             fontSize: 13,
//                                             color: Colors.grey[500],
//                                           ),
//                                         ),
//                                       ],
//                                     ),

//                                     // ─── Notes ───
//                                     if (notes.isNotEmpty) ...[
//                                       const SizedBox(height: 8),
//                                       Text(
//                                         notes,
//                                         style: TextStyle(
//                                           fontSize: 13,
//                                           color: Colors.grey[700],
//                                         ),
//                                       ),
//                                     ],

//                                     // ─── Operator Reply ───
//                                     if (hasReply) ...[
//                                       const SizedBox(height: 12),
//                                       Container(
//                                         padding: const EdgeInsets.all(12),
//                                         decoration: BoxDecoration(
//                                           color: isResolved 
//                                               ? Colors.green.shade50 
//                                               : Colors.blue.shade50,
//                                           borderRadius: BorderRadius.circular(8),
//                                           border: Border.all(
//                                             color: isResolved 
//                                                 ? Colors.green.shade200 
//                                                 : Colors.blue.shade200,
//                                           ),
//                                         ),
//                                         child: Column(
//                                           crossAxisAlignment: CrossAxisAlignment.start,
//                                           children: [
//                                             Row(
//                                               children: [
//                                                 Icon(
//                                                   Icons.reply,
//                                                   size: 14,
//                                                   color: isResolved 
//                                                       ? Colors.green.shade700 
//                                                       : Colors.blue.shade700,
//                                                 ),
//                                                 const SizedBox(width: 6),
//                                                 Text(
//                                                   'Operator Response',
//                                                   style: TextStyle(
//                                                     fontSize: 12,
//                                                     fontWeight: FontWeight.w600,
//                                                     color: isResolved 
//                                                         ? Colors.green.shade700 
//                                                         : Colors.blue.shade700,
//                                                   ),
//                                                 ),
//                                                 if (isResolved) ...[
//                                                   const SizedBox(width: 8),
//                                                   Icon(
//                                                     Icons.check_circle,
//                                                     size: 12,
//                                                     color: Colors.green.shade700,
//                                                   ),
//                                                 ],
//                                               ],
//                                             ),
//                                             const SizedBox(height: 4),
//                                             Text(
//                                               operatorReply,
//                                               style: const TextStyle(
//                                                 fontSize: 13,
//                                                 color: Colors.black87,
//                                               ),
//                                             ),
//                                             const SizedBox(height: 2),
//                                             Text(
//                                               '— $repliedByName',
//                                               style: TextStyle(
//                                                 fontSize: 11,
//                                                 color: Colors.grey[500],
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],

//                                     // ─── Reply Button (Operator only) ───
//                                     if (isOperator && !hasReply) ...[
//                                       const SizedBox(height: 12),
//                                       Align(
//                                         alignment: Alignment.centerRight,
//                                         child: TextButton(
//                                           onPressed: () => _showReplyDialog(report),
//                                           style: TextButton.styleFrom(
//                                             foregroundColor: _brandGreen,
//                                             minimumSize: Size.zero,
//                                             tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                                           ),
//                                           child: const Row(
//                                             mainAxisSize: MainAxisSize.min,
//                                             children: [
//                                               Text(
//                                                 'Reply',
//                                                 style: TextStyle(
//                                                   fontWeight: FontWeight.w600,
//                                                 ),
//                                               ),
//                                               SizedBox(width: 4),
//                                               Icon(Icons.arrow_forward, size: 14),
//                                             ],
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ],
//                                 ),
//                               );
//                             },
//                             childCount: _reports.length,
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//     );
//   }
// }




// lib/screens/station_reports_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'api_service.dart';
import 'auth_state.dart';

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

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = AuthState.instance.token ?? '';
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

      setState(() {
        _reports = reportsList;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading reports: $e');
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
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

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'resolved':
        return 'Resolved';
      case 'verified':
        return 'Verified';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'verified':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      if (diff.inDays == 0) return 'Today';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays} days ago';
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
      if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} months ago';
      return '${(diff.inDays / 365).floor()} years ago';
    } catch (e) {
      return dateStr;
    }
  }

  // ─── SHOW FULL SCREEN IMAGE ───
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

  // ─── REPLY DIALOG ───
  // void _showReplyDialog(Map<String, dynamic> report) {
  //   final replyController = TextEditingController();

  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => StatefulBuilder(
  //       builder: (context, setDialogState) {
  //         return AlertDialog(
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(20),
  //           ),
  //           title: const Text('Reply to Report'),
  //           content: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 'Report: ${_getIssueLabel(report['issue_type'])}',
  //                 style: const TextStyle(fontSize: 14),
  //               ),
  //               Text(
  //                 'Station: ${report['station_name'] ?? 'Unknown'}',
  //                 style: const TextStyle(fontSize: 14, color: Colors.grey),
  //               ),
  //               const SizedBox(height: 12),
  //               TextField(
  //                 controller: replyController,
  //                 maxLines: 4,
  //                 maxLength: 500,
  //                 decoration: InputDecoration(
  //                   hintText: 'Type your reply...',
  //                   border: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(12),
  //                   ),
  //                   focusedBorder: OutlineInputBorder(
  //                     borderRadius: BorderRadius.circular(12),
  //                     borderSide: const BorderSide(color: _brandGreen, width: 2),
  //                   ),
  //                 ),
  //               ),
  //               const SizedBox(height: 8),
  //               Container(
  //                 padding: const EdgeInsets.all(10),
  //                 decoration: BoxDecoration(
  //                   color: Colors.green.shade50,
  //                   borderRadius: BorderRadius.circular(8),
  //                   border: Border.all(color: Colors.green.shade200),
  //                 ),
  //                 child: Row(
  //                   children: [
  //                     Icon(
  //                       Icons.check_circle,
  //                       size: 18,
  //                       color: Colors.green.shade700,
  //                     ),
  //                     const SizedBox(width: 8),
  //                     Text(
  //                       'This report will be marked as resolved',
  //                       style: TextStyle(
  //                         fontSize: 13,
  //                         color: Colors.green.shade700,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ],
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Navigator.pop(context),
  //               child: const Text('Cancel'),
  //             ),
  //             ElevatedButton(
  //               onPressed: () async {
  //                 if (replyController.text.trim().isEmpty) {
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     const SnackBar(
  //                       content: Text('Please enter a reply'),
  //                       behavior: SnackBarBehavior.floating,
  //                       backgroundColor: Colors.orange,
  //                     ),
  //                   );
  //                   return;
  //                 }

  //                 try {
  //                   final token = AuthState.instance.token ?? '';
  //                   await ApiService.replyToReport(
  //                     token: token,
  //                     reportId: report['id'].toString(),
  //                     reply: replyController.text.trim(),
  //                   );

  //                   if (!mounted) return;
  //                   Navigator.pop(context);
  //                   _loadReports();

  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     const SnackBar(
  //                       content: Text('Reply sent successfully!'),
  //                       behavior: SnackBarBehavior.floating,
  //                       backgroundColor: Colors.green,
  //                     ),
  //                   );
  //                 } catch (e) {
  //                   if (!mounted) return;
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     SnackBar(
  //                       content: Text('Failed to send reply: ${e.toString().replaceAll('Exception: ', '')}'),
  //                       behavior: SnackBarBehavior.floating,
  //                       backgroundColor: Colors.red,
  //                     ),
  //                   );
  //                 }
  //               },
  //               style: ElevatedButton.styleFrom(
  //                 backgroundColor: _brandGreen,
  //                 foregroundColor: Colors.white,
  //                 shape: RoundedRectangleBorder(
  //                   borderRadius: BorderRadius.circular(10),
  //                 ),
  //               ),
  //               child: const Text('Send Reply'),
  //             ),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  // }


// ─── REPLY DIALOG (SCROLLABLE VERSION) ───
void _showReplyDialog(Map<String, dynamic> report) {
  final replyController = TextEditingController();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('Reply to Report'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report: ${_getIssueLabel(report['issue_type'])}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Station: ${report['station_name'] ?? 'Unknown'}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: replyController,
                  maxLines: 4,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: 'Type your reply...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _brandGreen, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 18,
                        color: Colors.green.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This report will be marked as resolved',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.green.shade700,
                          ),
                          softWrap: true,
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
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey[600], fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      if (replyController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a reply'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      try {
                        final token = AuthState.instance.token ?? '';
                        await ApiService.replyToReport(
                          token: token,
                          reportId: report['id'].toString(),
                          reply: replyController.text.trim(),
                        );

                        if (!mounted) return;
                        Navigator.pop(context);
                        _loadReports();

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Reply sent successfully!'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.green,
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to send reply: ${e.toString().replaceAll('Exception: ', '')}'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _brandGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Send Reply',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );
}




  @override
  Widget build(BuildContext context) {
    final isOperator = AuthState.instance.isOperator;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: _brandGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Reports for ${widget.stationName}',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
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
              : RefreshIndicator(
                  onRefresh: _loadReports,
                  child: CustomScrollView(
                    slivers: [
                      // ─── Summary Card ───
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Total Reports: ${_reports.length}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // ─── Reports List ───
                      if (_reports.isEmpty)
                        SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.flag_outlined, size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 16),
                                Text(
                                  'No reports yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final report = _reports[index];
                              final userName = report['user_name'] ?? 'Anonymous';
                              final notes = report['notes'] ?? '';
                              final issueType = report['issue_type'] ?? 'other';
                              final status = report['status'] ?? 'pending';
                              final createdAt = report['created_at'] ?? '';
                              final hasReply = report['has_reply'] == true;
                              final operatorReply = report['operator_reply'] ?? '';
                              final repliedByName = report['replied_by_name'] ?? 'Operator';
                              final isResolved = status == 'resolved';
                              final photoUrl = report['photo_url'] as String?;

                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 4,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: isResolved ? Colors.green.shade100 : Colors.transparent,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // ─── Header ───
                                    Row(
                                      children: [
                                        // Status dot
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: _getStatusColor(status),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          _getStatusLabel(status),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: _getStatusColor(status),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _getIssueLabel(issueType),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 4),

                                    // ─── Meta ───
                                    Row(
                                      children: [
                                        Text(
                                          'By $userName',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          _formatDate(createdAt),
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),

                                    // ─── Notes ───
                                    if (notes.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        notes,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],

                                    // ─── PHOTO EVIDENCE ───
                                    if (photoUrl != null && photoUrl.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      GestureDetector(
                                        onTap: () => _showFullScreenImage(context, photoUrl),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: Colors.grey.shade200),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              photoUrl,
                                              height: 120,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (context, child, loadingProgress) {
                                                if (loadingProgress == null) return child;
                                                return Container(
                                                  height: 120,
                                                  color: Colors.grey.shade100,
                                                  child: const Center(
                                                    child: CircularProgressIndicator(strokeWidth: 2),
                                                  ),
                                                );
                                              },
                                              errorBuilder: (context, error, stackTrace) {
                                                return Container(
                                                  height: 120,
                                                  color: Colors.grey.shade100,
                                                  child: const Center(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Icon(Icons.broken_image, color: Colors.grey, size: 32),
                                                        SizedBox(height: 4),
                                                        Text(
                                                          'Failed to load image',
                                                          style: TextStyle(fontSize: 12, color: Colors.grey),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],

                                    // ─── Operator Reply ───
                                    if (hasReply) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: isResolved 
                                              ? Colors.green.shade50 
                                              : Colors.blue.shade50,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: isResolved 
                                                ? Colors.green.shade200 
                                                : Colors.blue.shade200,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.reply,
                                                  size: 14,
                                                  color: isResolved 
                                                      ? Colors.green.shade700 
                                                      : Colors.blue.shade700,
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  'Operator Response',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                    color: isResolved 
                                                        ? Colors.green.shade700 
                                                        : Colors.blue.shade700,
                                                  ),
                                                ),
                                                if (isResolved) ...[
                                                  const SizedBox(width: 8),
                                                  Icon(
                                                    Icons.check_circle,
                                                    size: 12,
                                                    color: Colors.green.shade700,
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              operatorReply,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '— $repliedByName',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],

                                    // ─── Reply Button (Operator only) ───
                                    if (isOperator && !hasReply) ...[
                                      const SizedBox(height: 12),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () => _showReplyDialog(report),
                                          style: TextButton.styleFrom(
                                            foregroundColor: _brandGreen,
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Reply',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              SizedBox(width: 4),
                                              Icon(Icons.arrow_forward, size: 14),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                            childCount: _reports.length,
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }
}