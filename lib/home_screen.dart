import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:floating_window_android/floating_window_android.dart';
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
      // Fallback
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
      // Buka halaman pengaturan overlay
      final status = await Permission.systemAlertWindow.request();
      if (mounted) {
        setState(() {
          _hasPermission = status.isGranted;
        });
        if (status.isGranted) {
          _showSnackbar('Izin overlay diberikan!', Colors.green);
        } else {
          _showSnackbar('Izin overlay ditolak!', Colors.red);
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
      // TUTUP OVERLAY
      try {
        await FloatingWindowAndroid.closeOverlay();
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

    // BUKA OVERLAY
    if (!_hasPermission) {
      _showSnackbar('Izin overlay diperlukan!', Colors.orange);
      await _requestPermissions();
      if (!_hasPermission) {
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final result = await FloatingWindowAndroid.showOverlay(
        height: 400,
        width: 340,
        alignment: OverlayAlignment.topRight,
        flag: OverlayFlag.defaultFlag,
        enableDrag: true,
        positionGravity: PositionGravity.auto,
        overlayTitle: "Cheat Engine",
        overlayContent: "Memory Scanner Active",
      );

      if (mounted) {
        setState(() {
          _isOverlayShowing = true;
        });
        _showSnackbar('✅ Overlay aktif!', Colors.green);
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
            onPressed: _checkPermissions,
            tooltip: 'Cek Izin',
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
                // STATUS CARD
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

                // TOMBOL UTAMA
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

                // TOMBOL IZIN (jika belum)
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

                // INFO CARD
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
                              'Panduan Penggunaan',
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
                          '3. Klik "Buka Overlay" untuk memulai scanning\n'
                          '4. Cari nilai memory dan edit sesuai keinginan',
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
                  '⚠️ Membutuhkan akses ROOT untuk memory editing real',
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
