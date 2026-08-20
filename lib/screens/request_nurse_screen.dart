import 'package:flutter/material.dart';
import '../services/mock_data_service.dart';
import 'confirmation_ticket_screen.dart';

class RequestNurseScreen extends StatefulWidget {
  const RequestNurseScreen({super.key});

  @override
  State<RequestNurseScreen> createState() => _RequestNurseScreenState();
}

class _RequestNurseScreenState extends State<RequestNurseScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _servicioSeleccionado;
  final _direccionController = TextEditingController();
  final _referenciaController = TextEditingController();
  final _observacionesController = TextEditingController();
  DateTime? _fechaSeleccionada;
  TimeOfDay? _horaSeleccionada;
  String _metodoPago = 'Efectivo';

  final List<String> _servicios = [
    'Inyectología',
    'Curaciones y Mantenimiento de Heridas',
    'Control de Signos Vitales',
    'Sueroterapia y Venoclisis',
    'Cuidado Integral de Adulto Mayor',
  ];

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null) {
      setState(() => _fechaSeleccionada = picked);
    }
  }

  Future<void> _seleccionarHora(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() => _horaSeleccionada = picked);
    }
  }

  @override
  void dispose() {
    _direccionController.dispose();
    _referenciaController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enfermería a Domicilio'),
        backgroundColor: const Color(0xFF004D40),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Datos de la Atención Requerida',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF004D40),
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _servicioSeleccionado,
                decoration: InputDecoration(
                  labelText: 'Tipo de Servicio',
                  prefixIcon: const Icon(
                    Icons.medical_services_outlined,
                    color: Color(0xFF00796B),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                items: _servicios.map((servicio) {
                  return DropdownMenuItem(
                    value: servicio,
                    child: Text(servicio, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _servicioSeleccionado = val),
                validator: (val) =>
                    val == null ? 'Selecciona un tipo de servicio' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _direccionController,
                decoration: InputDecoration(
                  labelText: 'Dirección Exacta',
                  hintText: 'Calle principal y secundaria, Nº de casa',
                  prefixIcon: const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF00796B),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Ingresa la dirección de atención'
                    : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _referenciaController,
                decoration: InputDecoration(
                  labelText: 'Referencia de Ubicación',
                  hintText: 'Ej: Frente al parque, casa de 2 pisos color verde',
                  prefixIcon: const Icon(
                    Icons.explore_outlined,
                    color: Color(0xFF00796B),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Ingresa una referencia para la enfermera'
                    : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _seleccionarFecha(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Fecha',
                          prefixIcon: const Icon(
                            Icons.calendar_today_outlined,
                            color: Color(0xFF00796B),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        child: Text(
                          _fechaSeleccionada == null
                              ? 'Seleccionar'
                              : '${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year}',
                          style: TextStyle(
                            color: _fechaSeleccionada == null
                                ? Colors.grey.shade600
                                : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _seleccionarHora(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Hora',
                          prefixIcon: const Icon(
                            Icons.access_time_outlined,
                            color: Color(0xFF00796B),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        child: Text(
                          _horaSeleccionada == null
                              ? 'Seleccionar'
                              : _horaSeleccionada!.format(context),
                          style: TextStyle(
                            color: _horaSeleccionada == null
                                ? Colors.grey.shade600
                                : Colors.black87,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _metodoPago,
                decoration: InputDecoration(
                  labelText: 'Método de Pago',
                  prefixIcon: const Icon(
                    Icons.payments_outlined,
                    color: Color(0xFF00796B),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Efectivo',
                    child: Text('Efectivo (en domicilio)'),
                  ),
                  DropdownMenuItem(
                    value: 'Transferencia',
                    child: Text('Transferencia Bancaria'),
                  ),
                  DropdownMenuItem(
                    value: 'Tarjeta',
                    child: Text('Tarjeta de Débito / Crédito'),
                  ),
                ],
                onChanged: (val) => setState(() => _metodoPago = val!),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _observacionesController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Observaciones / Síntomas (Opcional)',
                  hintText: 'Ej: Indicaciones especiales o alergias conocidas',
                  prefixIcon: const Icon(
                    Icons.note_alt_outlined,
                    color: Color(0xFF00796B),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00796B),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      if (_fechaSeleccionada == null ||
                          _horaSeleccionada == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Por favor selecciona la fecha y hora de la visita',
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                        return;
                      }

                      final nuevaSolicitud = SolicitudAtencion(
                        id: 'TK-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                        tipo: 'Enfermería a Domicilio',
                        detalle: _servicioSeleccionado ?? 'Atención General',
                        profesional: 'Enf. Lic. Asignación Automática',
                        fechaHora:
                            '${_fechaSeleccionada!.day}/${_fechaSeleccionada!.month}/${_fechaSeleccionada!.year} • ${_horaSeleccionada!.format(context)}',
                        estado: 'Confirmada',
                      );

                      MockDataService.agregarSolicitud(nuevaSolicitud);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ConfirmationTicketScreen(
                            solicitud: nuevaSolicitud,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    'CONTINUAR SOLICITUD',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
