import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../widgets/request_card.dart';

class AdminRequestsPage extends StatelessWidget {
  const AdminRequestsPage({super.key});

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

              if (picked != null) {
                context.read<AdminCubit>().filterRequestsByDay(picked);
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state.isLoadingRequests) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.requests.isEmpty) {
            return const Center(child: Text("لا يوجد طلبات"));
          }

          return ListView.builder(
            itemCount: state.requests.length,
            itemBuilder: (context, i) {
              final r = state.requests[i];

              return RequestCard(
                name: r.name,
                wasteType: r.wasteType,
                phone: r.phone,
                nationalId: r.nationalId,
                status: r.status.name,
                onApprove: () {
                  context.read<AdminCubit>().approve(r.requestId, r.userId);
                },
              );
            },
          );
        },
      ),
    );
  }
}
