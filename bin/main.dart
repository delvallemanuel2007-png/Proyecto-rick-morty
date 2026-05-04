import 'utils/utils.dart';
import 'utils/sesion.dart';
import 'utils/navegacion.dart';

void main() async {
  print('Iniciando Rick and Morty App...');

  bool continuar = true;

  do {
    mostrarMenuPrincipal();
    int opcion = leerEntero('Elige una opcion: ');
    continuar = await gestionarMenuPrincipal(opcion);

    while (haySesionActiva()) {
      mostrarMenuUsuario();
      int opcionUsuario = leerEntero('Elige una opcion: ');
      await gestionarMenuUsuario(opcionUsuario);
    }
  } while (continuar);
}