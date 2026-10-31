import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AIPrayerExtractor {
  static const String prefKey = 'gemini_api_key';

  /// Retrieves the Gemini API key from local storage (SharedPreferences)
  /// or falls back to compile-time environment variable GEMINI_API_KEY.
  static Future<String?> getApiKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = prefs.getString(prefKey)?.trim();
      if (key != null && key.isNotEmpty) return key;
    } catch (e) {
      debugPrint('Error reading Gemini API key from storage: $e');
    }
    const envKey = String.fromEnvironment('GEMINI_API_KEY');
    if (envKey.isNotEmpty) return envKey.trim();
    return null;
  }

  /// Saves the Gemini API key to local storage (SharedPreferences).
  static Future<void> setApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(prefKey, key.trim());
  }

  /// Clears the Gemini API key from local storage.
  static Future<void> clearApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(prefKey);
  }

  /// Connects to Gemini to extract daily prayer schedules from a given document/image bytes.
  /// Ensure you provide the correct mimeType (e.g. 'application/pdf', 'image/png', 'image/jpeg')
  static Future<List<Map<String, dynamic>>?> extractPrayerTimes({
    required Uint8List bytes,
    required String mimeType,
    bool includeSunrise = true,
    String? apiKey,
  }) async {
    final effectiveApiKey = apiKey ?? await getApiKey();
    if (effectiveApiKey == null || effectiveApiKey.isEmpty) {
      throw Exception(
          'Gemini API key is not configured. Please set your API key in the settings.');
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-2.5-flash',
        apiKey: effectiveApiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          responseSchema: Schema.array(
            description: 'List of all days contained in the monthly prayer schedule',
            items: Schema.object(
              properties: {
                'day': Schema.integer(description: 'The Gregorian day of the month as an integer (1 to 31)'),
                'fajr': Schema.string(description: 'Fajr prayer time in 24-hour HH:mm format'),
                if (includeSunrise) 'sunrise': Schema.string(description: 'Sunrise time in 24-hour HH:mm format. If Sunrise is not explicitly listed, leave null or empty.', nullable: true),
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
          "You are an expert OCR parser. Extract all daily prayer times ${includeSunrise ? '(including Sunrise if available) ' : '(EXCLUDING Sunrise) '}from the provided document accurately. "
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
