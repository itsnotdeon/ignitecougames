// @ts-nocheck
export const BOND_KEY="ignite-bond-v1";
export const BOND_PROMPTS={
  daily:["Apa satu hal kecil yang membuatmu merasa dekat denganku hari ini?","Kalau malam ini hanya punya satu jam bersama, kamu ingin menghabiskannya bagaimana?","Apa momen kecil kita akhir-akhir ini yang ingin kamu ulang?","Hal apa dari pasanganmu yang akhir-akhir ini paling kamu hargai?"],
  deep:["Apa hal tentang masa depan kita yang paling ingin kamu bangun bersama?","Kapan kamu merasa paling aman untuk menjadi dirimu sendiri bersamaku?","Apa sesuatu yang ingin kamu pelajari tentang pasanganmu tahun ini?","Apa satu kebiasaan kecil yang bisa membuat hubungan kita terasa lebih hangat?"],
  quiz:["Siapa yang lebih mungkin mengajak liburan dadakan?","Siapa yang lebih cepat bilang ayo coba saat ada hal baru?","Siapa yang biasanya lebih dulu mencairkan suasana setelah salah paham?"]
};
export function readBond(){try{const raw=JSON.parse(localStorage.getItem(BOND_KEY)||"{}");return{...raw,favorites:Array.isArray(raw?.favorites)?raw.favorites:[],goals:Array.isArray(raw?.goals)?raw.goals:[]}}catch{return{favorites:[],goals:[]}}}
export function writeBond(v){localStorage.setItem(BOND_KEY,JSON.stringify(v));return v}
export function pickBond(type,current=""){const pool=BOND_PROMPTS[type]||BOND_PROMPTS.daily;const choices=pool.filter(x=>x!==current);return choices[Math.floor(Math.random()*choices.length)]||pool[0]}