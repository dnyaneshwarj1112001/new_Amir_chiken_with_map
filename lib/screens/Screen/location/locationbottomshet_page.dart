import 'package:meatzo/presentation/Global_widget/Appcolor.dart';
import 'package:meatzo/presentation/Global_widget/apptext.dart';
import 'package:meatzo/presentation/Global_widget/gap.dart';
import 'package:flutter/material.dart';

void showLocationBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
    ),
    builder: (context) {
      return SizedBox(
        height: 300,
        child: Column(
          children: [
            Column(
              children: [
                Container(
                  color: Appcolor.primaryRed,
                  height: 80,
                  width: MediaQuery.of(context).size.width,
                  child: const Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 15,
                              color: Colors.white,
                            ),
                            Apptext(
                              text: "Location Permisson is off",
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              size: 15,
                            ),
                            Gapw(width: 40),
                            Chip(
                              label: Apptext(
                                text: " GRANT",
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              backgroundColor: Colors.white,
                            )
                          ],
                        ),
                        Apptext(
                          text:
                              "Granting location permission will help ensure accurate delivery.",
                          size: 12,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                ),
                const Gaph(height: 10),
                const Apptext(
                  text: "Select Delevary Address",
                  fontWeight: FontWeight.bold,
                  size: 14,
                ),
                const Divider(),
              ],
            ),
            ListTile(
              leading: const Icon(
                  Icons.home_outlined), // Changed icon to work-related
              title: const Text("Home"), // Updated title
              subtitle: const Apptext(
                  text:
                      "123 Greenway Street, Maple City, NY 10001"), // Added fake address
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.work), // Changed icon to work-related
              title: const Text("Work Address"), // Updated title
              subtitle: const Apptext(
                  text:
                      "123 Greenway Street, Maple City, NY 10001"), // Added fake address
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    },
  );
}
