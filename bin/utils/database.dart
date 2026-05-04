import 'package:mysql1/mysql1.dart';
import '../entities/entities.dart';

final ConnectionSettings configuracion = ConnectionSettings(
  host: 'localhost',
  port: 3306,
  user: 'root',
  password: null,
  db: 'rickmorty_db',
);

Future<MySqlConnection> abrirConexion() async {
  try {
    print('Intentando conectar a MySQL...');
    final conn = await MySqlConnection.connect(configuracion);
    print('Conexión correcta');
    return conn;
  } catch (e) {
    print('ERROR DE CONEXIÓN: $e');
    rethrow;
  }
}

Future<bool> registrarUsuario(String username, String password) async {
  MySqlConnection conn = await abrirConexion();
  try {
    await conn.query(
      'INSERT INTO users (username, password, monedas) VALUES (?, ?, 100)',
      [username, password],
    );
    return true;
  } catch (e) {
    return false;
  } finally {
    await conn.close();
  }
}

Future<Usuario?> loginUsuario(String username, String password) async {
  MySqlConnection conn = await abrirConexion();
  try {
    Results resultado = await conn.query(
      'SELECT id, username, password, monedas FROM users WHERE username = ? AND password = ?',
      [username, password],
    );

    if (resultado.isNotEmpty) {
      ResultRow fila = resultado.first;
      return Usuario(
        id: fila[0],
        username: fila[1],
        password: fila[2],
        monedas: fila[3],
      );
    }
    return null;
  } finally {
    await conn.close();
  }
}

Future<bool> reclurarPersonaje(
    int idUsuario, int apiId, String name, String status, String species, int price) async {
  MySqlConnection conn = await abrirConexion();
  try {
    Results existe = await conn.query(
      'SELECT id FROM personajes WHERE api_id = ?',
      [apiId],
    );

    int idPersonaje;

    if (existe.isEmpty) {
      Results insercion = await conn.query(
        'INSERT INTO personajes (api_id, name, status, species, price) VALUES (?, ?, ?, ?, ?)',
        [apiId, name, status, species, price],
      );
      idPersonaje = insercion.insertId!;
    } else {
      idPersonaje = existe.first[0];
    }

    Results yaReclutado = await conn.query(
      'SELECT 1 FROM users_personajes WHERE id_user = ? AND id_personaje = ?',
      [idUsuario, idPersonaje],
    );

    if (yaReclutado.isNotEmpty) {
      print('Ya tienes a este personaje en tu equipo.');
      return false;
    }

    await conn.query(
      'INSERT INTO users_personajes (id_user, id_personaje) VALUES (?, ?)',
      [idUsuario, idPersonaje],
    );

    await conn.query(
      'UPDATE users SET monedas = monedas - ? WHERE id = ?',
      [price, idUsuario],
    );

    return true;
  } catch (e) {
    print('Error al reclutar personaje: $e');
    return false;
  } finally {
    await conn.close();
  }
}

Future<int> obtenerMonedas(int idUsuario) async {
  MySqlConnection conn = await abrirConexion();
  try {
    Results resultado = await conn.query(
      'SELECT monedas FROM users WHERE id = ?',
      [idUsuario],
    );
    return resultado.first[0];
  } finally {
    await conn.close();
  }
}

Future<void> actualizarMonedas(int idUsuario, int nuevasMonedas) async {
  MySqlConnection conn = await abrirConexion();
  try {
    await conn.query(
      'UPDATE users SET monedas = ? WHERE id = ?',
      [nuevasMonedas, idUsuario],
    );
  } finally {
    await conn.close();
  }
}

Future<List<Personaje>> obtenerEquipo(int idUsuario) async {
  MySqlConnection conn = await abrirConexion();
  try {
    Results resultado = await conn.query(
      '''
      SELECT p.id, p.api_id, p.name, p.status, p.species, p.price
      FROM personajes p
      INNER JOIN users_personajes up ON p.id = up.id_personaje
      WHERE up.id_user = ?
      ''',
      [idUsuario],
    );

    List<Personaje> equipo = [];
    for (ResultRow fila in resultado) {
      equipo.add(Personaje(
        id: fila[0],
        apiId: fila[1],
        name: fila[2],
        status: fila[3],
        species: fila[4],
        price: fila[5],
      ));
    }
    return equipo;
  } finally {
    await conn.close();
  }
}