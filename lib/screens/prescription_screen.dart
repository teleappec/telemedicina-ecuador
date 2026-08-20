// lib/screens/prescription_screen.dart
import 'package:flutter/material.dart';
import '../services/pdf_service.dart';

class PrescriptionScreen extends StatefulWidget {
  final String pacienteNombre;

  const PrescriptionScreen({super.key, this.pacienteNombre = 'Paciente'});

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  final TextEditingController _diagnosticoController = TextEditingController();
  final TextEditingController _medicamentoController = TextEditingController();
  final TextEditingController _dosisController = TextEditingController();
  final TextEditingController _duracionController = TextEditingController();
  final TextEditingController _indicacionesController = TextEditingController();

  final List<Map<String, String>> _medicamentos = [];

  void _agregarMedicamento() {
    if (_medicamentoController.text.trim().isNotEmpty &&
        _dosisController.text.trim().isNotEmpty) {
      setState(() {
        _medicamentos.add({
          'nombre': _medicamentoController.text.trim(),
          'dosis': _dosisController.text.trim(),
          'duracion': _duracionController.text.trim().isEmpty
              ? 'Según indicación'
              : _duracionController.text.trim(),
        });
        _medicamentoController.clear();
        _dosisController.clear();
        _duracionController.clear();
      });
    }
  }

  void _generarPdf() {
    PdfService.descargarRecetaPdf(
      pacienteNombre: widget.pacienteNombre,
      diagnostico: _diagnosticoController.text.isEmpty
          ? 'Consulta Médica General'
          : _diagnosticoController.text,
      medicamentos: _medicamentos,
      indicacionesAdicionales: _indicacionesController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Receta: ${widget.pacienteNombre}'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Prescripción para ${widget.pacienteNombre}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade900,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _diagnosticoController,
                decoration: const InputDecoration(
                  labelText: 'Diagnóstico Presuntivo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medical_information),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Añadir Medicamento',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _medicamentoController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Medicamento',
                  border: OutlineInputBorder(),
                  hintText: 'Ej. Paracetamol 500mg',
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dosisController,
                      decoration: const InputDecoration(
                        labelText: 'Dosis / Frecuencia',
                        border: OutlineInputBorder(),
                        hintText: '1 cada 8 horas',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _duracionController,
                      decoration: const InputDecoration(
                        labelText: 'Duración',
                        border: OutlineInputBorder(),
                        hintText: '5 días',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _agregarMedicamento,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar a la lista'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_medicamentos.isNotEmpty) ...[
                const Text(
                  'Medicamentos Añadidos:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _medicamentos.length,
                  itemBuilder: (context, index) {
                    final med = _medicamentos[index];
                    return Card(
                      child: ListTile(
                        title: Text(med['nombre'] ?? ''),
                        subtitle: Text(
                          'Dosis: ${med['dosis']} | Duración: ${med['duracion']}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _medicamentos.removeAt(index);
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _indicacionesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Indicaciones Adicionales',
                  border: OutlineInputBorder(),
                  hintText: 'Reposo, tomar abundante agua, etc.',
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
                  onPressed: _generarPdf,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text(
                    'DESCARGAR / IMPRIMIR RECETA',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
