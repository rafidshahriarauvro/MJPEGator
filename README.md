# ⚡ MJPEGator

### A tiny, self-contained video → 240×240 MJPEG converter.

**Drop videos into `In/` → run MJPEGator → get ready-to-use `.mjpeg` files in `Out/`.**

No system-wide FFmpeg installation.
No PATH configuration.
No complicated setup.
No unnecessary UI.

Just a small folder containing everything it needs to turn common video formats into **high-quality 240×240 MJPEG**.

---

## ✦ What is MJPEGator?

**MJPEGator** is a lightweight Windows batch utility designed for one specific job:

> **Convert video files into 240×240 MJPEG streams with high-quality 1:1 framing.**

It automatically downloads and keeps its own local copy of **FFmpeg**, so the project remains self-contained.

```text
┌──────────────────────────────────────────┐
│                MJPEGator                 │
│                                          │
│   In/                                    │
│    ├── video.mp4                         │
│    ├── animation.webm                    │
│    └── clip.mkv                          │
│                                          │
│              ↓ FFmpeg                    │
│                                          │
│        1:1 Center Crop                   │
│              ↓                           │
│        Lanczos Downscale                  │
│              ↓                           │
│        JPEG / MJPEG Encode               │
│                                          │
│   Out/                                   │
│    ├── video.mjpeg                       │
│    ├── animation.mjpeg                   │
│    └── clip.mjpeg                        │
└──────────────────────────────────────────┘
```

The project is intentionally **simple and self-contained**.

It is not trying to be a general-purpose video editor or transcoding suite.

It does one thing:

### **Video → 240×240 MJPEG**

---

# 🚀 Features

* ⚡ **One-click conversion**
* 📦 **Self-contained FFmpeg**
* 🗂️ Simple `In/` → `Out/` workflow
* 🖼️ Fixed **240×240** output
* ◼️ Automatic **1:1 center cropping**
* 🔍 High-quality **Lanczos downscaling**
* 🎞️ **24 FPS** output
* 🧩 Individual JPEG frames packed as **MJPEG**
* 💎 High-quality JPEG encoding
* 🛡️ Temporary output protection
* 🔄 Supports batch conversion
* 🪟 Designed for Windows
* 🧹 Automatically creates required folders
* 🌐 FFmpeg is downloaded only when it is not already present

---

# 📁 Project Structure

After running MJPEGator:

```text
MJPEGator/
│
├── MJPEGator.bat
│
├── In/
│   ├── video.mp4
│   ├── animation.webm
│   └── clip.mkv
│
├── Out/
│   ├── video.mjpeg
│   ├── animation.mjpeg
│   └── clip.mjpeg
│
└── ffmpeg/
    └── bin/
        └── ffmpeg.exe
```

That's basically it.

### `In/`

Put your source videos here.

### `Out/`

Converted `.mjpeg` files appear here.

### `ffmpeg/`

MJPEGator automatically stores its local FFmpeg installation here.

You **do not need to install FFmpeg globally** or add it to your Windows PATH.

---

# 🎬 Supported Input Formats

MJPEGator supports the following common video formats:

| Format                | Extension |
| --------------------- | --------- |
| MPEG-4                | `.mp4`    |
| QuickTime             | `.mov`    |
| Matroska              | `.mkv`    |
| AVI                   | `.avi`    |
| WebM                  | `.webm`   |
| MPEG-4 Video          | `.m4v`    |
| MPEG                  | `.mpg`    |
| MPEG                  | `.mpeg`   |
| MPEG Transport Stream | `.ts`     |
| MPEG Transport Stream | `.mts`    |
| MPEG Transport Stream | `.m2ts`   |
| Flash Video           | `.flv`    |

### In short:

```text
MP4
MOV
MKV
AVI
WEBM
M4V
MPG
MPEG
TS
MTS
M2TS
FLV
```

If FFmpeg can decode the file, MJPEGator can potentially process it — but the batch script specifically scans for the extensions above.

---

# 🖼️ Output Specification

Every successful conversion produces:

```text
240 × 240
24 FPS
MJPEG
JPEG frames
No audio
```

Example:

```text
Source:
1920 × 1080 WebM

        ↓

Center crop:
1080 × 1080

        ↓

Lanczos resize:
240 × 240

        ↓

MJPEG:
240 × 240 @ 24 FPS
```

---

# ◼️ Smart 1:1 Cropping

MJPEGator does **not stretch** your video.

Instead, it takes the largest possible square from the original frame.

### 16:9 video

```text
1920 × 1080

┌────────────────────────────────┐
│                                │
│       ┌────────────────┐       │
│       │                │       │
│       │   1080×1080    │       │
│       │                │       │
│       └────────────────┘       │
│                                │
└────────────────────────────────┘
```

Then:

```text
1080 × 1080
      ↓
240 × 240
```

### Portrait video

```text
1080 × 1920

┌──────────────┐
│              │
│              │
│   1080×1080  │
│              │
│              │
└──────────────┘
```

Again:

```text
1080 × 1080
      ↓
240 × 240
```

The result is always square without distortion.

---

# 🔬 High-Quality Scaling

MJPEGator uses **Lanczos** for the final downscale:

```text
flags=lanczos
```

This is particularly useful when converting high-resolution sources into the relatively tiny:

```text
240 × 240
```

output.

The goal is to retain as much useful detail as possible before JPEG encoding.

---

# 💎 JPEG Quality

MJPEGator uses FFmpeg's MJPEG encoder with:

```text
-q:v 2
```

This intentionally favors **high visual quality** rather than aggressively minimizing file size.

At 240×240, the resulting images are small enough that prioritizing image quality makes sense for applications where the MJPEG will actually be displayed on a small screen.

---

# 🎞️ Why MJPEG?

MJPEG is extremely simple:

```text
JPEG
JPEG
JPEG
JPEG
JPEG
JPEG
...
```

Each video frame is an independent JPEG image.

That makes MJPEG useful for simple embedded and hardware projects where decoding a modern video codec such as H.264, H.265 or AV1 would be unnecessarily complicated.

For a small display, you can simply decode:

```text
MJPEG frame
      ↓
JPEG decoder
      ↓
240×240 framebuffer
      ↓
Display
```

No complicated inter-frame prediction is required.

---

# 🧰 Zero Configuration

MJPEGator is intentionally designed so that you don't need to prepare your PC first.

On first launch:

```text
MJPEGator
    │
    ├── Is local FFmpeg present?
    │
    ├── YES → use it
    │
    └── NO
         │
         ├── Download FFmpeg
         ├── Extract it
         ├── Copy it locally
         └── Start conversion
```

After that, the local copy is reused.

This means the project does **not** depend on:

```text
C:\ffmpeg\
PATH
Chocolatey
winget
system-wide FFmpeg
```

The project carries its own FFmpeg installation.

---

# 📦 Installation

### 1. Download the repository

Clone it:

```bash
git clone https://github.com/YOUR-USERNAME/MJPEGator.git
```

Or download the ZIP from GitHub.

### 2. Put videos in `In/`

Example:

```text
MJPEGator/
└── In/
    ├── test.mp4
    ├── animation.webm
    └── sample.mkv
```

### 3. Run

Double-click:

```text
MJPEGator.bat
```

### 4. Get your MJPEGs

Converted files appear automatically:

```text
Out/
├── test.mjpeg
├── animation.mjpeg
└── sample.mjpeg
```

That's the entire workflow.

---

# ⚙️ Under the Hood

The core conversion pipeline is essentially:

```text
Input Video
    │
    ▼
FFmpeg Decode
    │
    ▼
Largest Possible Square Crop
    │
    ▼
Lanczos 240×240 Resize
    │
    ▼
24 FPS CFR
    │
    ▼
MJPEG JPEG Encoder
    │
    ▼
.mjpeg
```

The important FFmpeg parameters are:

```text
crop=min(iw,ih):min(iw,ih)
scale=240:240:flags=lanczos
-r 24
-fps_mode cfr
-c:v mjpeg
-q:v 2
-pix_fmt yuvj420p
-an
-f mjpeg
```

### Result

```text
240 × 240
24 FPS
MJPEG
No audio
High JPEG quality
```

---

# 🛡️ Safe Output Handling

MJPEGator does not immediately overwrite the final output with a partially encoded file.

It first writes to:

```text
.<filename>.mjpeg.tmp
```

Only after FFmpeg successfully completes and the file passes basic validation is it moved to:

```text
filename.mjpeg
```

So an interrupted or failed conversion doesn't normally leave a corrupted final `.mjpeg` pretending to be complete.

---

# 💡 Why a BAT File?

Because MJPEGator doesn't need a GUI.

The entire workflow is intentionally transparent:

```text
In
 ↓
Convert
 ↓
Out
```

A batch file keeps the project:

* tiny
* portable
* inspectable
* easy to modify
* easy to fork
* easy to run on another Windows machine

There are no unnecessary dependencies beyond Windows' built-in tools and the automatically downloaded FFmpeg binary.

---

# 🎯 Designed For

MJPEGator is particularly useful for projects involving:

* Embedded displays
* ESP32 / ESP32-S3
* ST7789 displays
* Small LCD panels
* SPI displays
* Microcontroller video playback
* Embedded UI animations
* Hardware prototypes
* Custom electronics projects
* Simple MJPEG playback systems

Especially when the target is something like:

```text
240 × 240 LCD
```

and you don't want to manually prepare every video.

---

# ⚠️ Notes

MJPEGator is **not** intended to be a replacement for a full video transcoding application.

It deliberately makes assumptions:

```text
Output = 240×240
FPS = 24
Format = MJPEG
Audio = removed
Aspect ratio = 1:1
Crop = centered
```

Those constraints are features, not bugs.

The entire point is to make preparing compatible video assets extremely simple.

---

# 📜 License

Add your preferred license here.

For example:

```text
MIT License
```

if you choose to release MJPEGator under MIT.

---

<div align="center">

### ⚡ MJPEGator

**Small tool. One job. Zero configuration.**

`VIDEO` → `240×240 MJPEG`

</div>
