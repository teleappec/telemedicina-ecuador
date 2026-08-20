// lib/screens/doctor_profile_screen.dart
import 'package:flutter/material.dart';
import 'prescription_screen.dart';

class DoctorProfileScreen extends StatefulWidget {
  final String nombreMedico;

  const DoctorProfileScreen({
    super.key,
    this.nombreMedico = 'Dr. Carlos Mendoza',
  });

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  String _telefono = '0991234567';
  String _correo = 'carlos.mendoza@telemedicina.ec';
  String _direccion = 'Av. República y Eloy Alfaro, Quito';
  String _banco = 'Banco Pichincha';
  String _tipoCuenta = 'Ahorros';
  String _numeroCuenta = '2200123456';

  final List<Map<String, String>> _citas = [
    {
      'id': '1',
      'paciente': 'María López',
      'hora': '09:00 AM',
      'tipo': 'Teleconsulta',
      'estado': 'Pendiente',
    },
    {
      'id': '2',
      'paciente': 'Juan Pérez',
      'hora': '10:30 AM',
      'tipo': 'Visita Domiciliaria',
      'estado': 'En Camino',
    },
    {
      'id': '3',
      'paciente': 'Ana Torres',
      'hora': '11:45 AM',
      'tipo': 'Teleconsulta',
      'estado': 'En Consulta',
    },
  ];

  void _mostrarModalEditarDatos() {
    final telController = TextEditingController(text: _telefono);
    final correoController = TextEditingController(text: _correo);
    final dirController = TextEditingController(text: _direccion);
    final bancoController = TextEditingController(text: _banco);
    final numCuentaController = TextEditingController(text: _numeroCuenta);
    String tipoCuentaSel = _tipoCuenta;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Actualizar Datos Profesionales',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 10),
                    const Text(
                      'Datos de Contacto',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: telController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Teléfono de Contacto',
                        prefixIcon: Icon(Icons.phone),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: correoController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Correo Electrónico',
                        prefixIcon: Icon(Icons.email),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: dirController,
                      decoration: const InputDecoration(
                        labelText: 'Dirección de Atenciones / Consultorio',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Datos Bancarios para Pagos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.teal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: bancoController,
                      decoration: const InputDecoration(
                        labelText: 'Banco / Institución Financiera',
                        prefixIcon: Icon(Icons.account_balance),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: tipoCuentaSel,
                      decoration: const InputDecoration(
                        labelText: 'Tipo de Cuenta',
                        prefixIcon: Icon(Icons.credit_card),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Ahorros',
                          child: Text('Ahorros'),
                        ),
                        DropdownMenuItem(
                          value: 'Corriente',
                          child: Text('Corriente'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => tipoCuentaSel = val);
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: numCuentaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Número de Cuenta',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.save),
                        label: const Text('Guardar Cambios'),
                        onPressed: () {
                          setState(() {
                            _telefono = telController.text;
                            _correo = correoController.text;
                            _direccion = dirController.text;
                            _banco = bancoController.text;
                            _tipoCuenta = tipoCuentaSel;
                            _numeroCuenta = numCuentaController.text;
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Datos actualizados correctamente'),
                              backgroundColor: Colors.teal,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _cambiarEstadoCita(int index, String nuevoEstado) {
    setState(() {
      _citas[index]['estado'] = nuevoEstado;
    });
  }

  Color _colorEstado(String estado) {
    switch (estado) {
      case 'Pendiente':
        return Colors.orange;
      case 'En Camino':
        return Colors.blue;
      case 'En Consulta':
        return Colors.purple;
      case 'Completada':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel del Médico'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: 'Editar Perfil y Pagos',
            onPressed: _mostrarModalEditarDatos,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Color(0xFF00796B),
                          child: Icon(
                            Icons.person,
                            size: 36,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.nombreMedico,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text('Medicina General'),
                              const Text(
                                'MSP: 1005-2022',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Color(0xFF00796B),
                          ),
                          onPressed: _mostrarModalEditarDatos,
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.phone, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(_telefono, style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.email, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(_correo, style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _direccion,
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.account_balance,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$_banco ($_tipoCuenta) - N° $_numeroCuenta',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Gestión de Atenciones',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _citas.length,
              itemBuilder: (context, index) {
                final cita = _citas[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              cita['paciente']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _colorEstado(
                                  cita['estado']!,
                                ).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                cita['estado']!,
                                style: TextStyle(
                                  color: _colorEstado(cita['estado']!),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${cita['tipo']} - ${cita['hora']}',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            DropdownButton<String>(
                              value: cita['estado'],
                              underline: const SizedBox(),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Pendiente',
                                  child: Text('Pendiente'),
                                ),
                                DropdownMenuItem(
                                  value: 'En Camino',
                                  child: Text('En Camino'),
                                ),
                                DropdownMenuItem(
                                  value: 'En Consulta',
                                  child: Text('En Consulta'),
                                ),
                                DropdownMenuItem(
                                  value: 'Completada',
                                  child: Text('Completada'),
                                ),
                              ],
                              onChanged: (nuevo) {
                                if (nuevo != null) {
                                  _cambiarEstadoCita(index, nuevo);
                                }
                              },
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              icon: const Icon(Icons.receipt_long, size: 16),
                              label: const Text(
                                'Receta',
                                style: TextStyle(fontSize: 12),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PrescriptionScreen(
                                      pacienteNombre: cita['paciente']!,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
