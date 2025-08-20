class Address {
  final int addressId;
  final String country;
  final String addressUserId;
  final String state;
  final String city;
  final String streetAddress;
  final int pinCode;
  final String createdAt;
  final String updatedAt;
  final String mobileNumber;
  final String? countryCodeDigits;
  final String? countryCode;
  final int isDefault;
  final String? lat;
  final String? lng;

  Address({
    required this.addressId,
    required this.country,
    required this.addressUserId,
    required this.state,
    required this.city,
    required this.streetAddress,
    required this.pinCode,
    required this.createdAt,
    required this.updatedAt,
    required this.mobileNumber,
    this.countryCodeDigits,
    this.countryCode,
    required this.isDefault,
    this.lat,
    this.lng,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressId: json['address_id'],
      country: json['country'],
      addressUserId: json['address_user_id'],
      state: json['state'],
      city: json['city'],
      streetAddress: json['street_address'],
      pinCode: json['pin_code'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      mobileNumber: json['mobile_number'],
      countryCodeDigits: json['country_code_digits'],
      countryCode: json['country_code'],
      isDefault: json['is_default'],
      lat: json['lat'],
      lng: json['lng'],
    );
  }
}
