# NusaFit AI Agent Guide Pack

Paket ini memecah dokumentasi proyek menjadi beberapa concern agar AI agent tidak mencampur design, UI, database, dan logic komputasi.

## File inti

| File | Fungsi |
|---|---|
| `PRD_NusaFit_Lengkap.md` | Seluruh requirement produk |
| `WRITING_RULES.md` | Aturan struktur dan penulisan source code |
| `MENU_IMPLEMENTATION.md` | Pembagian kode per menu/screen |
| `COMPUTATION_LOGIC.md` | Formula dan algoritma domain |
| `DESIGN_SYSTEM.md` | Warna, layout, typography, komponen visual |
| `agent.md` | Instruksi wajib semua AI agent |
| `AGENTS.md` | Compatibility entry point untuk agent yang mendukung AGENTS.md |
| `AI_AGENT_CONFIG.yaml` | Manifest konfigurasi instruction files |

## Compatibility shims

Paket menyediakan pointer untuk beberapa tool umum:

```text
CLAUDE.md
.github/copilot-instructions.md
.cursor/rules/00-nusafit-agent.mdc
.clinerules
.windsurfrules
.windsurf/rules/00-nusafit-agent.md
.roo/rules/00-nusafit-agent.md
CONVENTIONS.md
```

Semua file tersebut hanya menunjuk ke `agent.md` agar tidak terjadi duplicated/conflicting rules.

## Penting

Tidak ada standar universal yang dapat memaksa **semua** AI coding agent di dunia otomatis membaca `agent.md` dengan nama yang sama. Karena itu paket ini menggunakan dua strategi:

1. `agent.md` sebagai canonical instruction.
2. Compatibility entrypoint untuk beberapa konvensi agent yang umum.

Jika memakai agent baru yang mempunyai nama file instruksi lain, tambahkan shim baru yang hanya mengarahkan ke `agent.md`.
