/**
 * Browser checks for PEAICE FREE SHOOTER sizing and scroll lock.
 *
 *   npm install --prefix /tmp/pwtest playwright-core
 *   node tests/scroll-lock.mjs
 *
 * Serves this repo on two ports so the harness matches the live embed:
 * services page (cross-origin) → catalog (same origin as the game) → game.
 */
import { createRequire } from 'node:module';
import { existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { spawn } from 'node:child_process';
import { setTimeout as delay } from 'node:timers/promises';

const requireFrom = ['/tmp/pwtest/package.json'].find(p => existsSync(p));
if (!requireFrom) throw new Error('Install playwright-core: npm install --prefix /tmp/pwtest playwright-core');
const { chromium } = createRequire(requireFrom)('playwright-core');

const GAME_PORT = 4183;
const OUTER_PORT = 4184;
const ARTIFACTS = '/opt/cursor/artifacts';
mkdirSync(ARTIFACTS, { recursive: true });

const receipt = { checks: [], limitations: [] };
let failed = 0;
function check(name, ok, detail) {
  receipt.checks.push({ name, ok, detail });
  const mark = ok ? 'PASS' : 'FAIL';
  console.log(`${mark} ${name}${detail !== undefined ? ' — ' + JSON.stringify(detail) : ''}`);
  if (!ok) failed++;
}

function startServer(port) {
  const child = spawn('python3', ['-m', 'http.server', String(port), '--bind', '127.0.0.1'], {
    cwd: '/workspace',
    stdio: 'ignore'
  });
  return child;
}
async function waitFor(url) {
  for (let i = 0; i < 40; i++) {
    try {
      const res = await fetch(url);
      if (res.ok) return;
    } catch {}
    await delay(100);
  }
  throw new Error('server did not start: ' + url);
}

async function layoutOf(frame) {
  return frame.evaluate(() => {
    const stage = document.getElementById('stage').getBoundingClientRect();
    const canvas = document.getElementById('game');
    const box = canvas.getBoundingClientRect();
    const h1 = document.getElementById('gameTitle').getBoundingClientRect();
    const btn = document.getElementById('startBtn').getBoundingClientRect();
    const controls = document.querySelector('#titleScreen .controls').getBoundingClientRect();
    const screen = document.getElementById('titleScreen');
    const drift = document.body.innerText.includes('Benevolence Drift');
    const names = ['Session Amnesia', 'Alignment Illusion', 'INITIATE COHERENCE'];
    const text = document.body.innerText;
    const formula = document.querySelector('.subtitle').textContent;
    return {
      stage: { w: stage.width, h: stage.height },
      canvas: { w: box.width, h: box.height, bw: canvas.width, bh: canvas.height, styleW: canvas.style.width, styleH: canvas.style.height },
      client: { w: document.documentElement.clientWidth, h: document.documentElement.clientHeight },
      scroll: { w: document.documentElement.scrollWidth, h: document.documentElement.scrollHeight, top: document.scrollingElement.scrollTop },
      h1: { top: h1.top, bottom: h1.bottom, h: h1.height },
      btn: { top: btn.top, bottom: btn.bottom, w: btn.width },
      controlsTop: controls.top,
      screenScrollable: screen.scrollHeight > screen.clientHeight + 8,
      drift,
      formula,
      names: Object.fromEntries(names.map(n => [n, text.includes(n)])),
      links: document.querySelectorAll('a[href="https://peaice.org"]').length,
      parent: document.getElementById('titleScreen').parentElement.id,
      hudParent: document.getElementById('hud').parentElement.id
    };
  });
}

function assertLayout(name, lay, { narrow = false } = {}) {
  const cssRatio = lay.canvas.w / lay.canvas.h;
  const bufRatio = lay.canvas.bw / lay.canvas.bh;
  check(name + ' stage fills frame', Math.abs(lay.stage.w - lay.client.w) <= 1 && Math.abs(lay.stage.h - lay.client.h) <= 1, { stage: lay.stage, client: lay.client });
  check(name + ' canvas fills stage', Math.abs(lay.canvas.w - lay.stage.w) <= 1 && Math.abs(lay.canvas.h - lay.stage.h) <= 1, { canvas: lay.canvas, stage: lay.stage });
  check(name + ' buffer aspect matches css', Math.abs(cssRatio - bufRatio) < 0.02, { cssRatio, bufRatio });
  check(name + ' canvas is not pixel-stretched', lay.canvas.styleW === '' && lay.canvas.styleH === '', { styleW: lay.canvas.styleW, styleH: lay.canvas.styleH });
  check(name + ' no horizontal overflow', lay.scroll.w <= lay.client.w + 1, lay.scroll);
  check(name + ' title is inside the frame', lay.h1.top >= -1 && lay.h1.bottom > 0 && lay.h1.h >= (narrow ? 24 : 28), lay.h1);
  check(name + ' start control reachable', lay.btn.top >= -1 && lay.btn.w > 80 && (lay.btn.bottom <= lay.client.h + 1 || lay.screenScrollable), lay.btn);
  check(name + ' intro not clipped above the frame', lay.controlsTop >= -1, { controlsTop: lay.controlsTop });
  check(name + ' names preserved', lay.drift && Object.values(lay.names).every(Boolean) && lay.links >= 1 && lay.formula.includes('\u03b2') && lay.formula.includes('L\u00b2'), { drift: lay.drift, names: lay.names, links: lay.links, formula: lay.formula });
  check(name + ' screens are not trapped in the hud', lay.parent === 'ui' && lay.hudParent === 'ui', { parent: lay.parent, hudParent: lay.hudParent });
}

async function probe(frame) {
  return frame.evaluate(() => window.__peaice());
}

const gameServer = startServer(GAME_PORT);
const outerServer = startServer(OUTER_PORT);
const browser = await chromium.launch({ channel: 'chrome', headless: true });

try {
  await waitFor(`http://127.0.0.1:${GAME_PORT}/index.html`);
  await waitFor(`http://127.0.0.1:${OUTER_PORT}/tests/embed/services.html`);

  // --- game alone, desktop ---
  {
    const page = await browser.newPage({ viewport: { width: 1280, height: 800 } });
    const errors = [];
    page.on('pageerror', err => errors.push(String(err)));
    await page.goto(`http://127.0.0.1:${GAME_PORT}/index.html?probe=1`, { waitUntil: 'networkidle' });
    const lay = await layoutOf(page);
    assertLayout('desktop', lay);
    await page.screenshot({ path: `${ARTIFACTS}/desktop_1280_title.png` });
    const before = await probe(page);
    await page.locator('#startBtn').click();
    await page.waitForTimeout(80);
    const started = await probe(page);
    check('desktop play focuses the stage and locks scroll', started.state === 'playing' && started.lock === true && documentFocus(await page.evaluate(() => document.activeElement.id)), started);
    check('desktop document does not scroll on start', (await page.evaluate(() => document.scrollingElement.scrollTop)) === 0);
    const y0 = (await probe(page)).y;
    await page.keyboard.down('ArrowDown');
    await page.waitForTimeout(280);
    await page.keyboard.up('ArrowDown');
    const y1 = (await probe(page)).y;
    check('desktop arrow moves the player', y1 > y0 + 8, { y0, y1 });
    check('desktop arrow does not scroll the document', (await page.evaluate(() => document.scrollingElement.scrollTop)) === 0);
    await page.keyboard.down('KeyA');
    await page.waitForTimeout(280);
    await page.keyboard.up('KeyA');
    const x1 = (await probe(page)).x;
    await page.keyboard.down('KeyD');
    await page.waitForTimeout(280);
    await page.keyboard.up('KeyD');
    const x2 = (await probe(page)).x;
    check('desktop WASD moves the player', x2 > x1 + 8, { x1, x2 });
    const shots0 = (await probe(page)).shots;
    await page.keyboard.down('Space');
    await page.waitForTimeout(260);
    await page.keyboard.up('Space');
    const shots1 = (await probe(page)).shots;
    check('desktop space shoots', shots1 > shots0, { shots0, shots1 });
    check('desktop space does not scroll the document', (await page.evaluate(() => document.scrollingElement.scrollTop)) === 0);
    const prevented = await page.evaluate(() => {
      const plain = new KeyboardEvent('keydown', { key: 'ArrowDown', code: 'ArrowDown', bubbles: true, cancelable: true });
      const modified = new KeyboardEvent('keydown', { key: 'r', code: 'KeyR', ctrlKey: true, bubbles: true, cancelable: true });
      document.dispatchEvent(plain);
      document.dispatchEvent(modified);
      return { plain: plain.defaultPrevented, modified: modified.defaultPrevented };
    });
    check('desktop cancels play arrows but not ctrl+r', prevented.plain === true && prevented.modified === false, prevented);
    await page.keyboard.press('Tab');
    const tabbed = await page.evaluate(() => document.activeElement.id);
    check('desktop tab leaves the playfield for Pause', tabbed === 'pauseBtn', { tabbed });
    await page.keyboard.press('KeyP');
    const paused = await probe(page);
    check('desktop pause releases the lock', paused.state === 'paused' && paused.lock === false && paused.pressed.length === 0, paused);
    const resumeId = await page.evaluate(() => document.activeElement.id);
    check('desktop pause moves focus to Resume', resumeId === 'resumeBtn', { resumeId });
    check('desktop no page errors', errors.length === 0, errors);
    await page.screenshot({ path: `${ARTIFACTS}/desktop_1280_paused.png` });
    await page.close();
  }

  // --- game alone, narrow ---
  {
    const page = await browser.newPage({
      viewport: { width: 390, height: 844 },
      isMobile: true,
      hasTouch: true,
      deviceScaleFactor: 2
    });
    await page.goto(`http://127.0.0.1:${GAME_PORT}/index.html?probe=1`, { waitUntil: 'networkidle' });
    const lay = await layoutOf(page);
    assertLayout('narrow', lay, { narrow: true });
    const beforePlay = await page.evaluate(() => ({
      joy: getComputedStyle(document.getElementById('joystick')).display,
      coarse: matchMedia('(pointer: coarse)').matches
    }));
    check('narrow touch controls stay hidden on the title', beforePlay.joy === 'none', beforePlay);
    await page.screenshot({ path: `${ARTIFACTS}/narrow_390_title.png` });
    await page.locator('#startBtn').click();
    await page.waitForTimeout(100);
    const after = await page.evaluate(() => getComputedStyle(document.getElementById('joystick')).display);
    const state = await probe(page);
    check('narrow enters play', state.state === 'playing' && state.lock === true, state);
    if (beforePlay.coarse) check('narrow shows the move control during play', after === 'block', { after });
    else receipt.limitations.push('Narrow context did not emulate pointer: coarse, so touch controls stayed hidden.');
    await page.keyboard.down('ArrowDown');
    await page.waitForTimeout(200);
    await page.keyboard.up('ArrowDown');
    check('narrow document stays at scroll 0', (await page.evaluate(() => document.scrollingElement.scrollTop)) === 0);
    await page.screenshot({ path: `${ARTIFACTS}/narrow_390_playing.png` });
    await page.close();
  }

  // --- short iframe, same origin, intro readable ---
  {
    const page = await browser.newPage({ viewport: { width: 1100, height: 800 } });
    await page.setContent(`<!DOCTYPE html><html><body style="margin:0">
      <iframe id="g" title="game" src="http://127.0.0.1:${GAME_PORT}/index.html?probe=1" style="width:960px;height:448px;border:0"></iframe>
    </body></html>`, { waitUntil: 'networkidle' });
    const game = page.frames().find(f => f.url().includes('index.html'));
    await game.waitForSelector('#startBtn');
    const lay = await layoutOf(game);
    assertLayout('short-iframe', lay);
    await game.locator('#stage').screenshot({ path: `${ARTIFACTS}/short_iframe_intro.png` });
    await page.close();
  }

  async function openNested({ gameh = '540', allowfs = false, viewport = { width: 1280, height: 800 } } = {}) {
    const page = await browser.newPage({ viewport });
    const url = `http://127.0.0.1:${OUTER_PORT}/tests/embed/services.html?origin=${encodeURIComponent('http://127.0.0.1:' + GAME_PORT)}&gameh=${gameh}&allowfs=${allowfs ? '1' : '0'}`;
    await page.goto(url, { waitUntil: 'networkidle' });
    const catalog = page.frame({ name: 'catalog' });
    await catalog.waitForSelector('#game');
    let game;
    for (let i = 0; i < 40; i++) {
      game = catalog.childFrames().find(f => f.name() === 'game');
      if (game) break;
      await delay(100);
    }
    await game.waitForSelector('#startBtn');
    return { page, catalog, game };
  }

  async function scrolls(page, catalog, game) {
    return {
      outer: Math.round(await page.evaluate(() => document.scrollingElement.scrollTop)),
      mid: Math.round(await catalog.evaluate(() => document.scrollingElement.scrollTop)),
      inner: Math.round(await game.evaluate(() => document.scrollingElement.scrollTop))
    };
  }

  async function alignScrollable(page, catalog) {
    await catalog.evaluate(() => {
      const f = document.getElementById('game');
      const top = f.getBoundingClientRect().top + window.scrollY - 70;
      window.scrollTo(0, Math.max(0, top));
    });
    await page.evaluate(() => {
      const f = document.getElementById('catalog');
      const top = f.getBoundingClientRect().top + window.scrollY - 30;
      window.scrollTo(0, Math.max(0, top));
    });
    await delay(60);
  }

  function delta(a, b) {
    return { outer: b.outer - a.outer, mid: b.mid - a.mid, inner: b.inner - a.inner };
  }
  function stable(d) {
    return d.outer === 0 && d.mid === 0 && d.inner === 0;
  }

  // --- nested scrollable parents: outside play scrolls, during play does not ---
  {
    const { page, catalog, game } = await openNested({ gameh: '540' });
    await alignScrollable(page, catalog);
    const titleBox = await game.locator('#gameTitle').boundingBox();
    check('nested title is on screen before play', titleBox && titleBox.y > 0 && titleBox.y < 760, titleBox);
    await page.mouse.click(titleBox.x + 8, titleBox.y + 8);
    await delay(40);
    const beforeTitle = await scrolls(page, catalog, game);
    for (let i = 0; i < 8; i++) await page.keyboard.press('ArrowDown');
    await delay(40);
    const titleKeys = delta(beforeTitle, await scrolls(page, catalog, game));
    check('nested arrows scroll an ancestor on the title screen', titleKeys.outer + titleKeys.mid >= 8 && titleKeys.inner === 0, titleKeys);
    await alignScrollable(page, catalog);
    const canvasBox = await game.locator('canvas').boundingBox();
    await page.mouse.move(canvasBox.x + 30, canvasBox.y + 40);
    const beforeTitleWheel = await scrolls(page, catalog, game);
    await page.mouse.wheel(0, 200);
    await delay(40);
    const titleWheel = delta(beforeTitleWheel, await scrolls(page, catalog, game));
    check('nested wheel scrolls an ancestor on the title screen', titleWheel.outer + titleWheel.mid >= 40 && titleWheel.inner === 0, titleWheel);

    await alignScrollable(page, catalog);
    const startBox = await game.locator('#startBtn').boundingBox();
    const beforeStart = await scrolls(page, catalog, game);
    await page.mouse.click(startBox.x + startBox.width / 2, startBox.y + startBox.height / 2);
    await delay(180);
    const afterStart = await scrolls(page, catalog, game);
    check('nested starting play does not move ancestors', stable(delta(beforeStart, afterStart)), delta(beforeStart, afterStart));
    const playing = await probe(game);
    check('nested game is playing and locked', playing.state === 'playing' && playing.lock === true, playing);

    async function hold(key, ms = 220) {
      const b = await scrolls(page, catalog, game);
      const p0 = await probe(game);
      await page.keyboard.down(key);
      await delay(ms);
      await page.keyboard.up(key);
      await delay(30);
      return { d: delta(b, await scrolls(page, catalog, game)), p0, p1: await probe(game) };
    }
    const down = await hold('ArrowDown');
    check('nested ArrowDown does not scroll while playing', stable(down.d), down.d);
    check('nested ArrowDown moves the player', down.p1.y > down.p0.y + 6, { y0: down.p0.y, y1: down.p1.y });
    const up = await hold('ArrowUp');
    check('nested ArrowUp does not scroll while playing', stable(up.d), up.d);
    check('nested ArrowUp moves the player', up.p1.y < up.p0.y - 6, { y0: up.p0.y, y1: up.p1.y });
    const right = await hold('KeyD');
    check('nested KeyD does not scroll while playing', stable(right.d), right.d);
    check('nested KeyD moves the player', right.p1.x > right.p0.x + 6, { x0: right.p0.x, x1: right.p1.x });
    const space = await hold('Space', 240);
    check('nested Space does not scroll while playing', stable(space.d), space.d);
    check('nested Space shoots', space.p1.shots > space.p0.shots, { shots0: space.p0.shots, shots1: space.p1.shots });
    const pageDown = await hold('PageDown', 40);
    check('nested PageDown does not scroll while playing', stable(pageDown.d), pageDown.d);

    const canvas = await game.locator('canvas').boundingBox();
    await page.mouse.move(canvas.x + canvas.width / 2, canvas.y + Math.min(180, canvas.height / 2));
    const beforeWheel = await scrolls(page, catalog, game);
    await page.mouse.wheel(0, 200);
    await delay(50);
    const wheelD = delta(beforeWheel, await scrolls(page, catalog, game));
    check('nested wheel does not scroll while playing', stable(wheelD), wheelD);
    await page.screenshot({ path: `${ARTIFACTS}/nested_play_scroll_held.png` });

    await page.keyboard.press('KeyP');
    await delay(60);
    const paused = await probe(game);
    check('nested pause clears keys and the lock', paused.state === 'paused' && paused.lock === false && paused.pressed.length === 0, paused);
    const beforePausedWheel = await scrolls(page, catalog, game);
    await page.mouse.wheel(0, 220);
    await delay(50);
    const pausedWheel = delta(beforePausedWheel, await scrolls(page, catalog, game));
    check('nested wheel scrolls an ancestor after pause', pausedWheel.outer + pausedWheel.mid >= 40 && pausedWheel.inner === 0, pausedWheel);
    await page.screenshot({ path: `${ARTIFACTS}/nested_after_pause_scrolled.png` });

    await page.keyboard.press('KeyP');
    await delay(60);
    const resumed = await probe(game);
    check('nested resume locks scroll again', resumed.state === 'playing' && resumed.lock === true, resumed);
    const beforeAgain = await scrolls(page, catalog, game);
    await page.mouse.wheel(0, 180);
    await delay(40);
    check('nested wheel is locked again after resume', stable(delta(beforeAgain, await scrolls(page, catalog, game))));

    // Stuck key: hold right, blur to the services page, resume, player must not drift.
    await page.keyboard.down('ArrowRight');
    await delay(180);
    const drifting = await probe(game);
    await page.locator('#badge').click();
    await delay(80);
    const left = await probe(game);
    check('nested blur pauses and clears the held key', left.state === 'paused' && left.pressed.length === 0, { pressed: left.pressed, state: left.state });
    await page.keyboard.up('ArrowRight');
    const xAtPause = left.x;
    await game.evaluate(() => document.getElementById('resumeBtn').click());
    await delay(280);
    const settled = await probe(game);
    check('nested resume does not keep a stuck direction', settled.state === 'playing' && Math.abs(settled.x - xAtPause) < 8 && settled.pressed.length === 0, { xAtPause, x: settled.x, pressed: settled.pressed, moved: drifting.x });

    const outsideBefore = await scrolls(page, catalog, game);
    await page.locator('#badge').click();
    await delay(40);
    await page.evaluate(() => { document.body.tabIndex = -1; document.body.focus(); });
    for (let i = 0; i < 8; i++) await page.keyboard.press('ArrowDown');
    await delay(40);
    const outsideDelta = delta(outsideBefore, await scrolls(page, catalog, game));
    check('nested arrows scroll the services page after blur', outsideDelta.outer >= 16 && outsideDelta.inner === 0, outsideDelta);
    const afterBlur = await probe(game);
    check('nested blur leaves the round paused', afterBlur.state === 'paused', afterBlur);
    await page.close();
  }

  // --- content-sized catalog (IONOS embedHeight pattern): only the outer page can scroll ---
  {
    const { page, catalog, game } = await openNested({ gameh: '520' });
    const full = await catalog.evaluate(() => document.scrollingElement.scrollHeight);
    await page.evaluate(h => { document.getElementById('catalog').style.height = h + 'px'; }, full);
    const midMax = await catalog.evaluate(() => document.scrollingElement.scrollHeight - document.scrollingElement.clientHeight);
    check('content-sized catalog does not scroll internally', midMax === 0, { midMax, full });
    const gameTop = await catalog.evaluate(() => document.getElementById('game').getBoundingClientRect().top + window.scrollY);
    await page.evaluate(offset => {
      const f = document.getElementById('catalog');
      const y = f.getBoundingClientRect().top + window.scrollY + offset - 80;
      window.scrollTo(0, Math.max(0, y));
    }, gameTop);
    await delay(60);
    const startBox = await game.locator('#startBtn').boundingBox();
    check('content-sized game is on screen', startBox && startBox.y > 40 && startBox.y < 740, startBox);
    const before = await scrolls(page, catalog, game);
    await page.mouse.click(startBox.x + 10, startBox.y + 10);
    await delay(80);
    const canvas = await game.locator('canvas').boundingBox();
    await page.mouse.move(canvas.x + 40, canvas.y + 80);
    await page.keyboard.press('ArrowDown');
    await page.mouse.wheel(0, 200);
    await delay(40);
    const during = delta(before, await scrolls(page, catalog, game));
    // The click/start is included. Re-measure a clean wheel after resetting by reading fresh.
    const base = await scrolls(page, catalog, game);
    await page.keyboard.press('ArrowDown');
    await page.mouse.wheel(0, 180);
    await delay(40);
    const clean = delta(base, await scrolls(page, catalog, game));
    check('content-sized play does not scroll the services page', stable(clean), { clean, during });
    await page.screenshot({ path: `${ARTIFACTS}/services_fit_during_play.png` });
    await page.keyboard.press('KeyP');
    await delay(40);
    const pausedAt = await scrolls(page, catalog, game);
    await page.mouse.wheel(0, 200);
    await delay(40);
    const moved = delta(pausedAt, await scrolls(page, catalog, game));
    check('content-sized wheel scrolls the services page after pause', moved.outer >= 40 && moved.mid === 0 && moved.inner === 0, moved);
    await page.screenshot({ path: `${ARTIFACTS}/services_fit_after_pause.png` });
    await page.close();
  }

  // --- narrow nested ---
  {
    const { page, catalog, game } = await openNested({
      gameh: '700',
      viewport: { width: 390, height: 844 }
    });
    await alignScrollable(page, catalog);
    const lay = await layoutOf(game);
    assertLayout('narrow-nested', lay, { narrow: true });
    const box = await game.locator('#startBtn').boundingBox();
    if (box && box.y > 0 && box.y < 800) {
      const b = await scrolls(page, catalog, game);
      await page.mouse.click(box.x + 8, box.y + 8);
      await delay(80);
      await page.keyboard.down('ArrowDown');
      await delay(180);
      await page.keyboard.up('ArrowDown');
      const d = delta(b, await scrolls(page, catalog, game));
      check('narrow nested play does not scroll ancestors', stable(d), d);
    } else {
      check('narrow nested start button on screen', false, box);
    }
    await game.locator('#stage').screenshot({ path: `${ARTIFACTS}/narrow_nested_game.png` });
    await page.close();
  }

  // --- fullscreen permission chain ---
  {
    const alone = await browser.newPage({ viewport: { width: 1280, height: 800 } });
    await alone.goto(`http://127.0.0.1:${GAME_PORT}/index.html?probe=1`, { waitUntil: 'domcontentloaded' });
    const enabled = await alone.evaluate(() => document.fullscreenEnabled);
    await alone.locator('#fullBtn').click();
    await delay(200);
    const aloneFs = await alone.evaluate(() => ({
      on: !!document.fullscreenElement,
      id: document.fullscreenElement && document.fullscreenElement.id,
      note: document.getElementById('fullNote').textContent,
      hidden: document.getElementById('fullNote').hidden
    }));
    check('standalone fullscreen uses the stage', enabled && aloneFs.on && aloneFs.id === 'stage' && aloneFs.hidden, { enabled, aloneFs });
    if (aloneFs.on) await alone.screenshot({ path: `${ARTIFACTS}/fullscreen_stage.png` });
    else receipt.limitations.push('Standalone requestFullscreen did not activate in this browser: ' + JSON.stringify(aloneFs));
    await alone.close();

    const blocked = await openNested({ allowfs: false });
    await alignScrollable(blocked.page, blocked.catalog);
    const fullBox = await blocked.game.locator('#fullBtn').boundingBox();
    await blocked.page.mouse.click(fullBox.x + 8, fullBox.y + 8);
    await delay(200);
    const blockedFs = await blocked.game.evaluate(() => ({
      enabled: document.fullscreenEnabled,
      on: !!document.fullscreenElement,
      note: document.getElementById('fullNote').textContent,
      linkHidden: document.getElementById('fullPageLink').hidden
    }));
    check('nested fullscreen without allow is refused and explained', blockedFs.on === false && /allow="fullscreen"/.test(blockedFs.note) && blockedFs.linkHidden === false, blockedFs);
    await blocked.game.locator('#stage').screenshot({ path: `${ARTIFACTS}/fullscreen_denied_note.png` });
    await blocked.page.close();

    const allowed = await openNested({ allowfs: true });
    await alignScrollable(allowed.page, allowed.catalog);
    const okBox = await allowed.game.locator('#fullBtn').boundingBox();
    await allowed.page.mouse.click(okBox.x + 8, okBox.y + 8);
    await delay(250);
    const allowedFs = await allowed.game.evaluate(() => ({
      enabled: document.fullscreenEnabled,
      on: !!document.fullscreenElement,
      id: document.fullscreenElement && document.fullscreenElement.id,
      note: document.getElementById('fullNote').textContent
    }));
    check('nested fullscreen works when every ancestor allows it', allowedFs.on === true && allowedFs.id === 'stage', allowedFs);
    if (!allowedFs.on) receipt.limitations.push('Ancestor allow="fullscreen" was set on both iframes but requestFullscreen still failed: ' + JSON.stringify(allowedFs));
    await allowed.page.close();
  }

  // touch drag while playing must not scroll the content-sized services page
  {
    const context = await browser.newContext({ viewport: { width: 1280, height: 800 }, hasTouch: true });
    const page = await context.newPage();
    const url = `http://127.0.0.1:${OUTER_PORT}/tests/embed/services.html?origin=${encodeURIComponent('http://127.0.0.1:' + GAME_PORT)}&gameh=520&allowfs=0`;
    await page.goto(url, { waitUntil: 'networkidle' });
    const catalog = page.frame({ name: 'catalog' });
    const game = catalog.childFrames().find(f => f.name() === 'game');
    await game.waitForSelector('#startBtn');
    const full = await catalog.evaluate(() => document.scrollingElement.scrollHeight);
    await page.evaluate(h => { document.getElementById('catalog').style.height = h + 'px'; }, full);
    const gameTop = await catalog.evaluate(() => document.getElementById('game').getBoundingClientRect().top + window.scrollY);
    await page.evaluate(offset => {
      const f = document.getElementById('catalog');
      window.scrollTo(0, Math.max(0, f.getBoundingClientRect().top + window.scrollY + offset - 80));
    }, gameTop);
    await delay(40);
    const startBox = await game.locator('#startBtn').boundingBox();
    await page.mouse.click(startBox.x + 12, startBox.y + 12);
    await delay(60);
    const canvas = await game.locator('canvas').boundingBox();
    const session = await context.newCDPSession(page);
    const x = canvas.x + canvas.width / 2;
    const y = canvas.y + 120;
    const before = Math.round(await page.evaluate(() => document.scrollingElement.scrollTop));
    await session.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x, y }] });
    await session.send('Input.dispatchTouchEvent', { type: 'touchMove', touchPoints: [{ x, y: y + 220 }] });
    await session.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
    await delay(40);
    const after = Math.round(await page.evaluate(() => document.scrollingElement.scrollTop));
    check('touch drag does not scroll the services page during play', after === before, { before, after });
    await page.keyboard.press('KeyP');
    await delay(40);
    const pausedBefore = Math.round(await page.evaluate(() => document.scrollingElement.scrollTop));
    await session.send('Input.dispatchTouchEvent', { type: 'touchStart', touchPoints: [{ x, y }] });
    await session.send('Input.dispatchTouchEvent', { type: 'touchMove', touchPoints: [{ x, y: y + 180 }] });
    await session.send('Input.dispatchTouchEvent', { type: 'touchEnd', touchPoints: [] });
    await delay(40);
    const pausedAfter = Math.round(await page.evaluate(() => document.scrollingElement.scrollTop));
    check('touch drag can scroll the services page after pause', Math.abs(pausedAfter - pausedBefore) > 20, { pausedBefore, pausedAfter });
    await context.close();
  }
} finally {
  receipt.failed = failed;
  writeFileSync(`${ARTIFACTS}/scroll_lock_receipt.json`, JSON.stringify(receipt, null, 2));
  await browser.close();
  gameServer.kill();
  outerServer.kill();
}

if (failed) {
  console.error(`\n${failed} check(s) failed`);
  process.exit(1);
}
console.log(`\nAll ${receipt.checks.length} checks passed`);

function documentFocus(id) {
  return id === 'stage';
}
