import 'package:flutter/material.dart';
import '../mock_data.dart';
import '../models/evento.dart';
import '../models/trimestre.dart';
import 'chamada_interativa_screen.dart';
import 'evento_detalhes_screen.dart';

class CalendarioEnsaiosScreen extends StatefulWidget {
  final Trimestre trimestre;

  const CalendarioEnsaiosScreen({super.key, required this.trimestre});

  @override
  State<CalendarioEnsaiosScreen> createState() =>
      _CalendarioEnsaiosScreenState();
}

class _CalendarioEnsaiosScreenState extends State<CalendarioEnsaiosScreen> {
  String _formatarData(DateTime dataHora) {
    final dia = dataHora.day.toString().padLeft(2, '0');
    final mes = dataHora.month.toString().padLeft(2, '0');
    final ano = dataHora.year.toString();
    return '$dia/$mes/$ano';
  }

  String _formatarHora(DateTime dataHora) {
    final hora = dataHora.hour.toString().padLeft(2, '0');
    final minuto = dataHora.minute.toString().padLeft(2, '0');
    return '$hora:$minuto';
  }

  List<Evento> _eventosDoTrimestre() {
    final inicioHoje = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    final eventosDoTrimestre =
        mockEventos
            .where((evento) => evento.trimestreId == widget.trimestre.id)
            .toList();

    final naoPassados =
        eventosDoTrimestre
            .where((evento) => !evento.dataHora.isBefore(inicioHoje))
            .toList()
          ..sort((a, b) => a.dataHora.compareTo(b.dataHora));

    final passados =
        eventosDoTrimestre
            .where((evento) => evento.dataHora.isBefore(inicioHoje))
            .toList()
          ..sort((a, b) => b.dataHora.compareTo(a.dataHora));

    return [...naoPassados, ...passados];
  }

  Future<void> _abrirModalNovoEvento() async {
    final nomeController = TextEditingController();
    final descricaoController = TextEditingController();
    var dataSelecionada = DateTime.now();
    var horaSelecionada = TimeOfDay.now();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Novo Evento',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5d0565),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nomeController,
                      decoration: const InputDecoration(
                        labelText: 'Nome do evento',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.calendar_today,
                        color: Color(0xFF7e3285),
                      ),
                      title: Text('Data: ${_formatarData(dataSelecionada)}'),
                      trailing: const Icon(Icons.edit),
                      onTap: () async {
                        final data = await showDatePicker(
                          context: context,
                          initialDate: dataSelecionada,
                          firstDate: DateTime(widget.trimestre.anoId, 1, 1),
                          lastDate: DateTime(widget.trimestre.anoId, 12, 31),
                        );
                        if (data == null) return;
                        setModalState(() {
                          dataSelecionada = data;
                        });
                      },
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.access_time,
                        color: Color(0xFF7e3285),
                      ),
                      title: Text('Hora: ${horaSelecionada.format(context)}'),
                      trailing: const Icon(Icons.edit),
                      onTap: () async {
                        final hora = await showTimePicker(
                          context: context,
                          initialTime: horaSelecionada,
                        );
                        if (hora == null) return;
                        setModalState(() {
                          horaSelecionada = hora;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descricaoController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Descrição (opcional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final nomeDigitado = nomeController.text.trim();
                          if (nomeDigitado.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Informe o nome do evento.'),
                              ),
                            );
                            return;
                          }

                          final dataHora = DateTime(
                            dataSelecionada.year,
                            dataSelecionada.month,
                            dataSelecionada.day,
                            horaSelecionada.hour,
                            horaSelecionada.minute,
                          );

                          mockEventos.add(
                            Evento(
                              id: 'e${DateTime.now().microsecondsSinceEpoch}',
                              trimestreId: widget.trimestre.id,
                              dataHora: dataHora,
                              nome: nomeDigitado,
                              descricao: descricaoController.text.trim(),
                            ),
                          );

                          if (!mounted) return;
                          Navigator.pop(context);
                          setState(() {});
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Evento cadastrado com sucesso.'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.save),
                        label: const Text('Salvar evento'),
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

    nomeController.dispose();
    descricaoController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventos = _eventosDoTrimestre();

    return Scaffold(
      appBar: AppBar(
        title: Text('Calendário - Trimestre ${widget.trimestre.numero}'),
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
                  'Nenhum ensaio agendado.\nToque em + para cadastrar.',
                  textAlign: TextAlign.center,
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
                        evento.nome,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF5d0565),
                        ),
                      ),
                      subtitle: Text(
                        '${_formatarData(evento.dataHora)} • ${_formatarHora(evento.dataHora)}${evento.descricao.trim().isEmpty ? '' : '\n${evento.descricao.trim()}'}',
                        style: const TextStyle(color: Color(0xFF9f5ea5)),
                      ),
                      isThreeLine: evento.descricao.trim().isNotEmpty,
                      trailing: IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF7e3285)),
                        tooltip: 'Editar evento',
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EventoDetalhesScreen(eventoId: evento.id),
                            ),
                          );
                          if (!mounted) return;
                          setState(() {});
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ChamadaInterativaScreen(evento: evento),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _abrirModalNovoEvento,
        backgroundColor: const Color(0xFF9f5ea5),
        child: const Icon(Icons.add),
      ),
    );
  }
}
