import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AuthService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GetStorage _storage = GetStorage();
  
  // Observable untuk status login
  final RxBool isLoggedIn = false.obs;
  final RxString currentUsername = ''.obs;
  
  // Key untuk local storage
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUsername = 'username';
  
  @override
  void onInit() {
    super.onInit();
    _loadAuthState();
  }
  
  // Load auth state dari local storage
  void _loadAuthState() {
    isLoggedIn.value = _storage.read(_keyIsLoggedIn) ?? false;
    currentUsername.value = _storage.read(_keyUsername) ?? '';
  }
  
  // Login dengan username dan password dari Firebase
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // Query ke Firebase untuk mencari user dengan username yang sesuai
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
      
      // Cek apakah user ditemukan
      if (querySnapshot.docs.isEmpty) {
        return {
          'success': false,
          'message': 'Username tidak ditemukan',
        };
      }
      
      // Ambil data user
      final userDoc = querySnapshot.docs.first;
      final userData = userDoc.data();
      
      // Validasi password
      if (userData['password'] != password) {
        return {
          'success': false,
          'message': 'Password salah',
        };
      }
      
      // Cek apakah akun aktif (jika field isActive ada)
      // Jika field tidak ada atau null, dianggap aktif (default true)
      final isActive = userData['isActive'] ?? true;
      if (isActive == false) {
        return {
          'success': false,
          'message': 'Akun Anda tidak aktif',
        };
      }
      
      // Login berhasil - simpan ke local storage
      await _storage.write(_keyIsLoggedIn, true);
      await _storage.write(_keyUsername, username);
      
      isLoggedIn.value = true;
      currentUsername.value = username;
      
      return {
        'success': true,
        'message': 'Login berhasil',
        'user': userData,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Terjadi kesalahan: ${e.toString()}',
      };
    }
  }
  
  // Logout
  Future<void> logout() async {
    await _storage.remove(_keyIsLoggedIn);
    await _storage.remove(_keyUsername);
    
    isLoggedIn.value = false;
    currentUsername.value = '';
  }
  
  // Cek apakah user sudah login
  bool get isAuthenticated => isLoggedIn.value;
  
  // Get username yang sedang login
  String get username => currentUsername.value;
}
