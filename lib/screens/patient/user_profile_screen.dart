import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_profile.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/glass_container.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.read<AuthProvider>().userProfile!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Медицинский профиль'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileHeader(context, profile),
          const SizedBox(height: 16),
          _buildMainInfo(context, profile),
          const SizedBox(height: 16),
          _buildHealthInfo(context, profile),
          const SizedBox(height: 16),
          _buildAdditionalInfo(context, profile),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserProfile profile) {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Consumer<AuthProvider>(
              builder: (context, auth, _) => Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.primary,
                  image: auth.photoUrl != null
                      ? DecorationImage(
                          image: AssetImage(auth.photoUrl!),
                          fit: BoxFit.contain,
                        )
                      : null,
                ),
                child: auth.photoUrl == null
                    ? const Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              profile.fullName,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            Text(
              '${profile.age} лет',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainInfo(BuildContext context, UserProfile profile) {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Основная информация',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(context, 'Пол', profile.gender),
            _buildInfoRow(context, 'Дата рождения', 
                '${profile.birthDate.day}.${profile.birthDate.month}.${profile.birthDate.year}'),
            _buildInfoRow(context, 'Рост', '${profile.height} см'),
            _buildInfoRow(context, 'Вес', '${profile.weight} кг'),
            _buildInfoRow(context, 'Группа крови', profile.bloodType),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthInfo(BuildContext context, UserProfile profile) {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Медицинская информация',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Хронические заболевания:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...profile.chronicDiseases.map((disease) => Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 8),
                  const SizedBox(width: 8),
                  Text(disease),
                ],
              ),
            )),
            const SizedBox(height: 16),
            Text(
              'Аллергии:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...profile.allergies.map((allergy) => Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 4),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 8),
                  const SizedBox(width: 8),
                  Text(allergy),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfo(BuildContext context, UserProfile profile) {
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Дополнительная информация',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...profile.additionalInfo.entries.map(
              (entry) => _buildInfoRow(context, entry.key, entry.value.toString()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
} 