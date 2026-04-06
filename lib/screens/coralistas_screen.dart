import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../theme/app_theme.dart';
import '../mock_data.dart';
import '../models/pessoa.dart';

class CoralistasScreen extends StatefulWidget {
  const CoralistasScreen({super.key});

  @override
  State<CoralistasScreen> createState() => _CoralistasScreenState();
}

class _CoralistasScreenState extends State<CoralistasScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _buscaController = TextEditingController();
  final _telefoneMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {"#": RegExp(r'[0-9]')},
    type: MaskAutoCompletionType.lazy,
  );
  Timer? _buscaDebounce;
  String _termoBusca = '';
  TipoPessoa? _filtroTipo;
  ClassificacaoVocal? _filtroVoz;
  bool _mostrarFiltros = false;
  DateTime? _dataNascimento;
  ClassificacaoVocal _vozSelecionada = ClassificacaoVocal.soprano;
  TipoPessoa _tipoSelecionado = TipoPessoa.coralista;

  @override
  void initState() {
    super.initState();
    _buscaController.addListener(_onBuscaChanged);
  }

  @override
  void dispose() {
    _buscaDebounce?.cancel();
    _buscaController
      ..removeListener(_onBuscaChanged)
      ..dispose();
    _nomeController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  String _formatVoz(ClassificacaoVocal voz) {
    switch (voz) {
      case ClassificacaoVocal.soprano:
        return 'Soprano';
      case ClassificacaoVocal.contralto:
        return 'Contralto';
      case ClassificacaoVocal.tenor:
        return 'Tenor';
      case ClassificacaoVocal.baixo:
        return 'Baixo';
      case ClassificacaoVocal.na:
        return 'N/A';
    }
  }

  String _formatTipo(TipoPessoa tipo) {
    switch (tipo) {
      case TipoPessoa.coralista:
        return 'Coralista';
      case TipoPessoa.membro:
        return 'Naipe';
      case TipoPessoa.regente:
        return 'Regente';
    }
  }

  Color _getTipoColor(TipoPessoa tipo) {
    switch (tipo) {
      case TipoPessoa.coralista:
        return AppColors.primary;
      case TipoPessoa.membro:
        return AppColors.info;
      case TipoPessoa.regente:
        return AppColors.warning;
    }
  }

  Color _getVozColor(ClassificacaoVocal voz) {
    switch (voz) {
      case ClassificacaoVocal.soprano:
        return const Color(0xFFEC4899);
      case ClassificacaoVocal.contralto:
        return const Color(0xFF8B5CF6);
      case ClassificacaoVocal.tenor:
        return const Color(0xFF3B82F6);
      case ClassificacaoVocal.baixo:
        return const Color(0xFF10B981);
      case ClassificacaoVocal.na:
        return AppColors.textSecondary;
    }
  }

  void _onBuscaChanged() {
    _buscaDebounce?.cancel();
    _buscaDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      final valor = _buscaController.text.trim().toLowerCase();
      if (valor == _termoBusca) return;
      setState(() {
        _termoBusca = valor;
      });
    });
  }

  void _showAddOrEditCoralista({Pessoa? pessoaExistente}) {
    final isEdit = pessoaExistente != null;

    if (isEdit) {
      _nomeController.text = pessoaExistente.nome;
      _telefoneController.text = pessoaExistente.telefone;
      _dataNascimento = pessoaExistente.dataNascimento;
      _vozSelecionada = pessoaExistente.classificacaoVocal;
      _tipoSelecionado = pessoaExistente.tipoPadrao;
    } else {
      _nomeController.clear();
      _telefoneController.clear();
      _dataNascimento = null;
      _vozSelecionada = ClassificacaoVocal.soprano;
      _tipoSelecionado = TipoPessoa.coralista;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    isEdit ? 'Editar Coralista' : 'Novo Coralista',
                    style: GoogleFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Nome
                  _buildTextField(
                    controller: _nomeController,
                    label: 'Nome completo',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Informe o nome';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Telefone
                  _buildTelefoneField(),
                  const SizedBox(height: 16),

                  // Data de nascimento
                  GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _dataNascimento ?? DateTime(2000),
                        firstDate: DateTime(1930),
                        lastDate: DateTime.now(),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: const ColorScheme.light(
                                primary: AppColors.primary,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (date != null) {
                        setModalState(() => _dataNascimento = date);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.cake_outlined,
                            color: AppColors.textSecondary,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _dataNascimento != null
                                  ? '${_dataNascimento!.day.toString().padLeft(2, '0')}/${_dataNascimento!.month.toString().padLeft(2, '0')}/${_dataNascimento!.year}'
                                  : 'Data de nascimento',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: _dataNascimento != null
                                    ? AppColors.textPrimary
                                    : AppColors.textMuted,
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Voz
                  Text(
                    'Voz',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ClassificacaoVocal.values
                        .where((v) => v != ClassificacaoVocal.na)
                        .map(
                          (voz) => _buildChip(
                            label: _formatVoz(voz),
                            isSelected: _vozSelecionada == voz,
                            onTap: () =>
                                setModalState(() => _vozSelecionada = voz),
                            color: _getVozColor(voz),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),

                  // Tipo
                  Text(
                    'Tipo',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: TipoPessoa.values
                        .map(
                          (tipo) => _buildChip(
                            label: _formatTipo(tipo),
                            isSelected: _tipoSelecionado == tipo,
                            onTap: () =>
                                setModalState(() => _tipoSelecionado = tipo),
                            color: _getTipoColor(tipo),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 28),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          _saveCoralista(pessoaExistente: pessoaExistente),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        isEdit ? 'Salvar Alterações' : 'Salvar Coralista',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(color: AppColors.textMuted),
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 22),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildTelefoneField() {
    return TextFormField(
      controller: _telefoneController,
      keyboardType: TextInputType.phone,
      inputFormatters: [_telefoneMask],
      validator: (value) {
        if (value == null || value.isEmpty) return 'Informe o telefone';
        if (value.length < 15) return 'Telefone incompleto';
        return null;
      },
      style: GoogleFonts.inter(fontSize: 15, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: 'Telefone',
        hintText: '(00) 00000-0000',
        labelStyle: GoogleFonts.inter(color: AppColors.textMuted),
        hintStyle: GoogleFonts.inter(color: AppColors.textMuted),
        prefixIcon: const Icon(
          Icons.phone_outlined,
          color: AppColors.textSecondary,
          size: 22,
        ),
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    final chipColor = color ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? chipColor.withAlpha(20) : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? chipColor : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? chipColor : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Future<void> _saveCoralista({Pessoa? pessoaExistente}) async {
    if (_formKey.currentState!.validate()) {
      if (_dataNascimento == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione a data de nascimento')),
        );
        return;
      }

      try {
        if (pessoaExistente != null) {
          final pessoaAtualizada = Pessoa(
            id: pessoaExistente.id,
            nome: _nomeController.text.trim(),
            dataNascimento: _dataNascimento!,
            telefone: _telefoneController.text.trim(),
            classificacaoVocal: _vozSelecionada,
            tipoPadrao: _tipoSelecionado,
            fotoUrl: pessoaExistente.fotoUrl,
          );
          await atualizarPessoa(pessoaAtualizada);
          if (!mounted) return;
          setState(() {});
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${_nomeController.text} atualizado!')),
          );
        } else {
          final novaPessoa = await criarPessoa(
            nome: _nomeController.text.trim(),
            dataNascimento: _dataNascimento!,
            telefone: _telefoneController.text.trim(),
            classificacaoVocal: _vozSelecionada,
            tipoPadrao: _tipoSelecionado,
          );
          if (!mounted) return;
          setState(() {});
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${novaPessoa.nome} adicionado com sucesso!'),
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao salvar coralista: $e')));
      }
    }
  }

  void _deleteCoralista(Pessoa pessoa) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Excluir Coralista',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Tem certeza que deseja excluir "${pessoa.nome}"?\n\nTodos os registros de frequência dele serão removidos.',
          style: GoogleFonts.inter(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.inter(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                await excluirPessoa(pessoa.id);
                if (!context.mounted) return;
                setState(() {});
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${pessoa.nome} excluído!')),
                );
              } catch (e) {
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao excluir coralista: $e')),
                );
              }
            },
            child: Text(
              'Excluir',
              style: GoogleFonts.inter(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Pessoa> _filtrarCoralistas(List<Pessoa> pessoas) {
    return pessoas.where((pessoa) {
      if (_filtroTipo != null && pessoa.tipoPadrao != _filtroTipo) {
        return false;
      }
      if (_filtroVoz != null && pessoa.classificacaoVocal != _filtroVoz) {
        return false;
      }
      if (_termoBusca.isEmpty) {
        return true;
      }
      return pessoa.nome.toLowerCase().contains(_termoBusca);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final todosCoralistas = [...mockPessoas]
      ..sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
    final coralistas = _filtrarCoralistas(todosCoralistas);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Coralistas',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      body: todosCoralistas.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildHeader(
                  exibidos: coralistas.length,
                  total: todosCoralistas.length,
                ),
                _buildFiltros(),
                if (coralistas.isEmpty) _buildSemResultados(),
                ...coralistas.map(_buildCoralistaItem),
                const SizedBox(height: 80),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOrEditCoralista(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader({required int exibidos, required int total}) {
    final textoContagem = exibidos == total
        ? '$total cadastrados'
        : '$exibidos de $total exibidos';

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Membros do Coral',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            textoContagem,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    final temFiltrosAtivos = _filtroTipo != null || _filtroVoz != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _buscaController,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              labelText: 'Buscar coralista por nome',
              labelStyle: GoogleFonts.inter(color: AppColors.textMuted),
              prefixIcon: const Icon(
                Icons.search,
                color: AppColors.textSecondary,
              ),
              suffixIcon: _buscaController.text.trim().isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _buscaController.clear();
                        _buscaDebounce?.cancel();
                        setState(() {
                          _termoBusca = '';
                        });
                      },
                      icon: const Icon(Icons.clear),
                    ),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  setState(() {
                    _mostrarFiltros = !_mostrarFiltros;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Icon(
                        _mostrarFiltros
                            ? Icons.check_box_outlined
                            : Icons.check_box_outline_blank,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Filtros',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if (temFiltrosAtivos)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _filtroTipo = null;
                      _filtroVoz = null;
                    });
                  },
                  child: const Text('Limpar'),
                ),
            ],
          ),
          if (_mostrarFiltros) ...[
            const SizedBox(height: 6),
            Text(
              'Categoria',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildFiltroCheckbox(
                  label: 'Todas',
                  checked: _filtroTipo == null,
                  onChanged: (value) {
                    if (!value) return;
                    setState(() => _filtroTipo = null);
                  },
                ),
                ...TipoPessoa.values.map(
                  (tipo) => _buildFiltroCheckbox(
                    label: _formatTipo(tipo),
                    checked: _filtroTipo == tipo,
                    onChanged: (value) {
                      setState(() {
                        _filtroTipo = value ? tipo : null;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Naipe (tipo de voz)',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _buildFiltroCheckbox(
                  label: 'Todos',
                  checked: _filtroVoz == null,
                  onChanged: (value) {
                    if (!value) return;
                    setState(() => _filtroVoz = null);
                  },
                ),
                ...ClassificacaoVocal.values
                    .where((voz) => voz != ClassificacaoVocal.na)
                    .map(
                      (voz) => _buildFiltroCheckbox(
                        label: _formatVoz(voz),
                        checked: _filtroVoz == voz,
                        onChanged: (value) {
                          setState(() {
                            _filtroVoz = value ? voz : null;
                          });
                        },
                      ),
                    ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFiltroCheckbox({
    required String label,
    required bool checked,
    required ValueChanged<bool> onChanged,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => onChanged(!checked),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: checked ? AppColors.primary.withAlpha(12) : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: checked
                ? AppColors.primary.withAlpha(80)
                : AppColors.cardBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: checked,
              onChanged: (value) => onChanged(value ?? false),
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text(
            'Nenhum coralista',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Adicione coralistas usando o botão +',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSemResultados() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Text(
        'Nenhum coralista encontrado com os filtros atuais.',
        style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
      ),
    );
  }

  Widget _buildCoralistaItem(Pessoa pessoa) {
    final tipoColor = _getTipoColor(pessoa.tipoPadrao);
    final vozColor = _getVozColor(pessoa.classificacaoVocal);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: vozColor.withAlpha(20),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  pessoa.nome.isNotEmpty ? pessoa.nome[0].toUpperCase() : '?',
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: vozColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pessoa.nome,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: tipoColor.withAlpha(20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _formatTipo(pessoa.tipoPadrao),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: tipoColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: vozColor.withAlpha(15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _formatVoz(pessoa.classificacaoVocal),
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: vozColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Edit
            GestureDetector(
              onTap: () => _showAddOrEditCoralista(pessoaExistente: pessoa),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.info.withAlpha(12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: AppColors.info,
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Delete
            GestureDetector(
              onTap: () => _deleteCoralista(pessoa),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.delete_outline,
                  size: 16,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
