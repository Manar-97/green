import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../auth/presentation/pages/login.dart';
import '../cubit/admin_cubit.dart';
import 'admin_request.dart';
import 'admin_users.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});
  static const String routeName = "admin";

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int currentIndex = 0;

  final pages = const [AdminRequestsPage(), AdminUsersPage()];

  final titles = const ["الطلبات ♻️", "المستخدمين 👥"];

  @override
  void initState() {
    super.initState();
    final cubit = context.read<AdminCubit>();
    cubit.loadInitialData();
    cubit.startRealtime();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBody: false,
        appBar: AppBar(
          title: Text(
            'الطريق الأخضر',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.green,
          actions: [
            IconButton(
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                Navigator.pushReplacementNamed(context, Login.routeName);
              },
              icon: const Icon(Icons.logout, color: Colors.white),
            ),
          ],
        ),

        body: Column(
          children: [
            SizedBox(
              height: 40,
              child: Row(
                children: [
                  Image.asset('assets/logo1.jpeg'),
                  Image.asset('assets/logo2.jpeg'),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xffe8f5e9), Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: IndexedStack(index: currentIndex, children: pages),
              ),
            ),
          ],
        ),

        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.green,
          child: const Icon(Icons.eco),
          onPressed: () => setState(() => currentIndex = 0),
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.assignment,
                    color: currentIndex == 0 ? Colors.green : Colors.grey,
                  ),
                  onPressed: () => setState(() => currentIndex = 0),
                ),
                const SizedBox(width: 30),
                IconButton(
                  icon: Icon(
                    Icons.people,
                    color: currentIndex == 1 ? Colors.green : Colors.grey,
                  ),
                  onPressed: () => setState(() => currentIndex = 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
