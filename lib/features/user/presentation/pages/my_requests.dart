import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/request_dm.dart';
import '../cubit/request_cubit.dart';
import '../cubit/request_state.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        context.read<RequestCubit>().fetchRequests(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: const Text("طلباتي ♻️"),
          backgroundColor: Colors.green,
          centerTitle: true,
        ),
        body: BlocBuilder<RequestCubit, RequestState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.requests.isEmpty) {
              return const Center(child: Text("لا يوجد طلبات بعد 🌱"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.requests.length,
              itemBuilder: (context, i) {
                final req = state.requests[i];

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.recycling, color: Colors.green),

                    title: Text(
                      req.wasteType,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      req.status == RequestStatus.pending
                          ? "قيد المراجعة"
                          : "تم التنفيذ ✔️",
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: req.status == RequestStatus.pending
                            ? Colors.orange.shade100
                            : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        req.status.name, // 👈 هنا الحل
                        style: TextStyle(
                          color: req.status == RequestStatus.pending
                              ? Colors.orange
                              : Colors.green,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
