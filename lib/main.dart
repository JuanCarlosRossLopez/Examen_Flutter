import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int aforo = 0;
  int capacidad = 100;
  bool capacidadBloqueada = false;
  final TextEditingController capacidadController = TextEditingController();
  final FocusNode capacidadFocus = FocusNode();
  final List<String> historial = [];
  final ScrollController historialController = ScrollController();

  void aplicarCapacidad() {
    final valor = int.tryParse(capacidadController.text);
    if (valor != null && valor > 0) {
      setState(() {
        capacidad = valor;
        if (aforo > capacidad) aforo = capacidad;
        capacidadBloqueada = true;
        historial.add('Capacidad establecida en $capacidad');
      });
      capacidadController.clear();
      capacidadFocus.unfocus();
      _scrollHistorialToEnd();
    }
  }

  void modificarAforo(int cambio) {
    int nuevoAforo = aforo + cambio;
    if (nuevoAforo < 0) nuevoAforo = 0;
    if (nuevoAforo > capacidad) nuevoAforo = capacidad;
    if (nuevoAforo != aforo) {
      setState(() {
        aforo = nuevoAforo;
        historial.add(
          (cambio > 0 ? 'Entraron +$cambio' : 'Salieron $cambio') +
          ' → Aforo: $aforo/$capacidad'
        );
      });
      _scrollHistorialToEnd();
    }
  }

  void reiniciarAforo() {
    setState(() {
      aforo = 0;
      capacidadBloqueada = false;
      historial.add('Aforo reiniciado');
    });
    _scrollHistorialToEnd();
  }

  void _scrollHistorialToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (historialController.hasClients) {
        historialController.animateTo(
          historialController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Color getColor(double p) {
    if (p < 0.6) return Colors.green;
    if (p < 0.9) return Colors.yellow;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final double porcentaje = capacidad > 0 ? aforo / capacidad : 0;
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.indigo,
            side: const BorderSide(color: Colors.indigo, width: 2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Control de Aforo – Ferry Isla Mujeres'),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Imagen ilustrativa
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    'https://cdn.pixabay.com/photo/2013/06/08/04/17/ferry-boat-123059_1280.jpg',
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 160,
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.broken_image, size: 48, color: Colors.indigo),
                          SizedBox(height: 8),
                          Text('No se pudo cargar la imagen', style: TextStyle(color: Colors.indigo)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Campo capacidad + botón aplicar
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: capacidadController,
                            focusNode: capacidadFocus,
                            keyboardType: TextInputType.number,
                            enabled: !capacidadBloqueada,
                            decoration: const InputDecoration(
                              labelText: 'Capacidad máxima',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: capacidadBloqueada ? null : aplicarCapacidad,
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('Aplicar'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: capacidadBloqueada ? null : () {
                            setState(() {
                              capacidad += 10;
                              historial.add('Capacidad aumentada a $capacidad');
                              if (aforo > capacidad) aforo = capacidad;
                            });
                          },
                          child: const Text('+10'),
                        ),
                        const SizedBox(width: 4),
                        OutlinedButton(
                          onPressed: capacidadBloqueada || capacidad <= 10 ? null : () {
                            setState(() {
                              capacidad -= 10;
                              if (capacidad < 1) capacidad = 1;
                              if (aforo > capacidad) aforo = capacidad;
                              historial.add('Capacidad reducida a $capacidad');
                            });
                          },
                          child: const Text('-10'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Panel de estado (aforo, barra, semáforo)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('Aforo: $aforo / $capacidad', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: LinearProgressIndicator(
                                value: porcentaje,
                                minHeight: 12,
                                backgroundColor: Colors.grey[300],
                                valueColor: AlwaysStoppedAnimation<Color>(getColor(porcentaje)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text('${(porcentaje * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Semáforo visual
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: porcentaje < 0.6 ? Colors.green : Colors.grey[300],
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: (porcentaje >= 0.6 && porcentaje < 0.9) ? Colors.yellow : Colors.grey[300],
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: porcentaje >= 0.9 ? Colors.red : Colors.grey[300],
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Botones de control (+/-)
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          onPressed: (aforo + 1 <= capacidad) ? () => modificarAforo(1) : null,
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('+1'),
                        ),
                        OutlinedButton.icon(
                          onPressed: (aforo + 2 <= capacidad) ? () => modificarAforo(2) : null,
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('+2'),
                        ),
                        OutlinedButton.icon(
                          onPressed: (aforo + 5 <= capacidad) ? () => modificarAforo(5) : null,
                          icon: const Icon(Icons.add_circle_outline),
                          label: const Text('+5'),
                        ),
                        OutlinedButton.icon(
                          onPressed: (aforo - 1 >= 0) ? () => modificarAforo(-1) : null,
                          icon: const Icon(Icons.remove_circle_outline),
                          label: const Text('-1'),
                        ),
                        OutlinedButton.icon(
                          onPressed: (aforo - 2 >= 0) ? () => modificarAforo(-2) : null,
                          icon: const Icon(Icons.remove_circle_outline),
                          label: const Text('-2'),
                        ),
                        OutlinedButton.icon(
                          onPressed: (aforo - 5 >= 0) ? () => modificarAforo(-5) : null,
                          icon: const Icon(Icons.remove_circle_outline),
                          label: const Text('-5'),
                        ),
                        ElevatedButton.icon(
                          onPressed: aforo > 0 ? reiniciarAforo : null,
                          icon: const Icon(Icons.restart_alt),
                          label: const Text('Reiniciar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Historial de eventos (Expanded + ListView)
                const Text('Historial de eventos:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: historial.isEmpty
                      ? Center(child: Text('Sin eventos aún', style: TextStyle(color: Colors.grey[500], fontSize: 16)))
                      : ListView.builder(
                          controller: historialController,
                          itemCount: historial.length,
                          itemBuilder: (context, index) {
                            final evento = historial[index];
                            final esEntrada = evento.startsWith('Entraron');
                            final esReinicio = evento.startsWith('Aforo reiniciado');
                            final esCapacidad = evento.startsWith('Capacidad establecida');
                            IconData icono;
                            Color color;
                            if (esEntrada) {
                              icono = Icons.login;
                              color = Colors.green;
                            } else if (esReinicio) {
                              icono = Icons.restart_alt;
                              color = Colors.redAccent;
                            } else if (esCapacidad) {
                              icono = Icons.settings;
                              color = Colors.indigo;
                            } else {
                              icono = Icons.logout;
                              color = Colors.orange;
                            }
                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: ListTile(
                                leading: Icon(icono, color: color, size: 28),
                                title: Text(evento, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}