import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:meatzo/core/network/httpservice.dart';
import 'package:meatzo/models/address_model.dart';
import 'package:meatzo/presentation/Global_widget/AppbarGlobal.dart';
import 'package:meatzo/presentation/Global_widget/Appcolor.dart';
import 'package:meatzo/presentation/Global_widget/app_routes.dart';
import 'package:meatzo/presentation/Global_widget/apptext.dart';
import 'package:meatzo/screens/Mycart/ChangeAddress.dart';
import 'package:hive/hive.dart';

class AddressList extends StatefulWidget {
  const AddressList({super.key});

  @override
  State<AddressList> createState() => _AddressListState();
}

class _AddressListState extends State<AddressList> {
  List<Address> addresses = [];
  bool isLoading = true;
  String? error;
  Address? selectedAddress;

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    try {
      final response = await HttpClient.get("/addresses");
      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true) {
          if (!mounted) return;
          setState(() {
            addresses = (data['data'] as List)
                .map((address) => Address.fromJson(address))
                .toList();

            selectedAddress = addresses.firstWhere(
              (address) => address.isDefault == 1,
              orElse: () => addresses.first,
            );
            isLoading = false;
          });
        } else {
          if (!mounted) return;
          setState(() {
            error = data['message'] ?? 'Failed to load addresses';
            isLoading = false;
          });
        }
      } else {
        if (!mounted) return;
        setState(() {
          error = 'Failed to load addresses';
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _setDefaultAddress(int addressId) async {
    try {
      final response = await HttpClient.post(
        "/addresses/$addressId/set-default",
        {},
      );
      if (!mounted) return;

      if (response.statusCode == 200) {
        final box = await Hive.openBox('addressBox');
        final selected = addresses.firstWhere((a) => a.addressId == addressId);
        box.put('city', selected.city);
        box.put('state', selected.state);
        box.put('pin', selected.pinCode.toString());
        box.put('mobile', selected.mobileNumber);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Default address updated successfully')),
        );

        Navigator.pop(context, selected);
        _fetchAddresses();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update default address')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _deleteAddress(int addressId) async {
    try {
      final response = await HttpClient.delete("/addresses/$addressId");
      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address deleted successfully')),
        );
        _fetchAddresses();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete address')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Widget _buildAddressCard(Address address) {
    final isSelected = selectedAddress?.addressId == address.addressId;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Appcolor.primaryRed : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _setDefaultAddress(address.addressId),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on,
                                color: Appcolor.primaryRed, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Apptext(
                                text: address.streetAddress,
                                size: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_city,
                                color: Colors.grey, size: 16),
                            const SizedBox(width: 8),
                            Apptext(
                              text: '${address.city}, ${address.state}',
                              size: 14,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.public,
                                color: Colors.grey, size: 16),
                            const SizedBox(width: 8),
                            Apptext(
                              text: '${address.country} - ${address.pinCode}',
                              size: 14,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.phone,
                                color: Colors.grey, size: 16),
                            const SizedBox(width: 8),
                            Apptext(
                              text:
                                  '${address.countryCode ?? "+91"} ${address.mobileNumber}',
                              size: 14,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (address.isDefault == 1)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Appcolor.primaryRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star,
                              color: Appcolor.primaryRed, size: 14),
                          const SizedBox(width: 4),
                          Apptext(
                            text: 'Default',
                            color: Appcolor.primaryRed,
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (address.isDefault == 0)
                    TextButton.icon(
                      onPressed: () => _setDefaultAddress(address.addressId),
                      icon: Icon(Icons.star_border,
                          color: Appcolor.primaryRed, size: 18),
                      label: Apptext(
                        text: 'Set as Default',
                        color: Appcolor.primaryRed,
                        size: 14,
                      ),
                    ),
                  TextButton.icon(
                    onPressed: () => _deleteAddress(address.addressId),
                    icon: const Icon(Icons.delete_outline,
                        color: Colors.red, size: 18),
                    label: const Apptext(
                      text: 'Delete',
                      color: Colors.red,
                      size: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onTapped(int index) {
    setState(() {
      selectedIndex = index;
    });

    // Use pushReplacementNamed to avoid stacking nav bars
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.myCart);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.order);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).popUntil((route) => route.isFirst);
        return false;
      },
      child: Scaffold(
        appBar: const CustomAppBar(title: "My Addresses"),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Text(error!))
                : addresses.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_off,
                                size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text(
                              'No addresses found',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const AddressEntryScreen()),
                                ).then((_) => _fetchAddresses());
                              },
                              icon: const Icon(Icons.add_location),
                              label: const Text('Add New Address'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Appcolor.primaryRed,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: addresses.length,
                        itemBuilder: (context, index) =>
                            _buildAddressCard(addresses[index]),
                      ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AddressEntryScreen()),
            ).then((_) => _fetchAddresses());
          },
          backgroundColor: Appcolor.primaryRed,
          icon: const Icon(Icons.add_location, color: Colors.white),
          label:
              const Text('Add Address', style: TextStyle(color: Colors.white)),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF9A292F),
          currentIndex: selectedIndex,
          onTap: onTapped,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart), label: "MyCart"),
            BottomNavigationBarItem(
                icon: Icon(Icons.local_shipping), label: "Order"),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle), label: "Profile"),
          ],
        ),
      ),
    );
  }
}
