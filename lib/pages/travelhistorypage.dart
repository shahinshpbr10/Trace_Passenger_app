import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class TravelHistoryPage extends StatefulWidget {
  const TravelHistoryPage({super.key});

  @override
  State<TravelHistoryPage> createState() => _TravelHistoryPageState();
}

class _TravelHistoryPageState extends State<TravelHistoryPage> {
  String searchQuery = '';
  String? selectedRoute;

  Stream<QuerySnapshot> getPaymentsStream() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('passengers')
        .doc(uid)
        .collection('payments')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            runSpacing: 10,
            children: [
              const Text("Filter by Route", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ListTile(
                title: const Text("Melattur"),
                onTap: () {
                  setState(() => selectedRoute = 'MELATTUR');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Perinthalmanna"),
                onTap: () {
                  setState(() => selectedRoute = 'PERINTALMANNA');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Clear Filter"),
                onTap: () {
                  setState(() => selectedRoute = null);
                  Navigator.pop(context);
                },
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      appBar: AppBar(
        title: const Text("Travel History"),
        backgroundColor: const Color(0xFF3D5AFE),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by route or bus...',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Iconsax.search_normal),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) => setState(() => searchQuery = value),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: _showFilterSheet,
                  icon: const Icon(Iconsax.setting_4, color: Color(0xFF3D5AFE)),
                )
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getPaymentsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("No travel history available."));
                }

                final filtered = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final matchesSearch = data['route'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
                      data['busName'].toString().toLowerCase().contains(searchQuery.toLowerCase());
                  final matchesFilter = selectedRoute == null || data['route'] == selectedRoute;
                  return matchesSearch && matchesFilter;
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final data = filtered[index].data() as Map<String, dynamic>;
                    final date = (data['timestamp'] as Timestamp).toDate();
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.directions_bus, color: Color(0xFF3D5AFE)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    data['busName'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF3D5AFE),
                                    ),
                                  ),
                                ),
                                Text(
                                  "₹${data['amount']}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.route, size: 18, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Text("Route: ${data['route']}"),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.people, size: 18, color: Colors.grey),
                                    const SizedBox(width: 6),
                                    Text("x${data['passengerCount']}"),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                const SizedBox(width: 6),
                                Text(
                                  "${date.day}/${date.month}/${date.year}",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );

                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}