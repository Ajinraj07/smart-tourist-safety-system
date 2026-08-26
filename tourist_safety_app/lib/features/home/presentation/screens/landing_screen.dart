import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../auth/presentation/screens/register_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header / Navbar
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width > 600 ? 50 : 20, 
                vertical: 15
              ),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1D2671), Color(0xFFC33764)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Tourist Safety System',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width > 600 ? 22 : 18,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (MediaQuery.of(context).size.width > 600)
                    Row(
                      children: [
                        _buildNavText('Home', () {}),
                        _buildNavText('Features', () {}),
                        _buildNavText('About', () {}),
                        _buildNavText('Login', () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
                        }),
                        _buildNavText('Sign Up', () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                        }),
                      ],
                    ),
                ],
              ),
            ),

            // Hero Section
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width > 600 ? 50 : 20, 
                vertical: 80
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 40,
                runSpacing: 40,
                children: [
                  Container(
                    constraints: const BoxConstraints(maxWidth: 550),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Smart Tourist Safety & Risk Alert System',
                          style: GoogleFonts.poppins(
                            fontSize: MediaQuery.of(context).size.width > 600 ? 40 : 32,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1D2671),
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'A smart platform designed to protect tourists by providing real-time alerts, high-risk area warnings, and emergency support using data-driven insights.',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: const Color(0xFF333333),
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFC33764),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20), // Adjusted for flutter
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                            textStyle: GoogleFonts.poppins(fontSize: 16),
                          ),
                          child: const Text('Get Started'),
                        )
                      ],
                    ),
                  ),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Image.network(
                      'https://cdn-icons-png.flaticon.com/512/201/201623.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),

            // Features Section
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width > 600 ? 50 : 20, 
                vertical: 60
              ),
              child: Column(
                children: [
                  Text(
                    'Key Features',
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1D2671),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Wrap(
                    spacing: 25,
                    runSpacing: 25,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildFeatureCard('📍 Risk Zone Detection', 'Identifies crime-prone and unsafe locations for tourists.'),
                      _buildFeatureCard('🚨 Emergency Alerts', 'Instant alerts during emergencies or unsafe situations.'),
                      _buildFeatureCard('🗺️ Live Map View', 'Interactive map showing safe and risky zones.'),
                      _buildFeatureCard('🛠️ Admin Dashboard', 'Authorities can manage alerts and monitor activity.'),
                    ],
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              width: double.infinity,
              color: const Color(0xFF1D2671),
              padding: const EdgeInsets.all(15),
              child: Text(
                '© 2026 Smart Tourist Safety System | Mini Project',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            )
          ],
        ),
        ),
        ),
      ),
    );
  }

  Widget _buildNavText(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(left: 25),
      child: InkWell(
        onTap: onTap,
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, String description) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6F9),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12, // subtle shadow for flutter to mimic hover roughly
            blurRadius: 10,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: const Color(0xFFC33764),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: GoogleFonts.poppins(
              color: const Color(0xFF333333),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
