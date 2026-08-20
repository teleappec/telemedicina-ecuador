// lib/screens/payment_screen.dart
import 'package:flutter/material.dart';
import 'confirmation_ticket_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String doctorNombre;
  final String especialidad;
  final String servicioNombre;
  final double monto;
  final String fecha;
  final String hora;

  const PaymentScreen({
    super.key,
    this.doctorNombre = 'Dr. Carlos Mendoza',
    this.especialidad = 'Medicina General',
    this.servicioNombre = 'Teleconsulta',
    this.monto = 25.0,
    this.fecha = '20/10/2026',
    this.hora = '10:00 AM',
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _metodoPagoSeleccionado = 'Tarjeta';

  final _numTarjetaController = TextEditingController(
    text: '4532 •••• •••• 8821',
  );
  final _vencimientoController = TextEditingController(text: '12/28');
  final _cvvController = TextEditingController(text: '***');
  final _numComprobanteController = TextEditingController();

  @override
  void dispose() {
    _numTarjetaController.dispose();
    _vencimientoController.dispose();
    _cvvController.dispose();
    _numComprobanteController.dispose();
    super.dispose();
  }

  void _procesarPago() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pop(context); // Cierra indicador de carga

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmationTicketScreen(
            doctorNombre: widget.doctorNombre,
            especialidad: widget.especialidad,
            servicioNombre: widget.servicioNombre,
            monto: widget.monto,
            fecha: widget.fecha,
            hora: widget.hora,
            metodoPago: _metodoPagoSeleccionado,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pasarela de Pago')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen de la Orden
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resumen del Servicio',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Servicio:'),
                        Text(
                          widget.servicioNombre,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Médico:'),
                        Text(widget.doctorNombre),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Fecha / Hora:'),
                        Text('${widget.fecha} - ${widget.hora}'),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Monto a pagar:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${widget.monto.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
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
            const SizedBox(height: 20),

            const Text(
              'Seleccione Método de Pago',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            RadioListTile<String>(
              title: const Text('Tarjeta de Crédito / Débito'),
              secondary: const Icon(Icons.credit_card, color: Colors.teal),
              value: 'Tarjeta',
              groupValue: _metodoPagoSeleccionado,
              onChanged: (val) {
                if (val != null) setState(() => _metodoPagoSeleccionado = val);
              },
            ),
            RadioListTile<String>(
              title: const Text('Transferencia Bancaria Directa'),
              secondary: const Icon(Icons.account_balance, color: Colors.teal),
              value: 'Transferencia',
              groupValue: _metodoPagoSeleccionado,
              onChanged: (val) {
                if (val != null) setState(() => _metodoPagoSeleccionado = val);
              },
            ),
            RadioListTile<String>(
              title: const Text('Pago en Efectivo (Contra entrega)'),
              secondary: const Icon(Icons.payments, color: Colors.teal),
              value: 'Efectivo',
              groupValue: _metodoPagoSeleccionado,
              onChanged: (val) {
                if (val != null) setState(() => _metodoPagoSeleccionado = val);
              },
            ),

            const SizedBox(height: 16),

            if (_metodoPagoSeleccionado == 'Tarjeta') ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _numTarjetaController,
                        decoration: const InputDecoration(
                          labelText: 'Número de Tarjeta',
                          prefixIcon: Icon(Icons.credit_card),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _vencimientoController,
                              decoration: const InputDecoration(
                                labelText: 'Vencimiento (MM/AA)',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: _cvvController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'CVV',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (_metodoPagoSeleccionado == 'Transferencia') ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Datos Bancarios para Transferencia:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      const Text('• Banco Pichincha - Cta. Corriente'),
                      const Text('• N° 2100123456'),
                      const Text('• RUC / CI: 1792345678001'),
                      const Text('• Telemedicina Ecuador S.A.'),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _numComprobanteController,
                        decoration: const InputDecoration(
                          labelText: 'Número de Comprobante / Referencia',
                          prefixIcon: Icon(Icons.receipt),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else if (_metodoPagoSeleccionado == 'Efectivo') ...[
              Card(
                color: Colors.amber.shade50,
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Pagará directamente al profesional al momento de recibir la atención presencial o visita.',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_circle),
                label: Text(
                  'CONFIRMAR Y PAGAR \$${widget.monto.toStringAsFixed(2)}',
                ),
                onPressed: _procesarPago,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
