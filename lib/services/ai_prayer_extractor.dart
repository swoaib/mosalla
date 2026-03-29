import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AIPrayerExtractor {
  // Use the API key provided by the user
  static const String _geminiApiKey = "AIzaSyB6O58BGVQUCydKm4FTwvp_4srwBC5PHvU";

  /// Connects to Gemini 1.5 Pro to extract daily prayer schedules from a given document/image bytes.
  /// Ensure you provide the correct mimeType (e.g. 'application/pdf', 'image/png', 'image/jpeg')
  static Future<List<Map<String, dynamic>>?> extractPrayerTimes({
    required Uint8List bytes,
    required String mimeType,
  }) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: _geminiApiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: Schema.array(
            description: 'List of all days contained in the monthly prayer schedule',
            items: Schema.object(
              properties: {
                'day': Schema.integer(description: 'The Gregorian day of the month as an integer (1 to 31)'),
                'fajr': Schema.string(description: 'Fajr prayer time in 24-hour HH:mm format'),
                'duhr': Schema.string(description: 'Zuhr/Duhr standard prayer time in 24-hour HH:mm format'),
                'asr': Schema.string(description: 'Asr prayer time in 24-hour HH:mm format'),
                'maghrib': Schema.string(description: 'Maghrib prayer time in 24-hour HH:mm format'),
                'isha': Schema.string(description: 'Isha prayer time in 24-hour HH:mm format'),
                'jumma': Schema.string(
                    description: 'Jumma/Friday prayer time in 24-hour HH:mm format. Leave null or empty if not applicable to the day.',
                    nullable: true),
              },
              requiredProperties: ['day', 'fajr', 'duhr', 'asr', 'maghrib', 'isha'],
            ),
          ),
        ),
      );

      final prompt = TextPart(
          "You are an expert OCR parser. Extract all daily prayer times from the provided document accurately. "
          "Look at the main table closely. Ensure you retrieve the times specifically for the Gregorian month schedule. "
          "If a top banner defines explicit universal congregation times for all days (e.g. 'Zuhr starts at 12:00'), "
          "evaluate whether that overrides the table's times or if the table is the accurate Adhan time. "
          "Generally, trust the table matrix for the specific times for each day. Follow the required structured schema strictly.");

      final dataPart = DataPart(mimeType, bytes);
      
      final response = await model.generateContent([
        Content.multi([prompt, dataPart])
      ]);

      if (response.text == null || response.text!.isEmpty) {
        return null;
      }

      final dynamic decoded = jsonDecode(response.text!);
      if (decoded is List) {
        return decoded.cast<Map<String, dynamic>>();
      }
      return null;
    } catch (e) {
      debugPrint('AIPrayerExtractor error: \$e');
      rethrow;
    }
  }
}
