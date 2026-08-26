import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import 'admin_manage_places_screen.dart';
import 'admin_manage_zones_screen.dart';
import 'admin_monitoring_screen.dart';
import 'admin_sos_records_screen.dart';
import 'admin_bulk_upload_screen.dart';
import '../providers/admin_provider.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _selectedIndex = 0;

  void _logout() async {
    await ref.read(authStateProvider.notifier).logout();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardContent();
      case 1:
        return const AdminMonitoringScreen();
      case 2:
        return const AdminManagePlacesScreen();
      case 3:
        return const AdminManageZonesScreen();
      case 4:
        return const AdminSosRecordsScreen();
      case 5:
        return const AdminBulkUploadScreen();
      default:
        return _buildDashboardContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: isDesktop ? null : AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(0xFF1E2130),
        foregroundColor: Colors.white,
      ),
      drawer: isDesktop ? null : _buildSidebar(isMobile: true),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(isMobile: false),
          Expanded(
            child: Column(
              children: [
                if (isDesktop) _buildHeader(),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar({required bool isMobile}) {
    return Container(
      width: 260,
      color: const Color(0xFF1A1C29),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMobile) const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.security, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              const Text(
                'Admin Panel',
                style: TextStyle(fontFamily: 'Segoe UI', color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 5),
          const Text('Smart Tourist Safety System', style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 40),
          _buildSidebarItem(0, Icons.home, 'Dashboard'),
          const SizedBox(height: 10),
          _buildSidebarItem(2, Icons.location_on, 'Manage Places'),
          const SizedBox(height: 10),
          _buildSidebarItem(3, Icons.warning, 'Manage Danger Zones'),
          const SizedBox(height: 10),
          _buildSidebarItem(4, Icons.notifications, 'SOS Records'),
          const SizedBox(height: 10),
          _buildSidebarItem(5, Icons.upload_file, 'Bulk Upload (CSV)'),
          const SizedBox(height: 10),
          _buildSidebarItem(1, Icons.show_chart, 'Live Monitoring'),
          const Spacer(),
          if (isMobile)
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE53935), foregroundColor: Colors.white),
              child: const Text('Logout'),
            ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String title) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        if (MediaQuery.of(context).size.width <= 800) Navigator.pop(context);
        
        if (index == 1) {
          // Live monitoring is now a full screen route
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminMonitoringScreen()));
        } else {
          setState(() => _selectedIndex = index);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5E5CE6) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? Colors.white : const Color(0xFF94A3B8), size: 20),
            const SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(fontFamily: 'Segoe UI', 
                color: isSelected ? Colors.white : const Color(0xFFE2E8F0),
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Dashboard Overview', style: TextStyle(fontFamily: 'Segoe UI', fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          Row(
            children: [
              const CircleAvatar(backgroundColor: Color(0xFF5E5CE6), child: Text('A', style: TextStyle(color: Colors.white))),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('admin', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  Text('Administrator', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                ],
              ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Logout'),
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  elevation: 0,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDashboardContent() {
    final dashboardStatsAsync = ref.watch(dashboardStatsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Welcome back, admin!', style: TextStyle(fontFamily: 'Segoe UI', fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 5),
          const Text("Here's what's happening with your tourist safety system today.", style: TextStyle(fontFamily: 'Segoe UI', color: Color(0xFF64748B), fontSize: 15)),
          const SizedBox(height: 30),

          dashboardStatsAsync.when(
            data: (stats) {
              final recentPlaces = stats['recent_places'] as List<dynamic>? ?? [];
              final recentZones = stats['recent_zones'] as List<dynamic>? ?? [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Row
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          _buildModernStatCard('TOTAL PLACES', stats['total_places']?.toString() ?? '0', Icons.map, Colors.blue, 'Active locations', Icons.arrow_upward, Colors.green),
                          _buildModernStatCard('DANGER ZONES', stats['total_danger_zones']?.toString() ?? '0', Icons.warning_amber_rounded, Colors.red, '${stats['high_severity_zones'] ?? 0} high severity', Icons.shield, Colors.red),
                          _buildModernStatCard('TOTAL SOS RECORDS', stats['total_sos']?.toString() ?? '0', Icons.notifications_active, Colors.orange, 'All time records', Icons.access_time, Colors.orange),
                          _buildModernStatCard('ACTIVE TOURISTS', stats['total_tourists']?.toString() ?? '0', Icons.people_alt, Colors.green, 'Registered users', Icons.check_circle, Colors.green),
                        ],
                      );
                    }
                  ),
                  const SizedBox(height: 40),

                  // Quick Actions
                  const Text('Quick Actions', style: TextStyle(fontFamily: 'Segoe UI', fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 5),
                  const Text("Manage your system with these quick shortcuts.", style: TextStyle(fontFamily: 'Segoe UI', color: Color(0xFF64748B), fontSize: 14)),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      _buildQuickActionCard('Add New Place', 'Register hospital, police station, or help center', Icons.add_circle, Colors.blue, () => setState(() => _selectedIndex = 2)),
                      _buildQuickActionCard('Add Danger Zone', 'Mark high risk areas for tourist safety', Icons.location_off, Colors.red, () => setState(() => _selectedIndex = 3)),
                      _buildQuickActionCard('View SOS Records', 'Review emergency alerts and responses', Icons.list_alt, Colors.orange, () => setState(() => _selectedIndex = 4)),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Recent Lists
                  LayoutBuilder(
                    builder: (context, constraints) {
                      bool isSmall = constraints.maxWidth < 800;
                      return Flex(
                        direction: isSmall ? Axis.vertical : Axis.horizontal,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: isSmall ? 0 : 1,
                            child: _buildRecentListCard('Recent Places', Icons.location_on, 'View all', () => setState(() => _selectedIndex = 2), recentPlaces, true),
                          ),
                          if (!isSmall) const SizedBox(width: 20),
                          if (isSmall) const SizedBox(height: 20),
                          Expanded(
                            flex: isSmall ? 0 : 1,
                            child: _buildRecentListCard('Recent Danger Zones', Icons.warning_amber_rounded, 'View all', () => setState(() => _selectedIndex = 3), recentZones, false),
                          ),
                        ],
                      );
                    }
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error loading stats: $e'),
          ),
        ],
      ),
    );
  }

  Widget _buildModernStatCard(String title, String value, IconData icon, Color iconColor, String subText, IconData subIcon, Color subIconColor) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontFamily: 'Segoe UI', color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontFamily: 'Segoe UI', color: iconColor, fontSize: 36, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            children: [
              Icon(subIcon, color: subIconColor, size: 14),
              const SizedBox(width: 5),
              Text(subText, style: TextStyle(color: subIconColor, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            CircleAvatar(backgroundColor: color, radius: 20, child: Icon(icon, color: Colors.white, size: 20)),
            const SizedBox(height: 15),
            Text(title, style: const TextStyle(fontFamily: 'Segoe UI', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            const SizedBox(height: 5),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Segoe UI', fontSize: 12, color: Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentListCard(String title, IconData icon, String actionText, VoidCallback onActionTap, List<dynamic> items, bool isPlaces) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: const Color(0xFF1E293B), size: 20),
                  const SizedBox(width: 10),
                  Text(title, style: const TextStyle(fontFamily: 'Segoe UI', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                ],
              ),
              TextButton(
                onPressed: onActionTap,
                child: Text(actionText, style: const TextStyle(color: Color(0xFF5E5CE6), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(flex: 3, child: Text(isPlaces ? 'PLACE NAME' : 'ZONE NAME', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
              Expanded(flex: 1, child: Text(isPlaces ? 'TYPE' : 'SEVERITY', textAlign: TextAlign.right, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2))),
            ],
          ),
          const Divider(height: 30),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text("No recent entries", style: TextStyle(color: Color(0xFF94A3B8)))),
            )
          else
            ...items.map((item) {
              String name = item['name'] ?? '';
              String secondary = isPlaces ? (item['type'] ?? '') : (item['severity'] ?? '');
              
              Color badgeColor = Colors.blue;
              Color badgeBg = Colors.blue.withOpacity(0.1);
              
              if (!isPlaces) {
                if (secondary.toLowerCase() == 'high') {
                  badgeColor = Colors.red;
                  badgeBg = Colors.red.withOpacity(0.1);
                } else if (secondary.toLowerCase() == 'medium') {
                  badgeColor = Colors.orange;
                  badgeBg = Colors.orange.withOpacity(0.1);
                } else {
                  badgeColor = Colors.blue;
                  badgeBg = Colors.blue.withOpacity(0.1);
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text(name, style: const TextStyle(color: Color(0xFF475569), fontSize: 14))),
                    Expanded(
                      flex: 1,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(12)),
                          child: Text(secondary, style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }
}
