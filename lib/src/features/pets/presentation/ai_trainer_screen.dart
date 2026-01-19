import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// AI Köpek Eğitmeni Ekranı - Chat arayüzü mock
class AITrainerScreen extends StatefulWidget {
  const AITrainerScreen({super.key});

  @override
  State<AITrainerScreen> createState() => _AITrainerScreenState();
}

class _AITrainerScreenState extends State<AITrainerScreen> {
  final _controller = TextEditingController();
  final List<_ChatMessage> _messages = [
    _ChatMessage(text: 'Merhaba! Ben AI Köpek Eğitmeni. Size nasıl yardımcı olabilirim?', isAI: true),
    _ChatMessage(text: 'Köpeğim sürekli havlıyor, ne yapmalıyım?', isAI: false),
    _ChatMessage(text: 'Golden Retriever cinsi köpeklerde havlama genellikle dikkat çekme veya heyecan kaynaklıdır.\n\n🎯 Önerilen Eğitim:\n1. "Sessiz" komutu öğretin\n2. Havlamaya neden olan tetikleyicileri belirleyin\n3. Olumlu pekiştirme kullanın\n4. Günlük egzersiz süresini artırın\n\n⏱️ Sabırlı olun, sonuçlar 2-3 haftada görülür.', isAI: true),
  ];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text: _controller.text.trim(), isAI: false));
      _controller.clear();
    });
    // Simüle AI yanıtı
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _messages.add(_ChatMessage(text: 'Bu konuda size yardımcı olabilirim. Köpeğinizin yaşını ve cinsini belirtir misiniz? Daha detaylı bir eğitim planı oluşturabilirim. 🐕', isAI: true));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
      title: Row(children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('AI Eğitmen', style: AppTextStyles.cardTitle.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          Text('Online', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
        ]),
      ]),
    ),
    body: Column(children: [
      // Chat Messages
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(16), reverse: false,
          itemCount: _messages.length,
          itemBuilder: (_, i) => _ChatBubble(message: _messages[i]).animate(delay: Duration(milliseconds: 50 * i)).fadeIn().slideY(begin: 0.1, end: 0),
        ),
      ),
      // Input Field
      Container(
        padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        decoration: BoxDecoration(color: AppColors.surface, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))]),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Sorunuzu yazın...',
                filled: true, fillColor: AppColors.background,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
            ),
          ),
        ]),
      ),
    ]),
  );
}

class _ChatMessage {
  final String text;
  final bool isAI;
  _ChatMessage({required this.text, required this.isAI});
}

class _ChatBubble extends StatelessWidget {
  final _ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isAI = message.isAI;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isAI) ...[
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.smart_toy_rounded, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isAI ? AppColors.surface : AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20), topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isAI ? 4 : 20), bottomRight: Radius.circular(isAI ? 20 : 4),
                ),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
              ),
              child: Text(message.text, style: TextStyle(color: isAI ? AppColors.textPrimary : Colors.white, fontSize: 14, height: 1.4)),
            ),
          ),
        ],
      ),
    );
  }
}
