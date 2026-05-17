import 'package:flutter/material.dart';

void main() => runApp(const NetToolboxApp());

class NetToolboxApp extends StatelessWidget {
  const NetToolboxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0D2137),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const NetToolboxHome(),
    );
  }
}

class NetToolboxHome extends StatefulWidget {
  const NetToolboxHome({super.key});

  @override
  State<NetToolboxHome> createState() => _NetToolboxHomeState();
}

class _NetToolboxHomeState extends State<NetToolboxHome> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Net Toolbox'),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: const [PingTool(), WhoisTool(), DnsTool()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.send), label: 'Ping'),
          NavigationDestination(icon: Icon(Icons.search), label: 'WHOIS'),
          NavigationDestination(icon: Icon(Icons.dns), label: 'DNS'),
        ],
      ),
    );
  }
}

// ─── Ping Tool ───────────────────────────────────────────────────────────────
class PingTool extends StatefulWidget {
  const PingTool({super.key});
  @override
  State<PingTool> createState() => _PingToolState();
}

class _PingToolState extends State<PingTool> {
  final _hostCtl = TextEditingController(text: 'google.com');
  final _results = <String>[];
  bool _loading = false;

  Future<void> _ping() async {
    final host = _hostCtl.text.trim();
    if (host.isEmpty) return;
    setState(() {
      _loading = true;
      _results.clear();
    });
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final now = DateTime.now();
    final ms = [8, 12, 9, 14, 11, 10, 13, 9];
    final sim = <String>[];
    sim.add('PING $host (142.250.80.4): 56 data bytes');
    for (var i = 0; i < 4; i++) {
      sim.add('64 bytes from 142.250.80.4: icmp_seq=$i ttl=117 '
          'time=${ms[2 * i]}.${ms[2 * i + 1]} ms');
    }
    sim.add('');
    final avg = ms.reduce((a, b) => a + b) / ms.length;
    sim.add('--- $host ping statistics ---');
    sim.add('4 packets transmitted, 4 received, 0% loss');
    sim.add('round-trip min/avg/max = ${ms.reduce((a, b) => a < b ? a : b)}.'
        '0/${avg.toStringAsFixed(1)}/${ms.reduce((a, b) => a > b ? a : b)}.0 ms');
    sim.add('(Simulated — $now)');
    setState(() {
      _results.addAll(sim);
      _loading = false;
    });
  }

  @override
  void dispose() {
    _hostCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _hostCtl,
            decoration: const InputDecoration(
              labelText: 'Host / IP',
              prefixIcon: Icon(Icons.computer),
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _ping(),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _loading ? null : _ping,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            label: Text(_loading ? 'Pinging...' : 'Ping'),
          ),
          const SizedBox(height: 16),
          if (_results.isNotEmpty)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (_, i) => Text(
                    _results[i],
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: Color(0xFF00FF88),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── WHOIS Tool ──────────────────────────────────────────────────────────────
class WhoisTool extends StatefulWidget {
  const WhoisTool({super.key});
  @override
  State<WhoisTool> createState() => _WhoisToolState();
}

class _WhoisToolState extends State<WhoisTool> {
  final _domainCtl = TextEditingController(text: 'example.com');
  final _results = <String>[];
  bool _loading = false;

  static const _demo = '''
Domain Name: EXAMPLE.COM
Registry Domain ID: 2336799_DOMAIN_COM-VRSN
Registrar WHOIS Server: whois.example-registrar.com
Registrar URL: http://www.example-registrar.com
Updated Date: 2026-01-15T10:30:00Z
Creation Date: 1995-08-14T04:00:00Z
Registrar Registration Expiration Date: 2027-08-13T04:00:00Z
Registrar: EXAMPLE REGISTRAR LLC
Registrar IANA ID: 1234
Domain Status: clientTransferProhibited
Name Server: NS1.EXAMPLE.COM
Name Server: NS2.EXAMPLE.COM
DNSSEC: unsigned
(Simulated WHOIS data)''';

  Future<void> _lookup() async {
    final d = _domainCtl.text.trim();
    if (d.isEmpty) return;
    setState(() {
      _loading = true;
      _results.clear();
    });
    await Future<void>.delayed(const Duration(seconds: 1));
    setState(() {
      _results.addAll(_demo.split('\n'));
      _loading = false;
    });
  }

  @override
  void dispose() {
    _domainCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _domainCtl,
            decoration: const InputDecoration(
              labelText: 'Domain',
              prefixIcon: Icon(Icons.language),
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _lookup(),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _loading ? null : _lookup,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.search),
            label: Text(_loading ? 'Looking up...' : 'Lookup'),
          ),
          const SizedBox(height: 16),
          if (_results.isNotEmpty)
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (_, i) => Text(
                    _results[i],
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                      color: Color(0xFF00FF88),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── DNS Tool ────────────────────────────────────────────────────────────────
class DnsTool extends StatefulWidget {
  const DnsTool({super.key});
  @override
  State<DnsTool> createState() => _DnsToolState();
}

class _DnsToolState extends State<DnsTool> {
  final _domainCtl = TextEditingController(text: 'example.com');
  final _results = <_DnsRecord>[];
  String _selectedType = 'A';
  bool _loading = false;

  static const _recordTypes = ['A', 'AAAA', 'MX', 'CNAME', 'TXT', 'NS', 'SOA'];

  static const _demoRecords = {
    'A': [
      _DnsRecord('A', '93.184.216.34', 86400),
    ],
    'AAAA': [
      _DnsRecord('AAAA', '2606:2800:220:1:248:1893:25c8:1946', 86400),
    ],
    'MX': [
      _DnsRecord('MX', '0 mail.example.com.', 3600),
    ],
    'CNAME': [
      _DnsRecord('CNAME', 'www.example.com is an alias for example.com.', 86400),
    ],
    'TXT': [
      _DnsRecord('TXT', 'v=spf1 -all', 300),
      _DnsRecord('TXT', 'google-site-verification=abc123def456', 300),
    ],
    'NS': [
      _DnsRecord('NS', 'ns1.example.com.', 86400),
      _DnsRecord('NS', 'ns2.example.com.', 86400),
    ],
    'SOA': [
      _DnsRecord('SOA', 'ns1.example.com. admin.example.com. '
          '2026010101 7200 3600 1209600 86400', 3600),
    ],
  };

  Future<void> _query() async {
    final d = _domainCtl.text.trim();
    if (d.isEmpty) return;
    setState(() {
      _loading = true;
      _results.clear();
    });
    await Future<void>.delayed(const Duration(milliseconds: 600));
    setState(() {
      _results.addAll(_demoRecords[_selectedType] ?? []);
      _loading = false;
    });
  }

  @override
  void dispose() {
    _domainCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _domainCtl,
                  decoration: const InputDecoration(
                    labelText: 'Domain',
                    prefixIcon: Icon(Icons.language),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 120,
                child: DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: _recordTypes.map((t) => DropdownMenuItem(
                    value: t,
                    child: Text(t),
                  )).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedType = v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _loading ? null : _query,
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.dns),
            label: Text(_loading ? 'Querying...' : 'Query DNS'),
          ),
          const SizedBox(height: 16),
          if (_results.isNotEmpty)
            Expanded(
              child: Card(
                child: ListView.separated(
                  padding: const EdgeInsets.all(12),
                  itemCount: _results.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final r = _results[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  r.type,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'TTL: ${r.ttl}s',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(r.value, style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'Simulated DNS data for demonstration',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _DnsRecord {
  final String type;
  final String value;
  final int ttl;
  const _DnsRecord(this.type, this.value, this.ttl);
}
