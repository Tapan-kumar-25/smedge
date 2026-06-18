class PersonalDetailsModel {
  final Identity identity;
  final Contact contact;
  final Address address;
  final String authProvider;
  final String requestId;
  final String timestamp;

  PersonalDetailsModel({
    required this.identity,
    required this.contact,
    required this.address,
    required this.authProvider,
    required this.requestId,
    required this.timestamp,
  });

  factory PersonalDetailsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};

    return PersonalDetailsModel(
      identity: Identity.fromJson(data['identity'] ?? {}),
      contact: Contact.fromJson(data['contact'] ?? {}),
      address: Address.fromJson(data['address'] ?? {}),
      authProvider: data['auth_provider'] ?? "",
      requestId: json['request_id'] ?? "",
      timestamp: json['timestamp'] ?? "",
    );
  }
}

class Identity {
  final String fullName;
  final bool fullNameEditable;
  final EmiratesId emiratesId;
  final String dateOfBirth;
  final String nationality;
  final String gender;
  final bool verified;

  Identity({
    required this.fullName,
    required this.fullNameEditable,
    required this.emiratesId,
    required this.dateOfBirth,
    required this.nationality,
    required this.gender,
    required this.verified,
  });

  factory Identity.fromJson(Map<String, dynamic> json) {
    return Identity(
      fullName: json['full_name'] ?? "",
      fullNameEditable: json['full_name_editable'] ?? false,
      emiratesId: EmiratesId.fromJson(json['emirates_id'] ?? {}),
      dateOfBirth: json['date_of_birth'] ?? "",
      nationality: json['nationality'] ?? "",
      gender: json['gender'] ?? "",
      verified: json['verified'] ?? false,
    );
  }
}

class EmiratesId {
  final String masked;
  final String full;

  EmiratesId({
    required this.masked,
    required this.full,
  });

  factory EmiratesId.fromJson(Map<String, dynamic> json) {
    return EmiratesId(
      masked: json['masked'] ?? "",
      full: json['full'] ?? "",
    );
  }
}

class Contact {
  final Email email;
  final Phone phone;
  final bool emailVerified;
  final bool phoneVerified;

  Contact({
    required this.email,
    required this.phone,
    required this.emailVerified,
    required this.phoneVerified,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      email: Email.fromJson(json['email'] ?? {}),
      phone: Phone.fromJson(json['phone'] ?? {}),
      emailVerified: json['email_verified'] ?? false,
      phoneVerified: json['phone_verified'] ?? false,
    );
  }
}

class Email {
  final String masked;
  final String full;

  Email({
    required this.masked,
    required this.full,
  });

  factory Email.fromJson(Map<String, dynamic> json) {
    return Email(
      masked: json['masked'] ?? "",
      full: json['full'] ?? "",
    );
  }
}

class Phone {
  final String masked;
  final String full;

  Phone({
    required this.masked,
    required this.full,
  });

  factory Phone.fromJson(Map<String, dynamic> json) {
    return Phone(
      masked: json['masked'] ?? "",
      full: json['full'] ?? "",
    );
  }
}

class Address {
  final String permanentAddress;
  final String currentAddress;

  Address({
    required this.permanentAddress,
    required this.currentAddress,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      permanentAddress: json['permanent_address'] ?? "",
      currentAddress: json['current_address'] ?? "",
    );
  }
}