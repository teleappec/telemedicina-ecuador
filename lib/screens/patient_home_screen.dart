import 'package:flutter/material.dart';
import '../api_service.dart';
import 'teleconsultation_screen.dart';
import 'request_nurse_screen.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  List<dynamic> _especialidades = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarEspecialidades();
  }

  Future<void> _cargarEspecialidades() async {
    final lista = await ApiService.obtenerEspecialidades();
    setState(() {
      _especialidades = lista;
      _cargando = false;
    });
  }

  void _procesarPagoYReserva(String especialidad, double precio) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final resultado = await ApiService.reservarCita(especialidad, precio);

    if (!mounted) return;
    Navigator.pop(context);

    if (resultado['exito'] == true) {
      final desglose = resultado['desglose'];
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('¡Cita Confirmada!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Especialidad: $especialidad',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Total Pagado: \$${desglose['totalCobrado'].toStringAsFixed(2)}',
              ),
              const Divider(),
              Text(
                'Comisión App: \$${desglose['comisionPlataforma'].toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Pago Neto al Médico: \$${desglose['gananciaMedico'].toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.chat),
              label: const Text('IR A TELECONSULTA'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TeleconsultationScreen(especialidad: especialidad),
                  ),
                );
              },
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al procesar la reserva'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atención Médica - Paciente'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // BANNER PARA SOLICITAR ENFERMERÍA A DOMICILIO
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RequestNurseScreen(),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.directions_car,
                            color: Colors.white,
                            size: 32,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '¿Necesitas chequeo a domicilio?',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Solicita un/a enfermero/a en tu ubicación por \$15.00',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Text(
                    'Selecciona una Especialidad Médica',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Reserva tu teleconsulta o atención con profesionales verificados SENESCYT.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _especialidades.length,
                      itemBuilder: (context, index) {
                        final esp = _especialidades[index];
                        final String nombre = esp['nombre'];
                        final double precio = (esp['precio_sugerido'] as num)
                            .toDouble();
                        final double comision =
                            (esp['comision_porcentaje'] as num).toDouble();

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Colors.teal,
                              child: Icon(
                                Icons.medical_services,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(
                              nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Consulta Virtual\nTarifa: \$${precio.toStringAsFixed(2)} (Comisión app: $comision%)',
                            ),
                            isThreeLine: true,
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () =>
                                  _procesarPagoYReserva(nombre, precio),
                              child: const Text('RESERVAR'),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
