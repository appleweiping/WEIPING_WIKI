# vipin wiki Quartz Site

This directory is a publishing adapter for the public `wiki/` layer.

The canonical knowledge source remains `wiki/`. The site build copies only public Markdown into a temporary Quartz checkout and excludes raw sources, private wiki files, generated graph assets, and non-Markdown files.

## Local Build

From the repository root:

```powershell
.\scripts\build-site.ps1
```

The script clones Quartz v4 into `.wiki-tmp/quartz`, syncs public Markdown, copies the site configuration, and builds `public/`.

If local `node` or `npm` is missing, the PowerShell build script downloads an official Node 22 Windows x64 toolchain into `.wiki-tmp/node` and uses it only for this project.

## GitHub Pages

The workflow in `.github/workflows/deploy.yml` builds the same public-only site and deploys the `public/` artifact with GitHub Pages.

GitHub Pages should stay configured to deploy from GitHub Actions, not from a branch root. If Pages is pointed at the repository root, GitHub will render `README.md` as the website home and bypass the Quartz frontend.

Stability guards:

- `.github/workflows/deploy.yml` verifies the built artifact contains the Quartz root page before deployment.
- `.github/workflows/deploy.yml` verifies the deployed URL after deployment.
- `.github/workflows/pages-health.yml` checks the live site daily and fails if the public URL turns back into a README-style GitHub Markdown page.
