import 'package:google_generative_ai/google_generative_ai.dart';

void main() async {
  const apiKey = 'AIzaSyB6O58BGVQUCydKm4FTwvp_4srwBC5PHvU';
  
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
