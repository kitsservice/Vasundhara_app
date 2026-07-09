import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'About Us',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 12),
            // Company Logo placeholder or Icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.business,
                size: 64,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'KITS',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kajal Innovation & Technical Solutions',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.green.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),

            // About Company Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Who We Are'),
                  const SizedBox(height: 12),
                  _buildParagraph(
                      'KITS — Kajal Innovation & Technical Solutions is a technology-driven company working in Robotics, Industrial Automation, Artificial Intelligence, Computer Vision, Industrial IoT, Software Development, EV Technology, AR/VR Solutions, Bio-Medical Technology, and Training & Upskilling.',),
                  const SizedBox(height: 16),
                  _buildParagraph(
                      'KITS was founded with the vision of bringing advanced technology, practical engineering, and world-class learning opportunities to small cities. The company focuses on bridging the gap between academic knowledge and real industrial requirements by combining hands-on training, innovation, engineering services, product development, and industrial deployment under one platform.',),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Leadership'),
                  const SizedBox(height: 12),
                  _buildParagraph(
                      'Under the leadership of Ms. Kajal Aruna Prakash Rajvaidya, Founder & CEO of KITS, the organization is working to empower students, industries, professionals, and businesses with future-ready technical skills and smart technology solutions. KITS believes that innovation should not be limited to metro cities, and small cities can also become powerful centers of technology, talent, and industrial growth.',),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Our Mission'),
                  const SizedBox(height: 12),
                  _buildParagraph(
                      'Our mission is to simplify advanced technology and make robotics, automation, AI, and industrial innovation accessible, practical, and impactful for everyone.',),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Our Services'),
                  const SizedBox(height: 12),
                  _buildParagraph(
                      'Robotics Engineering, Industrial Automation, PLC, SCADA, HMI, AI & Computer Vision, Industrial IoT, Custom Software Development, Mobile App Development, Web Applications, SaaS Platforms, EV Solutions, AR/VR Simulations, Bio-Medical Technology Solutions, Product Prototyping, and Technical Training Programs.',),
                  const SizedBox(height: 16),
                  _buildParagraph(
                      'KITS provides industry-grade solutions designed for real-world performance, productivity, safety, reliability, and measurable results. Through its unique model of education and engineering, KITS helps students become job-ready, supports industries in automation and digital transformation, and contributes to building a stronger technology ecosystem.',),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Company Details'),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.person_outline, 'Founder & CEO', 'Ms. Kajal Aruna Prakash Rajvaidya'),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.business_outlined, 'Company Name', 'KITS — Kajal Innovation & Technical Solutions'),
                  const SizedBox(height: 16),
                  _buildDetailRow(Icons.location_on_outlined, 'Address', 'KITS, 1st Floor, Mukta Plaza,\nKITS Square, Income Tax Chowk,\nGaurakshan Road,\nAkola – 444001, Maharashtra, India'),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        color: Colors.grey.shade700,
        height: 1.5,
      ),
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 22, color: Colors.green.shade700),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
