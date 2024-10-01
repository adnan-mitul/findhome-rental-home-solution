import 'package:flutter/material.dart';

class FAQPage extends StatelessWidget {
  const FAQPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Frequently Asked Questions',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context); // Go back to the previous page
          },
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.cyan.shade100,
              Colors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: const [
              FAQItem(
                question: '1. How do I reset my password?',
                answer:
                    'To reset your password, go to the login page and click "Forgot Password". Follow the instructions to reset it.',
              ),
              FAQItem(
                question: '2. What is the typical rental process for a home?',
                answer:
                    'Search for a rental, visit, apply, complete background checks, sign the lease, pay the deposit, and move in.',
              ),
              FAQItem(
                question: '3. What is included in the rent payment?',
                answer:
                    'It may include water, trash, sewage, and maintenance. Other utilities like electricity and internet are usually extra.',
              ),
              FAQItem(
                question:
                    '4. What is a security deposit, and is it refundable?',
                answer:
                    'A security deposit is typically one month’s rent, refundable if there’s no damage or unpaid rent.',
              ),
              FAQItem(
                question: '5. How do I renew or terminate my lease?',
                answer:
                    'Contact your landlord to renew. For termination, give written notice (usually 30-60 days).',
              ),
              FAQItem(
                question:
                    '6. What happens if the landlord fails to make repairs?',
                answer:
                    'Notify the landlord in writing. If they don’t respond, contact housing authorities or withhold rent (depending on local laws).',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FAQItem extends StatelessWidget {
  final String question;
  final String answer;

  const FAQItem({Key? key, required this.question, required this.answer})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.black87, // Adjust text color for better readability
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            answer,
            style:
                const TextStyle(color: Colors.black54), // Style the answer text
          ),
        ),
      ],
    );
  }
}
