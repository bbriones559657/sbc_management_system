import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../domain/repositories/user_repository.dart';
import '../../models/user_record.dart';
import '../../widgets/common/app_dialog.dart';
import '../../widgets/common/data_table_card.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/layout/app_page.dart';

class UsersScreen extends StatefulWidget {
  final UserRepository userRepository;

  const UsersScreen({super.key, required this.userRepository});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late Future<List<UserRecord>> _usersFuture;
  String _searchQuery = '';
  String _roleFilter = 'All Roles';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void didUpdateWidget(covariant UsersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadUsers();
  }

  void _loadUsers() {
    _usersFuture = widget.userRepository.getUsers();
  }

  void _refreshUsers() => setState(_loadUsers);

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Users',
      action: ElevatedButton.icon(
        onPressed: () => _showAddUser(context),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add User'),
      ),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final search = TextField(
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search user...',
                ),
              );
              final roles = DropdownButtonFormField<String>(
                initialValue: _roleFilter,
                items: const [
                  DropdownMenuItem(
                    value: 'All Roles',
                    child: Text('All Roles'),
                  ),
                  DropdownMenuItem(value: 'Manager', child: Text('Manager')),
                  DropdownMenuItem(value: 'Employee', child: Text('Employee')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _roleFilter = value);
                },
              );
              if (constraints.maxWidth < 650) {
                return Column(
                  children: [
                    search,
                    const SizedBox(height: 12),
                    roles,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: search),
                  const SizedBox(width: 12),
                  SizedBox(width: 180, child: roles),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          Expanded(
            child: FutureBuilder<List<UserRecord>>(
              future: _usersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final query = _searchQuery.trim().toLowerCase();
                final users = (snapshot.data ?? const <UserRecord>[])
                    .where(
                      (user) =>
                          (user.name.toLowerCase().contains(query) ||
                              user.username.toLowerCase().contains(query)) &&
                          (_roleFilter == 'All Roles' ||
                              user.role == _roleFilter),
                    )
                    .toList();
                return SingleChildScrollView(
                  child: DataTableCard(
                    headers: const ['Name', 'Username', 'Role', 'Status'],
                    flexes: const [3, 3, 3, 2],
                    rows: users
                        .map(
                          (user) => [
                            InkWell(
                              onTap: () => _showUserDetails(context, user),
                              child: Text(
                                user.name,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            Text(user.username, style: AppTextStyles.body),
                            Text(user.role, style: AppTextStyles.body),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: StatusBadge(user.status),
                            ),
                          ],
                        )
                        .toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showUserDetails(BuildContext context, UserRecord user) async {
    await showPrototypeDialog(
      context: context,
      title: user.name,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StatusBadge(user.status),
          const SizedBox(height: 16),
          _row('User ID', user.id),
          _row('Username', user.username),
          _row('Role', user.role),
          _row(
            'Access',
            user.role == 'Manager'
                ? 'All management modules'
                : 'Orders, Inventory, Stock Movement',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
        OutlinedButton(
          onPressed: () {
            Navigator.pop(context);
            _showEditUser(context, user);
          },
          child: const Text('Edit User'),
        ),
        ElevatedButton(
          onPressed: user.status == 'Inactive'
              ? null
              : () async {
                  await widget.userRepository.deleteUser(user.id);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  _refreshUsers();
                },
          child: const Text('Deactivate'),
        ),
      ],
    );
  }

  Future<void> _showEditUser(BuildContext context, UserRecord user) async {
    final nameController = TextEditingController(text: user.name);
    final usernameController = TextEditingController(text: user.username);
    var selectedRole = user.role;

    await showPrototypeDialog(
      context: context,
      title: 'Edit User',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          dialogField('Name', controller: nameController),
          dialogField('Username', controller: usernameController),
          DropdownButtonFormField<String>(
            initialValue: selectedRole,
            items: const [
              DropdownMenuItem(value: 'Manager', child: Text('Manager')),
              DropdownMenuItem(value: 'Employee', child: Text('Employee')),
            ],
            onChanged: (value) {
              if (value != null) selectedRole = value;
            },
            decoration: const InputDecoration(labelText: 'Role'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (nameController.text.trim().isEmpty ||
                usernameController.text.trim().isEmpty) {
              return;
            }
            await widget.userRepository.updateUser(
              user.copyWith(
                name: nameController.text.trim(),
                username: usernameController.text.trim(),
                role: selectedRole,
              ),
            );
            if (!context.mounted) return;
            Navigator.pop(context);
            _refreshUsers();
          },
          child: const Text('Save Changes'),
        ),
      ],
    );
    nameController.dispose();
    usernameController.dispose();
  }

  Future<void> _showAddUser(BuildContext context) async {
    final nameController = TextEditingController();
    final usernameController = TextEditingController();
    var selectedRole = 'Employee';

    await showPrototypeDialog(
      context: context,
      title: 'Add User',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          dialogField('Name', controller: nameController),
          dialogField('Username', controller: usernameController),
          DropdownButtonFormField<String>(
            initialValue: selectedRole,
            items: const [
              DropdownMenuItem(value: 'Manager', child: Text('Manager')),
              DropdownMenuItem(value: 'Employee', child: Text('Employee')),
            ],
            onChanged: (value) {
              if (value != null) selectedRole = value;
            },
            decoration: const InputDecoration(labelText: 'Role'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (nameController.text.trim().isEmpty ||
                usernameController.text.trim().isEmpty) {
              return;
            }
            final users = await widget.userRepository.getUsers();
            await widget.userRepository.createUser(
              UserRecord(
                id: _nextUserId(users),
                name: nameController.text.trim(),
                username: usernameController.text.trim(),
                role: selectedRole,
                status: 'Active',
              ),
            );
            if (!context.mounted) return;
            Navigator.pop(context);
            _refreshUsers();
          },
          child: const Text('Save User'),
        ),
      ],
    );
    nameController.dispose();
    usernameController.dispose();
  }

  String _nextUserId(List<UserRecord> users) {
    var highest = 0;
    for (final user in users) {
      final value = int.tryParse(user.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      if (value > highest) highest = value;
    }
    return 'USR-${(highest + 1).toString().padLeft(3, '0')}';
  }

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(color: AppColors.gray700),
        ),
        const SizedBox(width: 20),
        Flexible(
          child: Text(
            value,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    ),
  );
}
