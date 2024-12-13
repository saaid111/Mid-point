import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class FlashcardsPage extends StatefulWidget {
  const FlashcardsPage({super.key});

  @override
  _FlashcardsPageState createState() => _FlashcardsPageState();
}

class _FlashcardsPageState extends State<FlashcardsPage> {
  final user = FirebaseAuth.instance.currentUser!;
  final TextEditingController _textController = TextEditingController();
  List<List<Map<String, String>>> allFlashcards = []; 
  bool isLoading = false;
  String errorMessage = '';

  // OpenAI API key
  final String openAIAPIKey = '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';
  final String openAIEndpoint = 'https://api.openai.com/v1/chat/completions';

  //fetchh flashcards from OpenAI API
  Future<void> fetchFlashcards(String text) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse(openAIEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKey',
        },
        body: json.encode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a helpful assistant that creates flashcards.',
            },
            {
              'role': 'user',
              'content': 'Create an appropriate amount of flashcards based on this text(follow format): $text. Format as "Question: ..., Answer: ..." for each flashcard.',
            },
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        String outputText = data['choices'][0]['message']['content'].toString().trim();
        setState(() {
          // Parse the flashcards for this set and add to the allFlashcards list
          allFlashcards.add(parseFlashcards(outputText));
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'Failed to fetch flashcards: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Error: $e';
      });
    }
  }

  // Parse the flashcards response from OpenAI API
  List<Map<String, String>> parseFlashcards(String outputText) {
    List<Map<String, String>> flashcardsList = [];
    final flashcardTextList = outputText.split('\n');

    for (var flashcardText in flashcardTextList) {
      if (flashcardText.trim().isNotEmpty) {
        final parts = flashcardText.split(':');
        if (parts.length == 2) {
          flashcardsList.add({
            'question': parts[0].trim(),
            'answer': parts[1].trim(),
          });
        }
      }
    }
    return flashcardsList;
  }

  // Show dialog to enter text and generate flashcards
  void _showInputDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Enter Text to Generate Flashcards"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _textController,
                decoration: InputDecoration(hintText: "Enter text here"),
                maxLines: 4,
              ),
              SizedBox(height: 10),
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () {
                        if (_textController.text.isNotEmpty) {
                          fetchFlashcards(_textController.text);
                          _textController.clear();
                          Navigator.of(context).pop(); // Close the dialog
                        }
                      },
                      child: Text('Generate Flashcards'),
                    ),
            ],
          ),
        );
      },
    );
  }

  // Show the flashcard in a dialog
  void _showFlashcardDialog(Map<String, String> flashcard) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Flashcard"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${flashcard['question']} \n ${flashcard['answer']}'),
              SizedBox(height: 1),
              Text('${flashcard['answer']}'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
                child: Text('Back'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Flashcards"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            InkWell(
              onTap: _showInputDialog,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
            SizedBox(height: 16),

            // Display all flashcard sets as black boxes
            Expanded(
              child: ListView.builder(
                itemCount: allFlashcards.length,
                itemBuilder: (context, setIndex) {
                  final flashcardSet = allFlashcards[setIndex];
                  return ExpansionTile(
                    title: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Flashcard Set ${setIndex + 1}',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    children: flashcardSet.map((flashcard) {
                      return ListTile(
                        title: Text(
                          '${flashcard['question']}',
                          style: TextStyle(color: Colors.black),
                        ),
                        subtitle: Text(
                          '${flashcard['answer']}',
                          style: TextStyle(color: Colors.black),
                        ),
                        onTap: () {
                          _showFlashcardDialog(flashcard); // show flashcard detaills
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
