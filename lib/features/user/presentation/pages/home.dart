import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:green/features/user/presentation/pages/profile.dart';
import 'request.dart';
import 'my_requests.dart';

class UserHome extends StatefulWidget {
  const UserHome({super.key});
  static const routeName = "user_home";

  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  int currentIndex = 0;

  final pages = [RequestScreen(), MyRequestsScreen(), ProfileScreen()];

  final titles = const ["اطلب جمع النفايات 🌿", "طلباتي ♻️", "ملفي الشخصي 🌿"];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text(
            titles[currentIndex],
            style: TextStyle(
              color: Colors.white,
              fontSize: 25.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        resizeToAvoidBottomInset: false,
        extendBody: true,
        body: Column(
          children: [
            SizedBox(
              height: 40.h,
              child: Row(
                children: [
                  Expanded(
                    child: Image.asset(
                      'assets/logo1.jpeg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Image.asset(
                      'assets/logo2.jpeg',
                      fit: BoxFit.contain,
                    ),
                  ),
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
          child: const Icon(Icons.add_circle),
          onPressed: () {
            setState(() => currentIndex = 0);
          },
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8.w,
          child: SizedBox(
            height: 60.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.person,
                    color: currentIndex == 2 ? Colors.green : Colors.grey,
                  ),
                  onPressed: () => setState(() => currentIndex = 2),
                ),
                SizedBox(width: 30.w), // مكان الـ FAB
                IconButton(
                  icon: Icon(
                    Icons.list_alt,
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
