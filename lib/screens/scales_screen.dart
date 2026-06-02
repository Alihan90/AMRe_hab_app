import 'package:flutter/material.dart';
import '../models/patient.dart';
import 'scale_ims_page.dart';
import 'scale_mrc_page.dart';
import 'scale_rass_page.dart';
import 'scale_cpax_page.dart';
import 'scale_cpot_page.dart';
import 'scale_stroke_pages.dart'; // Містить MoCA, Rancho, RMI, BBS, Ashworth
import 'scale_mwt_page.dart'; // Містить 6MWT + Borg

class ScalesScreen extends StatelessWidget {
  final Patient? patient;
  const ScalesScreen({super.key, this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(patient == null ? "Інструментальні Шкали" : "Оцінка: ${patient!.fullName}", 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader("🧠 ВІТ та Рання мобільність (Седація, Біль, Рух)"),
          _buildCard(context, "Шкала мобільності IMS", "Оцінка мобільності в реанімації від ліжка до ходьби (0–7 балів).", Colors.green, 
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => ScaleImsPage(patient: patient)))),
          _buildCard(context, "Індекс CPAX", "Клінічний профіль мобільності ВІТ (дихання, кушетка, баланс, сила) (0–50 балів).", Colors.green, 
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => ScaleCpaxPage(patient: patient)))),
          _buildCard(context, "Сила м'язів MRC-SumScore", "Мануальне тестування 6 симетричних груп м'язів для діагностики ICU-AW (0–60 балів).", Colors.blue, 
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => ScaleMrcPage(patient: patient)))),
          _buildCard(context, "Седація RASS", "Контроль рівня свідомості та глибини седації перед початком руху (від -5 до +4).", Colors.purple, 
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => ScaleRassPage(patient: patient)))),
          _buildCard(context, "Біль CPOT", "Поведенічний індикатор болю у критичних пацієнтів (вираз обличчя, рухи, ШВЛ) (0–8 балів).", Colors.red, 
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => ScaleCpotPage(patient: patient)))),

          _buildSectionHeader("⚡ Неврологія / Інсульт (Когніція, Баланс, Спастика)"),
          _buildCard(context, "MoCA Тест", "Монреальська шкала оцінки когнітивних функцій (увага, пам'ять, праксис) (0–30 балів).", Colors.orange, 
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => NeuroScalePage(type: "MoCA", patient: patient)))),
          _buildCard(context, "Рівні когнітивного відновлення Rancho Los Amigos", "Оцінка поведінкової та інтелектуальної готовності до реабілітації (I–VIII рівні).", Colors.orange, 
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => NeuroScalePage(type: "Rancho", patient: patient)))),
          _buildCard(context, "Індекс мобільності Рівермід (RMI)", "Послідовна оцінка рухової активності та самостійності в побуті (0–15 балів).", Colors.teal, 
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => NeuroScalePage(type: "Rivermead", patient: patient)))),
          _buildCard(context, "Шкала балансу Берга (BBS)", "Комплексна оцінка статичного та динамічного балансу для прогнозу ризику падінь (0–56 балів).", Colors.teal, 
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => NeuroScalePage(type: "Berg", patient: patient)))),
          _buildCard(context, "Модифікована шкала Ашворт (MAS)", "Оцінка м'язового тонусу та ступеня спастичності суглобів (0, 1, 1+, 2, 3, 4).", Colors.indigo, 
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => NeuroScalePage(type: "Ashworth", patient: patient)))),

          _buildSectionHeader("🫁 Кардіо-респіраторна система"),
          _buildCard(context, "Тест 6-хвилинної ходьби (6MWT) + Шкала Борга", "Розрахунок належної відстані за Enright, оцінка задишки та толерантності до навантаження.", Colors.deepOrange, 
            () => Navigator.push(context, MaterialPageRoute(builder: (context) => ScaleMwtPage(patient: patient)))),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8, left: 4),
      child: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
    );
  }

  Widget _buildCard(BuildContext context, String title, String desc, Color color, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(Icons.analytics_outlined, color: color, size: 20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(desc, style: const TextStyle(fontSize: 12, color: Colors.black54)),
        trailing: const Icon(Icons.chevron_right, size: 18),
        onTap: onTap,
      ),
    );
  }
}
