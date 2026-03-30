# Especificação de Projeto: App Frequência Koinonia

## 1. Visão Geral
Aplicativo móvel para gestão de frequência do grupo Koinonia. O sistema deve controlar a presença em ensaios e eventos, permitindo a gestão de diferentes tipos de participantes (Coralistas, Membros e Regentes) com visualização de estatísticas trimestrais e anuais.

## 2. Design System & UI
O aplicativo deve seguir uma identidade visual baseada em tons de roxo, transmitindo seriedade e modernidade.

### Paleta de Cores (Hex Codes)
* **Primary (Cor Principal/Botões):** `#7e3285`
* **Secondary (Detalhes/Ícones):** `#9f5ea5`
* **Background Light (Fundos de cards/áreas claras):** `#e0b6e4`
* **Dark Accent (Textos/Títulos):** `#5d0565`
* **Background Dark / Appbar (Fundo principal ou Barra superior):** `#47034e`

---

## 3. Arquitetura de Dados (Data Modeling)
*Estratégia para histórico:* O banco de dados deve separar as **Pessoas** (cadastro único) dos **Vínculos** (cadastro por período), permitindo que uma pessoa mude de função ou saia e volte sem perder o histórico anterior.

### Entidades Sugeridas
1.  **Pessoa (Entidade Global):**
    * `id`: UUID ou Inteiro.
    * `nome`: String.
    * `data_nascimento`: Date.
    * `telefone`: String.
    * `classificacao_vocal`: Enum (Soprano, Contralto, Tenor, Baixo, N/A).
    * `tipo_padrao`: Enum (**Coralista**, **Membro**, **Regente**). *Define o papel principal da pessoa.*
    * `foto_url`: String (opcional).

2.  **Ciclo (Ano Letivo):**
    * `ano`: Integer (ex: 2026).
    * `ativo`: Boolean.

3.  **Trimestre:**
    * `id`: UUID.
    * `ano_id`: FK para Ciclo.
    * `numero`: Integer (1, 2, 3, 4).

4.  **Matricula (Vínculo Trimestral):**
    * *Tabela de associação para definir quem está ativo naquele trimestre específico.*
    * `trimestre_id`: FK.
    * `pessoa_id`: FK.
    * `funcao_no_trimestre`: Enum (**Coralista**, **Membro**, **Regente**). *Permite que alguém seja Coralista num ano e Regente no outro.*

5.  **Evento (Ensaio/Reunião):**
    * `id`: UUID.
    * `trimestre_id`: FK.
    * `data_hora`: DateTime.
    * `tipo`: Enum (Ensaio Geral, Ensaio de Naipe, Reunião).

6.  **Frequencia:**
    * `evento_id`: FK.
    * `pessoa_id`: FK.
    * `status`: Enum (Presença, Falta, Justificativa, Atraso).

---

## 4. Requisitos Funcionais (Telas e Fluxo)

### Navegação & Menu (Drawer)
* Menu lateral acessível ("3 tracinhos").
* **Acesso Restrito:** Solicitar senha/PIN para funções administrativas (Cadastros e Configurações).
* **Itens do Menu:**
    * Cadastrar Pessoa (Regente/Coralista/Membro).
    * Relatório Geral Anual (Acumulado de todos os trimestres).
    * Trocar Senha de Acesso.

### Tela 1: Home (Seleção de Ciclo)
* **Header:** Logo ou Nome "Frequência Koinonia". Cor de fundo: `#47034e`.
* **Conteúdo:** Exibição do Ano Vigente.
* **Funcionalidade:** Botão discreto para criar/alternar para um novo Ano (preservando o banco de dados de pessoas).

### Tela 2: Dashboard Trimestral
* Grid com 4 Cards grandes representando os trimestres.
* Cada card deve usar cores da paleta (ex: `#7e3285` para o fundo do card) com texto claro.

### Tela 3: Calendário de Ensaios
* Lista cronológica das datas dentro do trimestre selecionado.
* Botão flutuante (FAB) na cor `#9f5ea5` para adicionar nova data de ensaio.

### Tela 4: Chamada Interativa
* Ao clicar na data, exibe a lista de pessoas matriculadas naquele trimestre.
* **Filtro Visual:** Ícone ou cor distinta ao lado do nome para diferenciar visualmente quem é **Coralista** de quem é **Membro**.
* **Controles:** Botões de ação rápida para marcar presença/falta.
* **Gestão da Lista:** Botão "Gerenciar Pessoas do Trimestre" -> Abre lista global de pessoas cadastradas para marcar quem participará deste trimestre (check in/check out).

### Tela 5: Detalhes da Pessoa (Perfil)
* Acessível ao clicar no nome da pessoa.
* Exibe dados cadastrais e **Tipo** (Coralista/Membro).
* **Dashboard Individual:**
    * Gráfico de Rosca (Donut Chart) usando as cores da paleta (`#9f5ea5` para presença, `#47034e` para falta).
    * Tabs ou Switch para alternar visualização: "Dados do Trimestre" vs "Acumulado do Ano".

---

## 5. Requisitos Não Funcionais
* **Tecnologia:** Flutter (Frontend) + SQLite (Persistência Local).
* **Responsividade:** Layout adaptável para diferentes tamanhos de tela.
* **Offline First:** O app deve funcionar 100% sem internet.