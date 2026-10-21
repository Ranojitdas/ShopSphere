import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';

class ProfilePage extends StatefulWidget {
  final bool isEmbedded;

  const ProfilePage({
    super.key,
    this.isEmbedded = false,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().refreshProfile();
    });
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text(
          'Are you sure you want to sign out of ShopSphere? Your session tokens will be cleared.',
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CartCubit>().clearCart();
              context.read<AuthCubit>().logout();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: widget.isEmbedded
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
          title: const Text(
            'My Profile',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            final user = state is Authenticated ? state.user : null;

            if (user == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return RefreshIndicator(
              onRefresh: () => context.read<AuthCubit>().refreshProfile(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  children: [
                    _buildProfileHeader(theme, user),
                    const SizedBox(height: 24),
                    _buildSectionCard(
                      theme,
                      title: 'Personal Information',
                      children: [
                        _buildInfoTile(
                          theme,
                          icon: Icons.person_outline_rounded,
                          label: 'Full Name',
                          value: user.fullName,
                        ),
                        const Divider(height: 1),
                        _buildInfoTile(
                          theme,
                          icon: Icons.alternate_email_rounded,
                          label: 'Username',
                          value: '@${user.username}',
                        ),
                        const Divider(height: 1),
                        _buildInfoTile(
                          theme,
                          icon: Icons.email_outlined,
                          label: 'Email',
                          value: user.email,
                        ),
                        const Divider(height: 1),
                        _buildInfoTile(
                          theme,
                          icon: Icons.phone_outlined,
                          label: 'Phone',
                          value: user.phone != null && user.phone!.isNotEmpty
                              ? user.phone!
                              : '+1 (555) 019-2834',
                        ),
                        const Divider(height: 1),
                        _buildInfoTile(
                          theme,
                          icon: Icons.wc_rounded,
                          label: 'Gender',
                          value: user.gender.isNotEmpty
                              ? user.gender[0].toUpperCase() +
                                  user.gender.substring(1)
                              : 'Not specified',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      theme,
                      title: 'Account & Preferences',
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.receipt_long_outlined,
                            color: theme.colorScheme.primary,
                          ),
                          title: const Text('My Orders'),
                          subtitle: const Text('View past and active orders'),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                          onTap: () => Navigator.pushNamed(context, '/cart'),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: Icon(
                            Icons.location_on_outlined,
                            color: theme.colorScheme.primary,
                          ),
                          title: const Text('Saved Address'),
                          subtitle: const Text('742 Evergreen Terrace, Springfield'),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                          onTap: () {},
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      theme,
                      title: 'App Information',
                      children: [
                        const ListTile(
                          leading: Icon(Icons.info_outline_rounded),
                          title: Text('ShopSphere Version'),
                          subtitle: Text('1.0.0 • Clean Architecture'),
                        ),
                        const Divider(height: 1),
                        const ListTile(
                          leading: Icon(Icons.api_rounded),
                          title: Text('Backend Data Source'),
                          subtitle: Text('DummyJSON Public REST API'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showLogoutDialog(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                          side: BorderSide(
                            color: theme.colorScheme.error.withValues(alpha: 0.5),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.logout_rounded, size: 20),
                        label: const Text(
                          'Sign Out',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, UserEntity user) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.primary,
                  width: 2.5,
                ),
              ),
              child: CircleAvatar(
                radius: 46,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: user.image,
                    width: 92,
                    height: 92,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Center(
                      child: Text(
                        user.initials,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Text(
                      user.initials,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                size: 14,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          user.fullName,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '@${user.username}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Verified Customer',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard(
    ThemeData theme, {
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 14),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
