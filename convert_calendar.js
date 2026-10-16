/**
 * Convert the verified calendar.csv (embedded in the .md file) into
 * assets/bs_data.json matching BsDataService / BsMonth / BsDay schema.
 *
 * CSV columns:
 *   bs_year, baisakh1_ad, m01..m12 (month lengths), evidence, sources, notes
 *
 * Output JSON:
 *   {
 *     "months": [
 *       {
 *         "bsYear": int,
 *         "bsMonth": int (1..12),
 *         "bsMonthName": str,
 *         "bsMonthNameNepali": str,
 *         "daysInMonth": int,
 *         "adStart": "yyyy-MM-dd",
 *         "adEnd": "yyyy-MM-dd",
 *         "days": [
 *           {"bsDay": int, "adDate": "yyyy-MM-dd", "weekday": str,
 *            "weekdayNepali": str, "tithi": str, "festival": null|str}
 *         ],
 *         "evidence": str,
 *         "sources": str,
 *         "notes": str
 *       },
 *       ...
 *     ]
 *   }
 */

const fs = require('fs');
const path = require('path');

const MONTH_NAMES = [
  '', // index 0 unused
  'Baisakh', 'Jestha', 'Ashad', 'Shrawan', 'Bhadra', 'Ashwin',
  'Kartik', 'Mangsir', 'Poush', 'Magh', 'Falgun', 'Chaitra',
];

const MONTH_NAMES_NEPALI = [
  '', // index 0 unused
  'बैशाख', 'जेठ', 'असार', 'श्रावण', 'भाद्रपद', 'असोज',
  'कार्तिक', 'मंसिर', 'पौष', 'माघ', 'फाल्गुन', 'चैत्र',
];

const WEEKDAY_EN = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
const WEEKDAY_NE = ['आइतबार', 'सोमबार', 'मंगलबार', 'बुधबार', 'बिहिबार', 'शुक्रबार', 'शनिबार'];

const mdPath = process.argv[2] ||
  'C:\\Users\\user\\Downloads\\Raw Data · Verified calendar.csv (1975–2083, evidence-tagged).md';
const outPath = process.argv[3] ||
  'C:\\Users\\user\\Downloads\\Project\\nCalender\\assets\\bs_data.json';

function isoToDate(s) {
  const [y, m, d] = s.split('-').map(Number);
  return new Date(Date.UTC(y, m - 1, d));
}

function dateToISO(d) {
  const y = d.getUTCFullYear();
  const m = String(d.getUTCMonth() + 1).padStart(2, '0');
  const day = String(d.getUTCDate()).padStart(2, '0');
  return `${y}-${m}-${day}`;
}

function addDays(d, n) {
  return new Date(d.getTime() + n * 86400000);
}

// Read markdown and extract the ```csv ... ``` block
const content = fs.readFileSync(mdPath, 'utf-8');
const match = content.match(/```csv\n([\s\S]*?)\n```/);
if (!match) {
  console.error('ERROR: No ```csv block found in ' + mdPath);
  process.exit(1);
}

const csvText = match[1].trim();
const lines = csvText.split('\n').filter(ln => ln.trim());
console.log(`Data rows: ${lines.length - 1}`);

const allMonths = [];

for (let i = 1; i < lines.length; i++) {
  const parts = lines[i].split(',');
  if (parts.length < 15) {
    console.log(`SKIP short row: ${parts[0] || '?'}`);
    continue;
  }

  const bsYear = parseInt(parts[0], 10);
  const baisakh1Ad = parts[1];
  const monthLengths = [];
  for (let j = 2; j <= 13; j++) {
    monthLengths.push(parseInt(parts[j], 10));
  }
  const evidence = parts[14] || '';
  const sources = parts[15] || '';
  const notes = parts[16] || '';

  let cursor = isoToDate(baisakh1Ad);

  for (let monthIdx = 1; monthIdx <= 12; monthIdx++) {
    const length = monthLengths[monthIdx - 1];
    const adStart = new Date(cursor);
    const adEnd = addDays(new Date(cursor), length - 1);

    const days = [];
    for (let day = 1; day <= length; day++) {
      const adDate = addDays(new Date(cursor), day - 1);
      // getUTCDay: Sun=0 .. Sat=6 (JS Date uses Sun=0 already)
      const wdIdx = adDate.getUTCDay();
      days.push({
        bsDay: day,
        adDate: dateToISO(adDate),
        weekday: WEEKDAY_EN[wdIdx],
        weekdayNepali: WEEKDAY_NE[wdIdx],
        tithi: '',
        festival: null,
      });
    }

    allMonths.push({
      bsYear: bsYear,
      bsMonth: monthIdx,
      bsMonthName: MONTH_NAMES[monthIdx],
      bsMonthNameNepali: MONTH_NAMES_NEPALI[monthIdx],
      daysInMonth: length,
      adStart: dateToISO(adStart),
      adEnd: dateToISO(adEnd),
      days: days,
      evidence: evidence,
      sources: sources,
      notes: notes,
    });

    cursor = addDays(new Date(adEnd), 1);
  }
}

const output = { months: allMonths };
fs.writeFileSync(outPath, JSON.stringify(output, null, 2), 'utf-8');
console.log(`Wrote ${allMonths.length} months to ${outPath}`);
