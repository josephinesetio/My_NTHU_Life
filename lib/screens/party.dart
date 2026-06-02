import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Theme colour aliases (from darkHighContrastScheme) ───────────────────────
const Color _bgBlack = Color(0xFF0B090A); // surface / scaffold
const Color _cardDark = Color(0xFF16121E); // surfaceContainerLow
const Color _cardMid = Color(0xFF1E1A24); // surfaceContainer
const Color _cardHigh = Color(0xFF241E2E); // surfaceContainerHigh
const Color _borderSubtle = Color(0xFF240046); // outlineVariant
const Color _neonPurple = Color(0xFFC77DFF); // primary / neonLightPurple
const Color _deepPurple = Color(0xFF7B2CBF); // outline (accent)
const Color _selectedPurple = Color(0xFF3C096C); // surfaceBright (selected)
const Color _intensePurple = Color(0xFF5A189A); // week label
const Color _paleLavender = Color(0xFFE0AAFF); // onPrimaryContainer
const Color _subtitleGrey = Color(0xFF9E9299); // onSurfaceVariant
const Color _goldAccent = Color(0xFFFFD700); // rank #1
const Color _silverAccent = Color(0xFFB0BEC5); // rank #2
const Color _bronzeAccent = Color(0xFFFF8A65); // rank #3

// ─── Data models ───────────────────────────────────────────────────────────────

class Party {
  String id;
  String name;
  String tag; // 4-char tag e.g. "NTHU"
  String creatorID;
  List<String> memberIDs;
  int totalWeeklyXP;
  String description;

  Party({
    required this.id,
    required this.name,
    required this.tag,
    required this.creatorID,
    required this.memberIDs,
    this.totalWeeklyXP = 0,
    this.description = '',
  });

  factory Party.fromJson(Map<String, dynamic> j) => Party(
    id: j['id'],
    name: j['name'],
    tag: j['tag'],
    creatorID: j['creatorID'],
    memberIDs: List<String>.from(j['memberIDs']),
    totalWeeklyXP: j['totalWeeklyXP'] ?? 0,
    description: j['description'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'tag': tag,
    'creatorID': creatorID,
    'memberIDs': memberIDs,
    'totalWeeklyXP': totalWeeklyXP,
    'description': description,
  };
}

class LeaderboardEntry {
  final String studentID;
  final String displayName;
  final int weeklyXP;
  final int rank;

  const LeaderboardEntry({
    required this.studentID,
    required this.displayName,
    required this.weeklyXP,
    required this.rank,
  });
}

// ─── Page ─────────────────────────────────────────────────────────────────────

class PartyPage extends StatefulWidget {
  final String studentID;
  const PartyPage({super.key, required this.studentID});

  @override
  State<PartyPage> createState() => _PartyPageState();
}

class _PartyPageState extends State<PartyPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Party? _myParty;
  bool _isLoading = true;

  // Simulated global leaderboard entries (replace with real backend data)
  final List<LeaderboardEntry> _globalLeaderboard = [
    LeaderboardEntry(
      studentID: 'S001',
      displayName: 'NebulaKnight',
      weeklyXP: 1840,
      rank: 1,
    ),
    LeaderboardEntry(
      studentID: 'S002',
      displayName: 'VoidWalker',
      weeklyXP: 1725,
      rank: 2,
    ),
    LeaderboardEntry(
      studentID: 'S003',
      displayName: 'ArcSorceress',
      weeklyXP: 1580,
      rank: 3,
    ),
    LeaderboardEntry(
      studentID: 'S004',
      displayName: 'CipherMage',
      weeklyXP: 1440,
      rank: 4,
    ),
    LeaderboardEntry(
      studentID: 'S005',
      displayName: 'DataWraith',
      weeklyXP: 1310,
      rank: 5,
    ),
    LeaderboardEntry(
      studentID: 'S006',
      displayName: 'PhotonRogue',
      weeklyXP: 1190,
      rank: 6,
    ),
    LeaderboardEntry(
      studentID: 'S007',
      displayName: 'LunarScribe',
      weeklyXP: 1050,
      rank: 7,
    ),
    LeaderboardEntry(
      studentID: 'S008',
      displayName: 'ByteShaman',
      weeklyXP: 920,
      rank: 8,
    ),
    LeaderboardEntry(
      studentID: 'S009',
      displayName: 'StarForger',
      weeklyXP: 810,
      rank: 9,
    ),
    LeaderboardEntry(
      studentID: 'S010',
      displayName: 'QuantumBard',
      weeklyXP: 700,
      rank: 10,
    ),
  ];

  // Simulated party leaderboard (replace with real backend data)
  final List<LeaderboardEntry> _partyLeaderboard = [
    LeaderboardEntry(
      studentID: 'P001',
      displayName: 'Stellar Vanguard',
      weeklyXP: 6840,
      rank: 1,
    ),
    LeaderboardEntry(
      studentID: 'P002',
      displayName: 'Code Wraiths',
      weeklyXP: 6120,
      rank: 2,
    ),
    LeaderboardEntry(
      studentID: 'P003',
      displayName: 'Arc Collective',
      weeklyXP: 5775,
      rank: 3,
    ),
    LeaderboardEntry(
      studentID: 'P004',
      displayName: 'Null Terminators',
      weeklyXP: 4990,
      rank: 4,
    ),
    LeaderboardEntry(
      studentID: 'P005',
      displayName: 'Byte Syndicate',
      weeklyXP: 4310,
      rank: 5,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadParty();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── Storage ────────────────────────────────────────────────────────────────

  Future<void> _loadParty() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('Party_${widget.studentID}');
    setState(() {
      _myParty = raw != null ? Party.fromJson(jsonDecode(raw)) : null;
      _isLoading = false;
    });
  }

  Future<void> _saveParty(Party party) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'Party_${widget.studentID}',
      jsonEncode(party.toJson()),
    );
    setState(() => _myParty = party);
  }

  Future<void> _leaveParty() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('Party_${widget.studentID}');
    setState(() => _myParty = null);
  }

  // ── Dialogs ────────────────────────────────────────────────────────────────

  void _showCreatePartyDialog() {
    final nameCtrl = TextEditingController();
    final tagCtrl = TextEditingController();
    final descCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _selectedPurple, width: 1.5),
        ),
        title: Text(
          'FORGE PARTY',
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            color: _paleLavender,
            fontSize: 16,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(nameCtrl, 'Party Name', 'e.g. Stellar Vanguard'),
              const SizedBox(height: 12),
              _dialogField(tagCtrl, 'Tag (4 chars)', 'e.g. NTHU', maxLength: 4),
              const SizedBox(height: 12),
              _dialogField(
                descCtrl,
                'Description (optional)',
                'What is your party about?',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final tag = tagCtrl.text.trim().toUpperCase();
              if (name.isEmpty || tag.isEmpty) return;
              final party = Party(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                name: name,
                tag: tag.length > 4 ? tag.substring(0, 4) : tag,
                creatorID: widget.studentID,
                memberIDs: [widget.studentID],
                description: descCtrl.text.trim(),
              );
              _saveParty(party);
              Navigator.pop(ctx);
            },
            child: Text(
              'Forge',
              style: GoogleFonts.orbitron(
                color: _neonPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showJoinPartyDialog() {
    final codeCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _selectedPurple, width: 1.5),
        ),
        title: Text(
          'JOIN PARTY',
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            color: _paleLavender,
            fontSize: 16,
          ),
        ),
        content: _dialogField(codeCtrl, 'Party Code', 'Enter the invite code'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              // TODO: look up party by code from backend
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: _cardHigh,
                  content: Text(
                    'Party lookup coming soon!',
                    style: GoogleFonts.outfit(color: _neonPurple),
                  ),
                ),
              );
            },
            child: Text(
              'Join',
              style: GoogleFonts.orbitron(
                color: _neonPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLeaveConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: _selectedPurple, width: 1.5),
        ),
        title: Text(
          'LEAVE PARTY?',
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
            fontSize: 15,
          ),
        ),
        content: Text(
          'Your weekly XP contribution will be removed from the leaderboard.',
          style: GoogleFonts.outfit(color: _subtitleGrey, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Stay', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              _leaveParty();
              Navigator.pop(ctx);
            },
            child: Text(
              'Leave',
              style: GoogleFonts.orbitron(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Widget _dialogField(
    TextEditingController ctrl,
    String label,
    String hint, {
    int? maxLength,
  }) {
    return TextField(
      controller: ctrl,
      maxLength: maxLength,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _neonPurple),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        counterStyle: TextStyle(color: _subtitleGrey),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: _selectedPurple),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: _neonPurple, width: 2),
        ),
      ),
    );
  }

  Color _rankColor(int rank) {
    if (rank == 1) return _goldAccent;
    if (rank == 2) return _silverAccent;
    if (rank == 3) return _bronzeAccent;
    return _subtitleGrey;
  }

  String _rankEmoji(int rank) {
    if (rank == 1) return '👑';
    if (rank == 2) return '🥈';
    if (rank == 3) return '🥉';
    return '#$rank';
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: _bgBlack,
        body: Center(child: CircularProgressIndicator(color: _neonPurple)),
      );
    }

    return Scaffold(
      backgroundColor: _bgBlack,
      appBar: AppBar(
        backgroundColor: _bgBlack,
        elevation: 0,
        title: Text(
          'PARTY NEXUS',
          style: GoogleFonts.orbitron(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: _neonPurple,
          indicatorWeight: 2.5,
          labelStyle: GoogleFonts.orbitron(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelColor: _subtitleGrey,
          labelColor: _neonPurple,
          tabs: const [
            Tab(text: 'MY PARTY'),
            Tab(text: 'SOLO RANK'),
            Tab(text: 'PARTY RANK'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyPartyTab(),
          _buildLeaderboardTab(_globalLeaderboard, isSolo: true),
          _buildLeaderboardTab(_partyLeaderboard, isSolo: false),
        ],
      ),
      // FAB shown only on My Party tab when user has no party
      floatingActionButton: AnimatedBuilder(
        animation: _tabController,
        builder: (_, __) {
          if (_tabController.index != 0 || _myParty != null) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton.extended(
            backgroundColor: _deepPurple,
            label: Text(
              'FORGE PARTY',
              style: GoogleFonts.orbitron(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 12,
              ),
            ),
            icon: const Icon(Icons.group_add, color: Colors.white),
            onPressed: _showCreatePartyDialog,
          );
        },
      ),
    );
  }

  // ── Tab: My Party ──────────────────────────────────────────────────────────

  Widget _buildMyPartyTab() {
    if (_myParty == null) {
      return _buildNoPartyScreen();
    }
    return _buildPartyDetailScreen(_myParty!);
  }

  Widget _buildNoPartyScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          // Hero banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: _cardDark,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _borderSubtle, width: 1.5),
            ),
            child: Column(
              children: [
                const Icon(Icons.shield_outlined, color: _deepPurple, size: 56),
                const SizedBox(height: 16),
                Text(
                  'NO PARTY ASSIGNED',
                  style: GoogleFonts.orbitron(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: _paleLavender,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join a party to combine XP with allies and climb the weekly leaderboard together.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: _subtitleGrey,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Forge button
          _actionButton(
            icon: Icons.add_circle_outline,
            label: 'FORGE NEW PARTY',
            subtitle: 'Create and lead your own guild',
            onTap: _showCreatePartyDialog,
          ),
          const SizedBox(height: 12),

          // Join button
          _actionButton(
            icon: Icons.login_rounded,
            label: 'JOIN WITH CODE',
            subtitle: 'Enter an invite code to join a party',
            onTap: _showJoinPartyDialog,
          ),

          const SizedBox(height: 28),
          _sectionLabel('HOW PARTY XP WORKS'),
          const SizedBox(height: 12),
          _infoCard(
            Icons.star_rounded,
            'Combined Weekly XP',
            'Every quest you complete contributes XP to your party\'s weekly total.',
          ),
          const SizedBox(height: 10),
          _infoCard(
            Icons.leaderboard_rounded,
            'Weekly Reset',
            'Leaderboards reset every Monday at 00:00. Top parties earn bonus rewards.',
          ),
          const SizedBox(height: 10),
          _infoCard(
            Icons.group_rounded,
            'Max 6 Members',
            'Parties are capped at 6 members for balanced competition.',
          ),
        ],
      ),
    );
  }

  Widget _buildPartyDetailScreen(Party party) {
    final bool isLeader = party.creatorID == widget.studentID;
    // Mock member data — replace with real lookup
    final List<Map<String, dynamic>> members = List.generate(
      party.memberIDs.length,
      (i) => {
        'id': party.memberIDs[i],
        'name': i == 0 ? 'You' : 'Member ${i + 1}',
        'weeklyXP': (i == 0 ? 420 : (300 - i * 40)).clamp(0, 9999),
        'isLeader': party.memberIDs[i] == party.creatorID,
      },
    );
    members.sort(
      (a, b) => (b['weeklyXP'] as int).compareTo(a['weeklyXP'] as int),
    );

    final int totalXP = members.fold(
      0,
      (sum, m) => sum + (m['weeklyXP'] as int),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Party banner card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _cardDark,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: _borderSubtle, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Tag badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedPurple,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _deepPurple),
                      ),
                      child: Text(
                        '[${party.tag}]',
                        style: GoogleFonts.orbitron(
                          color: _neonPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        party.name,
                        style: GoogleFonts.orbitron(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isLeader)
                      const Icon(
                        Icons.edit_outlined,
                        color: _subtitleGrey,
                        size: 18,
                      ),
                  ],
                ),
                if (party.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    party.description,
                    style: GoogleFonts.outfit(
                      color: _subtitleGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    _statChip(Icons.bolt, '$totalXP XP', 'This Week'),
                    const SizedBox(width: 12),
                    _statChip(
                      Icons.group,
                      '${party.memberIDs.length}/6',
                      'Members',
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          _sectionLabel('PARTY MEMBERS • THIS WEEK'),
          const SizedBox(height: 12),

          ...members.asMap().entries.map((e) {
            final int idx = e.key;
            final Map<String, dynamic> m = e.value;
            final bool isMe = m['id'] == widget.studentID;
            return _memberCard(
              rank: idx + 1,
              name: m['name'],
              xp: m['weeklyXP'],
              isLeader: m['isLeader'],
              isMe: isMe,
            );
          }),

          const SizedBox(height: 20),

          // Invite / Leave row
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _deepPurple),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(
                    Icons.share_outlined,
                    color: _neonPurple,
                    size: 18,
                  ),
                  label: Text(
                    'INVITE',
                    style: GoogleFonts.orbitron(
                      color: _neonPurple,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: _cardHigh,
                        content: Text(
                          'Invite code: ${party.id.substring(0, 8).toUpperCase()}',
                          style: GoogleFonts.outfit(color: _neonPurple),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Colors.redAccent,
                    size: 18,
                  ),
                  label: Text(
                    'LEAVE',
                    style: GoogleFonts.orbitron(
                      color: Colors.redAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: _showLeaveConfirmDialog,
                ),
              ),
            ],
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  // ── Tab: Leaderboard ───────────────────────────────────────────────────────

  Widget _buildLeaderboardTab(
    List<LeaderboardEntry> entries, {
    required bool isSolo,
  }) {
    // Find current user / party rank
    final myEntry = entries
        .where(
          (e) =>
              e.studentID == widget.studentID ||
              (isSolo == false &&
                  _myParty != null &&
                  e.studentID == _myParty!.id),
        )
        .firstOrNull;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _cardDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _borderSubtle, width: 1.5),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.emoji_events_rounded,
                  color: _goldAccent,
                  size: 36,
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSolo ? 'SOLO WEEKLY RANK' : 'PARTY WEEKLY RANK',
                      style: GoogleFonts.orbitron(
                        color: _paleLavender,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Resets every Monday at 00:00',
                      style: GoogleFonts.outfit(
                        color: _subtitleGrey,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Podium (top 3)
          if (entries.length >= 3) _buildPodium(entries),

          const SizedBox(height: 20),
          _sectionLabel('FULL RANKINGS'),
          const SizedBox(height: 12),

          ...entries.map((e) {
            final bool isMe =
                e.studentID == widget.studentID ||
                (!isSolo && _myParty?.id == e.studentID);
            return _leaderboardRow(e, isMe: isMe);
          }),

          if (myEntry == null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: _cardMid,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _deepPurple.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    color: _deepPurple,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isSolo
                        ? 'Complete quests to appear on the board!'
                        : 'Join a party to compete!',
                    style: GoogleFonts.outfit(
                      color: _subtitleGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPodium(List<LeaderboardEntry> entries) {
    final top3 = entries.take(3).toList();
    // Order: 2nd | 1st | 3rd
    final display = [top3[1], top3[0], top3[2]];
    final heights = [90.0, 120.0, 70.0];
    final colors = [_silverAccent, _goldAccent, _bronzeAccent];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderSubtle, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(3, (i) {
          final entry = display[i];
          final color = colors[i];
          final h = heights[i];
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                i == 1 ? '👑' : (i == 0 ? '🥈' : '🥉'),
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(height: 4),
              Text(
                entry.displayName,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                '${entry.weeklyXP} XP',
                style: GoogleFonts.orbitron(color: color, fontSize: 10),
              ),
              const SizedBox(height: 6),
              Container(
                width: 80,
                height: h,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                  border: Border.all(color: color.withOpacity(0.4)),
                ),
                child: Center(
                  child: Text(
                    '${entry.rank}',
                    style: GoogleFonts.orbitron(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _leaderboardRow(LeaderboardEntry e, {required bool isMe}) {
    final Color rankCol = _rankColor(e.rank);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? _selectedPurple.withOpacity(0.35) : _cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMe ? _deepPurple : _borderSubtle.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              _rankEmoji(e.rank),
              style: TextStyle(
                fontSize: e.rank <= 3 ? 18 : 13,
                color: rankCol,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              e.displayName + (isMe ? ' (You)' : ''),
              style: GoogleFonts.outfit(
                color: isMe ? _neonPurple : Colors.white,
                fontWeight: isMe ? FontWeight.bold : FontWeight.w400,
                fontSize: 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${e.weeklyXP} XP',
            style: GoogleFonts.orbitron(color: rankCol, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ── Sub-widgets ────────────────────────────────────────────────────────────

  Widget _sectionLabel(String text) => Text(
    text,
    style: GoogleFonts.orbitron(
      fontSize: 11,
      fontWeight: FontWeight.bold,
      color: _intensePurple,
      letterSpacing: 1,
    ),
  );

  Widget _actionButton({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderSubtle, width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _selectedPurple,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: _neonPurple, size: 22),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(color: _subtitleGrey, fontSize: 12),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: _subtitleGrey),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String title, String body) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderSubtle.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _deepPurple, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    color: _paleLavender,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: GoogleFonts.outfit(
                    color: _subtitleGrey,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statChip(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _cardMid,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: _deepPurple, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.orbitron(
                  color: _neonPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.outfit(color: _subtitleGrey, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _memberCard({
    required int rank,
    required String name,
    required int xp,
    required bool isLeader,
    required bool isMe,
  }) {
    return Card(
      color: isMe ? _selectedPurple.withOpacity(0.3) : _cardDark,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isMe ? _deepPurple : _borderSubtle.withOpacity(0.5),
        ),
      ),
      child: ListTile(
        leading: Container(width: 4, height: 26, color: _rankColor(rank)),
        title: Row(
          children: [
            if (isLeader)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Text('👑', style: TextStyle(fontSize: 13)),
              ),
            Expanded(
              child: Text(
                name + (isMe ? ' (You)' : ''),
                style: GoogleFonts.outfit(
                  color: isMe ? _neonPurple : Colors.white,
                  fontSize: 14,
                  fontWeight: isMe ? FontWeight.bold : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(
          '$xp XP this week',
          style: GoogleFonts.outfit(color: _subtitleGrey, fontSize: 11),
        ),
        trailing: Text(
          '#$rank',
          style: GoogleFonts.orbitron(
            color: _rankColor(rank),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
