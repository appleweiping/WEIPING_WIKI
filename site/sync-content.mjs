import { cp, mkdir, readdir, rm } from "node:fs/promises"
import path from "node:path"
import { fileURLToPath } from "node:url"

const siteDir = path.dirname(fileURLToPath(import.meta.url))
const repoRoot = path.resolve(siteDir, "..")
const sourceRoot = path.join(repoRoot, "wiki")
const destRoot = path.resolve(process.argv[2] ?? path.join(repoRoot, ".wiki-tmp", "quartz", "content"))

const skippedDirs = new Set(["_templates"])
const skippedFiles = new Set(["knowledge-graph.md"])

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
    await cp(from, to)
  }
}

await rm(destRoot, { recursive: true, force: true })
await copyMarkdownTree(sourceRoot, destRoot)
console.log(`Synced public markdown from ${sourceRoot} to ${destRoot}`)
