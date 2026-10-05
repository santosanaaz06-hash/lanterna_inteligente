import 'package:flutter/material.dart';
import 'package:torch_light/torch_light.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lanterna Inteligente',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppCores.amarelo,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: AppCores.cinzaFundo,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppCores.cinzaEscuro,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const LanternaScreen(),
    );
  }
}

class AppCores {
  static const amarelo = Color(0xFFFFD700);
  static const cinzaEscuro = Color(0xFF1A1A1A);
  static const cinzaMedio = Color(0xFF2C2C2C);
  static const cinzaTexto = Color(0xFF888888);
  static const vermelho = Color(0xFFEF5350);
  static const azul = Color(0xFF42A5F5);
  static const verde = Color(0xFF66BB6A);
  static const roxo = Color(0xFFAB47BC);
  static const cinzaFundo = Color(0xFF0D0D0D);
  static const cinzaClaro = Color(0xFF3A3A3A);
}

class LanternaScreen extends StatefulWidget {
  const LanternaScreen({super.key});

  @override
  State<LanternaScreen> createState() => _LanternaScreenState();
}

class _LanternaScreenState extends State<LanternaScreen> {
  bool _ligada = false;
  bool _modoAutomatico = false;
  bool _temFlash = false;
  bool _verificandoFlash = true;

  @override
  void initState() {
    super.initState();
    _verificarDisponibilidadeFlash();
  }

  Future<void> _verificarDisponibilidadeFlash() async {
    try {
      final disponivel = await TorchLight.isTorchAvailable();
      if (mounted) {
        setState(() {
          _temFlash = disponivel;
          _verificandoFlash = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _temFlash = false;
          _verificandoFlash = false;
        });
      }
    }
  }

  Future<bool> _solicitarPermissaoCamera() async {
    try {
      final status = await Permission.camera.request();
      return status.isGranted;
    } catch (_) {
      return false;
    }
  }

  Future<void> _alternarLanterna() async {
    if (_verificandoFlash) return;

    if (!_temFlash) {
      _mostrarMensagem(
        'Este dispositivo não possui lanterna. A interface está em modo de simulação.',
      );
      setState(() => _ligada = !_ligada);
      return;
    }

    final permitido = await _solicitarPermissaoCamera();
    if (!permitido) {
      _mostrarMensagem('Permissão de câmera negada. Não é possível acender a lanterna.');
      return;
    }

    try {
      if (_ligada) {
        await TorchLight.disableTorch();
        if (mounted) setState(() => _ligada = false);
      } else {
        await TorchLight.enableTorch();
        if (mounted) setState(() => _ligada = true);
      }
    } catch (e) {
      _mostrarMensagem('Não foi possível controlar a lanterna neste dispositivo.');
    }
  }

  void _alternarModoAutomatico(bool valor) {
    setState(() => _modoAutomatico = valor);
  }

  void _mostrarMensagem(String texto) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: AppCores.cinzaMedio,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppCores.cinzaFundo,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '🔦 Lanterna',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _ligada ? AppCores.amarelo : AppCores.cinzaMedio,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: _ligada
                          ? [
                              BoxShadow(
                                color: AppCores.amarelo.withOpacity(0.5),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                    child: Text(
                      _ligada ? 'LIGADA' : 'DESLIGADA',
                      style: TextStyle(
                        color: _ligada
                            ? AppCores.cinzaEscuro
                            : AppCores.cinzaTexto,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _modoAutomatico
                    ? AppCores.roxo.withOpacity(0.25)
                    : AppCores.cinzaEscuro,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _modoAutomatico ? AppCores.roxo : AppCores.cinzaClaro,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_mode,
                    color: _modoAutomatico ? AppCores.roxo : AppCores.cinzaTexto,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Modo Automático',
                          style: TextStyle(
                            color: _modoAutomatico
                                ? AppCores.roxo
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _modoAutomatico
                              ? 'Ativo — a lanterna se ajusta sozinha'
                              : 'Inativo — controle manual ativado',
                          style: const TextStyle(
                            color: AppCores.cinzaTexto,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _modoAutomatico,
                    onChanged: _alternarModoAutomatico,
                    activeColor: AppCores.roxo,
                    activeTrackColor: AppCores.roxo.withOpacity(0.4),
                    inactiveThumbColor: AppCores.cinzaTexto,
                    inactiveTrackColor: AppCores.cinzaClaro,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  width: _ligada ? 160 : 120,
                  height: _ligada ? 160 : 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _ligada
                        ? AppCores.amarelo.withOpacity(0.9)
                        : AppCores.cinzaMedio,
                    boxShadow: _ligada
                        ? [
                            BoxShadow(
                              color: AppCores.amarelo.withOpacity(0.6),
                              blurRadius: 60,
                              spreadRadius: 20,
                            ),
                            BoxShadow(
                              color: AppCores.amarelo.withOpacity(0.3),
                              blurRadius: 120,
                              spreadRadius: 40,
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Icon(
                      _ligada
                          ? Icons.flashlight_on
                          : Icons.flashlight_off,
                      key: ValueKey(_ligada),
                      size: _ligada ? 80 : 60,
                      color: _ligada
                          ? AppCores.cinzaEscuro
                          : AppCores.cinzaTexto,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: GestureDetector(
                onTap: _alternarLanterna,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _ligada ? AppCores.amarelo : AppCores.cinzaMedio,
                    boxShadow: _ligada
                        ? [
                            BoxShadow(
                              color: AppCores.amarelo.withOpacity(0.7),
                              blurRadius: 25,
                              spreadRadius: 5,
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.4),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                  ),
                  child: AnimatedRotation(
                    duration: const Duration(milliseconds: 300),
                    turns: _ligada ? 0.5 : 0,
                    child: Icon(
                      Icons.power_settings_new,
                      size: 40,
                      color: _ligada
                          ? AppCores.cinzaEscuro
                          : AppCores.cinzaTexto,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}