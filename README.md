<img src= "https://github.com/thrustlang/.github/blob/main/assets/logos/new%20logo/thrustlang-logo-banner-text-italic.png" alt= "logo" style= "width: 80%; height: 80%;"></img>

# Website

<img src= "https://github.com/thrustlang/.github/blob/main/assets/standard-text-separator.png" alt= "standard-separator" style= "width: 1hv;"> </img>

This is the official website and official documentation hub for the **Thrust Programming Language**.

It contains the public landing pages, versioned language documentation, standard library documentation, downloads pages, and the small Python tooling used to maintain documentation updates and releases.

## What Lives Here

- The public website pages under `en/` and `es/`
- The generated versioned documentation under `documentation/`
- The editable documentation content under `documentation/content/`
- The documentation maintenance scripts under `scripts/`
- The GitHub Pages deployment workflow under `.github/workflows/deploy-pages.yml`

## Documentation Guides

- `guide/DOCUMENTATION_WORKFLOW.md`
- `guide/DOCS_SCRIPTS_REFERENCE.md`
- `guide/CREATE_DOCS.md`
- `guide/UPDATE_DOCS.md`
- `guide/UPDATE_DOWNLOADS.md`
- `guide/RELEASE_DOCS.md`
- `guide/ARCHIVE_DOCS.md`
- `guide/GENERATE_STD_SOCIAL_CARDS.md`
- `guide/NORMALIZE_WEBSITE_PATH_FOR_GH_PAGES.md`
- `guide/DEPLOY_WEBSITE.md`

## Deployment

The repository can be deployed to GitHub Pages at `https://thrustlang.github.io/website/`.

Automatic deployment is handled by `.github/workflows/deploy-pages.yml`. Manual deployment is available through `scripts/deploy-website.sh`, `scripts/deploy-website.fish`, `scripts/deploy-website.ps1`, and `scripts/deploy-website.bat`.
