import 'package:flutter/material.dart';
import 'package:flutter_screen_overlay/flutter_screen_overlay.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isOverlayShowing = false;
  bool _hasPermission = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _checkOverlayStatus();
  }

  Future<void> _checkOverlayStatus() async {
    try {
      final isShowing = await OverlayService.isShowing;
      if (mounted) {
        setState(() {
          _isOverlayShowing = isShowing ?? false;
        });
      }
    } catch (e) {
      // Ignore
    }
  }

  Future<void> _checkPermissions() async {
    try {
      final status = await Permission.systemAlertWindow.status;
      if (mounted) {
        setState(() {
          _hasPermission = status.isGranted;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasPermission = false;
        });
      }
    }
  }

  Future<void> _requestPermissions() async {
    setState(() => _isLoading = true);
    try {
      final status = await Permission.systemAlertWindow.request();
      if (mounted) {
        setState(() {
          _hasPermission = status.isGranted;
        });
        if (status.isGranted) {
          _showSnackbar('✅ Izin overlay diberikan!', Colors.green);
        } else {
          _showSnackbar('⚠️ Izin overlay ditolak!', Colors.red);
        }
      }
    } catch (e) {
      _showSnackbar('Error: $e', Colors.red);
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleOverlay() async {
    if (_isOverlayShowing) {
      try {
        await OverlayService.hideOverlay;
        if (mounted) {
          setState(() {
            _isOverlayShowing = false;
          });
          _showSnackbar('Overlay ditutup', Colors.grey);
        }
      } catch (e) {
        _showSnackbar('Error: $e', Colors.red);
      }
      return;
    }

    if (!_hasPermission) {
      _showSnackbar('⚠️ Izin overlay diperlukan!', Colors.orange);
      await _requestPermissions();
      if (!_hasPermission) {
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      await OverlayService.showOverlay(
        child: const OverlayContent(),
        position: OverlayPosition.topRight,
        width: 320,
        height: 420,
        margin: const EdgeInsets.all(10),
        borderRadius: 16,
        backgroundColor: Colors.transparent,
        flag: OverlayFlag.focusPointer,
        enableDrag: true,
        enableSnap: true,
      );

      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        final isShowing = await OverlayService.isShowing;
        setState(() {
          _isOverlayShowing = isShowing ?? false;
        });

        if (_isOverlayShowing) {
          _showSnackbar(
              '✅ Overlay aktif! Ada logo di pojok kanan atas', Colors.green);
        } else {
          _showSnackbar('⚠️ Overlay gagal muncul! Cek izin', Colors.orange);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('❌ Gagal: $e', Colors.red);
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 14)),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cheat Overlay Engine'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1A73E8),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isOverlayShowing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _toggleOverlay,
              tooltip: 'Tutup Overlay',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _checkPermissions();
              _checkOverlayStatus();
            },
            tooltip: 'Refresh Status',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF121212), Color(0xFF1E1E1E)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: const Color(0xFF2C2C2C),
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _hasPermission
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.orange.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _hasPermission
                                    ? Icons.check_circle
                                    : Icons.warning_amber_rounded,
                                color: _hasPermission
                                    ? Colors.green
                                    : Colors.orange,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Izin Overlay',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  Text(
                                    _hasPermission
                                        ? '✅ Tersedia'
                                        : '⚠️ Belum Diizinkan',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!_hasPermission)
                              TextButton(
                                onPressed: _requestPermissions,
                                child: const Text('Izinkan'),
                              ),
                          ],
                        ),
                        const Divider(height: 24, color: Colors.grey),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _isOverlayShowing
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _isOverlayShowing
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: _isOverlayShowing
                                    ? Colors.green
                                    : Colors.grey,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Status Overlay',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  Text(
                                    _isOverlayShowing
                                        ? '🟢 Aktif'
                                        : '🔴 Nonaktif',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _toggleOverlay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isOverlayShowing
                          ? Colors.red.shade700
                          : const Color(0xFF1A73E8),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                      disabledBackgroundColor: Colors.grey.shade800,
                    ),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            _isOverlayShowing
                                ? Icons.close_fullscreen
                                : Icons.open_in_full,
                            size: 28,
                          ),
                    label: Text(
                      _isLoading
                          ? 'Memproses...'
                          : (_isOverlayShowing
                              ? 'Tutup Overlay'
                              : 'Buka Overlay'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (!_hasPermission)
                  SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _requestPermissions,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.settings),
                      label: const Text(
                        'Buka Pengaturan Izin',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                const Spacer(),
                Card(
                  color: const Color(0xFF1E1E1E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade800),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Cara Menggunakan',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '1. Berikan izin "Tampil di atas aplikasi lain"\n'
                          '2. Buka game yang ingin di-scan\n'
                          '3. Klik "Buka Overlay"\n'
                          '4. Akan muncul logo 🎯 di pojok kanan atas\n'
                          '5. Klik logo untuk membuka menu lengkap',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '⚠️ Pastikan izin overlay sudah aktif di Pengaturan HP',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
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
  bool _isExpanded = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchValue = '';
  List<String> _searchResults = [];
  bool _isScanning = false;
  String _statusMessage = 'Siap memindai';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: _isExpanded ? _buildExpandedOverlay() : _buildFloatingLogo(),
    );
  }

  Widget _buildFloatingLogo() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = true;
        });
      },
      child: Container(
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
        child: Column(
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
              setState(() {
                _isExpanded = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.chevron_right,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () async {
              await OverlayService.hideOverlay;
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
