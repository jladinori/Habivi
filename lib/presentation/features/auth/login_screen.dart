import 'package:flutter/material.dart';
import 'package:habivi/data/models/cuenta.dart';
import 'package:habivi/data/repositories/account_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _repository = AccountRepository();
  bool _loading = true;
  bool _saving = false;
  Cuenta? _currentAccount;

  @override
  void initState() {
    super.initState();
    _loadAccount();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadAccount() async {
    final allAccounts = await _repository.readAll();
    if (allAccounts.isNotEmpty) {
      setState(() {
        _currentAccount = allAccounts.values.first;
        _nicknameController.text = _currentAccount?.nickname ?? '';
        _emailController.text = _currentAccount?.correo ?? '';
        _passwordController.text = _currentAccount?.contrasena ?? '';
        _phoneController.text = _currentAccount?.telefono != null && _currentAccount!.telefono != 0
            ? _currentAccount!.telefono.toString()
            : '';
      });
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _saveAccount() async {
    final nickname = _nicknameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final phone = _phoneController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingresa correo y contraseña para continuar.')),
        );
      }
      return;
    }

    setState(() {
      _saving = true;
    });

    final updatedAccount = Cuenta(
      _currentAccount?.idUsuario ?? DateTime.now().millisecondsSinceEpoch,
      nickname,
      password,
      email,
      int.tryParse(phone) ?? 0,
    );

    if (_currentAccount == null) {
      await _repository.add(updatedAccount);
    } else {
      await _repository.updateAt(0, updatedAccount);
    }

    if (mounted) {
      setState(() {
        _currentAccount = updatedAccount;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuenta guardada correctamente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar sesión'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Inicio de sesión opcional',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nicknameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Teléfono (opcional)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _saving ? null : _saveAccount,
                    child: _saving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(_currentAccount == null ? 'Guardar cuenta' : 'Actualizar cuenta'),
                  ),
                  const SizedBox(height: 12),
                  if (_currentAccount != null) ...[
                    const Divider(),
                    const SizedBox(height: 12),
                    Text('Cuenta vinculada:', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('Nombre: ${_currentAccount?.nickname ?? ''}'),
                    Text('Correo: ${_currentAccount?.correo ?? ''}'),
                    if ((_currentAccount?.telefono ?? 0) != 0)
                      Text('Teléfono: ${_currentAccount?.telefono}'),
                  ],
                ],
              ),
            ),
    );
  }
}
