import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});
  static const routeName = "aboutus";

  Widget buildCard({required String title, required String content}) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            Text(content, style: const TextStyle(height: 1.6, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("من نحن", style: TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.green,
        ),
        body: SingleChildScrollView(
          child: Column(
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
              SizedBox(height: 10.h),

              buildCard(
                title: "من نحن",
                content:
                    "جمعية البلد لتنمية المجتمع بالرزقة والمشهرة برقم 1252 لسنة 2010 ونطاقها الجغرافي جمهورية مصر العربية تمتلك القدرة لإدارة أي مشروع تنموي، حيث أن لديها مجلس إدارة مكون من سبعة أفراد من ذوي الخبرة الكبيرة في المجال التنموي وذلك من الخبرة التي اكتسبوها من المشاريع المختلفة التي أسندت للجمعية.",
              ),

              buildCard(
                title: "المشروعات",
                content:
                    "• مشروع إطار للمعاقين\n"
                    "• مشروع نقدر نشارك لتأهيل الفتيات للحصول على فرص عمل ومهارات\n"
                    "• مشروع تشغيل الشباب في حملات النظافة البيئية\n"
                    "• مشروع إعادة تدوير المخلفات الزراعية بالشراكة مع مؤسسة النداء\n"
                    "• مشروع جمع المخلفات الصلبة من الوحدات السكنية والتجارية\n"
                    "• مشاريع تعليمية وصحية وثقافية متنوعة",
              ),

              buildCard(
                title: "تواصل معنا",
                content:
                    "اسم الجمعية: جمعية البلد لتنمية المجتمع بنجع العدوية بالرزقة\n"
                    "رقم الإشهار: 1252 لسنة 2010\n"
                    "نطاق العمل: جمهورية مصر العربية\n"
                    "العنوان: مركز أبوتشت شارع الثانوية العامة – بجوار مدرسة أبوتشت الثانوية العسكرية بنين\n\n"
                    "رئيس مجلس الإدارة:\n"
                    "أ/ أحمد عبدالباقي عثمان\n"
                    "01121871828 - 01090636930\n\n"
                    "المدير التنفيذي:\n"
                    "أ/ رأفت جادالله محمد\n"
                    "01122990095 - 01012015078",
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
