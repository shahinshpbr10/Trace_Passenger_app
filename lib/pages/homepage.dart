import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:trace_companion/pages/busdetailspage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = '';
  String searchQuery = '';
  String? selectedDriver;

  @override
  void initState() {
    super.initState();
    fetchPassengerName();
  }

  Future<void> fetchPassengerName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final doc = await FirebaseFirestore.instance.collection('passengers').doc(uid).get();
    setState(() {
      userName = doc.data()?['name'] ?? 'Passenger';
    });
  }

  Future<List<Map<String, dynamic>>> fetchAllBuses() async {
    final busOwners = await FirebaseFirestore.instance.collection('busOwners').get();
    List<Map<String, dynamic>> allBuses = [];

    for (var owner in busOwners.docs) {
      final busesSnap = await owner.reference.collection('buses').get();
      for (var busDoc in busesSnap.docs) {
        allBuses.add(busDoc.data());
      }
    }

    return allBuses.where((bus) {
      final matchesSearch = bus['name']
          .toString()
          .toLowerCase()
          .contains(searchQuery.toLowerCase()) ||
          bus['numberPlate']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase());
      final matchesDriver = selectedDriver == null || bus['driver'] == selectedDriver;
      return matchesSearch && matchesDriver;
    }).toList();
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
              const Text("Filter by Driver", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ListTile(
                title: const Text("Shijah"),
                onTap: () {
                  setState(() => selectedDriver = 'shijah');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Sayuj"),
                onTap: () {
                  setState(() => selectedDriver = 'sayuj');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Clear Filter"),
                onTap: () {
                  setState(() => selectedDriver = null);
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
      body: Column(
        children: [
          // Curved AppBar
          ClipPath(
            clipper: _CurveClipper(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 50),
              width: double.infinity,
              color: const Color(0xFF3D5AFE),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Hi, $userName 👋",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: const [
                          Icon(Iconsax.notification, color: Colors.white),
                          SizedBox(width: 10),
                          CircleAvatar(
                            backgroundImage: AssetImage('assets/Images/logotrace.png'),
                            radius: 18,
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() => searchQuery = value);
                          },
                          decoration: InputDecoration(
                            hintText: "Search buses...",
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Iconsax.search_normal),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Iconsax.setting_4, color: Colors.white),
                        onPressed: _showFilterSheet,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),

          // Bus List
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchAllBuses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No buses found."));
                }

                final buses = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: buses.length,
                  itemBuilder: (context, index) {
                    final bus = buses[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          )
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            bus['image'],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.bus_alert),
                          ),
                        ),
                        title: Text(
                          bus['name'] ?? 'No name',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text("Plate: ${bus['numberPlate']}"),
                            Text("Driver: ${bus['driver']}, Helper: ${bus['helper']}"),
                          ],
                        ),
                        trailing: const Icon(Iconsax.arrow_right_3),
                        onTap: () {
                         Navigator.of(context).push(MaterialPageRoute(builder: (context) => BusDetailsPage(bus: bus),));
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height );
    path.quadraticBezierTo(size.width / 2, size.height, size.width, size.height - 40);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
