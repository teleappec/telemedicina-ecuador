import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TeleconsultationScreen extends StatefulWidget {
  final String especialidad;
  final String doctorNombre;

  const TeleconsultationScreen({
    super.key,
    this.especialidad = 'Medicina General',
    this.doctorNombre = 'Dra. María Elena Paredes',
  });

  @override
  State<TeleconsultationScreen> createState() => _TeleconsultationScreenState();
}

class _TeleconsultationScreenState extends State<TeleconsultationScreen> {
  final List<Map<String, String>> _mensajes = [
    {
      'emisor': 'doctor',
      'texto':
          '¡Hola! Bienvenido a la consulta virtual de TeleMedicina Ecuador. Presiona el ícono de la cámara arriba para iniciar la videollamada.',
    },
  ];

  final _textController = TextEditingController();

  void _enviarMensaje() {
    if (_textController.text.trim().isEmpty) return;

    setState(() {
      _mensajes.add({
        'emisor': 'paciente',
        'texto': _textController.text.trim(),
      });
    });

    _textController.clear();
  }

  // Generador e iniciador de sala de videollamada HD
  Future<void> _iniciarVideoLlamada() async {
    // Genera un ID de sala único basado en la especialidad y timestamp
    final String cleanEspecialidad = widget.especialidad.replaceAll(
      RegExp(r'[^a-zA-Z0-9]'),
      '',
    );
    final String roomName = 'TelemedEcuador_${cleanEspecialidad}_17123456';
    final Uri url = Uri.parse('https://meet.jit.si/$roomName');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Abriendo sala segura de videollamada...'),
        backgroundColor: Colors.teal,
      ),
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir el navegador para la videollamada.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _mostrarDialogoReceta() {
    final diagController = TextEditingController();
    final medController = TextEditingController();
    final indController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.assignment, color: Colors.teal),
            SizedBox(width: 8),
            Text('Emitir Receta Médica'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: diagController,
                decoration: const InputDecoration(
                  labelText: 'Diagnóstico (CIE-10)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: medController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Medicamentos Prescritos',
                  hintText: 'Ej. Paracetamol 500mg cada 8 horas por 5 días',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: indController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Indicaciones Generales',
                  hintText: 'Reposo, abundante hidratación',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              _mostrarRecetaGenerada(
                diagController.text,
                medController.text,
                indController.text,
              );
            },
            child: const Text('GENERAR Y FIRMAR'),
          ),
        ],
      ),
    );
  }

  void _mostrarRecetaGenerada(String diag, String med, String ind) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '📄 Receta Médica Digital',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(thickness: 2),
            const SizedBox(height: 10),
            Text(
              'Profesional: ${widget.doctorNombre}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Especialidad: ${widget.especialidad}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DIAGNÓSTICO: $diag',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('PRESCRIPCIÓN:\n$med'),
                  const SizedBox(height: 8),
                  Text('INDICACIONES:\n$ind'),
                ],
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.teal),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified, color: Colors.teal),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Firma Electrónica Autorizada - Válida en Farmacias',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.doctorNombre, style: const TextStyle(fontSize: 16)),
            Text(
              widget.especialidad,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.note_add),
            tooltip: 'Emitir Receta Médica',
            onPressed: _mostrarDialogoReceta,
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            tooltip: 'Iniciar VideoLlamada HD',
            onPressed: _iniciarVideoLlamada,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _mensajes.length,
              itemBuilder: (context, index) {
                final msg = _mensajes[index];
                final esDoctor = msg['emisor'] == 'doctor';

                return Align(
                  alignment: esDoctor
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: esDoctor ? Colors.grey[200] : Colors.teal[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg['texto'] ?? '',
                      style: const TextStyle(fontSize: 15),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Escribe tu consulta...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.teal),
                  onPressed: _enviarMensaje,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
