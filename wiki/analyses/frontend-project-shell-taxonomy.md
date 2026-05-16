---
title: Frontend Project Shell Taxonomy
type: analysis
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - frontend-frameworks
  - project-shells
  - taxonomy
  - github
source_pages:
  - raw/frontend-frameworks-public/registry.json
  - raw/frontend-frameworks-public/manifest.json
---

# Frontend Project Shell Taxonomy

This taxonomy groups captured frontend repositories by reusable project role rather than popularity alone. Its first question is: can this help start or migrate a future frontend project?

## Shell Score Guide

- `10`: complete project shell with docs, routing/content conventions, examples, and clear deployment path.
- `8-9`: strong app/site shell, sometimes with a narrower ecosystem or more evolving API.
- `6-7`: important tooling or partial shell; useful when composing a custom project.
- `4-5`: dependency substrate/runtime; pair with a framework shell before starting a project.

## app-framework

- [[sources/frontend-frameworks/angular-angular|angular/angular]] - [[entities/frontend-frameworks/angular|Angular]], TypeScript, stars 100116
- [[sources/frontend-frameworks/angular-angular-cli|angular/angular-cli]] - [[entities/frontend-frameworks/angular|Angular]], TypeScript, stars 27041
- [[sources/frontend-frameworks/angular-components|angular/components]] - [[entities/frontend-frameworks/angular|Angular]], TypeScript, stars 25026
- [[sources/frontend-frameworks/vercel-next-js|vercel/next.js]] - [[entities/frontend-frameworks/nextjs|Next.js]], JavaScript, stars 139494
- [[sources/frontend-frameworks/nuxt-content|nuxt/content]] - [[entities/frontend-frameworks/nuxt|Nuxt]], TypeScript, stars 3637
- [[sources/frontend-frameworks/nuxt-image|nuxt/image]] - [[entities/frontend-frameworks/nuxt|Nuxt]], TypeScript, stars 1526
- [[sources/frontend-frameworks/nuxt-nuxt|nuxt/nuxt]] - [[entities/frontend-frameworks/nuxt|Nuxt]], TypeScript, stars 60225
- [[sources/frontend-frameworks/nuxt-ui|nuxt/ui]] - [[entities/frontend-frameworks/nuxt|Nuxt]], Vue, stars 6579
- [[sources/frontend-frameworks/qwikdev-qwik|QwikDev/qwik]] - [[entities/frontend-frameworks/qwik|Qwik]], TypeScript, stars 22010
- [[sources/frontend-frameworks/remix-run-react-router|remix-run/react-router]] - [[entities/frontend-frameworks/remix-react-router|Remix / React Router]], TypeScript, stars 56416
- [[sources/frontend-frameworks/remix-run-remix|remix-run/remix]] - [[entities/frontend-frameworks/remix-react-router|Remix / React Router]], TypeScript, stars 32974
- [[sources/frontend-frameworks/sveltejs-kit|sveltejs/kit]] - [[entities/frontend-frameworks/sveltekit|SvelteKit]], JavaScript, stars 20503
- [[sources/frontend-frameworks/tanstack-router|TanStack/router]] - [[entities/frontend-frameworks/tanstack-start|TanStack Start]], TypeScript, stars 14422

## build-tooling

- [[sources/frontend-frameworks/nitrojs-nitro|nitrojs/nitro]] - [[entities/frontend-frameworks/nitro|Nitro]], TypeScript, stars 10828
- [[sources/frontend-frameworks/vitejs-vite|vitejs/vite]] - [[entities/frontend-frameworks/vite|Vite]], TypeScript, stars 80631
- [[sources/frontend-frameworks/vitejs-vite-plugin-react|vitejs/vite-plugin-react]] - [[entities/frontend-frameworks/vite|Vite]], TypeScript, stars 1077

## docs-framework

- [[sources/frontend-frameworks/facebook-docusaurus|facebook/docusaurus]] - [[entities/frontend-frameworks/docusaurus|Docusaurus]], TypeScript, stars 64926
- [[sources/frontend-frameworks/fuma-nama-fumadocs|fuma-nama/fumadocs]] - [[entities/frontend-frameworks/fumadocs|Fumadocs]], TypeScript, stars 11863
- [[sources/frontend-frameworks/shuding-nextra|shuding/nextra]] - [[entities/frontend-frameworks/nextra|Nextra]], TypeScript, stars 13796
- [[sources/frontend-frameworks/withastro-starlight|withastro/starlight]] - [[entities/frontend-frameworks/starlight|Starlight]], TypeScript, stars 8489
- [[sources/frontend-frameworks/vuejs-vitepress|vuejs/vitepress]] - [[entities/frontend-frameworks/vitepress|VitePress]], TypeScript, stars 17718

## knowledge-site-framework

- [[sources/frontend-frameworks/jackyzha0-quartz|jackyzha0/quartz]] - [[entities/frontend-frameworks/quartz|Quartz]], TypeScript, stars 12186

## site-framework

- [[sources/frontend-frameworks/withastro-astro|withastro/astro]] - [[entities/frontend-frameworks/astro|Astro]], TypeScript, stars 59329
- [[sources/frontend-frameworks/withastro-docs|withastro/docs]] - [[entities/frontend-frameworks/astro|Astro]], MDX, stars 1625

## ui-runtime

- [[sources/frontend-frameworks/facebook-react|facebook/react]] - [[entities/frontend-frameworks/react|React]], JavaScript, stars 245053
- [[sources/frontend-frameworks/reactjs-react-dev|reactjs/react.dev]] - [[entities/frontend-frameworks/react|React]], JavaScript, stars 11750
- [[sources/frontend-frameworks/solidjs-solid|solidjs/solid]] - [[entities/frontend-frameworks/solid|Solid]], TypeScript, stars 35521
- [[sources/frontend-frameworks/solidjs-solid-docs|solidjs/solid-docs]] - [[entities/frontend-frameworks/solid|Solid]], MDX, stars 284
- [[sources/frontend-frameworks/solidjs-solid-start|solidjs/solid-start]] - [[entities/frontend-frameworks/solid|Solid]], TypeScript, stars 5860
- [[sources/frontend-frameworks/sveltejs-svelte|sveltejs/svelte]] - [[entities/frontend-frameworks/svelte|Svelte]], JavaScript, stars 86573
- [[sources/frontend-frameworks/sveltejs-svelte-dev|sveltejs/svelte.dev]] - [[entities/frontend-frameworks/svelte|Svelte]], Svelte, stars 295
- [[sources/frontend-frameworks/vuejs-core|vuejs/core]] - [[entities/frontend-frameworks/vue|Vue]], TypeScript, stars 53669
- [[sources/frontend-frameworks/vuejs-devtools|vuejs/devtools]] - [[entities/frontend-frameworks/vue|Vue]], TypeScript, stars 2827
- [[sources/frontend-frameworks/vuejs-docs|vuejs/docs]] - [[entities/frontend-frameworks/vue|Vue]], Vue, stars 3220
- [[sources/frontend-frameworks/vuejs-pinia|vuejs/pinia]] - [[entities/frontend-frameworks/vue|Vue]], TypeScript, stars 14581
- [[sources/frontend-frameworks/vuejs-router|vuejs/router]] - [[entities/frontend-frameworks/vue|Vue]], TypeScript, stars 4610

## Related

- [[frontend-frameworks-public]]
- [[frontend-framework-reuse-map]]

## Counterpoints And Gaps

- AMBIGUOUS: Ecosystem roles are registry-level project-reuse labels; some repos legitimately span docs, app, and runtime layers.
- INFERRED: Role grouping is for project selection and retrieval, not a definitive taxonomy of each framework's architecture.
