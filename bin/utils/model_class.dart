class PersonajeApi {
  int id;
  String name;
  String status;
  String species;

  PersonajeApi({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
  });

  factory PersonajeApi.fromJson(Map<String, dynamic> json) {
    return PersonajeApi(
      id: json['id'],
      name: json['name'],
      status: json['status'],
      species: json['species'],
    );
  }
}