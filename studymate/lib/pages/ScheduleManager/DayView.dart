import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../../Pop-ups/StylishPopup.dart';

class DayView extends StatefulWidget {
  const DayView({super.key});

  @override
  _DayViewState createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  DateTime _selectedDate = DateTime.now();
  List<dynamic> _events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTasksForSelectedDay();
  }

  Future<void> _fetchTasksForSelectedDay() async {
    int userId = Hive.box('userBox').get('id');

    final startOfDay =
        DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
    final endOfDay = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day, 23, 59, 59);

    String url = 'https://alyibrahim.pythonanywhere.com/schedule';
    Map<String, String> queryParams = {
      'user_id': userId.toString(),
      'start_date': startOfDay.toIso8601String().split('T')[0],
      'end_date': endOfDay.toIso8601String().split('T')[0],
    };

    try {
      final uri = Uri.parse(url).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _events = json.decode(response.body);
          print(_events);
          _isLoading = false;
        });
      } else {
        setState(() {
          _events = [];
          _isLoading = false;
        });
        print('Failed to fetch schedule: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      print("Error fetching schedule: $e");
      setState(() {
        _events = [];
        _isLoading = false;
      });
    }
  }

  String _formatTime(String time) {
    try {
      final parsedTime = DateFormat("HH:mm:ss").parse(time);
      return DateFormat("hh:mm a").format(parsedTime);
    } catch (e) {
      return "Invalid Time";
    }
  }

  String _formatDate(String dateString) {
    try {
      final parsedDate = DateTime.parse(dateString);
      return DateFormat("dd MMM yyyy").format(parsedDate);
    } catch (e) {
      return "Invalid Date";
    }
  }

  String _getMonthName(int month) {
    const List<String> monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return monthNames[month - 1];
  }

  void _previousDay() {
    setState(() {
      _selectedDate = _selectedDate.subtract(const Duration(days: 1));
      _isLoading = true;
    });
    _fetchTasksForSelectedDay();
  }

  void _nextDay() {
    setState(() {
      _selectedDate = _selectedDate.add(const Duration(days: 1));
      _isLoading = true;
    });
    _fetchTasksForSelectedDay();
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
        _isLoading = true;
      });
      _fetchTasksForSelectedDay();
    }
  }

  Widget _buildEventCard(BuildContext context, dynamic event) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          // Time Column
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _formatTime(event['StartTime']),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF165D96),
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: 2,
                height: 40,
                color: Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                _formatTime(event['EndTime']),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1BC0C4),
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          // Make only the Expanded widget (task card) slidable from end to start
          Expanded(
            child: Dismissible(
              key: ValueKey(event['Sid']),
              direction: DismissDirection.endToStart,
              confirmDismiss: (DismissDirection direction) async {
                return await StylishPopup.question(
                  context: context,
                  title: 'Confirm Delete',
                  message: 'Are you sure you want to delete this task?',
                  confirmText: 'Delete',
                  cancelText: 'Cancel',
                );
              },
              onDismissed: (direction) {
                // Remove the item from data source
                setState(() {
                  _events.remove(event);
                });
                // Call API to delete task from server
                _deleteTask(event['Sid']);
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20.0),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1c74bb),
                      Color(0xFF165d96),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1c74bb).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Card(
                  margin: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(
                      event['Title'],
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        event['Description'] ?? '',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    trailing: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        onPressed: () {
                          // Show a popup with all the data of the task
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              // Prepare the repeat information
                              String repeatInfo = event['Repeatance'] ?? 'None';
                              if (event['Repeatance'] != null &&
                                  event['Repeatance'] != 'None' &&
                                  event['RepeatEndDate'] != null) {
                                repeatInfo +=
                                    ' until ${_formatDate(event['RepeatEndDate'])}';
                              }

                              return Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF1c74bb),
                                            Color(0xFF18bebc),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.event_note_rounded,
                                              color: Colors.white, size: 28),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              event['Title'],
                                              style: GoogleFonts.poppins(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          _buildDetailRow(
                                              Icons.description,
                                              'Description',
                                              event['Description'] ?? 'N/A'),
                                          _buildDetailRow(
                                              Icons.calendar_today,
                                              'Date',
                                              _formatDate(event['Date'])),
                                          _buildDetailRow(
                                              Icons.access_time,
                                              'Start Time',
                                              _formatTime(event['StartTime'])),
                                          _buildDetailRow(
                                              Icons.access_time,
                                              'End Time',
                                              _formatTime(event['EndTime'])),
                                          _buildDetailRow(
                                              Icons.location_on,
                                              'Location',
                                              event['Location'] ?? 'N/A'),
                                          _buildDetailRow(
                                              Icons.category,
                                              'Category',
                                              event['Category'] ?? 'N/A'),
                                          _buildDetailRow(Icons.repeat,
                                              'Repeat', repeatInfo),
                                          const SizedBox(height: 16),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFF1c74bb),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                              ),
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: Text(
                                                'Close',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        icon: const Icon(
                          Icons.info_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTask(int taskId) async {
    String url = 'https://alyibrahim.pythonanywhere.com/delete_task';
    Map<String, String> jsonfile = {
      'Sid': taskId.toString(),
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(jsonfile),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Task deleted successfully
        await StylishPopup.success(
          context: context,
          title: 'Task Deleted',
          message: 'Task has been deleted successfully.',
        );
      } else {
        // Handle error
        print('Failed to delete task: ${response.statusCode}');
        await StylishPopup.error(
          context: context,
          title: 'Failed to Delete Task',
          message: 'Failed to delete task. Please try again later.',
        );
      }
    } catch (e) {
      print('Error deleting task: $e');
      await StylishPopup.error(
        context: context,
        title: 'Failed to Delete Task',
        message: 'Failed to delete task. Please try again later.',
      );
    }
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1c74bb)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // If you have any subscriptions or controllers, dispose of them here
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Modern Date Navigation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1c74bb).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: _previousDay,
                    icon: const Icon(Icons.chevron_left_rounded,
                        size: 28, color: Color(0xFF1c74bb)),
                  ),
                ),
                GestureDetector(
                  onTap: _pickDate,
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          color: Color(0xFF1c74bb), size: 20),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('EEEE').format(_selectedDate),
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${_selectedDate.day} ${_getMonthName(_selectedDate.month)}",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF18bebc),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1c74bb).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: _nextDay,
                    icon: const Icon(Icons.chevron_right_rounded,
                        size: 28, color: Color(0xFF1c74bb)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Task List View
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1c74bb),
                    ),
                  )
                : _events.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1c74bb).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.event_busy_rounded,
                                size: 64,
                                color: Color(0xFF1c74bb),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No events scheduled",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Tap + to add a new event",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _events.length,
                        itemBuilder: (context, index) {
                          final event = _events[index];
                          return _buildEventCard(context, event);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
