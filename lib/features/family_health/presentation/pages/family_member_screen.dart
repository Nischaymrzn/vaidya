import 'package:flutter/material.dart';
import 'package:vaidya/features/family_health/presentation/pages/family_health_screen.dart';

class FamilyMemberScreen extends StatelessWidget {
  final String memberId;

  const FamilyMemberScreen({super.key, required this.memberId});

  @override
  Widget build(BuildContext context) {
    return FamilyHealthScreen(initialMemberId: memberId, memberOnly: true);
  }
}
