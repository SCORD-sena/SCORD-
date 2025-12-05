import 'dart:convert';
import 'package:http/http.dart' as http;

class CronogramaController {
  static const String baseUrl = "http://127.0.0.1:8000/api/cronograma";

  Future<List> getCronogramas() async {
    final res = await http.get(Uri.parse("$baseUrl/cronogramas"));
    return jsonDecode(res.body);
  }

  Future<List> getPartidos() async {
    final res = await http.get(Uri.parse("$baseUrl/partidos"));
    return jsonDecode(res.body);
  }

  Future<List> getCategorias() async {
    final res = await http.get(Uri.parse("$baseUrl/categorias"));
    return jsonDecode(res.body);
  }
   Future<bool> borrarCronograma(int id) async {
    final res = await http.delete(Uri.parse("$baseUrl/cronogramas/$id"));
    final data = jsonDecode(res.body);
    return data["success"] == true;
  }

  Future<bool> borrarPartido(int id) async {
    final res = await http.delete(Uri.parse("$baseUrl/partidos/$id"));
    final data = jsonDecode(res.body);
    return data["success"] == true;
  }
}
