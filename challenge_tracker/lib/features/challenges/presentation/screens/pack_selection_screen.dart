import 'package:flutter/material.dart';
import '../../data/models/challenge_pack.dart';
import '../widgets/pack_card.dart';
import 'challenge_creation_screen.dart';

/// Screen displaying all available challenge packs for selection
class PackSelectionScreen extends StatelessWidget {
  const PackSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Challenge'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Select a 30-day challenge to start',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: ChallengePack.presets.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final pack = ChallengePack.presets[index];
                  return PackCard(
                    pack: pack,
                    onTap: () => _navigateToCreation(context, pack),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCreation(BuildContext context, ChallengePack pack) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChallengeCreationScreen(pack: pack),
      ),
    );
  }
}
