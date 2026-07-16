import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  OverlayEntry? _overlayEntry;
  bool _isOverlayShowing = false;

  void _toggleOverlay() {
    if (_isOverlayShowing) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      setState(() {
        _isOverlayShowing = false;
      });
    } else {
      _overlayEntry = OverlayEntry(
        builder: (context) => const OverlayFloatingButton(),
      );
      // Tambahkan ke overlay root
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final overlay = Navigator.of(context, rootNavigator: true).overlay;
        if (overlay != null) {
          overlay.insert(_overlayEntry!);
          setState(() {
            _isOverlayShowing = true;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cheat Overlay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF1A73E8),
          secondary: Color(0xFF4FC3F7),
          surface: Color(0xFF1E1E1E),
          background: Color(0xFF121212),
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(
        onToggleOverlay: _toggleOverlay,
        isOverlayShowing: _isOverlayShowing,
      ),
    );
  }
}

// ==================== OVERLAY FLOATING BUTTON ====================
class OverlayFloatingButton extends StatefulWidget {
  const OverlayFloatingButton({super.key});

  @override
  State<OverlayFloatingButton> createState() => _OverlayFloatingButtonState();
}

class _OverlayFloatingButtonState extends State<OverlayFloatingButton> {
  bool _isExpanded = false;
  Offset _position = const Offset(20, 100);
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanStart: (_) => setState(() => _isDragging = true),
        onPanUpdate: (details) {
          setState(() {
            _position += details.delta;
          });
        },
        onPanEnd: (_) => setState(() => _isDragging = false),
        onTap: () {
          if (!_isDragging) {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          }
        },
        child: _isExpanded ? _buildExpandedOverlay() : _buildFloatingLogo(),
      ),
    );
  }

  Widget _buildFloatingLogo() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade900],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          const Center(
            child: Icon(
              Icons.memory,
              color: Colors.white,
              size: 30,
            ),
          ),
          Positioned(
            right: 2,
            top: 2,
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '●',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -4,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'SCAN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedOverlay() {
    return Container(
      width: 320,
      height: 420,
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
          color: Colors.blue.shade700.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: const OverlayContent(),
      ),
    );
  }
}

// ==================== OVERLAY CONTENT ====================
class OverlayContent extends StatefulWidget {
  const OverlayContent({super.key});

  @override
  State<OverlayContent> createState() => _OverlayContentState();
}

class _OverlayContentState extends State<OverlayContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchValue = '';
  List<String> _searchResults = [];
  bool _isScanning = false;
  String _statusMessage = 'Siap memindai';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                _buildStatusBar(),
                const SizedBox(height: 8),
                _buildSearchInput(),
                const SizedBox(height: 8),
                _buildActionButtons(),
                const SizedBox(height: 8),
                Expanded(
                  child: _buildResultsList(),
                ),
              ],
            ),
          ),
        ),
      ],
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
          const Icon(Icons.memory, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Memory Scanner',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              // Tutup overlay (remove dari root)
              final navigator = Navigator.of(context, rootNavigator: true);
              final overlay = navigator.overlay;
              if (overlay != null && overlay.entries.isNotEmpty) {
                overlay.entries.last.remove();
              }
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

    await Future.delayed(const Duration(seconds: 1));

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
