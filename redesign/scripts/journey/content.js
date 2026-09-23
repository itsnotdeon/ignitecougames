export const starterNormalCards=[
"Hal kecil apa yang membuatmu merasa paling dihargai oleh pasanganmu?",
"Kalau kita punya satu hari kosong tanpa kewajiban, kamu ingin menghabiskannya bagaimana?",
"Apa momen sederhana bersama pasangan yang masih sering kamu ingat?",
"Hal apa dari pasanganmu yang akhir-akhir ini membuatmu tersenyum?",
"Apa satu hal yang ingin lebih sering kita lakukan berdua?",
"Kalau hubungan kita punya soundtrack, lagu apa yang cocok hari ini?"
];
export const starterTruth=[
"Apa hal kecil yang ingin kamu ceritakan kepadaku tapi belum sempat?",
"Kapan terakhir kali kamu merasa sangat dekat denganku?",
"Apa kebiasaan kecilku yang diam-diam kamu suka?",
"Apa satu kenangan kita yang ingin kamu ulang?",
"Menurutmu, apa yang membuat waktu berdua terasa spesial?"
];
export const starterDare=[
"Berikan pasanganmu pujian yang sangat spesifik.",
"Tatap mata pasanganmu selama 15 detik tanpa berbicara.",
"Ceritakan satu hal yang kamu syukuri dari hubungan kalian.",
"Biarkan pasanganmu memilih lagu untuk kalian dengarkan sekarang.",
"Peluk pasanganmu selama 20 detik."
];
export function randomUnused(pool,used){const available=pool.filter(x=>!used.has(x));const source=available.length?available:pool;if(!source.length)return"";const value=source[Math.floor(Math.random()*source.length)];used.add(value);return value}
