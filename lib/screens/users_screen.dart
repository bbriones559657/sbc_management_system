import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Users', style: AppTextStyles.h1),
                ElevatedButton.icon(
                  onPressed: () {
                    _showAddUserDialog(context);
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add User'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search users...',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                _buildRoleFilter(),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      _buildTableHeader(),
                      const Divider(color: AppColors.gray200),
                      Expanded(
                        child: ListView(
                          children: [
                            _buildUserRow(
                              context,
                              'Yesha',
                              'yesha',
                              'Manager',
                              'Active',
                            ),
                            _buildUserRow(
                              context,
                              'Carl',
                              'carl',
                              'Employee',
                              'Active',
                            ),
                            _buildUserRow(
                              context,
                              'Josh',
                              'josh',
                              'Employee',
                              'Active',
                            ),
                            _buildUserRow(
                              context,
                              'Brian',
                              'brian',
                              'Employee',
                              'Active',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleFilter() {
    return SizedBox(
      width: 180,
      child: DropdownButtonFormField<String>(
        initialValue: 'All Roles',
        decoration: const InputDecoration(labelText: 'Role'),
        items: const [
          DropdownMenuItem(value: 'All Roles', child: Text('All Roles')),
          DropdownMenuItem(value: 'Manager', child: Text('Manager')),
          DropdownMenuItem(value: 'Employee', child: Text('Employee')),
        ],
        onChanged: (value) {},
      ),
    );
  }

  Widget _buildTableHeader() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            'Name',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            'Username',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            'Role',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Status',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildUserRow(
    BuildContext context,
    String name,
    String username,
    String role,
    String status,
  ) {
    return InkWell(
      onTap: () {
        _showUserDetails(context, name, username, role, status);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.gray200)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                name,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            Expanded(flex: 3, child: Text(username, style: AppTextStyles.body)),
            Expanded(flex: 3, child: Text(role, style: AppTextStyles.body)),
            Expanded(
              flex: 2,
              child: Text(
                status,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUserDetails(
    BuildContext context,
    String name,
    String username,
    String role,
    String status,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(name),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Username', username),
                _buildDetailRow('Role', role),
                _buildDetailRow('Status', status),
                const SizedBox(height: AppSpacing.lg),
                const Divider(color: AppColors.gray200),
                const SizedBox(height: AppSpacing.md),
                Text('Access', style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.md),
                Text(
                  role == 'Manager'
                      ? 'Can manage users, inventory, finances, reports, and business operations.'
                      : 'Can process orders and access assigned operational functions.',
                  style: AppTextStyles.body,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Close'),
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _showEditUserDialog(context, name, username, role);
              },
              child: const Text('Edit'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _showStatusDialog(context, name, status);
              },
              child: Text(status == 'Active' ? 'Deactivate' : 'Activate'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: AppTextStyles.caption),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add User'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const TextField(decoration: InputDecoration(labelText: 'Name')),
                const SizedBox(height: AppSpacing.md),
                const TextField(
                  decoration: InputDecoration(labelText: 'Username'),
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: 'Employee',
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: const [
                    DropdownMenuItem(
                      value: 'Employee',
                      child: Text('Employee'),
                    ),
                    DropdownMenuItem(value: 'Manager', child: Text('Manager')),
                  ],
                  onChanged: (value) {},
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Save User'),
            ),
          ],
        );
      },
    );
  }

  void _showEditUserDialog(
    BuildContext context,
    String name,
    String username,
    String role,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit User'),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: TextEditingController(text: name),
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: TextEditingController(text: username),
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<String>(
                  initialValue: role,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: const [
                    DropdownMenuItem(
                      value: 'Employee',
                      child: Text('Employee'),
                    ),
                    DropdownMenuItem(value: 'Manager', child: Text('Manager')),
                  ],
                  onChanged: (value) {},
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  void _showStatusDialog(BuildContext context, String name, String status) {
    final newStatus = status == 'Active' ? 'deactivated' : 'activated';

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(status == 'Active' ? 'Deactivate User' : 'Activate User'),
          content: Text('Are you sure you want to $newStatus $name?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
