import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'; // For date picker
import 'RecognitionScreen.dart';
import 'RegistrationScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomePageState();
}

class _HomePageState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  _selectDate(BuildContext context) async {
    DateTime picked = await DatePicker.showDatePicker(
          context,
          showTitleActions: true,
          minTime: DateTime(2020),
          maxTime: DateTime.now(),
          onConfirm: (date) {
            setState(() {
              selectedDate = date;
              formattedDate = DateFormat('yyyy-MM-dd').format(date);
            });
          },
          currentTime: selectedDate,
          locale: LocaleType.en,
        ) ??
        selectedDate;

    setState(() {
      formattedDate = DateFormat('yyyy-MM-dd').format(picked);
    });
  }

  void _showAttendanceLogs(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Row(
                children: const [
                  Icon(Icons.fact_check, color: Colors.black, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Attendance History',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 300,
                height: 450,
                child: Column(
                  children: [
                    Text(
                      "Selected Date: $formattedDate",
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        DateTime picked = await DatePicker.showDatePicker(
                              context,
                              showTitleActions: true,
                              minTime: DateTime(2020),
                              maxTime: DateTime.now(),
                              onConfirm: (date) {
                                setState(() {
                                  formattedDate =
                                      DateFormat('yyyy-MM-dd').format(date);
                                });
                              },
                              currentTime: selectedDate,
                              locale: LocaleType.en,
                            ) ??
                            selectedDate;

                        setState(() {
                          formattedDate =
                              DateFormat('yyyy-MM-dd').format(picked);
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white70,
                        minimumSize: const Size(150, 40),
                      ),
                      child: const Text(
                        "Choose Date",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('recognition_history')
                            .where('timestamp',
                                isGreaterThanOrEqualTo: Timestamp.fromDate(
                                    DateTime.parse(formattedDate).toUtc()))
                            .where('timestamp',
                                isLessThanOrEqualTo: Timestamp.fromDate(
                                    DateTime.parse(formattedDate)
                                        .add(const Duration(days: 1))
                                        .toUtc()))
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'No logs available.',
                                style: TextStyle(color: Colors.black54),
                              ),
                            );
                          }

                          final logs = snapshot.data!.docs;

                          return ListView.builder(
                            itemCount: logs.length,
                            itemBuilder: (context, index) {
                              final log =
                                  logs[index].data() as Map<String, dynamic>;
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: ListTile(
                                  title: Text(
                                    'Name: ${log['name']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    'Timestamp: ${DateFormat('yyyy-MM-dd HH:mm:ss').format((log['timestamp'] as Timestamp).toDate())} ',
                                  ),
                                  leading: const Icon(
                                    Icons.check_circle_outline,
                                    color: Colors.green,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
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
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: Container(
          height: screenHeight,
          width: screenWidth,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.grey, Colors.black12],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 40.0),
              // Header Card - Expanded
              Container(
                width: screenWidth,
                height: screenHeight * 0.25,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black, Colors.grey],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'FaceRe',
                        style: TextStyle(
                          fontFamily: 'Bubble',
                          color: Colors.white,
                          fontSize: 36.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Face Recognition Attendance',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: const Color(0xFFE0E0E0),
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              // Combined Container for FaceRe and Register your face
              Expanded(
                flex: 2, // Increased flex to give more space
                child: Material(
                  color: Colors.transparent,
                  elevation: 2.0,
                  shape: RoundedRectangleBorder(
                      // No rounded corners here
                      ),
                  child: Container(
                    width: screenWidth,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.grey, Colors.blueGrey],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Register face / Attendance',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegistrationScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.person_add,
                                  color: Colors.black,
                                ),
                                label: const Text(
                                  'Register',
                                  style: TextStyle(color: Colors.black),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(195, 255, 255, 255),
                                  minimumSize: const Size(160, 50),
                                ),
                              ),
                              const SizedBox(height: 32),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RecognitionScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.face,
                                  color: Colors.black,
                                ),
                                label: const Text(
                                  'Attendance',
                                  style: TextStyle(color: Colors.black),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(188, 251, 252, 250),
                                  minimumSize: const Size(160, 50),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16.0),
                          // History Section
                          Container(
                            width: screenWidth,
                            height: screenHeight * 0.18,
                            padding: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.history,
                                        color: Colors.black,
                                        size: 24,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'HISTORY',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () => _showAttendanceLogs(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    minimumSize: const Size(160, 50),
                                  ),
                                  child: const Text(
                                    'View Attendance History',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
