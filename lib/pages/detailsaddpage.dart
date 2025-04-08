import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'custombottomnavbar.dart';

class PassengerDetailsPage extends StatefulWidget {
  const PassengerDetailsPage({super.key});

  @override
  State<PassengerDetailsPage> createState() => _PassengerDetailsPageState();
}

class _PassengerDetailsPageState extends State<PassengerDetailsPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String gender = "Male";
  bool isLoading = false;

  void saveDetails() async {
    setState(() => isLoading = true);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection("passengers").doc(uid).set({
      "name": nameController.text.trim(),
      "phone": phoneController.text.trim(),
      "address": addressController.text.trim(),
      "gender": gender,
      "uid": uid,
    });

    setState(() => isLoading = false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const BottomNavPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      appBar: AppBar(
        title: const Text("Passenger Details"),
        backgroundColor: const Color(0xFF3D5AFE),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Full Name",
                prefixIcon: const Icon(Iconsax.user),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Phone Number",
                prefixIcon: const Icon(Iconsax.call),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              decoration: InputDecoration(
                labelText: "Address",
                prefixIcon: const Icon(Iconsax.location),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: gender,
              decoration: InputDecoration(
                labelText: "Gender",
                prefixIcon: const Icon(Iconsax.profile_circle),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              items: ["Male", "Female", "Other"].map((g) {
                return DropdownMenuItem(value: g, child: Text(g));
              }).toList(),
              onChanged: (val) => setState(() => gender = val!),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3D5AFE),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Submit",
                  style:
                  TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}