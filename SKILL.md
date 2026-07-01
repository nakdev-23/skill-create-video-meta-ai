---
name: meta-ai-video
description: Generate videos via the Meta AI web app (no API key — uses an existing Meta/Facebook login through a Playwright-controlled browser). Claude crafts/refines the video prompt, drives meta.ai to generate a clip, then downloads the result into the current project. Trigger when the user asks to create/generate a video, clip, or animation with Meta AI without an API key, or says things like "สร้างวิดีโอ", "ทำคลิป", "gen วิดีโอ", "ทำวิดีโอด้วย meta ai".
---

# Meta AI Video Generator (browser, no API key)

Generate short videos using a logged-in Meta AI account via a Playwright-driven
browser. **No API key required.** Works in any project — saves output into the
current project's `./meta-ai-videos/` folder.

Meta AI produces **4 video variations per prompt**, each roughly **5 seconds**
long at 832×464 (16:9). For a longer story, generate several scenes in sequence
and stitch them (see "Optional: multi-scene & stitching").

## Prerequisites

- **Playwright MCP server** connected (the `mcp__playwright__browser_*` tools).
- A **Meta AI account** (Facebook/Instagram login). Login is a **one-time**
  manual step — the Playwright profile is persistent and remembers it.
- (Optional) **ffmpeg** on PATH — only needed for stitching multiple scenes.

## Pipeline

1. **Craft the prompt** (Claude) — turn the user's request into an optimized,
   detailed **English** video prompt. Show it to the user.
2. **Generate** — drive meta.ai in the Playwright browser to produce the clip.
3. **Save** — download the chosen variation into `./meta-ai-videos/`.

---

## Step 1 — Craft the prompt

From the user's request, write a single detailed English prompt. Good video
prompts specify: subject + action, art style/medium, camera movement, lighting,
color palette, mood, and aspect ratio (`16:9` or `9:16`). Keep it one paragraph.

Briefly show the user the prompt you'll send, then proceed. If the user gave an
explicit prompt and said "use exactly this", skip rewriting.

> Tip: append `, 16:9` (landscape) or `, 9:16` (vertical/reels) to control aspect.

---

## Step 2 — Generate via the browser

All browser actions use the `mcp__playwright__browser_*` tools.

1. Open Meta AI: `mcp__playwright__browser_navigate` → `https://www.meta.ai/`
2. `mcp__playwright__browser_snapshot` to read the page.
   - **If not logged in** (you see "เข้าสู่ระบบ / สมัคร" / "Log in / Sign up"
     buttons): tell the user
     *"กรุณา login Meta AI ในหน้าต่าง browser ที่เปิดขึ้นมา แล้วพิมพ์ ok"* and wait.
     Login is remembered for all future runs (persistent profile).
3. On a fresh chat, switch to **video mode**: click the **"สร้างวิดีโอ"**
   (English: **"Create video"**) button below the composer. The suggestion chips
   change to video examples once it's active.
4. Find the composer textbox (`textbox` with placeholder "ถาม Meta AI..." /
   "Ask Meta AI...") from the snapshot and `mcp__playwright__browser_type` the
   prompt into it.
5. **Submit reliably** — the most robust method (verified):
   - `mcp__playwright__browser_click` the **textbox** to focus it, then
   - `mcp__playwright__browser_press_key` → `Enter`.
   - Then re-snapshot the composer: if it's now empty (placeholder visible), it
     sent. If the prompt text is still there, repeat focus-click + `Enter` once.
   - Avoid relying on the send button — a route-guard overlay can intercept it.
6. **Handle the "discard prompt" dialog** — if a dialog titled
   **"ทิ้งพรอมต์หรือไม่"** ("Discard prompt?") appears, click **"อยู่ต่อ"**
   ("Stay") to keep your text, then submit again via focus-click + `Enter`.
7. **Wait for render** — generation takes ~30–45s. Use
   `mcp__playwright__browser_wait_for` (`time: 35`) then poll. Meta adds 4
   `<video>` elements when done.

---

## Step 3 — Save the video into the project

**3a. Extract the newest clip URLs** with `mcp__playwright__browser_evaluate`.
Meta appends 4 new `<video>` per prompt; the latest batch is the **last 4** in
document order:

```js
() => {
  const srcs = Array.from(document.querySelectorAll('video'))
    .map(v => v.currentSrc || v.src)
    .filter(Boolean);
  return { total: srcs.length, last4: srcs.slice(-4) };
}
```

The URLs are signed `fbcdn.net` `.mp4` links — they download fine **without
cookies**.

**3b. (Optional) Pick the best variation** — `mcp__playwright__browser_take_screenshot`
the page and `Read` it; the 4 clips show as side-by-side frames. Choose the one
that best matches the request, or just take `last4[0]`.

**3c. Download** the chosen URL. Inline command (run via the PowerShell tool) —
fully portable, no extra files needed:

```powershell
$dir = "./meta-ai-videos"; New-Item -ItemType Directory -Force -Path $dir | Out-Null
$url = "<URL_FROM_3a>"
$out = Join-Path (Resolve-Path $dir) ("metaai-" + (Get-Date -Format "yyyyMMdd-HHmmss") + ".mp4")
Invoke-WebRequest -Uri $url -OutFile $out -UseBasicParsing -Headers @{ "User-Agent" = "Mozilla/5.0" }
Write-Output ("Saved: " + $out + " (" + [math]::Round((Get-Item $out).Length/1MB,2) + " MB)")
```

Or use the bundled helper (creates the folder, timestamps the name, prints the
absolute path):

```
powershell -ExecutionPolicy Bypass -File "<this-skill-dir>/scripts/save-video.ps1" -Url "<URL_FROM_3a>" -OutDir "./meta-ai-videos"
```

Report the saved absolute path to the user. Done.

---

## Optional: multi-scene & stitching (for a longer / continuous story)

To build a longer continuous video (e.g. a 1-minute bedtime story):

1. Stay in the **same chat** so style stays consistent.
2. For each scene, type a continuation prompt that repeats the key
   subject/style and adds `seamless next scene` + the new action, then submit
   (Step 2.5). Save one variation per scene as `scene1.mp4`, `scene2.mp4`, …
   (Step 3).
3. Concatenate with ffmpeg (all clips share the same size/codec):

```powershell
$dir = "./meta-ai-videos"
$list = Join-Path $dir "concat.txt"
Set-Content $list (Get-ChildItem $dir -Filter "scene*.mp4" | Sort-Object Name | ForEach-Object { "file '$($_.Name)'" }) -Encoding ascii
ffmpeg -y -f concat -safe 0 -i $list -c:v libx264 -pix_fmt yuv420p -crf 18 -movflags +faststart (Join-Path $dir "story-FULL.mp4")
```

> Each Meta AI clip is ~5s, so ~12 scenes ≈ 1 minute.

---

## Notes

- Uses the user's existing Meta AI account via the browser — **no API key, no
  extra cost.**
- The Playwright browser keeps its own persistent profile, separate from the
  user's everyday browser. Login is one-time.
- meta.ai's UI is localized and changes often — always work from a fresh
  `browser_snapshot` rather than hardcoded refs/selectors. The button labels
  here are shown Thai-first because that's how the verified run appeared; the
  English equivalents are in parentheses.
- Respect Meta AI's content policy; if generation is refused, relay that to the
  user instead of trying to bypass it.
