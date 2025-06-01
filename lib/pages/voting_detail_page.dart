import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/voting.dart';
import '../providers/voting_provider.dart';
import '../theme.dart';

class VotingDetailPage extends StatelessWidget {
  final Voting voting;

  const VotingDetailPage({super.key, required this.voting});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<VotingProvider>(context);
    final hasVoted = provider.hasVoted(voting.id);
    final userVote = provider.getUserVote(voting.id);

    return Scaffold(
      appBar: AppBar(title: Text(voting.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: hasVoted
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Anda sudah memilih:', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 12),
              Text(
                voting.options.firstWhere((o) => o.id == userVote).label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 24, color: Colors.green),
              ),
            ],
          ),
        )
            : ListView(
          children: voting.options.map((option) {
            return Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                title: Text(option.label),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Pilih'),
                  onPressed: () {
                    provider.vote(voting.id, option.id);
                    Navigator.pop(context);
                  },
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
