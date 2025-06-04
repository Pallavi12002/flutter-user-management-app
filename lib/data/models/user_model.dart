


import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String image;
  final UserAddress address;
  final UserCompany company;

  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.image,
    required this.address,
    required this.company,
  });

  String get fullName => '$firstName $lastName';

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      image: json['image'] ?? '',
      address: UserAddress.fromJson(json['address'] ?? {}),
      company: UserCompany.fromJson(json['company'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'image': image,
      'address': address.toJson(),
      'company': company.toJson(),
    };
  }

  @override
  List<Object> get props => [
    id, firstName, lastName, email, phone, image, address, company
  ];
}

class UserAddress extends Equatable {
  final String address;
  final String city;
  final String state;
  final String postalCode;

  const UserAddress({
    required this.address,
    required this.city,
    required this.state,
    required this.postalCode,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postalCode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'city': city,
      'state': state,
      'postalCode': postalCode,
    };
  }

  @override
  List<Object> get props => [address, city, state, postalCode];
}

class UserCompany extends Equatable {
  final String name;
  final String title;

  const UserCompany({
    required this.name,
    required this.title,
  });

  factory UserCompany.fromJson(Map<String, dynamic> json) {
    return UserCompany(
      name: json['name'] ?? '',
      title: json['title'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'title': title,
    };
  }

  @override
  List<Object> get props => [name, title];
}