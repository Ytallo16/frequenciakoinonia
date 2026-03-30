import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/pessoa.dart';

class DetalhesPessoaScreen extends StatefulWidget {
  final Pessoa pessoa;

  const DetalhesPessoaScreen({super.key, required this.pessoa});

  @override
  _DetalhesPessoaScreenState createState() => _DetalhesPessoaScreenState();
}

class _DetalhesPessoaScreenState extends State<DetalhesPessoaScreen> {
  bool isTrimestre = true;

  @override
  Widget build(BuildContext context) {
    // Mock data for chart
    final presenca = 8;
    final falta = 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Pessoa'),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nome: ${widget.pessoa.nome}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF5d0565)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Data de Nascimento: ${widget.pessoa.dataNascimento.toLocal().toString().split(' ')[0]}',
                        style: const TextStyle(fontSize: 16, color: Color(0xFF5d0565)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Telefone: ${widget.pessoa.telefone}',
                        style: const TextStyle(fontSize: 16, color: Color(0xFF5d0565)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Classificação Vocal: ${widget.pessoa.classificacaoVocal.toString().split('.').last}',
                        style: const TextStyle(fontSize: 16, color: Color(0xFF5d0565)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tipo Padrão: ${widget.pessoa.tipoPadrao.toString().split('.').last}',
                        style: const TextStyle(fontSize: 16, color: Color(0xFF5d0565)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Gráfico de Presença',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF5d0565)),
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: presenca.toDouble(),
                            title: '$presenca\nPresente',
                            color: const Color(0xFF9f5ea5),
                            radius: 60,
                            titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          PieChartSectionData(
                            value: falta.toDouble(),
                            title: '$falta\nFaltou',
                            color: const Color(0xFF47034e),
                            radius: 60,
                            titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isTrimestre = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isTrimestre ? const Color(0xFF9f5ea5) : Colors.grey,
                      ),
                      child: const Text('Dados do Trimestre'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isTrimestre = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !isTrimestre ? const Color(0xFF9f5ea5) : Colors.grey,
                      ),
                      child: const Text('Acumulado do Ano'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}