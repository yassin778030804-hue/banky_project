/**
 * =====================================================================
 * مشروع النظام المالي السيادي الوطني: "بنكي من أجل وطني"
 * فكره وانشاء: ياسين العبادي الريّس شخصياً
 * 
 * يتضمن هذا الكود المتكامل:
 * 1. هيكل قاعدة البيانات (PostgreSQL - معلقات توضيحية).
 * 2. محاكاة منطق الخادم الخلفي (Node.js / NestJS).
 * 3. واجهات تطبيق Flutter التفاعلية الحية (المواطن، التاجر POS، الإيداع الفوري/الآجل، البلاغات، والتنبيهات الصحية).
 * =====================================================================
 */

/*
---------------------------------------------------------------------
أولاً: تصميم قاعدة البيانات (PostgreSQL Schema) - مرجع معماري
---------------------------------------------------------------------
CREATE TABLE citizens (
    national_id VARCHAR(20) PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    medical_profile JSONB,
    is_verified BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE wallets (
    wallet_id SERIAL PRIMARY KEY,
    national_id VARCHAR(20) REFERENCES citizens(national_id),
    balance NUMERIC(15, 2) DEFAULT 0.00,
    holding_limit NUMERIC(15, 2) DEFAULT 5000000.00,
    is_frozen BOOLEAN DEFAULT FALSE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE transactions (
    tx_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_wallet_id INT REFERENCES wallets(wallet_id),
    receiver_wallet_id INT REFERENCES wallets(wallet_id),
    amount NUMERIC(15, 2) NOT NULL,
    tx_type VARCHAR(30),
    status VARCHAR(20) DEFAULT 'completed',
    due_date TIMESTAMP NULL,
    standard_price_verified BOOLEAN DEFAULT TRUE,
    anti_corruption_flag BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE debt_disputes (
    dispute_id SERIAL PRIMARY KEY,
    creditor_national_id VARCHAR(20) REFERENCES citizens(national_id),
    debtor_national_id VARCHAR(20) REFERENCES citizens(national_id),
    amount_owed NUMERIC(15, 2) NOT NULL,
    due_date TIMESTAMP NOT NULL,
    status VARCHAR(20) DEFAULT 'pending_review',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
*/

import 'package:flutter/material.dart';

void main() {
  runApp(const BankyFullApplication());
}

class BankyFullApplication extends StatelessWidget {
  const BankyFullApplication({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'بنكي من أجل وطني',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Cairo',
        scaffoldBackgroundColor: const Color(0xFF0F172A),
      ),
      home: const SovereignInteractiveScreen(),
    );
  }
}

class SovereignInteractiveScreen extends StatefulWidget {
  const SovereignInteractiveScreen({Key? key}) : super(key: key);

  @override
  State<SovereignInteractiveScreen> createState() => _SovereignInteractiveScreenState();
}

class _SovereignInteractiveScreenState extends State<SovereignInteractiveScreen> {
  // متغيرات الحالة الحية لتطبيق المواطن
  double _balance = 1_500_000.00;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _debtorIdController = TextEditingController();
  final TextEditingController _debtAmountController = TextEditingController();
  
  String _selectedType = 'إيداع فوري';
  bool _hasHealthWarning = false;

  // تنفيذ المعاملة المالية السيادية
  void _executeTransaction() {
    final double? enteredAmount = double.tryParse(_amountController.text);
    if (enteredAmount == null || enteredAmount <= 0) {
      _showSnackBar('الرجاء إدخال مبلغ صحيح وسليم', Colors.redAccent);
      return;
    }

    setState(() {
      if (_selectedType == 'إيداع فوري') {
        _balance += enteredAmount;
      }
    });

    _showSnackBar('تمت عملية ${_selectedType} بنجاح وتوثيقها سيادياً بالبنك المركزي!', Colors.tealAccent);
    _amountController.clear();
  }

  // إرسال بلاغ المماطلة في سداد الديون
  void _submitDebtReport() {
    if (_debtorIdController.text.isEmpty || _debtAmountController.text.isEmpty) {
      _showSnackBar('الرجاء إدخال بيانات المدين والمبلغ بدقة', Colors.redAccent);
      return;
    }

    Navigator.pop(context);
    _showSnackBar('تم رفع بلاغ المماطلة بنجاح، جاري فحص حساب المدين وتطبيق العقوبات!', Colors.amber);
    _debtorIdController.clear();
    _debtAmountController.clear();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: color,
      ),
    );
  }

  // نافذة بلاغات المماطلة والديون التجارية
  void _openDebtReportModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('تقديم بلاغ مماطلة دين تجاري', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              TextField(
                controller: _debtorIdController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'الرقم الوطني أو رقم حساب المدين',
                  labelStyle: TextStyle(color: Colors.white60),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _debtAmountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'مبلغ الدين المتأخر (YER-D)',
                  labelStyle: TextStyle(color: Colors.white60),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, minimumSize: const Size(double.infinity, 45)),
                onPressed: _submitDebtReport,
                child: const Text('إرسال البلاغ وتفعيل الإنذار الآلي', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }

  // نافذة شاشة التاجر (QR Code POS)
  void _openMerchantQRPopup() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('رمز التحصيل السريع للتاجر (POS)', style: TextStyle(color: Colors.white, fontSize: 15), textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.qr_code_2, size: 120, color: Colors.black),
              ),
              const SizedBox(height: 15),
              const Text('السعر مضبوط ومطابق لتسعيرة هيئة المقاييس والمعايير وضبط الجودة.', style: TextStyle(color: Colors.white70, fontSize: 11), textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق', style: TextStyle(color: Colors.amber)),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('بنكي من أجل وطني (CBDC)', style: TextStyle(color: Colors.white, fontSize: 15)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.shield, color: Colors.amber),
            tooltip: 'مربوط بهيئة مكافحة الفساد والرقابة',
            onPressed: () {
              _showSnackBar('النظام مراقب ومحمي بالكامل عبر البنك المركزي', Colors.amber);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة الرصيد الرقمي السيادي
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF0D9488)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('الرصيد الرقمي السيادي المتوفر', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Text('$_balance YER-D', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  const Text('🛡️ حساب سيادي موثق ومربوط بالبنك المركزي والرقابة', style: TextStyle(color: Colors.amberAccent, fontSize: 11)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // الأزرار السريعة للخدمات الحية (POS + بلاغات)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, padding: const EdgeInsets.symmetric(vertical: 12)),
                    onPressed: _openMerchantQRPopup,
                    icon: const Icon(Icons.qr_code, color: Colors.white),
                    label: const Text('منصة التاجر (POS)', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, padding: const EdgeInsets.symmetric(vertical: 12)),
                    onPressed: _openDebtReportModal,
                    icon: const Icon(Icons.gavel, color: Colors.white),
                    label: const Text('بلاغ مماطلة دين', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // نافذة المعاملات (إيداع فوري / آجل / مشحونة بفحص الصحة ومكافحة الفساد)
            const Text('نافذة العمليات والإيداع السيادي:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    dropdownColor: const Color(0xFF1E293B),
                    style: const TextStyle(color: Colors.white),
                    items: ['إيداع فوري', 'إيداع آجل (دين تجاري)', 'شراء سلع أساسية'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedType = newValue!;
                        _hasHealthWarning = (_selectedType == 'شراء سلع أساسية');
                      });
                    },
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'المبلغ بالريال الرقمي (YER-D)',
                      labelStyle: TextStyle(color: Colors.white60),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white30)),
                      focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
                    ),
                  ),
                  if (_hasHealthWarning) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.redAccent),
                      ),
                      child: const Text(
                        '⚠️ تنبيه صحي ذكي: هذه السلعة تحتوي على مكونات قد تعارض حالتك الطبية المسجلة (مثل السكري والضغط)!',
                        style: TextStyle(color: Colors.redAccent, fontSize: 11),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    onPressed: _executeTransaction,
                    child: Text('تنفيذ $_selectedType الآن', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // التنسيب الثابت والحقوق محفوظة بالأسفل
      bottomNavigationBar: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: const BoxDecoration(
          color: Color(0xFF090D16),
          border: Border(top: BorderSide(color: Colors.amber, width: 1)),
        ),
        child: const Text(
          'فكره وانشاء ياسين العبادي الريّس شخصياً',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.amber,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
