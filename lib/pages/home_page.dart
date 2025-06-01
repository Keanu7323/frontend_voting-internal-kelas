import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voting_provider.dart';
import 'voting_detail_page.dart';
import 'voting_results_page.dart';
import 'riwayat_voting_page.dart';
import '../theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    VotingListPage(),
    RiwayatVotingPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VotingProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Halo, ${provider.user?.name ?? 'User'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              provider.loadVotings();
              provider.loadUserVotes();
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.how_to_vote), label: 'Voting'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

class VotingListPage extends StatefulWidget {
  const VotingListPage({super.key});

  @override
  State<VotingListPage> createState() => _VotingListPageState();
}

class _VotingListPageState extends State<VotingListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<VotingProvider>(context, listen: false);
      if (provider.votings.isEmpty) {
        provider.loadVotings();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VotingProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.votings.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Terjadi kesalahan',
                  style: AppTextStyle.subtitle.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    provider.clearError();
                    provider.loadVotings();
                  },
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          );
        }

        if (provider.votings.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Belum ada voting tersedia',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await provider.loadVotings();
            await provider.loadUserVotes();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.votings.length,
            itemBuilder: (context, index) {
              final voting = provider.votings[index];
              final hasVoted = provider.hasVoted(voting.id);
              final userVoteId = provider.getUserVote(voting.id);
              final userVoteLabel = hasVoted
                  ? voting.options.firstWhere((o) => o.id == userVoteId).label
                  : null;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(voting.title, style: AppTextStyle.subtitle),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (voting.description.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              voting.description,
                              style: TextStyle(color: Colors.grey[600]),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                hasVoted ? Icons.check_circle : Icons.radio_button_unchecked,
                                size: 16,
                                color: hasVoted ? Colors.green : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  hasVoted
                                      ? 'Sudah memilih: $userVoteLabel'
                                      : 'Belum memilih',
                                  style: TextStyle(
                                    color: hasVoted ? Colors.green : Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      trailing: voting.isActive
                          ? null
                          : Icon(Icons.lock, color: Colors.grey[400], size: 20),
                      onTap: voting.isActive
                          ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VotingDetailPage(voting: voting),
                          ),
                        );
                      }
                          : null,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => VotingResultsPage(voting: voting),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.bar_chart, size: 16),
                              label: const Text('Lihat Hasil'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: BorderSide(color: AppColors.primary),
                              ),
                            ),
                          ),
                          if (voting.isActive && !hasVoted) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => VotingDetailPage(voting: voting),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.how_to_vote, size: 16),
                                label: const Text('Vote'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VotingProvider>(
      builder: (context, provider, child) {
        final user = provider.user;

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: AppColors.primary,
                child: Text(
                  user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(user?.name ?? 'User', style: AppTextStyle.title),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '',
                style: AppTextStyle.subtitle.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.how_to_vote, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Total Voting Diikuti'),
                                Text(
                                  '${provider.userVotes.length}',
                                  style: const TextStyle(
                                    fontSize: 20,
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
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: provider.isLoading
                    ? null
                    : () async {
                  await provider.logout();
                  Navigator.pushReplacementNamed(context, '/');
                },
                icon: provider.isLoading
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.logout),
                label: Text(provider.isLoading ? 'Logging out...' : 'Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}