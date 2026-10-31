// ignore_for_file: avoid_print
import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  const apiKey = String.fromEnvironment('GEMINI_API_KEY');
  if (apiKey.isEmpty) {
    print('Please provide GEMINI_API_KEY via --dart-define=GEMINI_API_KEY=your_key');
    return;
  }
  try {
    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      )
    );

    final response = await model.generateContent([
      Content.text('Say hello world')
    ]);
    print('Response: ${response.text}');
  } catch (e) {
    print('Exception!');
    print(e.toString());
  }
}
