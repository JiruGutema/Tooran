import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  Future<void> _launchURL() async {
    final Uri url = Uri.parse('https://jirugutema.netlify.app');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 24),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(33,44,57,1),
      ),
      body: Container(
        color: Color.fromRGBO(23, 33, 43,1),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'About Developer:',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "I'm Jiren! a 3rd Year Software Engineering Student at Addis Ababa University. Contact me through the following channel or just go to my Portfolio section",
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: 'jethior1@gmail.com',
                );
                if (!await launchUrl(emailUri)) {
                  throw 'Could not launch $emailUri';
                }
              },
              child: const Text(
                'Email: jethior1@gmail.com',
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(221, 5, 148, 249),
                  decoration: TextDecoration.underline,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () async {
                final Uri telegramUri = Uri.parse('https://t.me/jethior');
                if (!await launchUrl(telegramUri, mode: LaunchMode.externalApplication)) {
                  throw 'Could not launch $telegramUri';
                }
              },
              child: const Text(
                'Telegram: https://t.me/jethior',
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(221, 5, 148, 249),
                  decoration: TextDecoration.underline,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: _launchURL,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 57, 86, 109),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: const Text(
                  'Go to Portfolio',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'App Version: 1.5.0',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
