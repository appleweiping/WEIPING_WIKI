---
title: Frontend Frameworks Public Corpus
type: topic
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - frontend-frameworks
  - public-corpus
  - github
source_pages:
  - raw/frontend-frameworks-public/registry.json
  - raw/frontend-frameworks-public/manifest.json
---

# Frontend Frameworks Public Corpus

This hub tracks reusable frontend project frameworks: knowledge-site shells, documentation frameworks, app frameworks, build substrates, and lower-level UI runtimes. The goal is project reuse: when a future project needs a frontend, a human or agent should be able to click through from use case to framework, repository, docs, demo, and release ideas.

The current `vipin wiki` publishing layer uses Quartz v4 through the local `site/` adapter and `.wiki-tmp/quartz` build flow.

## Choose By Project Need

### I Need A Personal Wiki Or Knowledge Site

| Framework | Role | Shell score | Captured repos | Docs | Demo/showcase |
| --- | --- | ---: | ---: | --- | --- |
| [[entities/frontend-frameworks/quartz|Quartz]] | `knowledge-site-framework` | `10` | 1 | https://quartz.jzhao.xyz | https://quartz.jzhao.xyz |

### I Need Documentation Or Developer Docs

| Framework | Role | Shell score | Captured repos | Docs | Demo/showcase |
| --- | --- | ---: | ---: | --- | --- |
| [[entities/frontend-frameworks/docusaurus|Docusaurus]] | `docs-framework` | `10` | 1 | https://docusaurus.io/docs | https://docusaurus.io/showcase |
| [[entities/frontend-frameworks/fumadocs|Fumadocs]] | `docs-framework` | `9` | 1 | https://fumadocs.dev/docs | https://fumadocs.dev |
| [[entities/frontend-frameworks/nextra|Nextra]] | `docs-framework` | `9` | 1 | https://nextra.site/docs | https://nextra.site |
| [[entities/frontend-frameworks/starlight|Starlight]] | `docs-framework` | `9` | 1 | https://starlight.astro.build/getting-started/ | https://starlight.astro.build |
| [[entities/frontend-frameworks/vitepress|VitePress]] | `docs-framework` | `9` | 1 | https://vitepress.dev/guide/getting-started | https://vitepress.dev |

### I Need A Website Or App Shell

| Framework | Role | Shell score | Captured repos | Docs | Demo/showcase |
| --- | --- | ---: | ---: | --- | --- |
| [[entities/frontend-frameworks/nextjs|Next.js]] | `app-framework` | `10` | 1 | https://nextjs.org/docs | https://nextjs.org/showcase |
| [[entities/frontend-frameworks/nuxt|Nuxt]] | `app-framework` | `10` | 4 | https://nuxt.com/docs | https://nuxt.com/templates |
| [[entities/frontend-frameworks/astro|Astro]] | `site-framework` | `9` | 3 | https://docs.astro.build | https://astro.build/themes/ |
| [[entities/frontend-frameworks/remix-react-router|Remix / React Router]] | `app-framework` | `9` | 2 | https://reactrouter.com | https://remix.run |
| [[entities/frontend-frameworks/sveltekit|SvelteKit]] | `app-framework` | `9` | 1 | https://svelte.dev/docs/kit | https://svelte.dev |
| [[entities/frontend-frameworks/angular|Angular]] | `app-framework` | `8` | 3 | https://angular.dev/overview | https://angular.dev |
| [[entities/frontend-frameworks/qwik|Qwik]] | `app-framework` | `8` | 1 | https://qwik.dev/docs/ | https://qwik.dev/examples/ |
| [[entities/frontend-frameworks/tanstack-start|TanStack Start]] | `app-framework` | `8` | 1 | https://tanstack.com/start/latest | https://tanstack.com/start |

### I Need Build Or Server Tooling

| Framework | Role | Shell score | Captured repos | Docs | Demo/showcase |
| --- | --- | ---: | ---: | --- | --- |
| [[entities/frontend-frameworks/vite|Vite]] | `build-tooling` | `7` | 2 | https://vite.dev/guide/ | https://vite.dev |
| [[entities/frontend-frameworks/nitro|Nitro]] | `build-tooling` | `6` | 1 | https://nitro.build/guide | https://nitro.build |

### I Need A UI Runtime Or Dependency Substrate

These are important, but usually not enough by themselves for a complete project shell.

| Framework | Role | Shell score | Captured repos | Docs | Demo/showcase |
| --- | --- | ---: | ---: | --- | --- |
| [[entities/frontend-frameworks/solid|Solid]] | `ui-runtime` | `6` | 3 | https://docs.solidjs.com | https://playground.solidjs.com |
| [[entities/frontend-frameworks/svelte|Svelte]] | `ui-runtime` | `5` | 3 | https://svelte.dev/docs | https://svelte.dev/playground |
| [[entities/frontend-frameworks/react|React]] | `ui-runtime` | `4` | 2 | https://react.dev | https://react.dev |
| [[entities/frontend-frameworks/vue|Vue]] | `ui-runtime` | `4` | 5 | https://vuejs.org/guide/ | https://play.vuejs.org |

## Full Matrix

| Framework | Role | Captured repos | Homepage |
| --- | --- | ---: | --- |
| [[entities/frontend-frameworks/angular|Angular]] | `app-framework` | 3 | https://angular.dev |
| [[entities/frontend-frameworks/astro|Astro]] | `site-framework` | 3 | https://astro.build |
| [[entities/frontend-frameworks/docusaurus|Docusaurus]] | `docs-framework` | 1 | https://docusaurus.io |
| [[entities/frontend-frameworks/fumadocs|Fumadocs]] | `docs-framework` | 1 | https://fumadocs.dev |
| [[entities/frontend-frameworks/nextjs|Next.js]] | `app-framework` | 1 | https://nextjs.org |
| [[entities/frontend-frameworks/nextra|Nextra]] | `docs-framework` | 1 | https://nextra.site |
| [[entities/frontend-frameworks/nitro|Nitro]] | `build-tooling` | 1 | https://nitro.build |
| [[entities/frontend-frameworks/nuxt|Nuxt]] | `app-framework` | 4 | https://nuxt.com |
| [[entities/frontend-frameworks/quartz|Quartz]] | `knowledge-site-framework` | 1 | https://quartz.jzhao.xyz |
| [[entities/frontend-frameworks/qwik|Qwik]] | `app-framework` | 1 | https://qwik.dev |
| [[entities/frontend-frameworks/react|React]] | `ui-runtime` | 2 | https://react.dev |
| [[entities/frontend-frameworks/remix-react-router|Remix / React Router]] | `app-framework` | 2 | https://reactrouter.com |
| [[entities/frontend-frameworks/solid|Solid]] | `ui-runtime` | 3 | https://www.solidjs.com |
| [[entities/frontend-frameworks/starlight|Starlight]] | `docs-framework` | 1 | https://starlight.astro.build |
| [[entities/frontend-frameworks/svelte|Svelte]] | `ui-runtime` | 3 | https://svelte.dev |
| [[entities/frontend-frameworks/sveltekit|SvelteKit]] | `app-framework` | 1 | https://svelte.dev/docs/kit |
| [[entities/frontend-frameworks/tanstack-start|TanStack Start]] | `app-framework` | 1 | https://tanstack.com/start |
| [[entities/frontend-frameworks/vite|Vite]] | `build-tooling` | 2 | https://vite.dev |
| [[entities/frontend-frameworks/vitepress|VitePress]] | `docs-framework` | 1 | https://vitepress.dev |
| [[entities/frontend-frameworks/vue|Vue]] | `ui-runtime` | 5 | https://vuejs.org |

## Entry Points

- [[frontend-project-shell-taxonomy]] - Browse frameworks by reusable project-shell role.
- [[frontend-framework-reuse-map]] - Decide which framework to migrate into a future project.
- `raw/frontend-frameworks-public/manifest.json` - Local manifest with stable IDs, hashes, candidate records, and provenance.

## Languages

- `TypeScript`: [[sources/frontend-frameworks/angular-angular|angular/angular]], [[sources/frontend-frameworks/angular-angular-cli|angular/angular-cli]], [[sources/frontend-frameworks/angular-components|angular/components]], [[sources/frontend-frameworks/facebook-docusaurus|facebook/docusaurus]], [[sources/frontend-frameworks/fuma-nama-fumadocs|fuma-nama/fumadocs]], [[sources/frontend-frameworks/jackyzha0-quartz|jackyzha0/quartz]], [[sources/frontend-frameworks/nitrojs-nitro|nitrojs/nitro]], [[sources/frontend-frameworks/nuxt-content|nuxt/content]], [[sources/frontend-frameworks/nuxt-image|nuxt/image]], [[sources/frontend-frameworks/nuxt-nuxt|nuxt/nuxt]], [[sources/frontend-frameworks/qwikdev-qwik|QwikDev/qwik]], [[sources/frontend-frameworks/remix-run-react-router|remix-run/react-router]], [[sources/frontend-frameworks/remix-run-remix|remix-run/remix]], [[sources/frontend-frameworks/shuding-nextra|shuding/nextra]], [[sources/frontend-frameworks/solidjs-solid|solidjs/solid]], [[sources/frontend-frameworks/solidjs-solid-start|solidjs/solid-start]], [[sources/frontend-frameworks/tanstack-router|TanStack/router]], [[sources/frontend-frameworks/vitejs-vite|vitejs/vite]], [[sources/frontend-frameworks/vitejs-vite-plugin-react|vitejs/vite-plugin-react]], [[sources/frontend-frameworks/vuejs-core|vuejs/core]], [[sources/frontend-frameworks/vuejs-devtools|vuejs/devtools]], [[sources/frontend-frameworks/vuejs-pinia|vuejs/pinia]], [[sources/frontend-frameworks/vuejs-router|vuejs/router]], [[sources/frontend-frameworks/vuejs-vitepress|vuejs/vitepress]], [[sources/frontend-frameworks/withastro-astro|withastro/astro]], [[sources/frontend-frameworks/withastro-starlight|withastro/starlight]]
- `JavaScript`: [[sources/frontend-frameworks/facebook-react|facebook/react]], [[sources/frontend-frameworks/reactjs-react-dev|reactjs/react.dev]], [[sources/frontend-frameworks/sveltejs-kit|sveltejs/kit]], [[sources/frontend-frameworks/sveltejs-svelte|sveltejs/svelte]], [[sources/frontend-frameworks/vercel-next-js|vercel/next.js]]
- `Vue`: [[sources/frontend-frameworks/nuxt-ui|nuxt/ui]], [[sources/frontend-frameworks/vuejs-docs|vuejs/docs]]
- `MDX`: [[sources/frontend-frameworks/solidjs-solid-docs|solidjs/solid-docs]], [[sources/frontend-frameworks/withastro-docs|withastro/docs]]
- `Svelte`: [[sources/frontend-frameworks/sveltejs-svelte-dev|sveltejs/svelte.dev]]

## Needs Review

- Vue: [vuejs/vitepress](https://github.com/vuejs/vitepress) - stars 17718, Vite & Vue powered static site generator.
- Vue: [vuejs/vue-hackernews-2.0](https://github.com/vuejs/vue-hackernews-2.0) - stars 10872, HackerNews clone built with Vue 2.0, vue-router & vuex, with server-side rendering
- Vue: [vuejs/petite-vue](https://github.com/vuejs/petite-vue) - stars 9672, 6kb subset of Vue optimized for progressive enhancement
- Vue: [vuejs/language-tools](https://github.com/vuejs/language-tools) - stars 6660, ⚡ High-performance Vue language tooling based-on Volar.js
- Vue: [vuejs/apollo](https://github.com/vuejs/apollo) - stars 6043, 🚀 Apollo/GraphQL integration for VueJS
- Vue: [vuejs/vue-class-component](https://github.com/vuejs/vue-class-component) - stars 5765, ES / TypeScript decorator for class-style Vue components.
- Vue: [vuejs/vetur](https://github.com/vuejs/vetur) - stars 5752, Vue tooling for VS Code.
- Vue: [vuejs/v2.vuejs.org](https://github.com/vuejs/v2.vuejs.org) - stars 4987, 📄 Documentation for Vue 2
- VitePress: [vuejs/vue](https://github.com/vuejs/vue) - stars 209766, This is the repo for Vue 2. For Vue 3, go to https://github.com/vuejs/core
- VitePress: [vuejs/awesome-vue](https://github.com/vuejs/awesome-vue) - stars 73594, 🎉 A curated list of awesome things related to Vue.js
- VitePress: [vuejs/core](https://github.com/vuejs/core) - stars 53669, 🖖 Vue.js is a progressive, incrementally-adoptable JavaScript framework for building UI on the web.
- VitePress: [vuejs/vue-cli](https://github.com/vuejs/vue-cli) - stars 29586, 🛠️ webpack-based tooling for Vue.js Development
- VitePress: [vuejs/vuex](https://github.com/vuejs/vuex) - stars 28362, 🗃️ Centralized State Management for Vue.js.
- VitePress: [vuejs/devtools-v6](https://github.com/vuejs/devtools-v6) - stars 24729, ⚙️ Browser devtools extension for debugging Vue.js applications.
- VitePress: [vuejs/vuepress](https://github.com/vuejs/vuepress) - stars 22771, 📝 Minimalistic Vue-powered static site generator
- VitePress: [vuejs/vue-router](https://github.com/vuejs/vue-router) - stars 18905, 🚦 The official router for Vue 2
- Vite: [vitejs/awesome-vite](https://github.com/vitejs/awesome-vite) - stars 17082, ⚡️ A curated list of awesome things related to Vite.js
- Vite: [vitejs/rolldown-vite](https://github.com/vitejs/rolldown-vite) - stars 1289, The WIP version of Vite powered by Rolldown
- Vite: [vitejs/devtools](https://github.com/vitejs/devtools) - stars 1157, DevTools for Vite (Rolldown).
- Vite: [vitejs/vite-plugin-react-swc](https://github.com/vitejs/vite-plugin-react-swc) - stars 957, Speed up your Vite dev server with SWC
- Vite: [vitejs/docs-cn](https://github.com/vitejs/docs-cn) - stars 867, Chinese translation of vite.dev
- Vite: [vitejs/vite-plugin-vue](https://github.com/vitejs/vite-plugin-vue) - stars 662, Vite Vue Plugins
- Vite: [vitejs/create-vite-app](https://github.com/vitejs/create-vite-app) - stars 586, Create a Vite-powered app in seconds!
- Vite: [vitejs/vite-plugin-vue2](https://github.com/vitejs/vite-plugin-vue2) - stars 580, Vite plugin for Vue 2.7
- TanStack Start: [TanStack/form](https://github.com/TanStack/form) - stars 6530, 🤖 Headless, performant, and type-safe form state management for TS/JS, React, Vue, Angular, Solid, and Lit.
- TanStack Start: [TanStack/cli](https://github.com/TanStack/cli) - stars 1257, The official TanStack CLI - Project Scaffolding, MCP Server, Agent Skills Installation, etc
- TanStack Start: [TanStack/tanstack.com](https://github.com/TanStack/tanstack.com) - stars 981, The marketing and docs site for all TanStack projects
- TanStack Start: [TanStack/devtools](https://github.com/TanStack/devtools) - stars 462, 🤖 Framework-agnostic devtools panel for handling TanStack libraries devtools and your custom devtool plugins
- TanStack Start: [TanStack/alt-cli](https://github.com/TanStack/alt-cli) - stars 30, The official TanStack CLI for scaffolding, MCP, agent skills, and all other productivity related tooling
- TanStack Start: [TanStack/template](https://github.com/TanStack/template) - stars 6, a blank template for creating a new tanstack library with tanstack configs set up
- SvelteKit: [sveltejs/svelte](https://github.com/sveltejs/svelte) - stars 86573, web development for the rest of us
- SvelteKit: [sveltejs/realworld](https://github.com/sveltejs/realworld) - stars 2416, SvelteKit implementation of the RealWorld app
- SvelteKit: [sveltejs/svelte-preprocess](https://github.com/sveltejs/svelte-preprocess) - stars 1787, A ✨ magical ✨ Svelte preprocessor with sensible defaults and support for: PostCSS, SCSS, Less, Stylus, Coffeescript, TypeScript, Pug and much more.
- SvelteKit: [sveltejs/template](https://github.com/sveltejs/template) - stars 1746, Template for building basic applications with Svelte
- SvelteKit: [sveltejs/vite-plugin-svelte](https://github.com/sveltejs/vite-plugin-svelte) - stars 1029, Svelte plugin for https://vite.dev
- SvelteKit: [sveltejs/prettier-plugin-svelte](https://github.com/sveltejs/prettier-plugin-svelte) - stars 810, Format your svelte components using prettier.
- SvelteKit: [sveltejs/sapper-template](https://github.com/sveltejs/sapper-template) - stars 693, Starter template for Sapper apps
- SvelteKit: [sveltejs/component-template](https://github.com/sveltejs/component-template) - stars 563, A base for building shareable Svelte components
- Svelte: [sveltejs/sapper](https://github.com/sveltejs/sapper) - stars 6937, The next small thing in web development, powered by Svelte
- Svelte: [sveltejs/svelte-devtools](https://github.com/sveltejs/svelte-devtools) - stars 1623, A browser extension to inspect Svelte application by extending your browser devtools capabilities
- Svelte: [sveltejs/language-tools](https://github.com/sveltejs/language-tools) - stars 1424, The Svelte Language Server, and official extensions which use it
- Svelte: [sveltejs/svelte-virtual-list](https://github.com/sveltejs/svelte-virtual-list) - stars 768, A virtual list component for Svelte apps
- Svelte: [sveltejs/integrations](https://github.com/sveltejs/integrations) - stars 621, Ways to incorporate Svelte into your stack
- Svelte: [sveltejs/svelte-loader](https://github.com/sveltejs/svelte-loader) - stars 604, Webpack loader for svelte components.
- Svelte: [sveltejs/gl](https://github.com/sveltejs/gl) - stars 600, A (very experimental) project to bring WebGL to Svelte
- Svelte: [sveltejs/community-legacy](https://github.com/sveltejs/community-legacy) - stars 556, Svelte community meetups, packages, resources, recipes, showcase websites, and more
- Starlight: [withastro/astro](https://github.com/withastro/astro) - stars 59329, The web framework for content-driven websites. ⭐️ Star to support our work!
- Starlight: [withastro/docs](https://github.com/withastro/docs) - stars 1625, Astro documentation
- Starlight: [withastro/storefront](https://github.com/withastro/storefront) - stars 809, Astro for ecommerce 💰
- Starlight: [withastro/compiler](https://github.com/withastro/compiler) - stars 653, The Astro compiler. Written in Go. Distributed as WASM.
- Starlight: [withastro/prettier-plugin-astro](https://github.com/withastro/prettier-plugin-astro) - stars 599, Prettier plugin for Astro
- Starlight: [withastro/astro.build](https://github.com/withastro/astro.build) - stars 494, No source summary text was available during this crawl.
- Starlight: [withastro/roadmap](https://github.com/withastro/roadmap) - stars 389, Ideas, suggestions, and formal RFC proposals for the Astro project.
- Starlight: [withastro/language-tools](https://github.com/withastro/language-tools) - stars 337, Language tools for Astro
- Solid: [solidjs/solid-router](https://github.com/solidjs/solid-router) - stars 1314, A universal router for Solid inspired by Ember and React Router
- Solid: [solidjs/templates](https://github.com/solidjs/templates) - stars 532, Vite + solid templates
- Solid: [solidjs/vite-plugin-solid](https://github.com/solidjs/vite-plugin-solid) - stars 508, A simple integration to run solid-js with vite
- Solid: [solidjs/solid-styled-components](https://github.com/solidjs/solid-styled-components) - stars 296, A 1kb Styled Components library for Solid
- Solid: [solidjs/solid-playground](https://github.com/solidjs/solid-playground) - stars 242, Quickly discover what the solid compiler will generate from your JSX template
- Solid: [solidjs/solid-realworld](https://github.com/solidjs/solid-realworld) - stars 233, A Solid Implementation of the Realworld Example App
- Solid: [solidjs/solid-testing-library](https://github.com/solidjs/solid-testing-library) - stars 226, Simple and complete Solid testing utilities that encourage good testing practices.
- Solid: [solidjs/react-solid-state](https://github.com/solidjs/react-solid-state) - stars 211, Auto tracking state management for modern React
- Remix / React Router: [remix-run/examples](https://github.com/remix-run/examples) - stars 1213, A community-driven repository showcasing examples using Remix 💿
- Remix / React Router: [remix-run/indie-stack](https://github.com/remix-run/indie-stack) - stars 1144, The Remix Stack for deploying to Fly with SQLite, authentication, testing, linting, formatting, etc.
- Remix / React Router: [remix-run/blues-stack](https://github.com/remix-run/blues-stack) - stars 973, The Remix Stack for deploying to Fly with PostgreSQL, authentication, testing, linting, formatting, etc.
- Remix / React Router: [remix-run/react-router-templates](https://github.com/remix-run/react-router-templates) - stars 641, No source summary text was available during this crawl.
- Remix / React Router: [remix-run/grunge-stack](https://github.com/remix-run/grunge-stack) - stars 445, The Remix Stack for deploying to AWS with DynamoDB, authentication, testing, linting, formatting, etc.
- Remix / React Router: [remix-run/example-trellix](https://github.com/remix-run/example-trellix) - stars 312, A partial trello board clone with Remix
- Remix / React Router: [remix-run/remix-store](https://github.com/remix-run/remix-store) - stars 208, Remix Store - Built on Hydrogen
- Remix / React Router: [remix-run/react-router-website](https://github.com/remix-run/react-router-website) - stars 200, The React Router website
- React: [facebook/react-native](https://github.com/facebook/react-native) - stars 125821, A framework for building native applications using React
- React: [facebook/docusaurus](https://github.com/facebook/docusaurus) - stars 64926, Easy to maintain open source documentation websites.
- React: [facebook/relay](https://github.com/facebook/relay) - stars 18938, Relay is a JavaScript framework for building data-driven React applications.
- React: [facebook/hermes](https://github.com/facebook/hermes) - stars 11051, A JavaScript engine optimized for running React Native.
- React: [facebook/react-devtools](https://github.com/facebook/react-devtools) - stars 11014, An extension that allows inspection of React component hierarchy in the Chrome and Firefox Developer Tools.
- React: [reactjs/react-transition-group](https://github.com/reactjs/react-transition-group) - stars 10246, An easy way to perform animations when a React component enters or leaves the DOM
- React: [reactjs/react-router-redux](https://github.com/reactjs/react-router-redux) - stars 7755, Ruthlessly simple bindings to keep react-router and redux in sync
- React: [reactjs/react-modal](https://github.com/reactjs/react-modal) - stars 7411, Accessible modal dialog component for React
- React: [reactjs/react-rails](https://github.com/reactjs/react-rails) - stars 6758, Integrate React.js with Rails views and controllers, the asset pipeline, or webpacker.
- React: [reactjs/rfcs](https://github.com/reactjs/rfcs) - stars 5792, RFCs for changes to React

## Maintenance Rules

- Stable IDs are mandatory: `framework:<slug>`, `github:<owner>/<repo>`, `github-release:<owner>/<repo>:<tag_name>`, and `github-candidate:<owner>/<repo>`.
- Do not promote candidates into public repo pages until `raw/frontend-frameworks-public/registry.json` explicitly includes them.
- Public pages contain metadata, summaries, hashes, and links only.
- Re-run `scripts/ingest-frontend-frameworks-public.ps1` before making current claims about stars, releases, or repo structure.
- Treat `ui-runtime` entries as dependency substrates unless their registry notes explicitly identify a complete project shell.

## Counterpoints And Gaps

- AMBIGUOUS: The corpus is complete only inside the curated project-framework registry boundary, not across every repo in each owner organization.
- AMBIGUOUS: Candidate discovery is keyword-based and may miss official repos whose descriptions/topics do not match project-shell keywords.
- INFERRED: Stars, file profiles, and release ordering are crawl-time signals and should not be treated as stable quality rankings.
