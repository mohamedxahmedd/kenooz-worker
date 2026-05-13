/// ──────────────────────────────────────────────────────────────────────────────
/// Billing Data — required by Paymob's payment-key endpoint.
/// ──────────────────────────────────────────────────────────────────────────────
class PaymobBillingData {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String apartment;
  final String floor;
  final String street;
  final String building;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String shippingMethod;

  const PaymobBillingData({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    this.apartment = 'N/A',
    this.floor = 'N/A',
    this.street = 'N/A',
    this.building = 'N/A',
    this.city = 'Cairo',
    this.state = 'Cairo',
    this.country = 'EG',
    this.postalCode = 'N/A',
    this.shippingMethod = 'N/A',
  });

  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone_number': phoneNumber,
        'apartment': apartment,
        'floor': floor,
        'street': street,
        'building': building,
        'city': city,
        'state': state,
        'country': country,
        'postal_code': postalCode,
        'shipping_method': shippingMethod,
      };
}
