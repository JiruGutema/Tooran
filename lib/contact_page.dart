import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({Key? key}) : super(key: key);

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
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'About Developer:',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "I'm Jiren! a 3rd Year Software Engineering Student at Addis Ababa University. Contact me through the following channel or just go to my Portfolio section",
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 94, 98, 102),
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
              style: TextStyle(fontSize: 18, color: Colors.black87, decoration: TextDecoration.underline),
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
              style: TextStyle(fontSize: 18, color: Colors.black87, decoration: TextDecoration.underline),
              textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: _launchURL,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
                child: const Text(
                  'Go to Portflio',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
