import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:desafio/modelo/dao/contrato_dao.dart';
import 'package:desafio/modelo/dao/recado_dao.dart';
import 'package:desafio/modelo/dao/clausulaGenerica_dao.dart';
import 'package:desafio/modelo/dao/clausula_dao.dart';

class PdfAnalysisServico extends ChangeNotifier {
  static const String _apiKey = 'AIzaSyAcVDLAFIF3XGEFwRabIqWRxc_kLEfNrdE';

  bool _isLoading = false;
  String? _analysisResult;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get analysisResult => _analysisResult;
  String? get errorMessage => _errorMessage;

  Future<void> analyzePdf(File pdfFile) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _analysisResult = null;
      notifyListeners();

      // Validate API key
      if (_apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
        throw Exception(
          'Please set your Gemini API key in pdf_analysis_servico.dart',
        );
      }

      // Get PDF file name
      final fileName = pdfFile.path.split('/').last;

      // Initialize Gemini
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);

      // Read PDF file as bytes
      final Uint8List pdfBytes = await pdfFile.readAsBytes();

      // Create the content with PDF data and prompt
      final content = [
        Content.multi([
          TextPart(
            'Please analyze this PDF document and provide a brief summary of what it\'s about. '
            'Include the main topics, purpose, and any key information you can extract from the document. '
            'Please respond in Portuguese.',
          ),
          DataPart('application/pdf', pdfBytes),
        ]),
      ];

      // Generate response
      final response = await model.generateContent(content);

      if (response.text != null) {
        _analysisResult = response.text!;

        // Save to database
        await _saveToDatabase(fileName, _analysisResult!);
      } else {
        throw Exception('Não foi possível gerar uma análise do documento');
      }
    } catch (e) {
      _errorMessage = 'Erro ao analisar PDF: ${e.toString()}';
      print('Error analyzing PDF: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearResults() {
    _analysisResult = null;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _saveToDatabase(String fileName, String geminiResponse) async {
    try {
      final contratoDao = ContratoDAO();
      final recadoDao = RecadoDAO();

      final now = DateTime.now();
      final dateString =
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

      // Create a formatted summary for the recado name
      final shortSummary = _createShortSummary(geminiResponse);

      // Create the contract and get its ID
      final contrato = await contratoDao.criarContrato(
        fileName, // titulo
        'PDF Analysis', // nomeEmpresa
        'Analisado', // status
        'PDF analisado via Gemini AI', // descricao
        dateString,
        fileName,
      );

      // Save Gemini response to recados table with better formatting
      final recado = await recadoDao.criarRecado(
        shortSummary, // nome - short summary for list view
        null, // erroIA
        modeloIA: 'gemini',
        conteudoAnalise: geminiResponse, // full analysis content
        nomeArquivo: fileName, // original PDF filename
      );

      // Parse the Gemini response into individual clauses and save to main clausulas table
      if (contrato != null && contrato.id != null) {
        await _parseAndSaveClausulas(geminiResponse, contrato.id!, fileName);
      }

      // Also save to clausulas_genericas if recado was created successfully (for backwards compatibility)
      if (recado != null && recado.id != null) {
        await _parseAndSaveClausulasGenericas(
          geminiResponse,
          recado.id!,
          fileName,
        );
      }

      print('Data saved successfully to database');
    } catch (e) {
      print('Error saving to database: $e');
    }
  }

  Future<void> _parseAndSaveClausulas(
    String analysisText,
    int contratoId,
    String fileName,
  ) async {
    try {
      final clausulaDao = ClausulaDAO();

      // Split the analysis into paragraphs/sections
      final paragraphs =
          analysisText
              .split('\n\n')
              .where((p) => p.trim().isNotEmpty)
              .map((p) => p.trim())
              .toList();

      // Also split by numbered points if they exist (1., 2., etc.)
      final List<String> clauses = [];
      for (String paragraph in paragraphs) {
        if (paragraph.contains(RegExp(r'\d+\.'))) {
          // Split by numbered points
          final numberedSections = paragraph.split(RegExp(r'(?=\d+\.)'));
          for (String section in numberedSections) {
            if (section.trim().isNotEmpty) {
              clauses.add(section.trim());
            }
          }
        } else {
          // Add whole paragraph as a clause
          clauses.add(paragraph);
        }
      }

      // Save each clause as a main clausula linked to the contract
      int clauseNumber = 1;
      for (String clauseContent in clauses) {
        if (clauseContent.length > 10) {
          // Only save meaningful content
          await clausulaDao.criarClausula(
            clauseContent, // texto
            'Análise PDF', // tipo
            'Ativa', // status
            contratoId, // contratoId
          );

          clauseNumber++;
        }
      }

      print('Created ${clauseNumber - 1} main clauses from PDF analysis');
    } catch (e) {
      print('Error parsing main clauses: $e');
    }
  }

  Future<void> _parseAndSaveClausulasGenericas(
    String analysisText,
    int recadoId,
    String fileName,
  ) async {
    try {
      final clausulaGenericaDao = ClausulaGenericaDAO();

      // Split the analysis into paragraphs/sections
      final paragraphs =
          analysisText
              .split('\n\n')
              .where((p) => p.trim().isNotEmpty)
              .map((p) => p.trim())
              .toList();

      // Also split by numbered points if they exist (1., 2., etc.)
      final List<String> clauses = [];
      for (String paragraph in paragraphs) {
        if (paragraph.contains(RegExp(r'\d+\.'))) {
          // Split by numbered points
          final numberedSections = paragraph.split(RegExp(r'(?=\d+\.)'));
          for (String section in numberedSections) {
            if (section.trim().isNotEmpty) {
              clauses.add(section.trim());
            }
          }
        } else {
          // Add whole paragraph as a clause
          clauses.add(paragraph);
        }
      }

      // Save each clause as a clausula_generica
      int clauseNumber = 1;
      for (String clauseContent in clauses) {
        if (clauseContent.length > 10) {
          // Only save meaningful content
          final clauseName = _generateClauseName(
            clauseContent,
            clauseNumber,
            fileName,
          );

          await clausulaGenericaDao.criarClausulaGenerica(
            nomeClausula: clauseName,
            conteudo: clauseContent,
            recadoId: recadoId,
          );

          clauseNumber++;
        }
      }

      print('Created ${clauseNumber - 1} clauses from PDF analysis');
    } catch (e) {
      print('Error parsing clauses: $e');
    }
  }

  String _generateClauseName(String content, int number, String fileName) {
    // Try to extract a meaningful title from the first line or sentence
    final firstLine = content.split('\n').first.trim();
    final firstSentence = content.split('.').first.trim();

    String title;
    if (firstLine.length <= 50 && firstLine.length > 0) {
      title = firstLine;
    } else if (firstSentence.length <= 50 && firstSentence.length > 0) {
      title = firstSentence;
    } else {
      // Fallback to first 47 characters + "..."
      title = content.length > 47 ? '${content.substring(0, 47)}...' : content;
    }

    // Clean up the title
    title = title.replaceAll(
      RegExp(r'^\d+\.?\s*'),
      '',
    ); // Remove leading numbers
    title = title.replaceAll(
      RegExp(r'[#*-]+\s*'),
      '',
    ); // Remove markdown symbols

    return 'PDF $number: $title'.trim();
  }

  String _createShortSummary(String fullAnalysis) {
    // Extract first sentence or first 100 characters for a summary
    final sentences = fullAnalysis.split('.');
    if (sentences.isNotEmpty) {
      String firstSentence = sentences[0].trim();
      if (firstSentence.length > 100) {
        return '${firstSentence.substring(0, 97)}...';
      }
      return '$firstSentence.';
    }

    // Fallback to character limit
    if (fullAnalysis.length > 100) {
      return '${fullAnalysis.substring(0, 97)}...';
    }
    return fullAnalysis;
  }
}
