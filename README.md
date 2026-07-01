# meta-ai-video — Claude Code Skill

![banner](assets/banner.png)

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
![Platform](https://img.shields.io/badge/Claude%20Code-Skill-8A2BE2)
![No API key](https://img.shields.io/badge/API%20key-not%20required-brightgreen)
![Powered by](https://img.shields.io/badge/Meta%20AI-video-0866FF)

สร้างวิดีโอจาก **Meta AI** ผ่านเบราว์เซอร์ที่ Claude คุมให้ (Playwright) แล้วเซฟลงเครื่อง
— **ไม่ต้องใช้ API key** ใช้บัญชี Meta AI ที่ล็อกอินไว้

> Generate videos with Meta AI through a Claude-controlled browser and save them
> to your computer. No API key — uses your logged-in Meta AI account.

---

## สิ่งที่ต้องมีก่อน (Prerequisites)

1. **Claude Code** ติดตั้งแล้ว
2. **Playwright MCP server** เชื่อมต่อกับ Claude Code (ดูขั้นตอนด้านล่าง)
3. **บัญชี Meta AI** (ล็อกอินด้วย Facebook/Instagram) — ล็อกอินครั้งเดียว จำไว้ตลอด
4. *(ไม่บังคับ)* **ffmpeg** บน PATH — ใช้เฉพาะตอนต่อหลายฉากเป็นคลิปยาว

> ⚠️ สคริปต์ดาวน์โหลด (`save-video.ps1`) เป็น **PowerShell (Windows)**
> ถ้าใช้ Mac/Linux ใช้คำสั่ง `curl` แทนได้ (ดูหมายเหตุท้ายไฟล์)

---

## ติดตั้ง (Install)

มี 2 วิธี — เลือกอย่างใดอย่างหนึ่ง

### ⭐ วิธี A (แนะนำ): ให้ Claude ติดตั้งให้

เปิด Claude Code แล้ว **ก็อปข้อความนี้ทั้งก้อนวางในแชท** — Claude จะ clone repo, วาง skill ให้ถูกที่, และเชื่อม Playwright MCP ให้เอง:

```text
ช่วยติดตั้ง skill "meta-ai-video" ให้หน่อย ทำตามนี้:
1. clone https://github.com/nakdev-23/skill-create-video-meta-ai
2. ก็อปไฟล์ทั้งหมด (SKILL.md + scripts/) ไปไว้ที่ ~/.claude/skills/meta-ai-video/
   (Windows: C:\Users\<ชื่อ>\.claude\skills\meta-ai-video\)
3. เชื่อม Playwright MCP: รัน `claude mcp add playwright -- npx @playwright/mcp@latest`
   แล้วเช็คด้วย `claude mcp list` ว่ามี playwright
4. บอกฉันด้วยว่าเสร็จแล้วต้องเปิด session ใหม่ไหม
```

เสร็จแล้วเปิด session ใหม่ (ถ้า Claude บอก) — เรียกใช้ได้เลยด้วย `/meta-ai-video`

### 🔧 วิธี B: ติดตั้งเอง — 2 ขั้นตอน

**1) วาง skill ลงในเครื่อง**

Clone แล้วก็อปเข้าโฟลเดอร์ skills:

```bash
git clone https://github.com/nakdev-23/skill-create-video-meta-ai
mkdir -p ~/.claude/skills/meta-ai-video
cp -r skill-create-video-meta-ai/SKILL.md skill-create-video-meta-ai/scripts ~/.claude/skills/meta-ai-video/
```

หรือวางเองที่ตำแหน่งนี้ (ทั้งโฟลเดอร์ มี `SKILL.md` + `scripts/`):

| ใช้ทุกโปรเจกต์ (ส่วนตัว) | เฉพาะโปรเจกต์เดียว |
|---|---|
| `~/.claude/skills/meta-ai-video/` | `<project>/.claude/skills/meta-ai-video/` |

- **Windows:** `C:\Users\<ชื่อ>\.claude\skills\meta-ai-video\`
- **Mac/Linux:** `~/.claude/skills/meta-ai-video/`

Claude Code จะ **เห็น skill เองอัตโนมัติ** ไม่ต้องลงทะเบียนเพิ่ม (เปิด session ใหม่ถ้าเปิดค้างอยู่)

**2) เชื่อม Playwright MCP server**

รันคำสั่งนี้ใน terminal ครั้งเดียว:

```bash
claude mcp add playwright -- npx @playwright/mcp@latest
```

เช็คว่าเชื่อมแล้ว: `claude mcp list` ต้องเห็น `playwright`

---

## เริ่มใช้ (First run)

1. เปิด Claude Code แล้วสั่ง เช่น:
   > `/meta-ai-video` แมวส้มเล่นในสวนตอนพระอาทิตย์ตก สไตล์ดินน้ำมัน

   หรือพิมพ์ธรรมดา: *"สร้างวิดีโอด้วย meta ai เป็นแมวส้ม..."*

2. **ครั้งแรกครั้งเดียว** — Claude จะเปิดหน้าต่างเบราว์เซอร์ แล้วบอกให้คุณ
   **ล็อกอิน Meta AI ในหน้าต่างนั้น** เสร็จแล้วพิมพ์ `ok`
   (ล็อกอินถูกจำไว้ใน profile ครั้งต่อๆ ไปไม่ต้องล็อกอินอีก)

3. Claude จะสร้างวิดีโอ (Meta ให้มา 4 แบบ/prompt คลิปละ ~5 วิ) แล้วเซฟลง
   `./meta-ai-videos/` ในโปรเจกต์ปัจจุบัน พร้อมบอก path ไฟล์

---

## ทำคลิปยาว / นิทานต่อเนื่อง

สั่งต่อในแชทเดิมทีละฉาก (Claude จะเติม `seamless next scene` ให้สไตล์ต่อเนื่อง)
แล้วให้ต่อด้วย ffmpeg เป็นคลิปเดียว — Meta คลิปละ ~5 วิ ดังนั้น ~12 ฉาก ≈ 1 นาที
(รายละเอียดอยู่ใน `SKILL.md` หัวข้อ "Optional: multi-scene & stitching")

---

## หมายเหตุ Mac/Linux (ดาวน์โหลดแทน PowerShell)

แทนที่จะรัน `save-video.ps1` ให้ใช้:

```bash
mkdir -p ./meta-ai-videos
curl -L "<URL_ที่ได้จากหน้าเว็บ>" -o "./meta-ai-videos/metaai-$(date +%Y%m%d-%H%M%S).mp4"
```

URL วิดีโอเป็นลิงก์ fbcdn ที่เซ็นแล้ว โหลดได้โดยไม่ต้องใช้ cookie

---

## แก้ปัญหา (Troubleshooting)

- **"Browser is already in use ... profile"** — มี Chrome ค้างจาก session ก่อน
  ปิด Chrome ของ profile นั้นให้หมด (หรือ kill process ที่ใช้
  `.claude-playwright-profile`) แล้วลองใหม่
- **กดส่งไม่ไป / มี dialog "ทิ้งพรอมต์หรือไม่"** — เป็นพฤติกรรมปกติของเว็บ
  skill จัดการให้แล้ว (โฟกัสช่องพิมพ์ → กด Enter / เลือก "อยู่ต่อ")
- **สร้างไม่ได้/ถูกปฏิเสธ** — อาจติด content policy ของ Meta AI ลองแก้ prompt
- **UI ภาษาอังกฤษ** — ปุ่ม "สร้างวิดีโอ" = "Create video", "อยู่ต่อ" = "Stay"

---

## License / การแจกจ่าย

**MIT License** — แจกฟรี ใช้/แก้/แจกต่อได้ตามสบาย ขอแค่ติดเครดิตไว้

```
MIT License

Copyright (c) 2026 nakdev-23

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

> หมายเหตุ: ตัว skill แจกฟรี แต่การสร้างวิดีโอต้องใช้ **บัญชี Meta AI ของผู้ใช้เอง**
> และอยู่ภายใต้เงื่อนไขการใช้งานของ Meta AI
