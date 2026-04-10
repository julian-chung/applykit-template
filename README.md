# applykit
*like overleaf, but for Dark Souls fans*

A LaTeX toolkit for building tailored, version-controlled job applications — resumes, and cover letters — faster than you can say "entry-level role requiring 5 years' experience."

Built with XeLaTeX, bundled fonts, and a snapshot system that archives each application with its content and design settings so you can roll back, reuse, and iterate without starting from scratch.

## Example output

Generated using applykit-template. Replace the content with your own.

CV and cover letter compiled with XeLaTeX — no external tooling.

![CV page 1](https://raw.githubusercontent.com/julian-chung/applykit-template/demo/docs/example_cv-1.png)
![CV page 2](https://raw.githubusercontent.com/julian-chung/applykit-template/demo/docs/example_cv-2.png)
![Cover letter](https://raw.githubusercontent.com/julian-chung/applykit-template/demo/docs/example_cover_letter-1.png)

PDFs: [example_cv.pdf](https://raw.githubusercontent.com/julian-chung/applykit-template/demo/docs/example_cv.pdf) | [example_cover_letter.pdf](https://raw.githubusercontent.com/julian-chung/applykit-template/demo/docs/example_cover_letter.pdf)

---

## Dependencies

### TeX Live (with XeLaTeX)

- **macOS:** [MacTeX](https://www.tug.org/mactex/) or `brew install --cask mactex-no-gui`
- **Linux:**  
  - Debian/Ubuntu: `sudo apt install texlive-xetex`  
  - Fedora: `sudo dnf install texlive-xetex`  
  - Arch (btw): `sudo pacman -S texlive-xetex`
- **Windows:** [MiKTeX](https://miktex.org/) or [TeX Live](https://www.tug.org/texlive/)

### FontAwesome5 package

The font *files* are bundled in `fonts/`, but the LaTeX package (which provides `\faGithub`, `\faEnvelope` etc.) must be installed separately:

```bash
tlmgr install fontawesome5
```

On Debian/Ubuntu system TeX:
```bash
sudo apt install texlive-fonts-extra
```

Arch (btw):
```bash
sudo pacman -S texlive-fontawesome
```

## Getting started

1. Clone or fork this repo
2. Update your details in `content/header.tex`
3. Replace the placeholder content in the other `content/` files with your own
4. Build your CV: 
   ```bash
   latexmk main.tex
   ```
5. Your PDF will be generated in `output/`

## Project structure

```
applykit/
├── main.tex                    # CV template — fonts, layout, flags
├── cover_letter_template.tex   # Cover letter template
├── snapshot.sh                 # Snapshot / archiving script (see below)
├── content/                    # Editable content (your actual application data)
│   ├── header.tex              # Name, contact details
│   ├── summary.tex             # Summary variants (switchable by flag)
│   ├── skills.tex
│   ├── education.tex
│   ├── experience.tex
│   ├── projects.tex
│   ├── publications.tex
│   └── engagements.tex
├── fonts/                      # Bundled fonts
├── archive/                    # Snapshots of past applications (created by snapshot.sh)
└── output/                     # Compiled PDFs and build artefacts (gitignored)
```

## Building

```bash
latexmk main.tex                    # CV
latexmk cover_letter_template.tex   # Cover letter
```

Output lands in `output/`.

## Fonts

All fonts are bundled in `fonts/` — no system font installation needed beyond the FontAwesome5 LaTeX package above.

| File | Used for |
|------|----------|
| `CalSans-SemiBold.ttf` | Display name in header |
| `Inter-*.otf` | Body text (Regular, Bold, Italic, BoldItalic, SemiBold, SemiBoldItalic, Medium, Light) |
| `FontAwesome5Free-Solid-900.otf` | Icons (map marker, phone, envelope, globe) |
| `FontAwesome5Free-Regular-400.otf` | Icons (regular weight variants) |
| `FontAwesome5Brands-Regular-400.otf` | Icons (GitHub) |

## Summary variants

`main.tex` has three summary flags — `summaryA`, `summaryB`, `summaryC` — which let you switch the framing of your summary section without editing the content file. Set the active one in `main.tex`:

```latex
\summaryAfalse
\summaryBtrue   % ← this one is active
\summaryCfalse
```

Each flag maps to a variant defined in `content/summary.tex`. Add or modify variants as needed.

The same flag pattern can be used in other sections (e.g. `education.tex`) to conditionally include or exclude content for specific applications.

## The archive system

Every application is different. The archiving system captures a full snapshot of your application at submission time: all content files, compiled PDFs, and a `meta.yaml` sidecar recording the design settings and application context.

This lets you:
- **Roll back** to any previous version, including layout and design choices by reading a past `meta.yaml`
- **Reuse** a past application as the starting point for a similar role
- **Track outcomes** by updating the `outcome` field in `meta.yaml` as the application progresses

### Step-by-step: your first application

**1. Fill in your content**

Edit the files in `content/` with your details. Build regularly to check the output:

```bash
latexmk main.tex
open output/main.pdf
```

**2. Snapshot before you submit**

Once you're happy with the application and ready to apply, snapshot the current state:

```bash
./snapshot.sh 2026-05-01 ExampleAnalytics data-analyst
```

This creates `archive/2026-05-01_ExampleAnalytics_data-analyst/` containing:
- A frozen copy of all your `.tex` files and compiled PDFs
- A `meta.yaml` sidecar with the design settings auto-extracted from `main.tex`

**3. Fill in the meta.yaml**

Open `archive/2026-05-01_ExampleAnalytics_data-analyst/meta.yaml` and fill in the application details:

```yaml
application:
  date: 2026-05-01
  organisation: ExampleAnalytics
  role: data-analyst
  type: industry           # public-service | research | industry | nfp
  req_id: "12345".         # job reference ID (from the listing)
  contact: hiring-team@example.com
  outcome: applied         # update this as it progresses
  notes: >
    Data-focused framing. Emphasised analytical and technical skills.
    Used summaryA. Tailored to highlight relevant experience.
```

The `notes` field is useful for recording why this version looks the way it does — what you emphasised, what you downplayed, and why.

**4. Update the outcome as it progresses**

Come back to the archive and update `outcome` in the `meta.yaml` as you hear back (or not):

```yaml
outcome: interview   # or: offer / rejected / ghosted
```

---

### Starting a new application from a past version

When applying for a similar role, bootstrap from the closest matching archive rather than starting from scratch:

```bash
./snapshot.sh 2026-06-15 OtherCorp junior-analyst --from 2026-05-01_ExampleAnalytics_data-analyst
```

The `--from` flag copies the content files from that archive into your working `content/` directory as a starting point. Edit from there as needed.

Once you're ready to submit:

```bash
./snapshot.sh 2026-06-15 OtherCorp junior-analyst
```

This creates a new archive entry with the updated content and design.

---

### Rolling back a design setting

Each `meta.yaml` records the exact design values used — margins, font sizes, line spread, spacing. To match a past version:

```bash
cat archive/2026-05-01_ExampleAnalytics_data-analyst/meta.yaml
```

Apply the relevant values back to `main.tex` to reproduce the layout.

---

### Quick reference

```bash
# Create a new snapshot
./snapshot.sh <date> <org> <role>

# Start from a past version
./snapshot.sh <date> <org> <role> --from <archive-name>

# Browse past applications
ls archive/

# Check an application's context and outcome
cat archive/<archive-name>/meta.yaml
```
