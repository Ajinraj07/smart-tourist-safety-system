import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../places/presentation/providers/place_provider.dart';
import '../../../places/data/models/place_model.dart';

class AdminManagePlacesScreen extends ConsumerStatefulWidget {
  const AdminManagePlacesScreen({super.key});

  @override
  ConsumerState<AdminManagePlacesScreen> createState() => _AdminManagePlacesScreenState();
}

class _AdminManagePlacesScreenState extends ConsumerState<AdminManagePlacesScreen> {
  final _nameController = TextEditingController();
  String _type = 'Hospital';
  final _latController = TextEditingController();
  final _lonController = TextEditingController();
  final _descController = TextEditingController();

  Future<void> _addPlace() async {
    try {
      await ref.read(placeRepositoryProvider).createPlace(PlaceModel(
        id: 0,
        name: _nameController.text,
        type: _type,
        latitude: double.tryParse(_latController.text) ?? 0.0,
        longitude: double.tryParse(_lonController.text) ?? 0.0,
        description: _descController.text,
        address: '',
      ));
      ref.refresh(placesProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Place Added Successfully')));
        _nameController.clear();
        _latController.clear();
        _lonController.clear();
        _descController.clear();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _deletePlace(int id) async {
    try {
      await ref.read(placeRepositoryProvider).deletePlace(id);
      ref.refresh(placesProvider);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final placesState = ref.watch(placesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Manage Places Table
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
                const Text('Manage Places', style: TextStyle(fontFamily: 'Segoe UI', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1C1F26))),
                const SizedBox(height: 15),
                placesState.when(
                  data: (places) {
                    bool isMobile = MediaQuery.of(context).size.width <= 800;
                    
                    if (isMobile) {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: places.length,
                        itemBuilder: (context, index) {
                          final p = places[index];
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
                                  Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 5),
                                  Text('Type: ${p.type}', style: TextStyle(color: Colors.grey.shade700)),
                                  Text('Location: ${p.latitude}, ${p.longitude}', style: TextStyle(color: Colors.grey.shade700)),
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
                                        onPressed: () => _deletePlace(p.id),
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
                          DataColumn(label: Text('Place', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Latitude', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Longitude', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: places.map((p) => DataRow(
                          cells: [
                            DataCell(Text(p.name)),
                            DataCell(Text(p.type)),
                            DataCell(Text(p.latitude.toString())),
                            DataCell(Text(p.longitude.toString())),
                            DataCell(Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2563EB), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
                                  child: const Text('Edit'),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () => _deletePlace(p.id),
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

          // Add Place Form
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
                const Text('Add New Place', style: TextStyle(fontFamily: 'Segoe UI', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1C1F26))),
                const SizedBox(height: 15),
                _buildInput('Place Name', _nameController, false),
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  value: _type,
                  decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.all(10)),
                  items: ['Hospital', 'Police Station', 'Help Center'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setState(() => _type = v!),
                ),
                const SizedBox(height: 15),
                _buildInput('Latitude', _latController, false),
                const SizedBox(height: 15),
                _buildInput('Longitude', _lonController, false),
                const SizedBox(height: 15),
                _buildInput('Description', _descController, true),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: _addPlace,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: const Text('Add Place'),
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
