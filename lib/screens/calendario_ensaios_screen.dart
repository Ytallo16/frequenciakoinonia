import 'package:flutter/material.dart';
import '../mock_data.dart';
import '../models/trimestre.dart';
import 'chamada_interativa_screen.dart';

class CalendarioEnsaiosScreen extends StatelessWidget {
  final Trimestre trimestre;

  const CalendarioEnsaiosScreen({super.key, required this.trimestre});

  @override
  Widget build(BuildContext context) {
    final eventos = mockEventos.where((e) => e.trimestreId == trimestre.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Calendário - Trimestre ${trimestre.numero}'),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFe0b6e4)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: eventos.isEmpty
            ? const Center(
                child: Text(
                  'Nenhum ensaio agendado',
                  style: TextStyle(fontSize: 18, color: Color(0xFF5d0565)),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: eventos.length,
                itemBuilder: (context, index) {
                  final evento = eventos[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(
                        Icons.event,
                        color: Color(0xFF7e3285),
                        size: 32,
                      ),
                      title: Text(
                        '${evento.dataHora.day}/${evento.dataHora.month}/${evento.dataHora.year} - ${evento.tipo.toString().split('.').last.replaceAll('ensaio', 'Ensaio ').replaceAll('reuniao', 'Reunião')}'.replaceAll('Geral', 'Geral').replaceAll('Naipe', 'de Naipe'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF5d0565),
                        ),
                      ),
                      subtitle: Text(
                        '${evento.dataHora.hour}:${evento.dataHora.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(color: Color(0xFF9f5ea5)),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChamadaInterativaScreen(evento: evento),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Adicionar nova data - Mock')),
          );
        },
        backgroundColor: const Color(0xFF9f5ea5),
        child: const Icon(Icons.add),
      ),
    );
  }
}