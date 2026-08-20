import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class BrigadesScreen extends StatefulWidget {
  const BrigadesScreen({super.key});

  @override
  State<BrigadesScreen> createState() => _BrigadesScreenState();
}

class _BrigadesScreenState extends State<BrigadesScreen> {
  List<dynamic> _brigadas = [];
  bool _cargando = true;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _lugarController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _latController = TextEditingController(
    text: '-0.1807',
  );
  final TextEditingController _longController = TextEditingController(
    text: '-78.4678',
  );
  final TextEditingController _obsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarBrigadas();
  }

  Future<void> _cargarBrigadas() async {
    setState(() => _cargando = true);
    final lista = await ApiService.obtenerBrigadas();
    if (!mounted) return;
    setState(() {
      _brigadas = lista;
      _cargando = false;
    });
  }

  Future<void> _mostrarModalNuevaBrigada() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Programar Brigada Médica de Campo',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre de la Brigada / Campaña',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.medical_services_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Campo obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _lugarController,
                    decoration: const InputDecoration(
                      labelText: 'Ubicación / Parroquia / Sector',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.place),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Campo obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _fechaController,
                    decoration: const InputDecoration(
                      labelText: 'Fecha Programada (AAAA-MM-DD)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_month),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Campo obligatorio';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _latController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Latitud GPS',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _longController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Longitud GPS',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _obsController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Detalles y Personal Asignado',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        if (!_formKey.currentState!.validate()) return;
                        Navigator.pop(context);

                        final res = await ApiService.registrarBrigada({
                          'nombre_brigada': _nombreController.text.trim(),
                          'lugar': _lugarController.text.trim(),
                          'fecha': _fechaController.text.trim(),
                          'latitud':
                              double.tryParse(_latController.text.trim()) ??
                              -0.1807,
                          'longitud':
                              double.tryParse(_longController.text.trim()) ??
                              -78.4678,
                          'observaciones': _obsController.text.trim(),
                        });

                        if (res['exito'] == true) {
                          NotificationService.mostrarNotificacion(
                            titulo: 'Brigada Registrada 📍',
                            mensaje:
                                'Ubicación y fecha guardadas en el servidor.',
                            icono: Icons.map,
                            colorFondo: Colors.indigo,
                          );
                          _nombreController.clear();
                          _lugarController.clear();
                          _fechaController.clear();
                          _obsController.clear();
                          _cargarBrigadas();
                        }
                      },
                      child: const Text('GUARDAR BRIGADA'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brigadas Médicas Territorial'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarBrigadas,
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _brigadas.isEmpty
          ? const Center(child: Text('No hay brigadas médicas programadas.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _brigadas.length,
              itemBuilder: (context, index) {
                final item = _brigadas[index];
                return Card(
                  elevation: 3,
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.indigo,
                      child: Icon(Icons.location_on, color: Colors.white),
                    ),
                    title: Text(
                      item['nombre_brigada'] ?? 'Brigada Médica',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Lugar: ${item['lugar']}\nFecha: ${item['fecha']}\nCoordenadas GPS: [${item['latitud']}, ${item['longitud']}]\nNotas: ${item['observaciones'] ?? "N/A"}',
                    ),
                    isThreeLine: true,
                    trailing: Chip(
                      label: Text(item['estado'] ?? 'Activa'),
                      backgroundColor: Colors.indigo.shade50,
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarModalNuevaBrigada,
        backgroundColor: Colors.indigo,
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Nueva Brigada'),
      ),
    );
  }
}
