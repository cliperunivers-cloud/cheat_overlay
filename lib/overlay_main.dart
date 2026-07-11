import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:floating_window_android/floating_window_android.dart';

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: OverlayScreen(),
  ));
}

class OverlayScreen extends StatefulWidget {
  const OverlayScreen({super.key});

  @override
  State<OverlayScreen> createState() => _OverlayScreenState();
}

class _OverlayScreenState extends State<OverlayScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchValue = '';
  List<String> _searchResults = [];
  bool _isScanning = false;
  String _statusMessage = 'Siap memindai';

  @override
  void initState() {
    super.initState();
    // Set agar tidak bisa di-screenshot (optional)
    // FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey.shade900.withOpacity(0.98),
              Colors.black.withOpacity(0.98),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.blue.shade700.withOpacity(0.4),
            width: 2,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // HEADER
              _buildHeader(),

              // KONTEN
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      // Status
                      _buildStatusBar(),

                      const SizedBox(height: 8),

                      // Input
                      _buildSearchInput(),

                      const SizedBox(height: 8),

                      // Tombol
                      _buildActionButtons(),

                      const SizedBox(height: 8),

                      // Hasil
                      Expanded(
                        child: _buildResultsList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade900, Colors.blue.shade700],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.memory,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Memory Scanner',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const Spacer(),
          // Indikator status overlay
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Tombol close
          GestureDetector(
            onTap: () async {
              await FloatingWindowAndroid.closeOverlay();
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade800.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            _isScanning ? Icons.sync : Icons.circle,
            color: _isScanning ? Colors.orange : Colors.green,
            size: 12,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _statusMessage,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 11,
                fontFamily: 'monospace',
              ),
            ),
          ),
          Text(
            '📍 ${_searchResults.length}',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInput() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'monospace',
            ),
            decoration: InputDecoration(
              hintText: 'Cari nilai (contoh: 100)',
              hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              filled: true,
              fillColor: Colors.grey.shade800,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon:
                          const Icon(Icons.clear, color: Colors.grey, size: 16),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _searchValue = value;
              });
            },
          ),
        ),
        const SizedBox(width: 6),
        // Tombol scan
        Container(
          height: 46,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade500],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: ElevatedButton(
            onPressed:
                _isScanning || _searchValue.isEmpty ? null : _performScan,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(0, 0),
            ),
            child: _isScanning
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.search, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.search,
            label: 'Scan',
            color: Colors.green.shade700,
            onPressed:
                _isScanning || _searchValue.isEmpty ? null : _performScan,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildActionButton(
            icon: Icons.filter_list,
            label: 'Next',
            color: Colors.orange.shade700,
            onPressed:
                _isScanning || _searchResults.isEmpty ? null : _performNextScan,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: _buildActionButton(
            icon: Icons.refresh,
            label: 'Reset',
            color: Colors.red.shade700,
            onPressed: _isScanning ? null : _resetScan,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        elevation: 0,
        disabledBackgroundColor: Colors.grey.shade700,
      ),
      icon: Icon(icon, size: 14),
      label: Text(label),
    );
  }

  Widget _buildResultsList() {
    if (_searchResults.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade800.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isScanning ? Icons.search : Icons.search_off,
                color: Colors.grey.shade600,
                size: 36,
              ),
              const SizedBox(height: 8),
              Text(
                _isScanning ? 'Memindai...' : 'Belum ada hasil',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                _isScanning ? 'Mohon tunggu' : 'Cari nilai untuk memulai',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade800.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.all(4),
        itemCount: _searchResults.length,
        itemBuilder: (context, index) {
          final result = _searchResults[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade700.withOpacity(0.5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Icon(
                    Icons.memory,
                    color: Colors.blue,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.grey, size: 16),
                  onPressed: () => _showEditDialog(result),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 18,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _performScan() async {
    setState(() {
      _isScanning = true;
      _statusMessage = 'Scanning...';
    });

    // SIMULASI SCAN (diganti dengan implementasi real nanti)
    await Future.delayed(const Duration(seconds: 1));

    // Hasil simulasi
    final results = [
      '0x7f8a4c20 -> $_searchValue',
      '0x7f8a4c28 -> $_searchValue',
      '0x7f8a4c30 -> $_searchValue',
      '0x7f8a4c38 -> $_searchValue',
      '0x7f8a4c40 -> $_searchValue',
    ];

    if (mounted) {
      setState(() {
        _searchResults = results;
        _isScanning = false;
        _statusMessage = '✅ Ditemukan ${results.length} alamat';
      });
    }
  }

  Future<void> _performNextScan() async {
    if (_searchResults.isEmpty) {
      setState(() {
        _statusMessage = '⚠️ Lakukan scan terlebih dahulu';
      });
      return;
    }

    setState(() {
      _isScanning = true;
      _statusMessage = 'Filtering...';
    });

    await Future.delayed(const Duration(seconds: 1));

    // Filter hasil (simulasi)
    final filtered =
        _searchResults.where((e) => e.contains(_searchValue)).toList();

    if (mounted) {
      setState(() {
        _searchResults =
            filtered.isEmpty ? ['Tidak ditemukan hasil yang cocok'] : filtered;
        _isScanning = false;
        _statusMessage = filtered.isEmpty
            ? '❌ Tidak ada yang cocok'
            : '✅ Ditemukan ${filtered.length} alamat';
      });
    }
  }

  void _resetScan() {
    setState(() {
      _searchResults = [];
      _searchController.clear();
      _searchValue = '';
      _statusMessage = '🔄 Scan di-reset';
    });
  }

  void _showEditDialog(String result) {
    final parts = result.split(' -> ');
    final address = parts.isNotEmpty ? parts[0] : 'Unknown';
    final currentValue = parts.length > 1 ? parts[1] : '0';
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Edit Nilai Memory',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alamat: $address',
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Nilai Baru',
                labelStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: const Color(0xFF2C2C2C),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 8),
            Text(
              '💡 Nilai saat ini: $currentValue',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              // SIMULASI UPDATE
              setState(() {
                _statusMessage = '✅ Nilai diubah: ${controller.text}';
              });
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A73E8),
            ),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
