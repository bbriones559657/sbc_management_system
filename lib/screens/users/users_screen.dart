import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock_data.dart';
import '../../models/user_record.dart';
import '../../widgets/common/app_dialog.dart';
import '../../widgets/common/data_table_card.dart';
import '../../widgets/common/status_badge.dart';
import '../../widgets/layout/app_page.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPage(
      title: 'Users',
      action: ElevatedButton.icon(onPressed: () => _showAddUser(context), icon: const Icon(Icons.add, size: 18), label: const Text('Add User')),
      child: Column(children: [
        Row(children: [const Expanded(child: TextField(decoration: InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search user...'))), const SizedBox(width: 12), SizedBox(width: 180, child: DropdownButtonFormField<String>(initialValue: 'All Roles', items: const [DropdownMenuItem(value: 'All Roles', child: Text('All Roles')), DropdownMenuItem(value: 'Manager', child: Text('Manager')), DropdownMenuItem(value: 'Employee', child: Text('Employee'))], onChanged: (_) {}))]),
        const SizedBox(height: 18),
        Expanded(child: SingleChildScrollView(child: DataTableCard(headers: const ['Name','Username','Role','Status'], flexes: const [3,3,3,2], rows: MockData.users.map((user) => [InkWell(onTap: () => _showUserDetails(context, user), child: Text(user.name, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primary))), Text(user.username, style: AppTextStyles.body), Text(user.role, style: AppTextStyles.body), Align(alignment: Alignment.centerLeft, child: StatusBadge(user.status))]).toList()))),
      ]),
    );
  }

  void _showUserDetails(BuildContext context, UserRecord user) {
    showPrototypeDialog(context: context, title: user.name, content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [StatusBadge(user.status), const SizedBox(height: 16), _row('Username', user.username), _row('Role', user.role), _row('Access', user.role == 'Manager' ? 'All management modules' : 'Orders, Inventory, Stock Movement')]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')), OutlinedButton(onPressed: () => _showEditUser(context, user), child: const Text('Edit User')), ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Deactivate'))]);
  }

  void _showEditUser(BuildContext context, UserRecord user) {
    showPrototypeDialog(context: context, title: 'Edit User', content: Column(mainAxisSize: MainAxisSize.min, children: [dialogField('Name', value: user.name), dialogField('Username', value: user.username), DropdownButtonFormField<String>(initialValue: user.role, items: const [DropdownMenuItem(value: 'Manager', child: Text('Manager')), DropdownMenuItem(value: 'Employee', child: Text('Employee'))], onChanged: (_) {}, decoration: const InputDecoration(labelText: 'Role'))]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Save Changes'))]);
  }

  void _showAddUser(BuildContext context) {
    showPrototypeDialog(context: context, title: 'Add User', content: Column(mainAxisSize: MainAxisSize.min, children: [dialogField('Name', hint: 'Enter employee name'), dialogField('Username', hint: 'Enter username'), dialogField('Password', hint: 'Enter temporary password')]), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Save User'))]);
  }

  Widget _row(String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: AppTextStyles.body.copyWith(color: AppColors.gray700)), Flexible(child: Text(value, style: AppTextStyles.bodyMedium, textAlign: TextAlign.right))]));
}
