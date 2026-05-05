import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as i;
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

  String getStatusText(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return "قيد المراجعة ⏳";
      case RequestStatus.approved:
        return "تم التنفيذ ✔️";
      default:
        return "غير معروف";
    }
  }

  Color getStatusColor(RequestStatus status) {
    switch (status) {
      case RequestStatus.pending:
        return Colors.orange;
      case RequestStatus.approved:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String formatDate(DateTime date) {
    return i.DateFormat('yyyy/MM/dd - hh:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: BlocBuilder<RequestCubit, RequestState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.requests.isEmpty) {
              return const Center(child: Text("لا يوجد طلبات بعد 🌱"));
            }

            return ListView.builder(
              padding: EdgeInsets.all(12.w),
              itemCount: state.requests.length,
              itemBuilder: (context, i) {
                final req = state.requests[i];

                return Card(
                  elevation: 3,
                  margin: EdgeInsets.only(bottom: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.recycling, color: Colors.green),

                    title: Text(
                      req.wasteType,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      formatDate(DateTime.parse(req.requestDate)),
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    trailing: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: getStatusColor(req.status).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        getStatusText(req.status),
                        style: TextStyle(
                          color: getStatusColor(req.status),
                          fontWeight: FontWeight.bold,
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
