/* Inline SVG mascot poses — charcoal silhouette, teal eyes */
const M = {
  idle: `<svg viewBox="0 0 120 100" fill="none" xmlns="http://www.w3.org/2000/svg">
    <ellipse cx="60" cy="88" rx="28" ry="6" fill="#0C0E0E" opacity=".5"/>
    <path d="M38 42c0-14 8-28 22-28s22 14 22 28v22c0 12-10 20-22 20S38 76 38 64V42z" fill="#2A2F2F"/>
    <path d="M42 28l-8-16 14 8M78 28l8-16-14 8" stroke="#2A2F2F" stroke-width="8" stroke-linecap="round"/>
    <circle cx="50" cy="48" r="3.5" fill="#14B8A6"/><circle cx="70" cy="48" r="3.5" fill="#14B8A6"/>
    <path d="M56 58c2 3 6 3 8 0" stroke="#6B7373" stroke-width="2" stroke-linecap="round"/>
    <path d="M82 58c10 4 16 14 14 24" stroke="#2A2F2F" stroke-width="8" stroke-linecap="round"/>
  </svg>`,
  hunt: `<svg viewBox="0 0 120 100" fill="none" xmlns="http://www.w3.org/2000/svg">
    <ellipse cx="60" cy="90" rx="30" ry="5" fill="#0C0E0E" opacity=".45"/>
    <path d="M34 50c2-16 12-30 26-30s24 14 26 30l2 18c1 12-9 20-22 20H54c-13 0-22-8-20-20l0-18z" fill="#2A2F2F"/>
    <path d="M44 30l-10-14 16 6M76 30l10-14-16 6" stroke="#2A2F2F" stroke-width="8" stroke-linecap="round"/>
    <circle cx="52" cy="50" r="3.5" fill="#14B8A6"/><circle cx="72" cy="50" r="3.5" fill="#14B8A6"/>
    <ellipse cx="62" cy="60" rx="3" ry="2" fill="#6B7373"/>
    <path d="M30 62c-6 8-4 18 4 22" stroke="#2A2F2F" stroke-width="7" stroke-linecap="round"/>
    <path d="M90 62c6 8 4 18-4 22" stroke="#2A2F2F" stroke-width="7" stroke-linecap="round"/>
  </svg>`,
  found: `<svg viewBox="0 0 120 100" fill="none" xmlns="http://www.w3.org/2000/svg">
    <ellipse cx="60" cy="90" rx="28" ry="5" fill="#0C0E0E" opacity=".4"/>
    <path d="M40 44c0-14 9-26 20-26s20 12 20 26v20c0 11-9 18-20 18S40 75 40 64V44z" fill="#2A2F2F"/>
    <path d="M44 30l-6-14 12 7M76 30l6-14-12 7" stroke="#2A2F2F" stroke-width="8" stroke-linecap="round"/>
    <circle cx="52" cy="48" r="3.5" fill="#E8B84A"/><circle cx="68" cy="48" r="3.5" fill="#E8B84A"/>
    <path d="M54 58c3 4 9 4 12 0" stroke="#34D399" stroke-width="2.5" stroke-linecap="round"/>
    <circle cx="88" cy="36" r="10" fill="#0D9488" opacity=".9"/>
    <path d="M84 36l3 3 6-7" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
  </svg>`,
  celebrate: `<svg viewBox="0 0 120 100" fill="none" xmlns="http://www.w3.org/2000/svg">
    <ellipse cx="60" cy="92" rx="26" ry="4" fill="#0C0E0E" opacity=".35"/>
    <path d="M42 48c0-16 8-28 18-28s18 12 18 28v16c0 12-8 20-18 20s-18-8-18-20V48z" fill="#2A2F2F"/>
    <path d="M46 32l-8-18 14 8M74 32l8-18-14 8" stroke="#2A2F2F" stroke-width="8" stroke-linecap="round"/>
    <path d="M50 46c0 2 2 3 4 3s4-1 4-3M62 46c0 2 2 3 4 3s4-1 4-3" fill="#14B8A6"/>
    <path d="M54 58c3 5 9 5 12 0" stroke="#34D399" stroke-width="2.5" stroke-linecap="round"/>
    <path d="M28 40l8 4M92 40l-8 4M34 28l6 8M86 28l-6 8" stroke="#E8B84A" stroke-width="2.5" stroke-linecap="round"/>
  </svg>`,
  nap: `<svg viewBox="0 0 120 100" fill="none" xmlns="http://www.w3.org/2000/svg">
    <ellipse cx="60" cy="86" rx="32" ry="6" fill="#0C0E0E" opacity=".4"/>
    <ellipse cx="60" cy="62" rx="34" ry="22" fill="#2A2F2F"/>
    <path d="M40 52l-6-12 10 4M80 52l6-12-10 4" stroke="#2A2F2F" stroke-width="7" stroke-linecap="round"/>
    <path d="M48 60c2 0 4 1 4 2M68 60c2 0 4 1 4 2" stroke="#6B7373" stroke-width="2" stroke-linecap="round"/>
    <path d="M56 68c2 2 6 2 8 0" stroke="#6B7373" stroke-width="2" stroke-linecap="round"/>
    <path d="M88 58c8 2 12 10 8 18" stroke="#2A2F2F" stroke-width="7" stroke-linecap="round"/>
  </svg>`,
  peek: `<svg viewBox="0 0 120 100" fill="none" xmlns="http://www.w3.org/2000/svg">
    <ellipse cx="70" cy="90" rx="22" ry="4" fill="#0C0E0E" opacity=".4"/>
    <path d="M48 70c4-22 16-36 30-32 12 4 16 22 12 38-3 12-14 18-26 14S45 84 48 70z" fill="#2A2F2F"/>
    <path d="M62 42l-4-14 10 6M82 40l8-12-12 4" stroke="#2A2F2F" stroke-width="7" stroke-linecap="round"/>
    <circle cx="70" cy="58" r="3" fill="#14B8A6"/><circle cx="84" cy="56" r="3" fill="#14B8A6"/>
    <path d="M74 66c2 2 6 2 8 0" stroke="#6B7373" stroke-width="2" stroke-linecap="round"/>
  </svg>`,
};

function mountMascots() {
  document.querySelectorAll("[data-mascot]").forEach((el) => {
    const pose = el.getAttribute("data-mascot") || "idle";
    el.innerHTML = M[pose] || M.idle;
  });
}

document.addEventListener("DOMContentLoaded", mountMascots);
