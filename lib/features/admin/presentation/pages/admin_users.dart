import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../widgets/export_button.dart';
import '../widgets/user_card.dart';
import 'export_excel.dart';

class AdminUsersPage extends StatelessWidget {
  const AdminUsersPage({super.key});

  Future<void> exportAndShare(BuildContext context) async {
    final users = context.read<AdminCubit>().state.users;

    print("USERS COUNT: ${users.length}");

    if (users.isEmpty) {
      showAppDialog(
        context,
        title: "تنبيه ⚠️",
        message: "لا يوجد بيانات للتصدير",
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: Colors.green)),
    );

    try {
      final file = await ExcelService.exportUsersFile(users);

      Navigator.pop(context);

      showAppDialog(
        context,
        title: "نجاح 🎉",
        message: "تم تصدير الملف بنجاح",
        isSuccess: true,
      );

      await Future.delayed(const Duration(milliseconds: 400));

      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (_) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.open_in_new),
                  title: const Text("فتح الملف"),
                  onTap: () => OpenFile.open(file.path),
                ),
                ListTile(
                  leading: const Icon(Icons.share),
                  title: const Text("مشاركة"),
                  onTap: () => Share.shareXFiles([XFile(file.path)]),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      Navigator.pop(context);

      showAppDialog(context, title: "خطأ ❌", message: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("المستخدمين")),

      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state.isLoadingUsers && state.users.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.users.isEmpty) {
            return const Center(child: Text("لا يوجد مستخدمين"));
          }

          return Stack(
            children: [
              ListView.builder(
                itemCount: state.users.length,
                itemBuilder: (context, i) {
                  final u = state.users[i];
                  return UserCard(name: u.name, phone: u.phone, score: u.score);
                },
              ),
              Positioned(
                bottom: 30.h,
                left: 20.w,
                right: 20.w,
                child: ExportButton(onTap: () => exportAndShare(context)),
              ),
            ],
          );
        },
      ),
    );
  }
}
