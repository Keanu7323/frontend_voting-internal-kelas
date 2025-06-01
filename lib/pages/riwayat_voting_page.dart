import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voting_provider.dart';
import '../theme.dart';

class RiwayatVotingPage extends StatelessWidget {
  const RiwayatVotingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VotingProvider>(context);

    if (provider.userVotes.isEmpty) {
      return const Center(child: Text('Belum ada riwayat voting'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: provider.userVotes.entries.map((entry) {
        final voting =
        provider.votings.firstWhere((v) => v.id == entry.key);
        final option =
        voting.options.firstWhere((o) => o.id == entry.value);

        return Card(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text(voting.title, style: AppTextStyle.subtitle),
            subtitle: Text('Pilihan Anda: ${option.label}'),
          ),
        );
      }).toList(),
    );
  }
}
