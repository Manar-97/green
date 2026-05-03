import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
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

  Widget buildExportButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        exportAndShare(context);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [Colors.green, Colors.lightGreen],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.download, color: Colors.white),
            SizedBox(width: 8),
            Text(
              "تصدير Excel",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("المستخدمين")),

      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state.isLoadingUsers) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.users.isEmpty) {
            return const Center(child: Text("لا يوجد مستخدمين"));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: state.users.length,
                  itemBuilder: (context, i) {
                    final u = state.users[i];

                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green,
                          child: Text(u.name[0]),
                        ),
                        title: Text(u.name),
                        subtitle: Text(u.phone),
                        trailing: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text("⭐ ${u.score}"),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // 👇 الزرار تحت الليست
              SafeArea(child: buildExportButton(context)),
              SizedBox(height: 20.h),
            ],
          );
        },
      ),
    );
  }
}
