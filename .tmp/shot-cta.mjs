import { chromium } from 'playwright';

const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 1280, height: 900 } });
await page.goto('http://127.0.0.1:3456/download/copycat', { waitUntil: 'networkidle' });

// Force-load lazy images and scroll CTA into view
await page.evaluate(async () => {
  const h2 = [...document.querySelectorAll('h2')].find((el) =>
    el.textContent?.includes('Ready when you are')
  );
  const section = h2?.closest('section');
  section?.scrollIntoView({ block: 'center' });
  for (const img of document.querySelectorAll('img')) {
    if (img.loading === 'lazy') img.loading = 'eager';
    if (!img.complete) {
      await new Promise((res) => {
        img.addEventListener('load', res, { once: true });
        img.addEventListener('error', res, { once: true });
        setTimeout(res, 2000);
      });
    }
  }
});
await page.waitForTimeout(800);

const section = page.locator('section').filter({ hasText: 'Ready when you are' });
await section.screenshot({ path: '.tmp/live-verify/cta-loaded.png' });

// zoom mascot
const box = await section.boundingBox();
await page.screenshot({
  path: '.tmp/live-verify/cta-mascot-area.png',
  clip: { x: box.x + box.width / 2 - 180, y: box.y + 20, width: 360, height: 220 },
});

const info = await page.evaluate(() => {
  const img = document.querySelector('.cc-cta-mascot');
  if (!img) return null;
  const cs = getComputedStyle(img);
  return {
    src: img.currentSrc || img.src,
    complete: img.complete,
    natural: [img.naturalWidth, img.naturalHeight],
    display: [img.clientWidth, img.clientHeight],
    filter: cs.filter,
    opacity: cs.opacity,
    mixBlendMode: cs.mixBlendMode,
  };
});
console.log(JSON.stringify(info, null, 2));
await browser.close();
