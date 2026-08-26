import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_provider.dart';

class AdminSosRecordsScreen extends ConsumerStatefulWidget {
  const AdminSosRecordsScreen({super.key});

  @override
  ConsumerState<AdminSosRecordsScreen> createState() => _AdminSosRecordsScreenState();
}

class _AdminSosRecordsScreenState extends ConsumerState<AdminSosRecordsScreen> {
  @override
  Widget build(BuildContext context) {
    final sosState = ref.watch(allSosProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                const Text('All SOS Records', style: TextStyle(fontFamily: 'Segoe UI', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1C1F26))),
                const SizedBox(height: 15),
                sosState.when(
                  data: (records) {
                    bool isMobile = MediaQuery.of(context).size.width <= 800;
                    
                    if (isMobile) {
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: records.length,
                        itemBuilder: (context, index) {
                          final r = records[index];
                          Color statusColor = r['status'] == 'pending' ? Colors.red : (r['status'] == 'closed' ? Colors.green : Colors.orange);
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
                                  Text(r['tourist_name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 5),
                                  Text('Time: ${r['created_at']}', style: TextStyle(color: Colors.grey.shade700)),
                                  Text('Location: ${r['latitude']}, ${r['longitude']}', style: TextStyle(color: Colors.grey.shade700)),
                                  const SizedBox(height: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                    child: Text((r['status'] ?? '').toUpperCase(), style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
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
                          DataColumn(label: Text('Tourist', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Time', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Latitude', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Longitude', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: records.map((r) {
                          Color statusColor = r['status'] == 'pending' ? Colors.red : (r['status'] == 'closed' ? Colors.green : Colors.orange);
                          return DataRow(
                            cells: [
                              DataCell(Text(r['tourist_name'] ?? 'Unknown')),
                              DataCell(Text(r['created_at'] ?? '')),
                              DataCell(Text(r['latitude']?.toString() ?? '')),
                              DataCell(Text(r['longitude']?.toString() ?? '')),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                  child: Text((r['status'] ?? '').toUpperCase(), style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
                                )
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text('Error: $e'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
