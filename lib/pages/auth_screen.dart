import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'home_page.dart';

/// Authentication screen for the Todo app.
///
/// Handles PIN creation and authentication using secure storage.
class AuthScreen extends StatefulWidget {
  /// Creates an [AuthScreen] widget.
  ///
  /// @param key Optional widget key.
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

/// State for [AuthScreen].
///
/// Manages PIN creation, validation, and navigation to the home page.
class _AuthScreenState extends State<AuthScreen> {
  /// @attribute _storage Secure storage instance for storing and retrieving the PIN.
  final _storage = const FlutterSecureStorage();

  /// @attribute _pinController Controller for the PIN input field.
  final _pinController = TextEditingController();

  /// @attribute _error Error message to display if authentication fails.
  String? _error;

  /// @attribute _isCreatingPin Indicates if the user is creating a new PIN.
  bool _isCreatingPin = false;

  /// Initializes the state and checks if a PIN already exists in storage.
  @override
  void initState() {
    super.initState();
    _checkPinExists();
  }

  /// Checks if a PIN exists in secure storage.
  ///
  /// Sets [_isCreatingPin] to true if no PIN is found.
  Future<void> _checkPinExists() async {
    String? pin = await _storage.read(key: 'user_pin');
    setState(() {
      _isCreatingPin = pin == null;
    });
  }

  /// Handles authentication logic for PIN creation and validation.
  ///
  /// If creating a PIN, ensures it meets minimum length requirements.
  /// If validating, compares entered PIN with stored PIN.
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

  /// Navigates to the [HomePage] after successful authentication.
  void _navigateToHome() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
  }

  /// Builds the authentication UI, including PIN input and error display.
  ///
  /// @param context The build context.
  /// @return Widget
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
