# Marketplace Icon Assets

This folder contains branding assets for the Azure DevOps extension marketplace listing.

## Required file

- `extension-icon.png`

Azure DevOps requires a PNG icon with a minimum size of `128x128`.

## Recommended size

- `256x256` PNG for better quality on high-DPI displays.

## Publishing checklist

Before packaging/publishing:

1. Confirm `extension-icon.png` exists in this folder.
2. Verify the icon path in manifests:
   - `vss-extension.json`
   - `vss-extension.dev.json`
3. Ensure the image remains clear at small sizes.

## Design tips

- Keep shapes simple and recognizable.
- Use strong contrast for readability.
- Avoid tiny text inside the icon.
