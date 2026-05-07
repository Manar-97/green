import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../widgets/request_card.dart';

class AdminRequestsPage extends StatefulWidget {
  const AdminRequestsPage({super.key});

  @override
  State<AdminRequestsPage> createState() => _AdminRequestsPageState();
}

class _AdminRequestsPageState extends State<AdminRequestsPage> {
  @override
  void initState() {
    super.initState();

    context.read<AdminCubit>().startRealtime(); // ✅ أهم سطر
  }

  void _confirmDelete(BuildContext context, String requestId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("حذف الطلب"),
        content: const Text("هل أنت متأكد أنك تريد حذف الطلب؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AdminCubit>().deleteRequest(requestId);
            },
            child: const Text(
              "حذف",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("الطلبات"),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              context.read<AdminCubit>().setFilterDay(picked);
            },
          ),
        ],
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state.isLoadingRequests) {
            return const Center(child: CircularProgressIndicator());
          }

          // ✨ FILTER (UI ONLY)
          final requests = state.selectedDay == null
              ? state.requests
              : state.requests.where((r) {
                  final date = DateTime.parse(r.requestDate);

                  return date.year == state.selectedDay!.year &&
                      date.month == state.selectedDay!.month &&
                      date.day == state.selectedDay!.day;
                }).toList();
          if (state.requests.isEmpty) {
            return const Center(child: Text("لا يوجد طلبات"));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, i) {
              final r = requests[i];

              return RequestCard(
                name: r.name,
                wasteType: r.wasteType,
                phone: r.phone,
                requestDate: r.requestDate,
                status: r.status.name,
                onApprove: () {
                  context.read<AdminCubit>().approve(r.requestId, r.userId);
                },
                onDelete: () {
                  _confirmDelete(context, r.requestId);
                },
              );
            },
          );
        },
      ),
    );
  }
}
