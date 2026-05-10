import { mkdir, readFile, readdir, rm, writeFile } from "node:fs/promises"
import path from "node:path"
import { fileURLToPath } from "node:url"

const siteDir = path.dirname(fileURLToPath(import.meta.url))
const repoRoot = path.resolve(siteDir, "..")
const sourceRoot = path.join(repoRoot, "wiki")
const destRoot = path.resolve(process.argv[2] ?? path.join(repoRoot, ".wiki-tmp", "quartz", "content"))

const skippedDirs = new Set(["_templates"])
const skippedFiles = new Set(["home.md", "index.md", "knowledge-graph.md"])

function rewriteSiteLinks(markdown) {
  return markdown
    .replace(/\[\[index\|([^\]]+)\]\]/g, "[[catalog|$1]]")
    .replaceAll("[[index]]", "[[catalog|index]]")
    .replace(/\[\[home\|([^\]]+)\]\]/g, "[[index|$1]]")
    .replaceAll("[[home]]", "[[index|home]]")
}

async function copyMarkdownTree(source, dest) {
  await mkdir(dest, { recursive: true })
  const entries = await readdir(source, { withFileTypes: true })

  for (const entry of entries) {
    if (entry.name.startsWith(".")) continue
    const from = path.join(source, entry.name)
    const to = path.join(dest, entry.name)

    if (entry.isDirectory()) {
      if (skippedDirs.has(entry.name)) continue
      await copyMarkdownTree(from, to)
      continue
    }

    if (!entry.isFile()) continue
    if (!entry.name.endsWith(".md")) continue
    if (skippedFiles.has(entry.name)) continue
    const markdown = await readFile(from, "utf8")
    await writeFile(to, rewriteSiteLinks(markdown))
  }
}

function asSiteHome(markdown) {
  return rewriteSiteLinks(markdown)
    .replace(/aliases:\s*\n(?:\s+- .+\n)*/m, "")
    .replace(/^---\n/, "---\naliases:\n  - home\n")
}

function asSiteCatalog(markdown) {
  return rewriteSiteLinks(markdown)
    .replace(/^title:\s*Index\s*$/m, "title: Catalog")
    .replace(/^# Index\s*$/m, "# Catalog")
    .replace(/aliases:\s*\n(?:\s+- .+\n)*/m, "")
    .replace(/^---\n/, "---\naliases:\n  - index\n")
}

await rm(destRoot, { recursive: true, force: true })
await copyMarkdownTree(sourceRoot, destRoot)

const homeMarkdown = await readFile(path.join(sourceRoot, "home.md"), "utf8")
const catalogMarkdown = await readFile(path.join(sourceRoot, "index.md"), "utf8")
await writeFile(path.join(destRoot, "index.md"), asSiteHome(homeMarkdown))
await writeFile(path.join(destRoot, "catalog.md"), asSiteCatalog(catalogMarkdown))

console.log(`Synced public markdown from ${sourceRoot} to ${destRoot}`)
console.log("Mapped wiki/home.md to the site root and preserved wiki/index.md as catalog.md")
