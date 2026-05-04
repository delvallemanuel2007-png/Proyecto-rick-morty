import '../entities/entities.dart';


Usuario? usuarioActivo;

bool haySesionActiva() {
  return usuarioActivo != null;
}

void cerrarSesion() {
  usuarioActivo = null;
}