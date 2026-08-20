// lib/screens/teleconsultation_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';

class TeleconsultationScreen extends StatefulWidget {
  final String doctorNombre;

  const TeleconsultationScreen({
    super.key,
    this.doctorNombre = 'Dr. Carlos Mendoza',
  });

  @override
  State<TeleconsultationScreen> createState() => _TeleconsultationScreenState();
}

class _TeleconsultationScreenState extends State<TeleconsultationScreen> {
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isSpeakerOn = true;
  int _callDurationSeconds = 0;
  Timer? _timer;

  final List<Map<String, String>> _chatMessages = [
    {
      'sender': 'doctor',
      'text':
          'Hola, bienvenido a la teleconsulta. ¿En qué le puedo ayudar hoy?',
    },
  ];
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startCallTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  void _startCallTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDurationSeconds++;
        });
      }
    });
  }

  String _formatDuration(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _chatMessages.add({
        'sender': 'patient',
        'text': _messageController.text.trim(),
      });
      _messageController.clear();
    });
  }

  void _openChatBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 16,
                left: 16,
                right: 16,
              ),
              child: SizedBox(
                height: 400,
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Chat de la Consulta',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _chatMessages.length,
                        itemBuilder: (context, index) {
                          final msg = _chatMessages[index];
                          final isMe = msg['sender'] == 'patient';
                          return Align(
                            alignment: isMe
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? Colors.teal
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                msg['text'] ?? '',
                                style: TextStyle(
                                  color: isMe ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: const InputDecoration(
                              hintText: 'Escriba un mensaje...',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: Colors.teal),
                          onPressed: () {
                            _sendMessage();
                            setModalState(() {});
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _finalizarLlamada() {
    _timer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Llamada Finalizada'),
        content: Text(
          'La consulta con ${widget.doctorNombre} ha concluido con una duración de ${_formatDuration(_callDurationSeconds)}.',
        ),
        actions: [
          ElevatedButton(
            child: const Text('Aceptar'),
            onPressed: () {
              Navigator.pop(context); // Cierra dialog
              Navigator.pop(context); // Regresa a pantalla anterior
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Feed Principal: Cámara del Doctor
            Positioned.fill(
              child: Container(
                color: Colors.grey.shade900,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.teal,
                      child: Icon(Icons.person, size: 70, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.doctorNombre,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.fiber_manual_record,
                          color: Colors.green,
                          size: 12,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'En vivo • ${_formatDuration(_callDurationSeconds)}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // PiP (Picture-in-Picture): Vista previa de la cámara del paciente
            Positioned(
              right: 16,
              top: 16,
              width: 110,
              height: 150,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  color: _isVideoOff
                      ? Colors.grey.shade800
                      : Colors.blueGrey.shade700,
                  child: _isVideoOff
                      ? const Center(
                          child: Icon(
                            Icons.videocam_off,
                            color: Colors.white54,
                            size: 30,
                          ),
                        )
                      : Stack(
                          children: const [
                            Center(
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                            Positioned(
                              bottom: 4,
                              left: 4,
                              child: Text(
                                'Tú',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),

            // Barra inferior con controles de la llamada
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Mute / Unmute
                    CircleAvatar(
                      backgroundColor: _isMuted ? Colors.red : Colors.white24,
                      child: IconButton(
                        icon: Icon(
                          _isMuted ? Icons.mic_off : Icons.mic,
                          color: Colors.white,
                        ),
                        onPressed: () => setState(() => _isMuted = !_isMuted),
                      ),
                    ),
                    // Video On / Off
                    CircleAvatar(
                      backgroundColor: _isVideoOff
                          ? Colors.red
                          : Colors.white24,
                      child: IconButton(
                        icon: Icon(
                          _isVideoOff ? Icons.videocam_off : Icons.videocam,
                          color: Colors.white,
                        ),
                        onPressed: () =>
                            setState(() => _isVideoOff = !_isVideoOff),
                      ),
                    ),
                    // Altavoz
                    CircleAvatar(
                      backgroundColor: _isSpeakerOn
                          ? Colors.teal
                          : Colors.white24,
                      child: IconButton(
                        icon: Icon(
                          _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                          color: Colors.white,
                        ),
                        onPressed: () =>
                            setState(() => _isSpeakerOn = !_isSpeakerOn),
                      ),
                    ),
                    // Abrir Chat
                    CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: IconButton(
                        icon: const Icon(Icons.chat, color: Colors.white),
                        onPressed: _openChatBottomSheet,
                      ),
                    ),
                    // Cortar Llamada
                    CircleAvatar(
                      backgroundColor: Colors.red,
                      child: IconButton(
                        icon: const Icon(Icons.call_end, color: Colors.white),
                        onPressed: _finalizarLlamada,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
