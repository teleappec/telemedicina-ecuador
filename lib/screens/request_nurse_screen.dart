import 'package:flutter/material.dart';
import '../api_service.dart';

class RequestNurseScreen extends StatefulWidget {
  const RequestNurseScreen({super.key});

  @override
  State<RequestNurseScreen> createState() => _RequestNurseScreenState();
}

class _RequestNurseScreenState extends State<RequestNurseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _direccionController = TextEditingController();
  final _referenciaController = TextEditingController();
  final _motivoController = TextEditingController();
  bool _enviando = false;

  void _confirmarSolicitud() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _enviando = true);

      final resp = await ApiService.solicitarEnfermero(
        _direccionController.text,
        _referenciaController.text,
        _motivoController.text,
      );

      setState(() => _enviando = false);

      if (!mounted) return;

      if (resp['exito'] == true) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.local_hospital, color: Colors.teal),
                SizedBox(width: 8),
                Text('Enfermero/a en Camino'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tu solicitud ha sido asignada a personal de enfermería cercano validado por SENESCYT.',
                ),
                const SizedBox(height: 12),
                Text(
                  'Tarifa del servicio: \$15.00',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Dirección: ${_direccionController.text}',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context); // Cierra diálogo
                  Navigator.pop(context); // Regresa a pantalla anterior
                },
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al solicitar enfermero'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar Enfermería a Domicilio'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.health_and_safety, color: Colors.teal, size: 36),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Un/a profesional acudirá a tu vivienda para toma de signos vitales, triaje o administración de medicamentos.',
                        style: TextStyle(fontSize: 13, color: Colors.teal),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _direccionController,
                decoration: const InputDecoration(
                  labelText:
                      'Dirección Exacta (Barrio, Calle Principal y Secundaria)',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Ingrese la dirección' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _referenciaController,
                decoration: const InputDecoration(
                  labelText: 'Referencia de la Casa o Casa Color/N°',
                  prefixIcon: Icon(Icons.home),
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || val.isEmpty
                    ? 'Ingrese una referencia'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _motivoController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText:
                      'Motivo de la Visita (Ej: Chequeo de presión y SpO2, inyectología)',
                  prefixIcon: Icon(Icons.medical_information),
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Describa el motivo' : null,
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tarifa Fija de Visita:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        '\$15.00',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.send),
                  label: _enviando
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'SOLICITAR ENFERMERO AHORA',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                  onPressed: _enviando ? null : _confirmarSolicitud,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
