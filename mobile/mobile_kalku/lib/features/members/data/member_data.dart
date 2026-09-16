import '../models/member.dart';

/// Group member list for the "Daftar Anggota" screen.
///
/// TODO(taufikk): NIM dan foto masih placeholder — ganti dengan data asli
/// kelompok sebelum submit tugas. Nama & pembagian peran diambil dari
/// PRODUCTION_SPLIT_2_PERSON.md.
const List<Member> kGroupMembers = [
  Member(
    name: 'Dito',
    nim: 'TODO: isi NIM',
    role: 'Developer 1 — Core, Database, Security, Auth, BMI',
  ),
  Member(
    name: 'Taufikk',
    nim: 'TODO: isi NIM',
    role:
        'Developer 2 — Design System, Navigation, Kalender Nusantara, Stopwatch',
  ),
];
