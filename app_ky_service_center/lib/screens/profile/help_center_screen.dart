import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../l10n/app_localizations.dart';
import '../../services/theme_service.dart';
import '../../theme/app_fonts.dart';
import '../../widgets/circle_back_button.dart';
import '../support/support_chat_screen.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  String _query = '';
  int? _expandedIndex;

  static const _brandBlue = Color(0xFF4A88F7);
  static const _brandBlueDark = Color(0xFF2563EB);

  bool get _isDark => ThemeService.instance.isDark(context);
  Color get _bg => _isDark ? const Color(0xFF0F172A) : const Color(0xFFEEF6FD);
  Color get _surface => _isDark ? const Color(0xFF161B22) : Colors.white;
  Color get _border => _isDark ? const Color(0xFF2B3442) : const Color(0xFFE6ECF5);
  Color get _textPrimary => _isDark ? const Color(0xFFE6EDF7) : const Color(0xFF111827);
  Color get _textMuted => _isDark ? const Color(0xFF97A2B5) : const Color(0xFF6B7280);

  final List<_HelpCategory> _categories = const [
    _HelpCategory(icon: HugeIcons.strokeRoundedShippingTruck01, label: 'Orders & Shipping', labelKm: 'ការបញ្ជាទិញ និងដឹក', color: Color(0xFF3B82F6)),
    _HelpCategory(icon: HugeIcons.strokeRoundedReverseWithdrawal01, label: 'Returns & Refunds', labelKm: 'ការប្រគល់ និងសង', color: Color(0xFF10B981)),
    _HelpCategory(icon: HugeIcons.strokeRoundedCreditCard, label: 'Payments', labelKm: 'ការទូទាត់', color: Color(0xFF8B5CF6)),
    _HelpCategory(icon: HugeIcons.strokeRoundedUser, label: 'My Account', labelKm: 'គណនី', color: Color(0xFFF59E0B)),
    _HelpCategory(icon: HugeIcons.strokeRoundedSmartPhone01, label: 'Products', labelKm: 'ផលិតផល', color: Color(0xFFEC4899)),
    _HelpCategory(icon: HugeIcons.strokeRoundedWrench01, label: 'Repair Service', labelKm: 'សេវាជួសជុល', color: Color(0xFF06B6D4)),
  ];

  final List<_Faq> _allFaqs = const [
    _Faq(
      question: 'How do I track my order?',
      questionKm: 'តើខ្ញុំតាមដានការបញ្ជាទិញបានយ៉ាងដូចម្ដេច?',
      answer: 'You can track your order in real-time from the Orders tab. Tap any order to see its current status, estimated delivery time, and live map tracking. You will also receive push notifications at every stage.',
      answerKm: 'អ្នកអាចតាមដានការបញ្ជាទិញក្នុងពេលវេលាជាក់ស្ដែងពីផ្ទាំង "ការបញ្ជាទិញ"។ ចុចលើការបញ្ជាទិញណាមួយដើម្បីមើលស្ថានភាពបច្ចុប្បន្ន ពេលវេលាដឹកជញ្ជូន និងផែនទីតាមដាន។',
      category: 'Orders & Shipping',
    ),
    _Faq(
      question: 'What payment methods are accepted?',
      questionKm: 'តើវិធីសាស្ត្រទូទាត់ណាខ្លះដែលអាចប្រើបាន?',
      answer: 'We accept Bakong QR, major credit/debit cards (Visa, Mastercard), and Cash on Delivery. All online transactions are encrypted and processed securely.',
      answerKm: 'យើងទទួលយក Bakong QR, កាតឥណទាន/ឥណពន្ធ (Visa, Mastercard) និងការទូទាត់ពេលទទួលទំនិញ។ ប្រតិបត្តិការអនឡាញទាំងអស់ត្រូវបានអ៊ីនគ្រីប។',
      category: 'Payments',
    ),
    _Faq(
      question: 'How do I return a product?',
      questionKm: 'តើខ្ញុំប្រគល់ផលិតផលបានដោយរបៀបណា?',
      answer: 'Returns are accepted within 7 days of delivery for unused items in original packaging. Go to Orders → select your order → tap "Request Return". Our team will arrange a pickup within 24 hours.',
      answerKm: 'ការប្រគល់ទំនិញត្រូវបានទទួលក្នុងរយៈពេល ៧ ថ្ងៃក្រោយការដឹកជញ្ជូន សម្រាប់ទំនិញដែលមិនទាន់ប្រើ។ ចូលទៅ ការបញ្ជាទិញ → ជ្រើសការបញ្ជាទិញ → ចុច "សំណើប្រគល់"។',
      category: 'Returns & Refunds',
    ),
    _Faq(
      question: 'How long does delivery take?',
      questionKm: 'ការដឹកជញ្ជូនចំណាយពេលប៉ុន្មាន?',
      answer: 'Standard delivery within Phnom Penh takes 1–2 business days. Provincial deliveries take 3–5 business days. Express same-day delivery is available for select areas.',
      answerKm: 'ការដឹកជញ្ជូនក្នុងភ្នំពេញចំណាយ ១–២ ថ្ងៃធ្វើការ។ ការដឹកតាមបណ្ដាខេត្តចំណាយ ៣–៥ ថ្ងៃធ្វើការ។ ការដឹកដល់ថ្ងៃនៃការបញ្ជាទិញក៏មានផងដែរ សម្រាប់តំបន់ដែលបានជ្រើស។',
      category: 'Orders & Shipping',
    ),
    _Faq(
      question: 'How do I cancel an order?',
      questionKm: 'តើខ្ញុំអាចបោះបង់ការបញ្ជាទិញបានដោយរបៀបណា?',
      answer: 'Orders can be cancelled before they are shipped. Go to Orders → select your order → tap "Cancel Order". If the order is already in transit, please contact our support team.',
      answerKm: 'ការបញ្ជាទិញអាចត្រូវបានបោះបង់មុនពេលដឹកជញ្ជូន។ ចូល ការបញ្ជាទិញ → ជ្រើសការបញ្ជាទិញ → ចុច "បោះបង់ការបញ្ជាទិញ"។',
      category: 'Orders & Shipping',
    ),
    _Faq(
      question: 'How do I book a repair service?',
      questionKm: 'តើខ្ញុំកក់សេវាជួសជុលបានដោយរបៀបណា?',
      answer: 'Tap the Repair tab, select your device type, describe the issue, and submit. A technician will review your request within 2 hours and confirm your appointment.',
      answerKm: 'ចុចផ្ទាំង "ជួសជុល" ជ្រើសប្រភេទឧបករណ៍ ពណ៌នាបញ្ហា ហើយដាក់ស្នើ។ បច្ចេកទេសករនឹងពិនិត្យ​សំណើក្នុងរយៈ ២ ម៉ោង។',
      category: 'Repair Service',
    ),
    _Faq(
      question: 'Can I change my delivery address?',
      questionKm: 'តើខ្ញុំអាចប្ដូរអាសយដ្ឋានដឹកជញ្ជូនបានទេ?',
      answer: 'You can change your delivery address before the order is dispatched. Contact our support chat immediately and provide your order number and the new address.',
      answerKm: 'អ្នកអាចប្ដូរអាសយដ្ឋានមុនពេលការបញ្ជាទិញត្រូវបានបញ្ជូន។ ទំនាក់ទំនងជំនួយរបស់យើងភ្លាមៗ ហើយផ្ដល់លេខការបញ្ជាទិញ និងអាសយដ្ឋានថ្មី។',
      category: 'Orders & Shipping',
    ),
    _Faq(
      question: 'Is my payment information secure?',
      questionKm: 'តើព័ត៌មានទូទាត់របស់ខ្ញុំមានសុវត្ថិភាពទេ?',
      answer: 'Yes. We use industry-standard TLS encryption for all transactions. We never store your full card details on our servers. All payments are processed through certified payment gateways.',
      answerKm: 'បាទ/ចាស។ យើងប្រើការអ៊ីនគ្រីប TLS ស្ដង់ដារឧស្សាហកម្ម សម្រាប់ប្រតិបត្តិការទាំងអស់។ យើងមិនដែលរក្សាទុកព័ត៌មានកាតពេញលេញរបស់អ្នក។',
      category: 'Payments',
    ),
  ];

  _HelpCategory _categoryFor(String label) => _categories.firstWhere(
        (c) => c.label == label,
        orElse: () => _categories.first,
      );

  List<_Faq> get _filteredFaqs {
    if (_query.isEmpty) return _allFaqs;
    final q = _query.toLowerCase();
    return _allFaqs.where((f) =>
      f.question.toLowerCase().contains(q) ||
      f.answer.toLowerCase().contains(q) ||
      f.questionKm.contains(q) ||
      f.answerKm.contains(q),
    ).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isKhmer = l.isKhmer;

    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        slivers: [
          _buildHeader(isKhmer),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
              child: _buildSearchBar(isKhmer),
            ),
          ),
          if (_query.isEmpty) ...[
            SliverToBoxAdapter(child: _sectionTitle(isKhmer ? 'ប្រភេទជំនួយ' : 'Browse by Category', topPad: 24)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.0,
                ),
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _categoryCard(_categories[i], isKhmer),
                  childCount: _categories.length,
                ),
              ),
            ),
          ],
          SliverToBoxAdapter(
            child: _sectionTitle(
              _query.isEmpty
                  ? (isKhmer ? 'សំណួរសួរញឹកញាប់' : 'Frequently Asked Questions')
                  : (isKhmer ? 'លទ្ធផលស្វែងរក' : 'Search Results (${_filteredFaqs.length})'),
              topPad: 24,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => _faqItem(_filteredFaqs[i], i, isKhmer),
                childCount: _filteredFaqs.length,
              ),
            ),
          ),
          if (_query.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 40),
              sliver: SliverToBoxAdapter(child: _contactCard(isKhmer)),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isKhmer) {
    return SliverAppBar(
      expandedHeight: 160,
      collapsedHeight: 60,
      pinned: true,
      backgroundColor: _isDark ? const Color(0xFF0F172A) : _brandBlue,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleBackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF60A5FA)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // decorative circles
              Positioned(right: -30, top: -30,
                child: Container(width: 140, height: 140,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.07)))),
              Positioned(right: 60, bottom: -20,
                child: Container(width: 90, height: 90,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06)))),
              Padding(
                padding: const EdgeInsets.fromLTRB(56, 60, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      isKhmer ? 'មជ្ឈមណ្ឌលជំនួយ' : 'Help Center',
                      style: kFont(context,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isKhmer ? 'តើយើងអាចជួយអ្នកបានដោយរបៀបណា?' : 'How can we help you today?',
                      style: kFont(context,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isKhmer) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _brandBlue.withValues(alpha: _isDark ? 0.12 : 0.10),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() {
          _query = v.trim();
          _expandedIndex = null;
        }),
        style: kFont(context, fontSize: 14, fontWeight: FontWeight.w500, color: _textPrimary),
        decoration: InputDecoration(
          hintText: isKhmer ? 'ស្វែងរកជំនួយ...' : 'Search for help...',
          hintStyle: kFont(context, fontSize: 14, color: _textMuted),
          prefixIcon: Icon(HugeIcons.strokeRoundedSearch01, color: _textMuted, size: 20),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: Icon(HugeIcons.strokeRoundedCancel01, color: _textMuted, size: 18),
                  onPressed: () => setState(() {
                    _searchCtrl.clear();
                    _query = '';
                  }),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, {double topPad = 0}) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18, topPad, 18, 12),
      child: Text(
        text,
        style: kFont(context,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: _textPrimary,
        ),
      ),
    );
  }

  Widget _categoryCard(_HelpCategory cat, bool isKhmer) {
    final label = isKhmer ? cat.labelKm : cat.label;
    return Material(
      color: _surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() {
          _searchCtrl.text = cat.label;
          _query = cat.label;
          _expandedIndex = null;
        }),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: cat.color.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cat.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(cat.icon, color: cat.color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: kFont(context,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _faqItem(_Faq faq, int index, bool isKhmer) {
    final isOpen = _expandedIndex == index;
    final question = isKhmer ? faq.questionKm : faq.question;
    final answer = isKhmer ? faq.answerKm : faq.answer;
    final cat = _categoryFor(faq.category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => setState(() {
            _expandedIndex = isOpen ? null : index;
          }),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isOpen ? _brandBlue.withValues(alpha: 0.4) : _border,
                width: isOpen ? 1.5 : 1,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: cat.color.withValues(alpha: isOpen ? 0.16 : 0.10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          cat.icon,
                          size: 16,
                          color: cat.color,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          question,
                          style: kFont(context,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isOpen ? _brandBlue : _textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: isOpen ? 0.5 : 0,
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          HugeIcons.strokeRoundedArrowDown01,
                          color: isOpen ? _brandBlue : _textMuted,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox.shrink(),
                  secondChild: Column(
                    children: [
                      Divider(height: 1, color: _border),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(58, 12, 16, 16),
                        child: Text(
                          answer,
                          style: kFont(context,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: _textMuted,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                  crossFadeState: isOpen
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _contactCard(bool isKhmer) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1D4ED8), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _brandBlueDark.withValues(alpha: 0.30),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(HugeIcons.strokeRoundedHeadset, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isKhmer ? 'នៅតែត្រូវការជំនួយ?' : 'Still need help?',
                    style: kFont(context,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    isKhmer ? 'ក្រុមការងារ ២៤/៧' : 'Our team is 24/7 ready',
                    style: kFont(context,
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.80),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _contactButton(
                  icon: HugeIcons.strokeRoundedMessage01,
                  label: isKhmer ? 'ជជែក' : 'Live Chat',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const SupportChatScreen(
                        contextType: 'general',
                        subject: 'Help Center',
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _contactButton(
                  icon: HugeIcons.strokeRoundedMail01,
                  label: isKhmer ? 'អ៊ីមែល' : 'Email Us',
                  onTap: () => _showContactDialog(isKhmer),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _contactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: kFont(context,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showContactDialog(bool isKhmer) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          isKhmer ? 'ទំនាក់ទំនងតាមអ៊ីមែល' : 'Contact via Email',
          style: kFont(context, fontSize: 16, fontWeight: FontWeight.w700, color: _textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(HugeIcons.strokeRoundedMail01, color: _brandBlue, size: 48),
            const SizedBox(height: 12),
            Text(
              'support@kyservicecenter.com',
              style: kFont(context, fontSize: 14, fontWeight: FontWeight.w600, color: _brandBlue),
            ),
            const SizedBox(height: 8),
            Text(
              isKhmer
                  ? 'ក្រុមការងាររបស់យើងនឹងឆ្លើយតបក្នុងរយៈ ២-៤ ម៉ោង'
                  : 'Our team typically responds within 2–4 hours.',
              textAlign: TextAlign.center,
              style: kFont(context, fontSize: 13, color: _textMuted, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              isKhmer ? 'យល់ព្រម' : 'Got it',
              style: kFont(context, fontSize: 14, fontWeight: FontWeight.w600, color: _brandBlue),
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpCategory {
  const _HelpCategory({
    required this.icon,
    required this.label,
    required this.labelKm,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String labelKm;
  final Color color;
}

class _Faq {
  const _Faq({
    required this.question,
    required this.questionKm,
    required this.answer,
    required this.answerKm,
    required this.category,
  });
  final String question;
  final String questionKm;
  final String answer;
  final String answerKm;
  final String category;
}
