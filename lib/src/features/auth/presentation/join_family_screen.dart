import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class JoinFamilyScreen extends ConsumerStatefulWidget {
  const JoinFamilyScreen({super.key});

  @override
  ConsumerState<JoinFamilyScreen> createState() => _JoinFamilyScreenState();
}

class _JoinFamilyScreenState extends ConsumerState<JoinFamilyScreen> {
  final _codeController = TextEditingController();
  final _familyNameController = TextEditingController();
  bool _isLoading = false;
  bool _isCreatingFamily = false;

  Future<void> _joinFamily() async {
    if (_codeController.text.trim().isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      // Supabase RPC fonksiyonunu çağır
      await Supabase.instance.client.rpc('join_family_by_code', params: {
        'invite_code_input': _codeController.text.trim().toUpperCase(),
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aileye başarıyla katıldın! 🎉'),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/hub');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _createFamily() async {
    if (_familyNameController.text.trim().isEmpty) return;
    
    setState(() => _isLoading = true);
    try {
      // Yeni aile oluştur
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      
      // Random invite code oluştur
      final inviteCode = 'FAM${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
      
      // Aileyi oluştur
      final response = await Supabase.instance.client
          .from('families')
          .insert({
            'name': _familyNameController.text.trim(),
            'invite_code': inviteCode,
          })
          .select()
          .single();
      
      final familyId = response['id'];
      
      // Kullanıcının profilini güncelle
      await Supabase.instance.client
          .from('profiles')
          .update({'family_id': familyId, 'role': 'admin'})
          .eq('id', userId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Aile oluşturuldu! Davet kodu: $inviteCode'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
        context.go('/hub');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _familyNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Aile Kurulumu"),
        backgroundColor: const Color(0xFFE8B5CF),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8B5CF).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.family_restroom,
                  size: 50,
                  color: Color(0xFFE8B5CF),
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                _isCreatingFamily ? "Yeni Aile Oluştur" : "Aileye Katıl",
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _isCreatingFamily 
                  ? "Aile adını gir ve diğerlerini davet et"
                  : "Yöneticiden aldığın davet kodunu gir",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 32),
              
              // Form alanı
              if (_isCreatingFamily) ...[
                TextField(
                  controller: _familyNameController,
                  decoration: InputDecoration(
                    labelText: "Aile Adı",
                    hintText: "Örn: Yılmaz Ailesi",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.home, color: Color(0xFFE8B5CF)),
                  ),
                ),
              ] else ...[
                TextField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: "Davet Kodu",
                    hintText: "Örn: FAM12345",
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.vpn_key, color: Color(0xFFE8B5CF)),
                  ),
                ),
              ],
              
              const SizedBox(height: 24),
              
              // Ana buton
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading 
                    ? null 
                    : (_isCreatingFamily ? _createFamily : _joinFamily),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE8B5CF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        _isCreatingFamily ? "Aile Oluştur" : "Katıl",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Toggle butonu
              TextButton(
                onPressed: () => setState(() => _isCreatingFamily = !_isCreatingFamily),
                child: Text(
                  _isCreatingFamily 
                    ? "Zaten bir aile var mı? Katıl →" 
                    : "Yeni bir aile oluştur →",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
