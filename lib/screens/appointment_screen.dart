// lib/screens/appointment_screen.dart
import 'package:flutter/material.dart';
import 'payment_screen.dart';

class AppointmentScreen extends StatefulWidget {
  final String? tipoServicio; // 'Teleconsulta' o 'Visita Domiciliaria'

  const AppointmentScreen({super.key, this.tipoServicio = 'Teleconsulta'});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  String _especialidadSeleccionada = 'Medicina General';
  String _doctorSeleccionado = 'Dr. Carlos Mendoza';
  DateTime _fechaSeleccionada = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _horaSeleccionada = const TimeOfDay(hour: 10, minute: 0);

  final List<String> _especialidades = [
    'Medicina General',
    'Pediatría',
    'Cardiología',
    'Ginecología',
    'Dermatología',
  ];

  final Map<String, List<String>> _doctoresPorEspecialidad = {
    'Medicina General': ['Dr. Carlos Mendoza', 'Dra. Andrea Silva'],
    'Pediatría': ['Dr. Roberto Gómez', 'Dra. Elena Ramos'],
    'Cardiología': ['Dr. Fernando Torres'],
    'Ginecología': ['Dra. Patricia Ortiz'],
    'Dermatología': ['Dr. Gabriel Castro'],
  };

  double get _precioServicio {
    return widget.tipoServicio == 'Visita Domiciliaria' ? 40.0 : 25.0;
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null && picked != _fechaSeleccionada) {
      setState(() {
        _fechaSeleccionada = picked;
      });
    }
  }

  Future<void> _seleccionarHora(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _horaSeleccionada,
    );
    if (picked != null && picked != _horaSeleccionada) {
      setState(() {
        _horaSeleccionada = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctoresDisponibles =
        _doctoresPorEspecialidad[_especialidadSeleccionada] ??
        ['Dr. Carlos Mendoza'];

    if (!doctoresDisponibles.contains(_doctorSeleccionado)) {
      _doctorSeleccionado = doctoresDisponibles.first;
    }

    final fechaFormateada =
        '${_fechaSeleccionada.day.toString().padLeft(2, '0')}/${_fechaSeleccionada.month.toString().padLeft(2, '0')}/${_fechaSeleccionada.year}';
    final horaFormateada = _horaSeleccionada.format(context);

    return Scaffold(
      appBar: AppBar(title: Text('Agendar ${widget.tipoServicio}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selección de Especialidad
            const Text(
              '1. Seleccione Especialidad',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _especialidadSeleccionada,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.medical_services),
              ),
              items: _especialidades.map((esp) {
                return DropdownMenuItem(value: esp, child: Text(esp));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _especialidadSeleccionada = val;
                  });
                }
              },
            ),
            const SizedBox(height: 20),

            // Selección de Médico
            const Text(
              '2. Seleccione Médico',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _doctorSeleccionado,
              decoration: const InputDecoration(prefixIcon: Icon(Icons.person)),
              items: doctoresDisponibles.map((doc) {
                return DropdownMenuItem(value: doc, child: Text(doc));
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _doctorSeleccionado = val;
                  });
                }
              },
            ),
            const SizedBox(height: 20),

            // Selección de Fecha y Hora
            const Text(
              '3. Fecha y Hora de Atención',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text(fechaFormateada),
                    onPressed: () => _seleccionarFecha(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.access_time),
                    label: Text(horaFormateada),
                    onPressed: () => _seleccionarHora(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Tarjeta con el Resumen del Pago
            Card(
              color: Colors.teal.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.teal),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Servicio:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(widget.tipoServicio ?? 'Teleconsulta'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Médico:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(_doctorSeleccionado),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total a Pagar:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${_precioServicio.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Botón hacia pasarela de pago
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.payment),
                label: const Text('CONTINUAR AL PAGO'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(
                        doctorNombre: _doctorSeleccionado,
                        especialidad: _especialidadSeleccionada,
                        servicioNombre: widget.tipoServicio ?? 'Teleconsulta',
                        monto: _precioServicio,
                        fecha: fechaFormateada,
                        hora: horaFormateada,
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
