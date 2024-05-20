import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class Generator extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    
    return GeneratorState();
  }
}

class GeneratorState extends State<Generator> {

  // Various variable setups
  String generatedText = '';
  late final _model;
  TextEditingController _controller = TextEditingController();

  @override
  void initState() {

      super.initState();

      // Gets the API key on instantiation to be used with the models
      _getAPIkey();

  }

  void _getAPIkey() async {
    // This function gets the API key and sets up the model to be used in _generateText()
    
    // Uses the flutter_dotenv library to get the API key stored in .env
    await dotenv.load(fileName: ".env");
    var apikey = dotenv.env['API_KEY'] ?? '';
    
    // Sets up the Gemini Pro model that is used to generate the desired output
    _model = GenerativeModel(
      model: 'gemini-pro', 
      apiKey: apikey,
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.high),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.high),
      ],
    );

  }
  
  void _generateText() async {
    //  This function creates the recipe based on the user provided text. It first involves stripping out the ingredients from the user-provided text and then generating the recipe. This function is where Gemini is used.


    // First the ingredients are pulled from the user inputs to turn into a structured, consistent format. Any nonsensical ingredients are hopefully pulled out through this step
    String preprocessingPrompt = "You will be provided text with ingredients from a user that hopes to cook something from this. Please process the text provided by the user and return a list in the following format: Ingredient A, Ingredient B, Ingredient C, .... If no ingredients that can be used to realistically create food are provided, please return 'None'. Please return no additional text apart from this list in your response. Please find the user provided text here: ";
    
    String preprocessingInput = preprocessingPrompt + _controller.text;

    final preContent = [Content.text(preprocessingInput)];
    final ingredientList = await _model.generateContent(preContent);

    
    // The ingredients are then passed through another LLM call where the recipe is generated.
    String prompt = "You are an expert cook with detailed knowledge of making recipes. A user is interested in making recipes with a certain set of ingredients. Please generate a recipe that uses these ingredients. Please only return the following sections: Recipe Name, Ingredients, Complexity, Steps to Create. Please only return the recipe and do not return any other text in your response. The recipe ingredients requested are ";

    String finalInput = prompt + ingredientList.text;

    final content = [Content.text(finalInput)];
    final recipe = await _model.generateContent(content);


    // Sets state to update the display of the app
    setState(() {
      
      generatedText = recipe.text;

    });
  }

  @override
  Widget build(BuildContext context) {

    // Creates the UI that is displayed to the user
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Maker'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Enter text',
                      labelStyle: TextStyle(color: Colors.teal),
                      border: OutlineInputBorder(),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: _generateText,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Replaces primary
                    foregroundColor: Colors.white, // Replaces onPrimary
                  ),
                  child: const Text('Submit'),
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.teal[50],
                  borderRadius: BorderRadius.circular(12.0),
                ),
                width: double.infinity, // Ensures the container spans the width
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: double.infinity),
                    child: SelectableText(
                      generatedText,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.teal[900],
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}