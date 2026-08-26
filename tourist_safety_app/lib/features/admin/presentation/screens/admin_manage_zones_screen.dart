import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../danger_zones/presentation/providers/danger_zone_provider.dart';
import '../../../danger_zones/data/models/danger_zone_model.dart';

class AdminManageZonesScreen extends ConsumerStatefulWidget {
  const AdminManageZonesScreen({super.key});

  @override
  ConsumerState<AdminManageZonesScreen> createState() => _AdminManageZonesScreenState();
}

class _AdminManageZonesScreenState extends ConsumerState<AdminManageZonesScreen> {
  final _nameController = TextEditingController();
  String _riskType = 'Crime';
  String _severity = 'Low';
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  final _descController = TextEditingController();

  Future<void> _addZone() async {
    try {
      await ref.read(dangerZoneRepositoryProvider).createDangerZone(DangerZoneModel(
        id: 0,
        name: _nameController.text,
        riskType: _riskType,
        severity: _severity,
        latitude: double.tryParse(_latController.text) ?? 0.0,
        longitude: double.tryParse(_lonController.text) ?? 0.0,
        additionalDetails: _descController.text,
        radius: 500,
      ));
      ref.refresh(dangerZonesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Danger Zone Added Successfully')));
        _nameController.clear();
        _latController.clear();
        _lonController.clear();
        _descController.clear();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _deleteZone(int id) async {
    try {
      await ref.read(dangerZoneRepositoryProvider).deleteDangerZone(id);
      ref.refresh(dangerZonesProvider);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final zonesState = ref.watch(dangerZonesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Manage Zones Table
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Manage Danger Zones', style: TextStyle(fontFamily: 'Segoe UI', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1C1F26))),
                const SizedBox(height: 15),
                zonesState.when(
                  data: (zones) {
                    bool isMobile = MediaQuery.of(context).size.width <= 800;
                    
                    if (isMobile) {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: zones.length,
                        itemBuilder: (context, index) {
                          final z = zones[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 2,
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(z.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 5),
                                  Text('Risk: ${z.riskType}', style: TextStyle(color: Colors.grey.shade700)),
                                  Text('Severity: ${z.severity}', style: TextStyle(color: Colors.grey.shade700)),
                                  Text('Location: ${z.latitude}, ${z.longitude}', style: TextStyle(color: Colors.grey.shade700)),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {},
                                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8)),
                                        child: const Text('Edit'),
                                      ),
                                      const SizedBox(width: 10),
                                      ElevatedButton(
                                        onPressed: () => _deleteZone(z.id),
                                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8)),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                    
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(const Color(0xFFF4F6F9)),
                        dataRowColor: WidgetStateProperty.all(Colors.white),
                        columns: const [
                          DataColumn(label: Text('Zone', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Risk', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Severity', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Latitude', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Longitude', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: zones.map((z) => DataRow(
                          cells: [
                            DataCell(Text(z.name)),
                            DataCell(Text(z.riskType)),
                            DataCell(Text(z.severity)),
                            DataCell(Text(z.latitude.toString())),
                            DataCell(Text(z.longitude.toString())),
                            DataCell(Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                                  child: const Text('Edit'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () => _deleteZone(z.id),
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                                  child: const Text('Delete'),
                                ),
                              ],
                            )),
                          ],
                        )).toList(),
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 30),

          // Add Zone Form
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 6))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Add Danger Zone', style: TextStyle(fontFamily: 'Segoe UI', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1C1F26))),
                const SizedBox(height: 15),
                _buildInput('Zone Name', _nameController, false),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _riskType,
                  decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.all(10)),
                  items: ['Crime', 'Flood', 'Landslide'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _riskType = v!),
                ),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _severity,
                  decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.all(10)),
                  items: ['Low', 'Medium', 'High'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _severity = v!),
                ),
                const SizedBox(height: 15),
                _buildInput('Latitude', _latController, false),
                const SizedBox(height: 15),
                _buildInput('Longitude', _lonController, false),
                const SizedBox(height: 15),
                _buildInput('Description', _descController, true),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: _addZone,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text('Add Zone'),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(String hint, TextEditingController controller, bool isMulti) {
    return TextField(
      controller: controller,
      maxLines: isMulti ? 3 : 1,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.all(10),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFCCCCCC))),
      ),
    );
  }
}
