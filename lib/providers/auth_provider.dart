import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  int? _usuarioId;
  String? _nome;
  String? _tipoUsuario;
  bool _logado = false;

  int? get usuarioId => _usuarioId;
  String? get nome => _nome;
  String? get tipoUsuario => _tipoUsuario;
  bool get logado => _logado;

  Future<void> carregarSessao() async {
    final prefs = await SharedPreferences.getInstance();

    _usuarioId = prefs.getInt('usuarioId');
    _nome = prefs.getString('nome');
    _tipoUsuario = prefs.getString('tipoUsuario');
    _logado = prefs.getBool('logado') ?? false;

    notifyListeners();
  }

  Future<void> login({
    required int usuarioId,
    required String nome,
    required String tipoUsuario,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('usuarioId', usuarioId);
    await prefs.setString('nome', nome);
    await prefs.setString('tipoUsuario', tipoUsuario);
    await prefs.setBool('logado', true);

    _usuarioId = usuarioId;
    _nome = nome;
    _tipoUsuario = tipoUsuario;
    _logado = true;

    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.clear();

    _usuarioId = null;
    _nome = null;
    _tipoUsuario = null;
    _logado = false;

    notifyListeners();
  }
}