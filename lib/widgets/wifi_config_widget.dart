import 'package:flutter/material.dart';
import '../services/wifi_service.dart';

class WiFiConfigWidget extends StatefulWidget {
  final WiFiService wifiService;
  final Function(String ssid, String password) onSendConfig;
  final bool isSending;
  final String? initialSsid;
  final String? initialPassword;

  const WiFiConfigWidget({
    super.key,
    required this.wifiService,
    required this.onSendConfig,
    required this.isSending,
    this.initialSsid,
    this.initialPassword,
  });

  @override
  State<WiFiConfigWidget> createState() => _WiFiConfigWidgetState();
}

class _WiFiConfigWidgetState extends State<WiFiConfigWidget> {
  late TextEditingController _ssidController;
  late TextEditingController _passwordController = TextEditingController();
  TextEditingController? _autocompleteController;
  bool _isScanningWifi = false;
  bool _listenerAdded = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _ssidController = TextEditingController(text: widget.initialSsid ?? '');
    _passwordController = TextEditingController(text: widget.initialPassword ?? '');
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _scanWifiNetworks() async {
    setState(() => _isScanningWifi = true);

    try {
      final networks = await widget.wifiService.scanNetworks();

      if (mounted && networks.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${networks.length} WiFi-Netzwerke gefunden'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('WiFi-Scan Fehler: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isScanningWifi = false);
      }
    }
  }

  void _sendConfiguration() {
    final ssid = _ssidController.text.trim();
    final password = _passwordController.text.trim();

    if (ssid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SSID darf nicht leer sein')),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwort darf nicht leer sein')),
      );
      return;
    }

    widget.onSendConfig(ssid, password);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'WiFi Konfiguration:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            IconButton(
              onPressed: _isScanningWifi ? null : _scanWifiNetworks,
              icon: Icon(_isScanningWifi ? Icons.hourglass_empty : Icons.wifi_find),
              tooltip: 'WiFi-Netzwerke scannen',
            ),
          ],
        ),
        const SizedBox(height: 8),
        Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return widget.wifiService.availableNetworks;
            }
            return widget.wifiService.availableNetworks.where((String option) {
              return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (String selection) {
            _ssidController.text = selection;
            // Update the autocomplete field controller if available
            if (_autocompleteController != null) {
              _autocompleteController!.text = selection;
            }
          },
          fieldViewBuilder: (BuildContext context, TextEditingController fieldController,
              FocusNode focusNode, VoidCallback onFieldSubmitted) {
            // Store reference to the field controller
            _autocompleteController = fieldController;

            // Initialize with the initial SSID value if available
            if (_ssidController.text.isNotEmpty && fieldController.text.isEmpty) {
              fieldController.text = _ssidController.text;
            }

            // Only add listener once to avoid multiple listeners
            if (!_listenerAdded) {
              fieldController.addListener(() {
                _ssidController.text = fieldController.text;
              });
              _listenerAdded = true;
            }

            return TextField(
              controller: fieldController,
              focusNode: focusNode,
              decoration: InputDecoration(
                labelText: 'SSID',
                hintText: 'WiFi-Netzwerkname eingeben oder auswählen',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.wifi),
                suffixIcon: widget.wifiService.hasNetworks
                    ? const Icon(Icons.arrow_drop_down)
                    : null,
              ),
            );
          },
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Passwort',
            hintText: 'WiFi-Passwort',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: widget.isSending ? null : _sendConfiguration,
            icon: Icon(widget.isSending ? Icons.hourglass_empty : Icons.send),
            label: Text(widget.isSending ? 'Sende...' : 'WiFi konfigurieren'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade100,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}
