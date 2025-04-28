import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'home_page.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _storage = const FlutterSecureStorage();
  final _pinController = TextEditingController();
  String? _error;
  bool _isCreatingPin = false;

  @override
  void initState() {
    super.initState();
    _checkPinExists();
  }

  Future<void> _checkPinExists() async {
    String? pin = await _storage.read(key: 'user_pin');
    setState(() {
      _isCreatingPin = pin == null;
    });
  }

  Future<void> _handleAuth() async {
    String enteredPin = _pinController.text;
    if (_isCreatingPin) {
      if (enteredPin.length < 4) {
        setState(() => _error = 'PIN muss mindestens 4 Ziffern haben');
        return;
      }
      await _storage.write(key: 'user_pin', value: enteredPin);
      _navigateToHome();
    } else {
      String? savedPin = await _storage.read(key: 'user_pin');
      if (enteredPin == savedPin) {
        _navigateToHome();
      } else {
        setState(() => _error = 'Falsche PIN');
      }
    }
  }

  void _navigateToHome() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isCreatingPin ? 'PIN erstellen' : 'PIN eingeben',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'PIN',
                  errorText: _error,
                  border: const OutlineInputBorder(),
                ),
                onSubmitted: (_) => _handleAuth(),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _handleAuth,
                child: Text(_isCreatingPin ? 'Erstellen' : 'Entsperren'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
