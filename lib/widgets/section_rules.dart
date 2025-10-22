import 'package:flutter/material.dart';

class SectionRules extends StatelessWidget {
  final String chooseOpenDate;
  final String chooseCloseDate;
  final VoidCallback onCompleted;

  const SectionRules({
    super.key,
    required this.chooseOpenDate,
    required this.chooseCloseDate,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.blueGrey.withOpacity(0.1),
        border: Border.all(color: Colors.blueGrey, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Wahlregeln",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text("Auswahl offen ab: $chooseOpenDate"),
          Text("Auswahl schließt am: $chooseCloseDate"),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: onCompleted,
            child: const Text("Als erledigt markieren"),
          ),
        ],
      ),
    );
  }
}
