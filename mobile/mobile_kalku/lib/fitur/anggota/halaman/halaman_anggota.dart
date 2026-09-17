import 'package:flutter/material.dart';

import '../../../inti/konstanta/warna_aplikasi.dart';
import '../../../inti/konstanta/dimensi_aplikasi.dart';
import '../../../komponen/kartu_aplikasi.dart';
import '../data/data_anggota.dart';
import '../model/anggota.dart';

class MembersPage extends StatelessWidget {
  const MembersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Daftar Anggota',
          style: TextStyle(
            color: AppColors.surface,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppColors.surface,
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.primaryGradient,
          ),
        ),
      ),
        
      body: ListView.separated(
        padding: const EdgeInsets.all(AppDimensions.screenHorizontalPadding),
        itemCount: kGroupMembers.length,
          separatorBuilder: (context, _) =>
            const SizedBox(height: AppDimensions.fieldGap),
        itemBuilder: (context, index) => _MemberCard(member: kGroupMembers[index]),
      ),
    );
  }
}

class _MemberCard extends StatelessWidget {
  const _MemberCard({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          _Avatar(member: member),
          const SizedBox(width: AppDimensions.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  member.nim,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  member.role,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Avatar with photo -> initials fallback (MENU_IMPLEMENTATION.md #5:
/// "Jika foto gagal -> fallback avatar/initial").
class _Avatar extends StatelessWidget {
  const _Avatar({required this.member});

  final Member member;

  @override
  Widget build(BuildContext context) {
    const size = 52.0;
    final assetPath = member.avatarAssetPath;

    if (assetPath == null) {
      return _InitialsCircle(initials: member.initials, size: size);
    }

    return ClipOval(
      child: Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _InitialsCircle(initials: member.initials, size: size);
        },
      ),
    );
  }
}

class _InitialsCircle extends StatelessWidget {
  const _InitialsCircle({required this.initials, required this.size});

  final String initials;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );
  }
}
