import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'loginandsignup.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const OTPLoginPage()),
          (route) => false,
    );
  }

  void triggerEmergency(BuildContext context) async {
    final dbRef = FirebaseDatabase.instance.ref().child('buseslive');

    // Fetch all buses
    final snapshot = await dbRef.get();
    if (!snapshot.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No buses available.")),
      );
      return;
    }

    final buses = snapshot.children.map((busSnap) {
      final busId = busSnap.key!;
      return {
        'busId': busId,
        'alert': busSnap.child('alert').value ?? false,
      };
    }).toList();

    // Show bottom sheet to pick a bus
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select a Bus to Trigger Emergency 🚨", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            ...buses.map((bus) {
              return ListTile(
                title: Text("Bus ID: ${bus['busId']}"),
                trailing: bus['alert'] == true
                    ? const Text("Already Alerted", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500))
                    : const Text("Available", style: TextStyle(color: Colors.green)),
                onTap: () async {
                  // Update alert flag
                  await dbRef.child(bus['busId'] as String).update({'alert': true});
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("🚨 Emergency alert triggered successfully!")),
                  );
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: const Color(0xFF3D5AFE),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Iconsax.user, color: Color(0xFF3D5AFE)),
              title: const Text("Account"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Iconsax.information, color: Color(0xFF3D5AFE)),
              title: const Text("About"),
              onTap: () {},
            ),
            const Spacer(),

            // 🚨 Emergency Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () => triggerEmergency(context),
                icon: const Icon(Iconsax.warning_2, color: Colors.white),
                label: const Text("Emergency", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🚪 Logout Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () => logout(context),
                icon: const Icon(Iconsax.logout, color: Colors.white),
                label: const Text("Logout", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
