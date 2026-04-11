/// Represents a veterinarian in the system.
class Veterinarian {
  /// The unique ID from the database (null if not yet saved).
  int? id;

  /// The veterinarian's full name.
  String name;

  /// The veterinarian's date of birth (stored as a string, e.g. "1985-06-15").
  String birthday;

  /// The veterinarian's home address.
  String address;

  /// The university where the veterinarian graduated.
  String university;

  /// Creates a new [Veterinarian] instance.
  Veterinarian({
    this.id,
    required this.name,
    required this.birthday,
    required this.address,
    required this.university,
  });

  /// Converts a database map row into a [Veterinarian] object.
  factory Veterinarian.fromMap(Map<String, dynamic> map) {
    return Veterinarian(
      id: map['id'],
      name: map['name'],
      birthday: map['birthday'],
      address: map['address'],
      university: map['university'],
    );
  }

  /// Converts this [Veterinarian] into a map for database insertion.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'birthday': birthday,
      'address': address,
      'university': university,
    };
  }
}