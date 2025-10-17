import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:desafio/modelo/dao/contrato_dao.dart';
import 'package:desafio/modelo/dao/recado_dao.dart';

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

      // Get current date
      final now = DateTime.now();
      final dateString =
          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

      // Save PDF info to contratos table
      await contratoDao.criarContrato(
        fileName, // titulo
        'PDF Analysis', // nomeEmpresa
        'Analisado', // status
        'PDF analisado via Gemini AI', // descricao
        dateString, // dataGeracao
        fileName, // link (using filename as reference)
      );

      // Save Gemini response to recados table
      await recadoDao.criarRecado(
        geminiResponse, // nome (storing the analysis content)
        null, // erroIA
        modeloIA: 'gemini', // modeloIA
      );

      print('Data saved successfully to database');
    } catch (e) {
      print('Error saving to database: $e');
      // Don't throw here to avoid disrupting the user experience
      // The analysis result is still shown even if database save fails
    }
  }
}
