import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';
import '../providers/auth_provider.dart';
import 'register_screen.dart';
import '../../../dashboard/presentation/screens/tourist_dashboard_screen.dart';
import '../../../admin/presentation/screens/admin_dashboard_screen.dart';
import '../../../home/presentation/screens/landing_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> with SingleTickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _bgAnimationController;

  @override
  void initState() {
    super.initState();
    _bgAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgAnimationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final user = await ref.read(authStateProvider.notifier).login(
        _usernameController.text,
        _passwordController.text,
      );
      if (mounted) {
        if (user.isSuperuser) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
          );
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const TouristDashboardScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(e.toString())),
              ],
            ),
            backgroundColor: const Color(0xFFFF8080),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.4, 1.0],
                colors: [Color(0xFF0A0F1E), Color(0xFF0D1F3C), Color(0xFF0F2C4A)],
              ),
            ),
          ),
          // Animated Glow 1
          AnimatedBuilder(
            animation: _bgAnimationController,
            builder: (context, child) {
              return Positioned(
                top: -150 + (50 * _bgAnimationController.value),
                left: -150 + (50 * _bgAnimationController.value),
                child: Container(
                  width: 500,
                  height: 500,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color(0x261E90FF), Colors.transparent],
                    ),
                  ),
                ),
              );
            },
          ),
          // Animated Glow 2
          AnimatedBuilder(
            animation: _bgAnimationController,
            builder: (context, child) {
              return Positioned(
                bottom: -100 - (30 * _bgAnimationController.value),
                right: -100 - (30 * _bgAnimationController.value),
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [Color(0x2600C6FF), Colors.transparent],
                    ),
                  ),
                ),
              );
            },
          ),
          // Center Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 44),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                        boxShadow: const [
                          BoxShadow(color: Colors.black54, blurRadius: 60, offset: Offset(0, 20)),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Brand
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF1E90FF), Color(0xFF00C6FF)],
                              ),
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: const [
                                BoxShadow(color: Color(0x591E90FF), blurRadius: 24, offset: Offset(0, 8)),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: const Text('🛡️', style: TextStyle(fontSize: 28)),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Smart Tourist Safety',
                            style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.3),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Sign in to continue to your dashboard',
                            style: GoogleFonts.inter(fontSize: 13.5, color: Colors.white.withOpacity(0.45)),
                          ),
                          const SizedBox(height: 36),

                          // Form
                          _buildTextField('Username', _usernameController, false),
                          const SizedBox(height: 16),
                          _buildTextField('Password', _passwordController, true),
                          const SizedBox(height: 22),

                          // Submit
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E90FF),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 6,
                              ).copyWith(
                                shadowColor: WidgetStateProperty.all(const Color(0x4D1E90FF)),
                              ),
                              child: _isLoading
                                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Text('Sign In', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600)),
                            ),
                          ),

                          // Footer Links
                          const SizedBox(height: 28),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('New tourist? ', style: GoogleFonts.inter(color: Colors.white.withOpacity(0.6), fontSize: 13.5)),
                              InkWell(
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                                child: Text('Create an account', style: GoogleFonts.inter(color: const Color(0xFF1E90FF), fontSize: 13.5, fontWeight: FontWeight.w500)),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(color: Colors.white10),
                          ),
                          InkWell(
                            onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LandingScreen())),
                            child: Text('← Back to Home', style: GoogleFonts.inter(color: Colors.white.withOpacity(0.45), fontSize: 13.5)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, bool isPassword) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white.withOpacity(0.65)),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 14.5),
          decoration: InputDecoration(
            hintText: 'Enter your ${label.toLowerCase()}',
            hintStyle: GoogleFonts.inter(color: Colors.white.withOpacity(0.25)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.06),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0x991E90FF), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
