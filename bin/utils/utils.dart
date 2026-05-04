import 'dart:io';
import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'model_class.dart';

String leerTexto(String mensaje) {
  stdout.write(mensaje);
  return stdin.readLineSync() ?? '';
}

int leerEntero(String mensaje) {
  stdout.write(mensaje);
  String entrada = stdin.readLineSync() ?? '';
  return int.tryParse(entrada) ?? -1;
}

int numeroAleatorio(int min, int max) {
  Random random = Random();
  return min + random.nextInt(max - min + 1);
}

Future<PersonajeApi?> obtenerPersonajeAleatorio() async {
  int id = numeroAleatorio(1, 200);
  String url = 'https://rickandmortyapi.com/api/character/$id';

  try {
    http.Response respuesta = await http.get(Uri.parse(url));

    if (respuesta.statusCode == 200) {
      Map<String, dynamic> datos = jsonDecode(respuesta.body);
      return PersonajeApi.fromJson(datos);
    } else {
      print('Error al conectar con la API. Codigo: ${respuesta.statusCode}');
      return null;
    }
  } catch (e) {
    print('No se pudo conectar con la API: $e');
    return null;
  }
}

void mostrarPersonajeApi(PersonajeApi personaje, int precio) {
  print('');
  print('--- Personaje encontrado ---');
  print('ID en la API : ${personaje.id}');
  print('Nombre       : ${personaje.name}');
  print('Estado       : ${personaje.status}');
  print('Especie      : ${personaje.species}');
  print('Precio       : $precio monedas');
  print('----------------------------');
}