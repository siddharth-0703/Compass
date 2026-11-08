import 'package:flutter/material.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String _selectedRole = 'All';

  final List<Map<String, dynamic>> _users = [
    {
      'id': 'u-1',
      'name': 'Siddharth Jaiswar',
      'email': 'siddharthjaiswar9107@gmail.com',
      'phone': '+918779170923',
      'role': 'Admin',
      'status': 'Active',
      'state': 'Maharashtra',
    },
    {
      'id': 'u-2',
      'name': 'Rameshwar Patil',
      'email': 'ramesh.patil@agrotech.in',
      'phone': '+919822014589',
      'role': 'Entrepreneur',
      'status': 'Active',
      'state': 'Maharashtra',
    },
    {
      'id': 'u-3',
      'name': 'Dr. Ananya Sharma',
      'email': 'ananya.sharma@icar.gov.in',
      'phone': '+919811056723',
      'role': 'Mentor',
      'status': 'Active',
      'state': 'Madhya Pradesh',
    },
    {
      'id': 'u-4',
      'name': 'Vikas Gramin Sansthan',
      'email': 'contact@vikasgramin.org',
      'phone': '+919877123456',
      'role': 'NGO',
      'status': 'Active',
      'state': 'Gujarat',
    },
    {
      'id': 'u-5',
      'name': 'Sunita Deshmukh',
      'email': 'sunita.shg@mahila.in',
      'phone': '+919765432109',
      'role': 'Entrepreneur',
      'status': 'Active',
      'state': 'Maharashtra',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedRole == 'All'
        ? _users
        : _users.where((u) => u['role'] == _selectedRole).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management',
            style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: ['All', 'Admin', 'Entrepreneur', 'Mentor', 'NGO']
                  .map((role) {
                final isSelected = _selectedRole == role;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(role),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedRole = role);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final user = filtered[index];
                final role = user['role'] as String;

                Color roleColor = Colors.blue;
                if (role == 'Admin') roleColor = Colors.purple;
                if (role == 'Mentor') roleColor = Colors.amber;
                if (role == 'NGO') roleColor = Colors.teal;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8,),
                    leading: CircleAvatar(
                      backgroundColor: roleColor.withValues(alpha: 0.15),
                      child: Text(
                        user['name'].substring(0, 1),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: roleColor,),
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            user['name'],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15,),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2,),
                          decoration: BoxDecoration(
                            color: roleColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            role,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: roleColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(user['email'],
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.6),),),
                        Text('${user['phone']} • ${user['state']}',
                            style: TextStyle(
                                fontSize: 11,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5),),),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

