import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/voting.dart';
import '../models/user.dart';
import '../providers/voting_provider.dart';
import '../theme.dart';

class VotingResultsPage extends StatefulWidget {
  final Voting voting;

  const VotingResultsPage({super.key, required this.voting});

  @override
  State<VotingResultsPage> createState() => _VotingResultsPageState();
}

class _VotingResultsPageState extends State<VotingResultsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<VotingProvider>(context, listen: false)
          .loadVotingResults(widget.voting.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hasil ${widget.voting.title}'),
      ),
      body: Consumer<VotingProvider>(
        builder: (context, provider, child) {
          final results = provider.getVotingResults(widget.voting.id);

          if (provider.isLoading && results == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (results == null || results.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada hasil voting',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final totalVotes = results.fold(0, (sum, result) => sum + result.count);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.voting.title,
                          style: AppTextStyle.title.copyWith(fontSize: 20),
                        ),
                        if (widget.voting.description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            widget.voting.description,
                            style: AppTextStyle.subtitle.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.people, color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Total Suara: $totalVotes',
                              style: AppTextStyle.subtitle.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Hasil Voting',
                  style: AppTextStyle.title.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 12),

                ...results.map((result) => _buildResultCard(result, totalVotes)),

                const SizedBox(height: 24),

                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Grafik Hasil',
                          style: AppTextStyle.subtitle.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...results.map((result) => _buildBarChart(result, totalVotes)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultCard(VoteResult result, int totalVotes) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.optionLabel,
                    style: AppTextStyle.subtitle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${result.count} suara (${result.percentage.toStringAsFixed(1)}%)',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getColorForIndex(results.indexOf(result)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${result.count}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(VoteResult result, int totalVotes) {
    final percentage = totalVotes > 0 ? result.percentage : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  result.optionLabel,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${result.count} (${percentage.toStringAsFixed(1)}%)',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: _getColorForIndex(results.indexOf(result)),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      AppColors.primary,
      AppColors.accent,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }
}