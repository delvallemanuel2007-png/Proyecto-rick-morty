import 'utils.dart';
import 'sesion.dart';
import 'database.dart';
import 'model_class.dart';
import '../entities/entities.dart';

void mostrarMenuPrincipal() {
  print('');
  print('=== Rick and Morty App ===');
  print('1. Registrarse');
  print('2. Iniciar sesion');
  print('0. Salir');
  print('==========================');
}

void mostrarMenuUsuario() {
  print('');
  print('=== Bienvenido, ${usuarioActivo!.username} ===');
  print('Monedas: ${usuarioActivo!.monedas}');
  print('1. Obtener personaje aleatorio');
  print('2. Mi equipo');
  print('3. Quiz');
  print('4. Cerrar sesion');
  print('================================');
}

Future<bool> gestionarMenuPrincipal(int opcion) async {
  switch (opcion) {
    case 2:
      await flujoRegistro();
      break;
    case 3:
      await flujoLogin();
      break;
    case 1:
      print('Hasta luego.');
      return false;
    default:
      print('Opcion no valida.');
  }
  return true;
}

Future<void> gestionarMenuUsuario(int opcion) async {
  switch (opcion) {
    case 1:
      await flujoPersonajeAleatorio();
      break;
    case 2:
      await flujoMiEquipo();
      break;
    case 3:
      await flujoQuiz();
      break;
    case 4:
      cerrarSesion();
      print('Sesion cerrada.');
      break;
    default:
      print('Opcion no valida.');
  }
}

Future<void> flujoRegistro() async {
  print('');
  print('--- Registro ---');
  String username = leerTexto('Nombre de usuario: ');
  String password = leerTexto('Contrasena: ');

  if (username.isEmpty || password.isEmpty) {
    print('El nombre y la contrasena no pueden estar vacios.');
    return;
  }

  bool exito = await registrarUsuario(username, password);
  if (exito) {
    print('Usuario registrado correctamente. Ya puedes iniciar sesion.');
  } else {
    print('Ese nombre de usuario ya existe. Prueba con otro.');
  }
}

Future<void> flujoLogin() async {
  print('');
  print('--- Inicio de sesion ---');
  String username = leerTexto('Nombre de usuario: ');
  String password = leerTexto('Contrasena: ');

  Usuario? usuario = await loginUsuario(username, password);
  if (usuario != null) {
    usuarioActivo = usuario;
    print('Sesion iniciada correctamente.');
  } else {
    print('Nombre de usuario o contrasena incorrectos.');
  }
}

Future<void> flujoPersonajeAleatorio() async {
  print('');
  print('Buscando un personaje aleatorio...');

  PersonajeApi? personaje = await obtenerPersonajeAleatorio();

  if (personaje == null) {
    print('No se pudo obtener el personaje. Comprueba tu conexion a internet.');
    return;
  }

  int precio = numeroAleatorio(50, 150);
  mostrarPersonajeApi(personaje, precio);

  print('');
  print('Tienes ${usuarioActivo!.monedas} monedas.');

  if (usuarioActivo!.monedas < precio) {
    print('No tienes suficientes monedas para reclutar a este personaje.');
    return;
  }

  String respuesta = leerTexto('Quieres reclutar a ${personaje.name}? (s/n): ');

  if (respuesta.toLowerCase() == 's') {
    bool exito = await reclurarPersonaje(
      usuarioActivo!.id,
      personaje.id,
      personaje.name,
      personaje.status,
      personaje.species,
      precio,
    );

    if (exito) {
      usuarioActivo!.monedas -= precio;
      print('${personaje.name} ha sido reclutado. Te quedan ${usuarioActivo!.monedas} monedas.');
    }
  } else {
    print('No has reclutado al personaje.');
  }
}

Future<void> flujoMiEquipo() async {
  print('');
  print('--- Mi equipo ---');

  List<Personaje> equipo = await obtenerEquipo(usuarioActivo!.id);

  if (equipo.isEmpty) {
    print('Todavia no tienes ningun personaje en tu equipo.');
    return;
  }

  for (Personaje p in equipo) {
    print('');
    print('Nombre  : ${p.name}');
    print('Estado  : ${p.status}');
    print('Especie : ${p.species}');
    print('Precio  : ${p.price} monedas');
  }
  print('');
  print('Total de personajes: ${equipo.length}');
}

Future<void> flujoQuiz() async {
  print('');
  print('--- Quiz de Rick and Morty ---');
  print('Respuesta correcta: +30 monedas');
  print('Respuesta incorrecta: -10 monedas');
  print('');

  List<Map<String, dynamic>> preguntas = [
    {
      'texto': 'Cual es el nombre completo del inventor de la pistola de portal?',
      'opciones': ['Rick Sanchez', 'Morty Smith', 'Bird Person', 'Mr. Meeseeks'],
      'correcta': 0,
    },
    {
      'texto': 'Como se llama el planeta en el que vive la familia Smith?',
      'opciones': ['Marte', 'Cronenberg World', 'La Tierra', 'Gazorpazorp'],
      'correcta': 2,
    },
    {
      'texto': 'Que frase repite constantemente Mr. Meeseeks?',
      'opciones': [
        'Wubba lubba dub dub',
        'Existence is pain',
        'I am Meeseeks, look at me',
        'Get schwifty'
      ],
      'correcta': 2,
    },
  ];

  int monedasGanadas = 0;

  for (int i = 0; i < preguntas.length; i++) {
    Map<String, dynamic> pregunta = preguntas[i];
    print('Pregunta ${i + 1}: ${pregunta['texto']}');

    List<String> opciones = pregunta['opciones'];
    for (int j = 0; j < opciones.length; j++) {
      print('  ${j + 1}. ${opciones[j]}');
    }

    int respuesta = leerEntero('Tu respuesta (1-4): ');

    if (respuesta < 1 || respuesta > 4) {
      print('Respuesta no valida. Se cuenta como incorrecta.');
      monedasGanadas -= 10;
    } else if (respuesta - 1 == pregunta['correcta']) {
      print('Correcto! +30 monedas.');
      monedasGanadas += 30;
    } else {
      print('Incorrecto. La respuesta era: ${opciones[pregunta['correcta']]}. -10 monedas.');
      monedasGanadas -= 10;
    }

    print('');
  }

  int nuevasMonedas = usuarioActivo!.monedas + monedasGanadas;
  if (nuevasMonedas < 0) nuevasMonedas = 0;

  await actualizarMonedas(usuarioActivo!.id, nuevasMonedas);
  usuarioActivo!.monedas = nuevasMonedas;

  if (monedasGanadas >= 0) {
    print('Has ganado $monedasGanadas monedas en el quiz.');
  } else {
    print('Has perdido ${monedasGanadas.abs()} monedas en el quiz.');
  }
  print('Monedas actuales: ${usuarioActivo!.monedas}');
}