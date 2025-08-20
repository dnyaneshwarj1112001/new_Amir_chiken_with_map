import 'package:flutter/material.dart';
import 'package:meatzo/presentation/Global_widget/Appcolor.dart';
import 'package:meatzo/presentation/Global_widget/icons/globalicons.dart';

class CustomiseDrawerandchip extends StatefulWidget {
  final String text;
  const CustomiseDrawerandchip({super.key, required this.text});

  @override
  State<CustomiseDrawerandchip> createState() => _CustomiseDrawerandchipState();
}

class _CustomiseDrawerandchipState extends State<CustomiseDrawerandchip> {
  final TextEditingController _pincodeController = TextEditingController();

  void _showLocationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Change Location"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter your new pincode:"),
              const SizedBox(height: 10),
              TextField(
                controller: _pincodeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Enter pincode",
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Appcolor.primaryRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                String updatedPincode = _pincodeController.text.trim();
                if (updatedPincode.isNotEmpty) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Location updated to $updatedPincode"),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Please enter a valid pincode"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text(
                "Update",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  const Row(
                    children: [
                      Globalicons(
                        icon: Icons.home,
                        color: Colors.white,
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: _showLocationDialog,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  SizedBox(
                                    width: 200,
                                    child: Text(
                                      "Flat No. 301, Balaji Heights, Shivaji Nagar, Pune",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                  SizedBox(width: 5),
                                  Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                              Builder(
                                builder: (context) => IconButton(
                                  icon: const Icon(
                                    Icons.menu,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    Scaffold.of(context).openDrawer();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        // const SizedBox(height: 8),
      ],
    );
  }
}
