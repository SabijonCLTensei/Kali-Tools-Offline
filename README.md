# Kali Tools Offline Documentation

A complete, self-contained offline mirror of the official [Kali Linux Tools Documentation](https://www.kali.org/tools/).

## Features
- **790+ Tools Included**: Complete manuals, command flags, package dependencies, and usage examples (from `0trace` to `zsh-syntax-highlighting`).
- **100% Offline & Air-Gapped**:
  - All internal documentation links point to local `.html` files.
  - Assets, images, banners, and SVGs resolve to the local `images/` directory.
  - Stylesheets (`style.min.css`, `tools.min.css`) and Themify fonts are included locally.
  - External tracking scripts removed.
- **Two-Way Navigation**:
  - [**All Tools Catalog**](www.kali.org/tools/all-tools/index.html): Lists every tool alphabetically with direct links to their offline manual.
  - Inside each tool page, the `↤ Go back` button and `Tools Documentation` header link return directly to `all-tools/index.html`.
  - [**Categories Hub**](www.kali.org/tools/index.html): Browse tools by tactical security categories (Reconnaissance, Exploitation, Privilege Escalation, etc.).

## Quick Start (How to Open)

### In a Web Browser
Double-click or open in any web browser:
```
www.kali.org/tools/all-tools/index.html
```

### In VS Code
1. Install the **Live Preview** extension (by Microsoft).
2. Right-click `www.kali.org/tools/all-tools/index.html` and select **Live Preview: Show Preview**.
3. Or press `Ctrl + Shift + B` to launch in your default browser.

### Local HTTP Server
Run from the root of this folder:
```bash
# Python
python -m http.server 8080

# Or navigate to:
# http://localhost:8080/www.kali.org/tools/all-tools/index.html
```

## Maintenance Scripts
- `convert_offline_links.ps1`: PowerShell script to convert online URLs to relative offline paths.
- `convert_offline_links.py`: Python equivalent of the offline link converter.
