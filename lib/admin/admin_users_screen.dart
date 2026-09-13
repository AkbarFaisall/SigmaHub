import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../profile/profile_screen.dart';
import 'admin_drawer.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _users = [];
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final client = Supabase.instance.client;
      final response = await client.from('profiles').select().order('updated_at', ascending: false);
      
      if (mounted) {
        setState(() {
          var allUsers = List<Map<String, dynamic>>.from(response);
          // Filter out Admin and Guest accounts
          _users = allUsers.where((user) {
            final email = (user['email'] ?? '').toString().toLowerCase();
            final name = (user['name'] ?? '').toString().toLowerCase();
            return email != 'admin@sigma.edu' && name != 'guest' && name != 'tamu';
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching users: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data pengguna: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return 'Tidak diketahui';
    try {
      final DateTime date = DateTime.parse(isoDate).toLocal();
      const List<String> bulan = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      final String d = date.day.toString().padLeft(2, '0');
      final String m = bulan[date.month - 1];
      final String y = date.year.toString();
      final String h = date.hour.toString().padLeft(2, '0');
      final String min = date.minute.toString().padLeft(2, '0');
      return '$d $m $y, $h:$min';
    } catch (e) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: globalDarkModeNotifier,
      builder: (context, isDark, child) {
        Color primaryWarna = isDark ? Colors.green.shade400 : const Color(0xFF004900);
        Color bgWarna = isDark ? const Color(0xFF121212) : const Color(0xFFF9F9FF);
        Color surfaceWarna = isDark ? const Color(0xFF1E1E1E) : Colors.white;

        return Scaffold(
          backgroundColor: bgWarna,
          appBar: AppBar(
            backgroundColor: surfaceWarna,
            elevation: 0,
            iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
            title: Text('Kelola Pengguna', style: TextStyle(color: primaryWarna, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          drawer: const AdminDrawer(activeRoute: 'pengguna'),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  style: TextStyle(color: isDark ? Colors.white : Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Cari nama, email, universitas, atau jurusan...',
                    hintStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                    prefixIcon: Icon(Icons.search, color: isDark ? Colors.grey.shade500 : Colors.grey),
                    filled: true,
                    fillColor: surfaceWarna,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(99), borderSide: BorderSide.none),
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: primaryWarna))
                    : _users.isEmpty
                        ? Center(
                            child: Text(
                              'Belum ada pengguna terdaftar.',
                              style: TextStyle(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                            ),
                          )
                        : RefreshIndicator(
                            color: primaryWarna,
                            onRefresh: _fetchUsers,
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: _users.where((user) {
                                final name = (user['name'] ?? '').toString().toLowerCase();
                                final email = (user['email'] ?? '').toString().toLowerCase();
                                final university = (user['university'] ?? '').toString().toLowerCase();
                                final major = (user['major'] ?? '').toString().toLowerCase();
                                final query = _searchQuery.toLowerCase();
                                return name.contains(query) || email.contains(query) || university.contains(query) || major.contains(query);
                              }).length,
                              itemBuilder: (context, index) {
                                final filteredUsers = _users.where((user) {
                                  final name = (user['name'] ?? '').toString().toLowerCase();
                                  final email = (user['email'] ?? '').toString().toLowerCase();
                                  final university = (user['university'] ?? '').toString().toLowerCase();
                                  final major = (user['major'] ?? '').toString().toLowerCase();
                                  final query = _searchQuery.toLowerCase();
                                  return name.contains(query) || email.contains(query) || university.contains(query) || major.contains(query);
                                }).toList();
                                final user = filteredUsers[index];
                                return _buildUserCard(user, isDark, surfaceWarna, primaryWarna);
                              },
                            ),
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user, bool isDark, Color surfaceWarna, Color primaryWarna) {
    final String name = user['name'] ?? 'Anonim';
    final String email = user['email'] ?? 'Tanpa Email';
    final String university = user['university'] ?? 'Universitas Tidak Diketahui';
    final String major = user['major'] ?? 'Jurusan Tidak Diketahui';
    final String updatedAt = user['updated_at'] ?? '';
    final String avatarUrl = user['avatar_url'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: surfaceWarna,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row Header: Avatar & Name/Email
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
                  backgroundImage: (avatarUrl.isNotEmpty && avatarUrl.startsWith('http')) 
                      ? NetworkImage(avatarUrl) 
                      : null,
                  child: (avatarUrl.isEmpty || !avatarUrl.startsWith('http'))
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: TextStyle(color: primaryWarna, fontWeight: FontWeight.bold, fontSize: 20),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : Colors.black)),
                      const SizedBox(height: 2),
                      Text(email, style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, height: 1),
            const SizedBox(height: 16),
            
            // Info Akademik
            Row(
              children: [
                Icon(Icons.school_outlined, size: 18, color: isDark ? Colors.grey.shade500 : Colors.grey.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$university - $major',
                    style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade300 : Colors.grey.shade800),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            
            // Info Waktu Bergabung/Aktif
            Row(
              children: [
                Icon(Icons.access_time, size: 18, color: isDark ? Colors.grey.shade500 : Colors.grey.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Aktif: ${_formatDate(updatedAt)}',
                    style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
