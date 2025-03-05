import 'dart:async'; // Importar el paquete para usar Timer
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cortes de Producción L1',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        textTheme: TextTheme(
          titleLarge: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(
              153,
              255,
              250,
              250,
            ), // Blanco para que se vea bien sobre el fondo negro
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const MyHomePage(),
        '/corteLavadora': (context) => const CorteLavadoraScreen(),
        '/screen1': (context) => const Screen1(),
        '/screen2': (context) => const Screen2(),
      },
    );
  }
}

class CorteLavadoraScreen extends StatefulWidget {
  const CorteLavadoraScreen({super.key});

  @override
  CorteLavadoraScreenState createState() => CorteLavadoraScreenState();
}

class CorteLavadoraScreenState extends State<CorteLavadoraScreen> {
  final TextEditingController canastosController = TextEditingController();
  final TextEditingController rechazoController = TextEditingController();
  final TextEditingController bufferController = TextEditingController();
  final TextEditingController velocidadController = TextEditingController();

  String? formatoSeleccionado = '600'; // Formato por defecto
  double volumenLavadora = 0.0;
  double golpesParaCorte = 0.0;
  double tiempoParaCorte = 0.0;

  int seconds = 0; // Variable para los segundos del temporizador
  late Timer _timer; // Temporizador
  bool isTimerRunning = false;

  void startTimer() {
    if (!isTimerRunning) {
      isTimerRunning = true;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          seconds++;
        });
      });
    }
  }

  void stopTimer() {
    if (isTimerRunning) {
      _timer.cancel();
      isTimerRunning = false;
    }
  }

  void resetTimer() {
    setState(() {
      seconds = 0;
    });
  }

  void calcularValores() {
    double canastos = double.tryParse(canastosController.text) ?? 0.0;
    double rechazo = double.tryParse(rechazoController.text) ?? 0.0;
    double buffer = double.tryParse(bufferController.text) ?? 0.0;
    double velocidad =
        double.tryParse(velocidadController.text) ??
        0.0; // Obtener la velocidad

    if (formatoSeleccionado == '600') {
      volumenLavadora = (canastos * 434 * 600) / 100000;
      double volBeer = buffer + 35;
      double volEnvase = 27.2 - rechazo * 0.01 * 18;
      double volFaltante = volBeer - volEnvase;
      golpesParaCorte = (volumenLavadora - volFaltante) / 0.258;
    } else if (formatoSeleccionado == '550') {
      volumenLavadora = (canastos * 434 * 550) / 100000;
      double volBeer = buffer + 35;
      double volEnvase = 24.94 - rechazo * 0.01 * 17;
      double volFaltante = volBeer - volEnvase;
      golpesParaCorte = (volumenLavadora - volFaltante) / 0.2365;
    }

    // Calcular tiempo para corte, si la velocidad no es cero
    if (velocidad > 0) {
      tiempoParaCorte = golpesParaCorte / velocidad;
    } else {
      tiempoParaCorte = 0.0; // Si la velocidad es cero, no se puede calcular
    }
    // Redondear los resultados a 2 decimales
    volumenLavadora = double.parse(volumenLavadora.toStringAsFixed(2));
    golpesParaCorte = double.parse(golpesParaCorte.toStringAsFixed(2));
    tiempoParaCorte = double.parse(tiempoParaCorte.toStringAsFixed(2));

    setState(() {});
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD1C4E9), // Fondo color lavanda
      appBar: AppBar(
        title: const Text('Corte en Lavadora'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButton<String>(
                value: formatoSeleccionado,
                onChanged: (String? newValue) {
                  setState(() {
                    formatoSeleccionado = newValue;
                  });
                },
                items:
                    <String>['600', '550'].map<DropdownMenuItem<String>>((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: canastosController,
                decoration: const InputDecoration(labelText: '#Canastos'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: rechazoController,
                decoration: const InputDecoration(labelText: '% Rechazo IBV'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: bufferController,
                decoration: const InputDecoration(labelText: 'Volumen Buffer'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: velocidadController,
                decoration: const InputDecoration(
                  labelText: 'Velocidad [golpes/min] ',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: calcularValores,
                child: const Text('Calcular'),
              ),
              const SizedBox(height: 20),
              Text('Volumen Lavadora: $volumenLavadora'),
              Text('Golpes para Corte: $golpesParaCorte'),
              Text(
                'Tiempo para Corte [min]: $tiempoParaCorte',
              ), // Mostrar el tiempo calculado
              const SizedBox(height: 20),

              // Timer display
              Text(
                'Tiempo: ${Duration(seconds: seconds).toString().split('.').first}',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              // Start, stop, reset buttons for timer
              Row(
                children: [
                  ElevatedButton(
                    onPressed: startTimer,
                    child: const Text('Iniciar Timer'),
                  ),
                  const SizedBox(width: 1),
                  ElevatedButton(
                    onPressed: stopTimer,
                    child: const Text('Detener Timer'),
                  ),
                  const SizedBox(width: 1),
                  ElevatedButton(
                    onPressed: resetTimer,
                    child: const Text('Resetear Timer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Fondo negro en la pantalla principal
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Hacemos la AppBar transparente
        elevation: 0, // Quitamos la sombra
        title: Center(
          child: Text(
            'Cortes de Producción L1',
            style: Theme.of(context).textTheme.titleLarge, // Usar titleLarge
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(
            alpha: 255,
          ), // Reemplazado con withValues
          image: DecorationImage(
            image: AssetImage(
              'assets/images/linea1.jpeg',
            ), // Cambiar a la imagen de fondo
            fit: BoxFit.cover, // La imagen cubre toda la pantalla
            colorFilter: ColorFilter.mode(
              const Color.fromARGB(
                255,
                0,
                0,
                0,
              ).withValues(alpha: 178), // Reemplazado con withValues
              BlendMode.darken, // Mezcla el color negro con la imagen
            ),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Alineación vertical centrada
            crossAxisAlignment:
                CrossAxisAlignment.center, // Alineación horizontal centrada
            children: <Widget>[
              _buildIconWithText(
                context,
                CupertinoIcons.hand_draw,
                'Corte en Lavadora',
                '/corteLavadora',
              ),
              const SizedBox(height: 30),
              _buildIconWithText(
                context,
                CupertinoIcons.chevron_down_square,
                'Corte con BBT',
                '/screen1',
              ),
              const SizedBox(height: 30),
              _buildIconWithText(
                context,
                CupertinoIcons.dial_fill,
                'CIPs (Mismo Formato)',
                '/screen2',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconWithText(
    BuildContext context,
    IconData icon,
    String label,
    String route,
  ) {
    return Column(
      mainAxisAlignment:
          MainAxisAlignment
              .center, // Alineación centrada para los iconos y nombres
      children: <Widget>[
        IconButton(
          onPressed: () {
            Navigator.pushNamed(context, route);
          },
          icon: Icon(icon, size: 80.0), // Hacemos los iconos más grandes
          color: Colors.white,
        ),
        const SizedBox(width: 15),
        Container(
          color: const Color(0xFF000000).withValues(
            red: 0,
            green: 0,
            blue: 0,
            alpha: 178, // 70% opacidad en lugar de 0.7
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(label, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

// Pantalla 1 (Corte con BBT)
class Screen1 extends StatefulWidget {
  const Screen1({super.key});

  @override
  Screen1State createState() => Screen1State();
}

class Screen1State extends State<Screen1> {
  final TextEditingController canastoController = TextEditingController();
  final TextEditingController rechazoController = TextEditingController();
  final TextEditingController bufferController = TextEditingController();

  String? formatoSeleccionado = '600'; // Formato por defecto
  double transito = 0.0;
  double corteBBT = 0.0;
  double envaseReal = 0.0;
  double envaseNecesario = 0.0;

  void calcularValores() {
    double canastos = double.tryParse(canastoController.text) ?? 0.0;
    double rechazo = double.tryParse(rechazoController.text) ?? 0.0;
    double buffer = double.tryParse(bufferController.text) ?? 0.0;

    double volumenLavadora = 0.0;
    double capacidad = 0.0;
    double transitoResultado = 0.0;
    double envaseDL = 0.0;

    if (formatoSeleccionado == '600') {
      volumenLavadora = (canastos * 434 * 600) / 100000; //Hl
      capacidad = 30.2; //Hl
      transitoResultado =
          0.7 * capacidad + 6 - 0.7 * capacidad * rechazo * 0.01; //Hl
      envaseDL = 12 * 84 / 13.89; //Hl
      envaseReal =
          (envaseDL + volumenLavadora + transitoResultado) -
          rechazo * 0.01 * (envaseDL + volumenLavadora);
      corteBBT = envaseReal - 35 - buffer + 15;
    } else if (formatoSeleccionado == '550') {
      volumenLavadora = (canastos * 434 * 550) / 100000;
      capacidad = 28; //Hl
      transitoResultado =
          0.7 * capacidad + 5.5 - capacidad * 0.7 * rechazo * 0.01; //Hl
      envaseDL = 11.5 * 84 / 15.15; //Hl
      envaseReal =
          (envaseDL + volumenLavadora + transitoResultado) -
          rechazo * 0.01 * (envaseDL + volumenLavadora);
      corteBBT = envaseReal - 35 - buffer + 15;
    }

    // Redondear los resultados a 2 decimales
    transito = double.parse(transitoResultado.toStringAsFixed(2));
    corteBBT = double.parse(corteBBT.toStringAsFixed(2));
    volumenLavadora = double.parse(volumenLavadora.toStringAsFixed(2));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD1C4E9), // Fondo color lavanda
      appBar: AppBar(
        title: const Text('Corte con BBT'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: formatoSeleccionado,
              onChanged: (String? newValue) {
                setState(() {
                  formatoSeleccionado = newValue;
                });
              },
              items:
                  <String>['600', '550'].map<DropdownMenuItem<String>>((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: canastoController,
              decoration: const InputDecoration(labelText: '# Canastos'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: rechazoController,
              decoration: const InputDecoration(labelText: '% Rechazo IBV'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: bufferController,
              decoration: const InputDecoration(labelText: 'Buffer'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: calcularValores,
              child: const Text('Calcular'),
            ),
            const SizedBox(height: 20),
            Text('Transito Lav-Llen [Hl]: $transito'),
            Text('Corte BBT [Hl]: $corteBBT'),
          ],
        ),
      ),
    );
  }
}

// PANTALLA 2 CIPs (Mismo Formato0)
class Screen2 extends StatefulWidget {
  const Screen2({super.key});

  @override
  Screen2State createState() => Screen2State();
}

class Screen2State extends State<Screen2> {
  final TextEditingController canastoController = TextEditingController();
  final TextEditingController rechazoController = TextEditingController();
  final TextEditingController bufferController = TextEditingController();

  String? formatoSeleccionado = '600'; // Formato por defecto

  double volHilera = 0.0;
  double transito = 0.0;
  double volPorLlenar = 0.0;
  double golpesAdicionales = 0.0;

  void calcularValores() {
    double canastos = double.tryParse(canastoController.text) ?? 0.0;
    double rechazo = double.tryParse(rechazoController.text) ?? 0.0;
    double buffer = double.tryParse(bufferController.text) ?? 0.0;

    double capacidad = 0.0;
    double volHileraTemp = 0.0;
    double transitoResultado = 0.0;
    double envaseTransito = 0.0;
    double volFaltante = 0.0;

    if (formatoSeleccionado == '600') {
      // Cálculos para formato 600
      volHileraTemp = (canastos * 600) / 100000;
      capacidad = 30.2;
      transitoResultado = 0.7 * capacidad;
      volPorLlenar = 22 + 10 + buffer + 3;
      envaseTransito =
          transitoResultado + 6 - transitoResultado * rechazo * 0.01;
      volFaltante = volPorLlenar - envaseTransito;
      golpesAdicionales = volFaltante / volHileraTemp;
    } else if (formatoSeleccionado == '550') {
      // Cálculos para formato 550
      volHileraTemp = (canastos * 550) / 100000;
      capacidad = 27.7;
      transitoResultado = 0.7 * capacidad;
      volPorLlenar = 22 + 10 + buffer + 3;
      envaseTransito =
          transitoResultado + 5.5 - transitoResultado * rechazo * 0.01;
      volFaltante = volPorLlenar - envaseTransito;
      golpesAdicionales = volFaltante / volHileraTemp;
    }

    setState(() {
      volHilera = volHileraTemp;
      transito = envaseTransito;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD1C4E9), // Fondo color lavanda
      appBar: AppBar(
        title: const Text('CIPs (Mismo Formato)'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: formatoSeleccionado,
              onChanged: (String? newValue) {
                setState(() {
                  formatoSeleccionado = newValue;
                });
              },
              items:
                  <String>['600', '550'].map<DropdownMenuItem<String>>((
                    String value,
                  ) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: canastoController,
              decoration: const InputDecoration(labelText: '# Canastos'),
              keyboardType: TextInputType.number,
            ),

            TextField(
              controller: rechazoController,
              decoration: const InputDecoration(labelText: '% Rechazo IBV'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: bufferController,
              decoration: const InputDecoration(labelText: 'Buffer'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: calcularValores,
              child: const Text('Calcular'),
            ),
            const SizedBox(height: 20),
            Text('Transito: ${transito.toStringAsFixed(2)}'),
            Text('Vol. Por Llenar: ${volPorLlenar.toStringAsFixed(2)}'),
            Text('Golpes Adicionales: ${golpesAdicionales.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }
}
