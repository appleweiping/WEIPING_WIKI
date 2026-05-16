---
title: Frontend Framework Reuse Map
type: analysis
status: active
created: 2026-05-16
updated: 2026-05-16
tags:
  - frontend-frameworks
  - project-shells
  - reuse-map
  - releases
source_pages:
  - raw/frontend-frameworks-public/registry.json
  - raw/frontend-frameworks-public/manifest.json
---

# Frontend Framework Reuse Map

This page explains what each captured frontend project framework is trying to provide, when to reuse it, and which release ideas matter for future project migration.

## Angular

### Repository Ideas

- [[sources/frontend-frameworks/angular-angular|angular/angular]]: Deliver web apps with confidence 🚀 Angular - The modern web developer's platform Angular is a development platform for building mobile and desktop web applications using TypeScript/JavaScript and other languages. angular.dev Contributing Guidelines · Submit an Issue · Blog Documentation Get started with Angular, learn the fundamentals and explore advanced topics on our documentation website. - [Getting Started][quickstart] - [Architecture][architecture] - [Components and Templates][componentstemplates] - [Forms][forms] - [API][api] Advanced - [Angular Elements][angularelements] - [Server Side Rendering][ssr] - [Schematics][schemati...
- [[sources/frontend-frameworks/angular-angular-cli|angular/angular-cli]]: CLI tool for Angular Angular CLI - The CLI tool for Angular. The Angular CLI is a command-line interface tool that you use to initialize, develop, scaffold, and maintain Angular applications directly from a command shell. angular.dev/tools/cli Contributing Guidelines · Submit an Issue · Blog Documentation Get started with Angular CLI, learn the fundamentals and explore advanced topics on our documentation website. - [Getting started][quickstart] - [CLI][cli] - [Workspace and project file structure][filestructure] - [Workspace configuration][workspaceconfig] - [Schematics][schematics] Development Setup Prerequisites - Install [Node.j...
- [[sources/frontend-frameworks/angular-components|angular/components]]: Component infrastructure and Material Design components for Angular Official components for Angular $1](https://www.npmjs.com/package/@angular/cdk) $1](https://circleci.com/gh/angular/components) $1](https://gitter.im/angular/material2?utm source=badge&utm medium=badge&utm campaign=pr-badge) The Angular team builds and maintains both common UI components and tools to help you build your own custom components. The team maintains several npm packages. Package Description Docs ------------------------- ------------------------------------------------------------------------------------- ----------------- @angular/aria Collection of hea...

### Release Ideas

- [[sources/frontend-frameworks/releases/angular-components-v22-0-0-rc-0|v22.0.0-rc.0]]: material Commit Description -- -- $1](https://github.com/angular/components/commit/c3161985279bf49f9aae55b732fdd3b2872e1f7e) sidenav: mark content as inert while open $1](https://github.com/angular/components/commit/c2f1...
- [[sources/frontend-frameworks/releases/angular-components-v21-2-11|v21.2.11]]: No user facing changes in this release
- [[sources/frontend-frameworks/releases/angular-angular-v22-0-0-rc-0|v22.0.0-rc.0]]: compiler Commit Description -- -- $1](https://github.com/angular/angular/commit/c7aef8ec5dd12b5b1d4c703a61bd1dd43f998e18) enforce parentheses containing arguments for :host-context $1](https://github.com/angular/angular/...
- [[sources/frontend-frameworks/releases/angular-angular-v21-2-13|v21.2.13]]: core Commit Description -- -- $1](https://github.com/angular/angular/commit/1c6553e97d9655d8c48fbf625987fae86f9cd947) disallow event attribute bindings in host bindings unconditionally platform-server Commit Description...
- [[sources/frontend-frameworks/releases/angular-angular-cli-v22-0-0-rc-0|v22.0.0-rc.0]]: Webpack builders in build-angular are deprecated. Use @angular/build builders instead.; Webpack builders in build-webpack are deprecated. Use @angular/build builders instead.

## Astro

### Repository Ideas

- [[sources/frontend-frameworks/withastro-astro|withastro/astro]]: The web framework for content-driven websites. ⭐️ Star to support our work! !$1 Astro is a website build tool for the modern web &mdash; powerful developer experience meets lightweight output. $1](https://github.com/withastro/astro/actions/workflows/ci.yml) $1](https://github.com/withastro/astro/blob/main/LICENSE) $1](https://badge.fury.io/js/astro) Install The recommended way to install the latest version of Astro is by running the command below: You can also install Astro manually by running this command instead: Looking for help? Start with our $1 guide. Looking for quick examples? $1 right in your browser. Documentation Visit ou...
- [[sources/frontend-frameworks/withastro-docs|withastro/docs]]: Astro documentation Astro Docs To all who come to this happy place: welcome. This is the repo for $1. This repo contains all the source code we use to build our docs site. $1](https://codesandbox.io/p/github/withastro/docs) $1](https://pr.new/github.com/withastro/docs) We are Astro Astro is an all-in-one web framework for building fast, content-focused websites. We want everyone to be successful building sites, and that means helping everyone understand how Astro works. You are Awesome You can also help make the docs awesome. Your feedback is welcome. Your writing, editing, translating, designing, and developing skills are welcome....
- [[sources/frontend-frameworks/withastro-starlight|withastro/starlight]]: 🌟 Build beautiful, accessible, high-performance documentation websites with Astro packages/starlight/README.md

### Release Ideas

- [[sources/frontend-frameworks/releases/withastro-astro-astrojs-mdx-5-0-6|@astrojs/mdx@5.0.6]]: [#16579](https://github.com/withastro/astro/pull/16579) [`49e10e3`](https://github.com/withastro/astro/commit/49e10e3b97a49d805802b8972a2f848ea7847b91) Thanks [@igor-koop](https://github.com/igor-koop)! - Fixes an issue...
- [[sources/frontend-frameworks/releases/withastro-astro-astro-6-3-3|astro@6.3.3]]: [#16737](https://github.com/withastro/astro/pull/16737) [`bd84f33`](https://github.com/withastro/astro/commit/bd84f33d68cfa7d077e0a638970e28b0a9bd83db) Thanks [@matthewp](https://github.com/matthewp)! - Fixes a reflected...
- [[sources/frontend-frameworks/releases/withastro-astro-astro-6-3-2|astro@6.3.2]]: [#16675](https://github.com/withastro/astro/pull/16675) [`11d4592`](https://github.com/withastro/astro/commit/11d4592e9498e900b433ba94abed9cd615a9350b) Thanks [@ascorbic](https://github.com/ascorbic)! - Fixes a regressio...; [#16691](https://github.com/withastro/astro/pull/16691) [`0f0a4ce`](https://github.com/withastro/astro/commit/0f0a4ce1b28a6d6ec1658c7f59e0e68408935135) Thanks [@matthewp](https://github.com/matthewp)! - Fixes `HTMLElemen...
- [[sources/frontend-frameworks/releases/withastro-starlight-astrojs-starlight-0-39-2|@astrojs/starlight@0.39.2]]: [#3890](https://github.com/withastro/starlight/pull/3890) [`2d05e18`](https://github.com/withastro/starlight/commit/2d05e1802ac81f1db1220fc7a2c775e0c0bba9bc) Thanks [@tats-u](https://github.com/tats-u)! - Fixes CSS selec...
- [[sources/frontend-frameworks/releases/withastro-starlight-astrojs-starlight-0-39-1|@astrojs/starlight@0.39.1]]: [#3885](https://github.com/withastro/starlight/pull/3885) [`010eed1`](https://github.com/withastro/starlight/commit/010eed1d73d88481a116546caa800385f409ce28) Thanks [@ArmandPhilippot](https://github.com/ArmandPhilippot)!...; [#3887](https://github.com/withastro/starlight/pull/3887) [`b3c6990`](https://github.com/withastro/starlight/commit/b3c699042cf0a0f69f6637772275afb4418c6ebf) Thanks [@delucis](https://github.com/delucis)! - Adds 13 new i...

## Docusaurus

### Repository Ideas

- [[sources/frontend-frameworks/facebook-docusaurus|facebook/docusaurus]]: Easy to maintain open source documentation websites. Docusaurus Introduction Docusaurus is a project for building, deploying, and maintaining open source project websites easily. Short on time? Check out our $1! Tip : use $1 to test Docusaurus immediately in a playground. - Simple to Start Docusaurus is built in a way so that it can $1 in as little time as possible. We've built Docusaurus to handle the website build process so you can focus on your project. - Localizable Docusaurus ships with $1 via CrowdIn. Empower and grow your international community by translating your documentation. - Customizable While Docusaurus ships with th...

### Release Ideas

- [[sources/frontend-frameworks/releases/facebook-docusaurus-v3-10-1|v3.10.1]]: [#11981](https://github.com/facebook/docusaurus/pull/11981) fix(bundler): fix v3 webpackbar bug due to webpack breaking change ([@slorber](https://github.com/slorber))
- [[sources/frontend-frameworks/releases/facebook-docusaurus-v3-10-0|v3.10.0]]: [#11896](https://github.com/facebook/docusaurus/pull/11896) feat(core): add `future.v4.mdx1CompatDisabledByDefault` flag ([@slorber](https://github.com/slorber)); [#11797](https://github.com/facebook/docusaurus/pull/11797) feat(core): promote `siteConfig.storage` to stable + add `future.v4.siteStorageNamespacing` flag [Claude] ([@slorber](https://github.com/slorber))
- [[sources/frontend-frameworks/releases/facebook-docusaurus-v3-9-2|v3.9.2]]: `docusaurus-plugin-content-docs`; [#11490](https://github.com/facebook/docusaurus/pull/11490) fix(docs): add support for missing `sidebar_key` front matter attribute ([@slorber](https://github.com/slorber))

## Fumadocs

### Repository Ideas

- [[sources/frontend-frameworks/fuma-nama-fumadocs|fuma-nama/fumadocs]]: The beautiful & flexible React.js docs framework. !$1 The framework for building documentation websites in any React.js frameworks. Officially Supported: - Next.js - Vite: Tanstack Start, Waku, React Router 📘 Learn More: $1. Compatibility All packages are ESM only . Sticker !$1 Welcome to print it out :D Contributions Make sure to read the $1 before submitting a pull request.

### Release Ideas

- [[sources/frontend-frameworks/releases/fuma-nama-fumadocs-fumadocs-sanity-0-0-4|@fumadocs/sanity@0.0.4]]: 1fb6a61: Support custom base directory for content sources
- [[sources/frontend-frameworks/releases/fuma-nama-fumadocs-fumadocs-mdx-15-0-5|fumadocs-mdx@15.0.5]]: 1fb6a61: Support custom base directory for content sources
- [[sources/frontend-frameworks/releases/fuma-nama-fumadocs-fumadocs-local-md-0-2-2|@fumadocs/local-md@0.2.2]]: 1fb6a61: Support custom base directory for content sources

## Next.js

### Repository Ideas

- [[sources/frontend-frameworks/vercel-next-js|vercel/next.js]]: The React Framework packages/next/README.md

### Release Ideas

- [[sources/frontend-frameworks/releases/vercel-next-js-v16-3-0-canary-21|v16.3.0-canary.21]]: Redesign dev overlay: cleaner shell + instant fix-card guidance: #93755
- [[sources/frontend-frameworks/releases/vercel-next-js-v16-3-0-canary-20|v16.3.0-canary.20]]: [turbopack] fix feature usage telemetry: #93100; Extend instant error overlay to metadata, viewport, and sync IO errors: #93287
- [[sources/frontend-frameworks/releases/vercel-next-js-v16-3-0-canary-19|v16.3.0-canary.19]]: Misc Changes - Proof of concept: task eviction after snapshot for turbo-tasks-backend: 91790 Credits Huge thanks to @lukesandberg for helping!

## Nextra

### Repository Ideas

- [[sources/frontend-frameworks/shuding-nextra|shuding/nextra]]: Simple, powerful and flexible site generation framework with everything you love from Next.js. Nextra Simple, powerful and flexible site generation framework with everything you love from Next.js. Documentation https://nextra.site Development Installation The Nextra repository uses $1 and $1. 1. Run corepack enable to enable Corepack. If the command above fails, run npm install -g corepack@latest to install the latest version of $1. 2. Run pnpm install to install the project's dependencies. Build nextra Watch mode: pnpm --filter nextra dev Build nextra-theme-docs Development You can also debug them together with a website locally. F...

### Release Ideas

- [[sources/frontend-frameworks/releases/shuding-nextra-nextra-theme-docs-4-6-1|nextra-theme-docs@4.6.1]]: fix compatibility with Next.js 16; nextra@4.6.1
- [[sources/frontend-frameworks/releases/shuding-nextra-nextra-4-6-1|nextra@4.6.1]]: fix compatibility with Next.js 16
- [[sources/frontend-frameworks/releases/shuding-nextra-nextra-theme-blog-4-6-1|nextra-theme-blog@4.6.1]]: fix compatibility with Next.js 16; nextra@4.6.1

## Nitro

### Repository Ideas

- [[sources/frontend-frameworks/nitrojs-nitro|nitrojs/nitro]]: Next Generation Server Toolkit. Create web servers with everything you need and deploy them wherever you prefer. $1](https://deepwiki.com/nitrojs/nitro) Nitro [!NOTE] You’re viewing the v3 branch. For the current stable release, see $1. Nitro extends your Vite app with a production-ready server , designed to run anywhere . Add server routes, deploy across multiple platforms, and enjoy a zero-config experience. 📘 Docs: $1 Contributing See Check out the $1 to get started. License Released under the $1.

### Release Ideas

- [[sources/frontend-frameworks/releases/nitrojs-nitro-v3-0-260429-beta|v3.0.260429-beta]]: Improve jsdocs ([#4199](https://github.com/nitrojs/nitro/pull/4199)); Ofer Shapira (@ofershap)
- [[sources/frontend-frameworks/releases/nitrojs-nitro-v2-13-4|v2.13.4]]: Add version meta ([#4194](https://github.com/nitrojs/nitro/pull/4194))
- [[sources/frontend-frameworks/releases/nitrojs-nitro-v3-0-260415-beta|v3.0.260415-beta]]: **vercel:** Allow overriding function config per route ([#4124](https://github.com/nitrojs/nitro/pull/4124)); Add version meta to Nitro instance ([#4193](https://github.com/nitrojs/nitro/pull/4193))

## Nuxt

### Repository Ideas

- [[sources/frontend-frameworks/nuxt-content|nuxt/content]]: The file-based CMS for your Nuxt application, powered by Markdown and Vue components. $1](https://content.nuxt.com) Nuxt Content [![npm version][npm-version-src&#93;&#93;[npm-version-href] [![npm downloads][npm-downloads-src&#93;&#93;[npm-downloads-href] [![License][license-src&#93;&#93;[license-href] [![Nuxt][nuxt-src&#93;&#93;[nuxt-href] [![Volta][volta-src&#93;&#93;[volta-href] Nuxt Content reads the content/ directory in your project, parses .md , .yml , .csv or .json files and creates a powerful data layer for your application. Bonus, use Vue components in Markdown with the $1. - $1 - $1 - $1 Features - $1 support - Work in serverless and edge environments (Cloudflar...
- [[sources/frontend-frameworks/nuxt-image|nuxt/image]]: Plug-and-play image optimization for Nuxt applications. $1](https://image.nuxt.com) [![npm version][npm-version-src&#93;&#93;[npm-version-href] [![npm downloads][npm-downloads-src&#93;&#93;[npm-downloads-href] [![License][license-src&#93;&#93;[license-href] [![Nuxt][nuxt-src&#93;&#93;[nuxt-href] [![Volta][volta-src&#93;&#93;[volta-href] $1](https://nuxt.care/?search=image) Nuxt Image Plug-and-play image optimization for Nuxt apps. Resize and transform your images using built-in optimizer or your favorite images CDN. - $1 - $1 Features - drop-in replacement for the native element - drop-in replacement for the native element. - Built-in image resizer and transformer with $1...
- [[sources/frontend-frameworks/nuxt-nuxt|nuxt/nuxt]]: The Full-Stack Vue Framework. Nuxt Nuxt is a free and open-source framework with an intuitive and extendable way to create type-safe, performant and production-grade full-stack web applications and websites with Vue.js. It provides a number of features that make it easy to build fast, SEO-friendly, and scalable web applications, including: - Server-side rendering, static site generation, hybrid rendering and edge-side rendering - Automatic routing with code-splitting and pre-fetching - Data fetching and state management - Search engine optimization and defining meta tags - Auto imports of components, composables and utils - TypeScri...
- [[sources/frontend-frameworks/nuxt-ui|nuxt/ui]]: The Intuitive Vue UI Library powered by Reka UI & Tailwind CSS. Nuxt UI [![npm version][npm-version-src&#93;&#93;[npm-version-href] [![npm downloads][npm-downloads-src&#93;&#93;[npm-downloads-href] [![License][license-src&#93;&#93;[license-href] [![Nuxt][nuxt-src&#93;&#93;[nuxt-href] Nuxt UI harnesses the combined strengths of $1, $1, and $1 to offer developers an unparalleled set of tools for creating sophisticated, accessible, and highly performant user interfaces. [!NOTE] You are on the v4 branch, check out the $1 for Nuxt UI v3 or $1 for Nuxt UI v2. Documentation Visit https://ui.nuxt.com to explore the documentation. Templates Kickstart your project with one...

### Release Ideas

- [[sources/frontend-frameworks/releases/nuxt-nuxt-v4-4-5|v4.4.5]]: **kit:** Cache layer roots and short-circuit `isIgnored` relative ([#35015](https://github.com/nuxt/nuxt/pull/35015)); **vite:** Resolve vite `clientServer` with `ssr: false` ([#34959](https://github.com/nuxt/nuxt/pull/34959))
- [[sources/frontend-frameworks/releases/nuxt-nuxt-v3-21-5|v3.21.5]]: **kit:** Cache layer roots and short-circuit `isIgnored` relative ([#35015](https://github.com/nuxt/nuxt/pull/35015)); **nitro:** Correct payload route rule for `/` + override `ssr: true` ([#34990](https://github.com/nuxt/nuxt/pull/34990))
- [[sources/frontend-frameworks/releases/nuxt-nuxt-v4-4-3|v4.4.3]]: **nitro:** Directly import nuxt package version ([#34567](https://github.com/nuxt/nuxt/pull/34567)); **vite,webpack:** Use vfs for manifest + vite node server ([#34666](https://github.com/nuxt/nuxt/pull/34666))
- [[sources/frontend-frameworks/releases/nuxt-ui-v4-7-1|v4.7.1]]: **ChatMessage:** make actions slot accessible on touch devices ([f5a3349](https://github.com/nuxt/ui/commit/f5a33496926faa582bac10428ec560cb17757e4c)); **Drawer:** handle RTL mode ([#6396](https://github.com/nuxt/ui/issues/6396)) ([2e3fed2](https://github.com/nuxt/ui/commit/2e3fed2f002e5321621a923c2af425c0ab69fc81))
- [[sources/frontend-frameworks/releases/nuxt-ui-v4-7-0|v4.7.0]]: **AuthForm:** add `separator` slot ([#6305](https://github.com/nuxt/ui/issues/6305)) ([81c7ddb](https://github.com/nuxt/ui/commit/81c7ddb6d47dade3f7f2415a2a9714e949133344)); **Card:** add `title` and `description` props ([3cf7d75](https://github.com/nuxt/ui/commit/3cf7d7550918c6d29a6dcaffd10d50305f90c4cd)), closes [#6001](https://github.com/nuxt/ui/issues/6001)

## Quartz

### Repository Ideas

- [[sources/frontend-frameworks/jackyzha0-quartz|jackyzha0/quartz]]: 🌱 a fast, batteries-included static-site generator that transforms Markdown content into fully functional websites Quartz v4 “[One] who works with the door open gets all kinds of interruptions, but [they] also occasionally gets clues as to what the world is and what might be important.” — Richard Hamming Quartz is a set of tools that helps you publish your $1 and notes as a website for free. 🔗 Read the documentation and get started: https://quartz.jzhao.xyz/ $1 Sponsors

### Release Ideas

- [[sources/frontend-frameworks/releases/jackyzha0-quartz-v4-0-8|v4.0.8]]: [Comprehensive and type-safe configuration](https://quartz.jzhao.xyz/configuration); [Easily customizable layout](https://quartz.jzhao.xyz/layout)
- [[sources/frontend-frameworks/releases/jackyzha0-quartz-v3-3|v3.3]]: Semantic Search using Operand! A personally long-awaited personal feature, learn how to set it up [here](https://quartz.jzhao.xyz/notes/search) or [here](https://docs.operand.ai/guides/quartz); SPA Routing (https://github.com/jackyzha0/quartz/pull/118)
- [[sources/frontend-frameworks/releases/jackyzha0-quartz-v3-2|v3.2]]: Performance Improvements (fcd5d2807d2bab68c6776e031e85d65fe88a6f7a, https://github.com/jackyzha0/quartz/pull/62); Images no longer need to be root prefixed (54a68e6e5c020fa1e4eacf7942eb37974f332887)

## Qwik

### Repository Ideas

- [[sources/frontend-frameworks/qwikdev-qwik|QwikDev/qwik]]: Instant-loading web apps, without effort Instant-loading web apps, without effort Qwik offers the fastest possible page load times - regardless of the complexity of your website. Qwik is so fast because it allows fully interactive sites to load with almost no JavaScript and $1. As users interact with the site, only the necessary parts of the site load on-demand. This $1 is what makes Qwik so quick. Getting Started - Understand the difference between $1 applications. - Learn about Qwik's high level $1. Resources - $1 - $1 - $1 - $1 - $1 - $1 - $1 Community - Ping us at $1 - Join our $1 community - Join all the $1 Development - See $1...

### Release Ideas

- [[sources/frontend-frameworks/releases/qwikdev-qwik-qwik-dev-react-2-0-0-beta-35|@qwik.dev/react@2.0.0-beta.35]]: Updated dependencies \&#91;&#91;`8fdf639`](https://github.com/QwikDev/qwik/commit/8fdf6393312a10407db8d9a0b0199d77e2a208c7), [`8dbdc12`](https://github.com/QwikDev/qwik/commit/8dbdc1253d7ab4fe9bcef520d79b1c85aac3b372), [`b6f7556...; @qwik.dev/core@2.0.0-beta.35
- [[sources/frontend-frameworks/releases/qwikdev-qwik-qwik-dev-router-2-0-0-beta-35|@qwik.dev/router@2.0.0-beta.35]]: ✨ add worker$ support running heavy work in Web Workers (by [@Varixo](https://github.com/Varixo) in [#8572](https://github.com/QwikDev/qwik/pull/8572)); fix(router): Node SSR no longer hangs when using `compression` (or other middleware that wraps `res.write` / `res.end`). (by [@maiieul](https://github.com/maiieul) in [#8620](https://github.com/QwikDev/qwik/pull/8620))
- [[sources/frontend-frameworks/releases/qwikdev-qwik-qwik-dev-optimizer-2-1-0-beta-4|@qwik.dev/optimizer@2.1.0-beta.4]]: ✨ add worker$ support running heavy work in Web Workers (by [@Varixo](https://github.com/Varixo) in [#8572](https://github.com/QwikDev/qwik/pull/8572))

## React

### Repository Ideas

- [[sources/frontend-frameworks/facebook-react|facebook/react]]: The library for web and native user interfaces. $1 &middot; $1](https://github.com/facebook/react/blob/main/LICENSE) $1](https://www.npmjs.com/package/react) $1](https://github.com/facebook/react/actions/workflows/runtime build and test.yml) $1](https://github.com/facebook/react/actions/workflows/compiler typescript.yml) $1](https://legacy.reactjs.org/docs/how-to-contribute.html your-first-pull-request) React is a JavaScript library for building user interfaces. Declarative: React makes it painless to create interactive UIs. Design simple views for each state in your application, and React will efficiently update and render just the...
- [[sources/frontend-frameworks/reactjs-react-dev|reactjs/react.dev]]: The React documentation website react.dev This repo contains the source code and documentation powering $1. Getting started Prerequisites 1. Git 1. Node: any version starting with v16.8.0 or greater 1. Yarn: See $1 1. A fork of the repo (for any contributions) 1. A clone of the $1 on your local machine Installation 1. cd react.dev to go into the project root 3. yarn to install the website's npm dependencies Running locally 1. yarn dev to start the development server (powered by $1) 1. open http://localhost:3000 to open the site in your favorite browser Contributing Guidelines The documentation is divided into several sections with a...

### Release Ideas

- [[sources/frontend-frameworks/releases/facebook-react-v19-2-6|v19.2.6]]: Type hardening and performance improvements
- [[sources/frontend-frameworks/releases/facebook-react-v19-1-7|v19.1.7]]: Type hardening and performance improvements
- [[sources/frontend-frameworks/releases/facebook-react-v19-0-6|v19.0.6]]: Type hardening and performance improvements

## Remix / React Router

### Repository Ideas

- [[sources/frontend-frameworks/remix-run-react-router|remix-run/react-router]]: Declarative routing for React [![npm package][npm-badge&#93;&#93;[npm] [![build][build-badge&#93;&#93;[build] [npm-badge]: https://img.shields.io/npm/v/react-router-dom.svg [npm]: https://www.npmjs.org/package/react-router-dom [build-badge]: https://img.shields.io/github/actions/workflow/status/remix-run/react-router/test.yml?branch=dev&style=square [build]: https://github.com/remix-run/react-router/actions/workflows/test.yml React Router is a multi-strategy router for React bridging the gap from React 18 to React 19. You can use it maximally as a React framework or minimally as a library with your own architecture. - $1 - $1 - $1 - $1 - $1 Package...
- [[sources/frontend-frameworks/remix-run-remix|remix-run/remix]]: Build Better Websites. Create modern, resilient user experiences with web fundamentals. Welcome to Remix 3! This is the source repository for Remix 3. It is under active development. We published $1 earlier this year with some of our thoughts around Remix 3. It explains our philosophy for web development and why we think the time is right for something new. When working on Remix 3, we follow these principles: 1. Model-First Development . AI fundamentally shifts the human-computer interaction model for both user experience and developer workflows. Optimize the source code, documentation, tooling, and abstractions for LLMs. Additional...

### Release Ideas

- [[sources/frontend-frameworks/releases/remix-run-react-router-react-router-7-15-1|react-router@7.15.1]]: See the changelog for release notes: https://github.com/remix-run/react-router/blob/main/CHANGELOG.md v7151
- [[sources/frontend-frameworks/releases/remix-run-react-router-react-router-7-15-0|react-router@7.15.0]]: See the changelog for release notes: https://github.com/remix-run/react-router/blob/main/CHANGELOG.md v7150
- [[sources/frontend-frameworks/releases/remix-run-remix-static-middleware-0-4-8|static-middleware@0.4.8]]: [`fetch-router@0.18.2`](https://github.com/remix-run/remix/releases/tag/fetch-router@0.18.2)
- [[sources/frontend-frameworks/releases/remix-run-remix-ui-0-1-1|ui@0.1.1]]: Improved runtime rendering performance by reducing child normalization, keyed reconciliation, mixin lifecycle, scheduler phase, and host insertion overhead.; Stripped `<!DOCTYPE>` markup from server and client frame responses before rendering frame content.
- [[sources/frontend-frameworks/releases/remix-run-remix-test-0-3-0|test@0.3.0]]: Add `FakeTimers#advanceAsync(ms)` to `t.useFakeTimers()`. Like `advance`, it walks pending timers in time order and fires them, but yields to microtasks between each firing so promise continuations (and any timers they s...; Accept arrays for `glob.{test,browser,e2e,exclude}`, `project`, `type`, and `coverage.{include,exclude}` config fields

## Solid

### Repository Ideas

- [[sources/frontend-frameworks/solidjs-solid|solidjs/solid]]: A declarative, efficient, and flexible JavaScript library for building user interfaces. $1](https://github.com/solidjs/solid/actions/workflows/main-ci.yml) $1](https://coveralls.io/github/solidjs/solid?branch=main) $1](https://www.npmjs.com/package/solid-js) $1](https://www.npmjs.com/package/solid-js) $1](https://discord.com/invite/solidjs) $1](https://www.reddit.com/r/solidjs/) $1 • $1 • $1 • $1 • $1 Solid is a declarative JavaScript library for creating user interfaces. Instead of using a Virtual DOM, it compiles its templates to real DOM nodes and updates them with fine-grained reactions. Declare your state and use it throughout...
- [[sources/frontend-frameworks/solidjs-solid-docs|solidjs/solid-docs]]: Official documentation for the Solid ecosystem Welcome to Solid's documentation! This is the repo for $1. This repo contains all the source code that we use to build our docs. $1](https://gitpod.io/ https://github.com/solidjs/solid-docs-next) $1](https://codesandbox.io/p/github/solidjs/solid-docs-next/) $1](https://stackblitz.com/github/solidjs/solid-docs-next) What is Solid? Solid is a JavaScript framework used for building high-performance user-interfaces. Using a reactive approach and component-based architecture, we want to empower developers in creating efficient and scalable web applications. Thank you for being here! You can...
- [[sources/frontend-frameworks/solidjs-solid-start|solidjs/solid-start]]: SolidStart, the Solid app framework $1](https://github.com/solidjs) $1](https://npmjs.com/package/@solidjs/start) $1](https://npmjs.com/package/@solidjs/start) $1](https://github.com/solidjs/solid-start) $1](https://discord.com/invite/solidjs) $1](https://reddit.com/r/solidjs) - For building apps with SolidStart, check the $1 and our $1 - For contributing to codebase, check $1 - For creating a new template, please head over to $1 [!IMPORTANT] This is the branch for the SolidStart 2.0.0-alpha that is currently under heavy development. Current SolidStart is maintained at $1. Prerequisites - Node.js : Use the version specified in .nvmr...

### Release Ideas

- [[sources/frontend-frameworks/releases/solidjs-solid-v2-0-0-beta-0|v2.0.0-beta.0]]: **Dev guardrails**: dev warnings catch accidental “top-level reads” in components and writes in reactive scopes before they become async bugs.; **Beta tester guide**: [`documentation/solid-2.0/MIGRATION.md`](https://github.com/solidjs/solid/blob/next/documentation/solid-2.0/MIGRATION.md)
- [[sources/frontend-frameworks/releases/solidjs-solid-start-solidjs-start-1-3-0|@solidjs/start@1.3.0]]: 7144da5: fix: use percent encoding for `x-server-id` header value instead of reserved `#` character
- [[sources/frontend-frameworks/releases/solidjs-solid-start-solidjs-start-1-3-2|@solidjs/start@1.3.2]]: e534ea8: Fix a regression introduced in SolidStart v1.3.0 that could cause an infinite loop when a server function returns unexpected response (for example, S3/XML error responses).
- [[sources/frontend-frameworks/releases/solidjs-solid-start-solidjs-start-1-3-1|@solidjs/start@1.3.1]]: 5249fdd: fix client-side serialization typo
- [[sources/frontend-frameworks/releases/solidjs-solid-v1-9-0|v1.9.0]]: This release like the last is focusing on small quality of life improvements and adjustments that will help us move towards 2.0. So while not the most exciting release to everyone it provides some really important featur...

## Starlight

### Repository Ideas

- [[sources/frontend-frameworks/withastro-starlight|withastro/starlight]]: 🌟 Build beautiful, accessible, high-performance documentation websites with Astro packages/starlight/README.md

### Release Ideas

- [[sources/frontend-frameworks/releases/withastro-starlight-astrojs-starlight-0-39-2|@astrojs/starlight@0.39.2]]: [#3890](https://github.com/withastro/starlight/pull/3890) [`2d05e18`](https://github.com/withastro/starlight/commit/2d05e1802ac81f1db1220fc7a2c775e0c0bba9bc) Thanks [@tats-u](https://github.com/tats-u)! - Fixes CSS selec...
- [[sources/frontend-frameworks/releases/withastro-starlight-astrojs-starlight-0-39-1|@astrojs/starlight@0.39.1]]: [#3885](https://github.com/withastro/starlight/pull/3885) [`010eed1`](https://github.com/withastro/starlight/commit/010eed1d73d88481a116546caa800385f409ce28) Thanks [@ArmandPhilippot](https://github.com/ArmandPhilippot)!...; [#3887](https://github.com/withastro/starlight/pull/3887) [`b3c6990`](https://github.com/withastro/starlight/commit/b3c699042cf0a0f69f6637772275afb4418c6ebf) Thanks [@delucis](https://github.com/delucis)! - Adds 13 new i...
- [[sources/frontend-frameworks/releases/withastro-starlight-astrojs-starlight-0-39-0|@astrojs/starlight@0.39.0]]: [#3618](https://github.com/withastro/starlight/pull/3618) [`dcf6d09`](https://github.com/withastro/starlight/commit/dcf6d094bbcfa1f83e45742901f4178df07c2156) Thanks [@HiDeoo](https://github.com/HiDeoo)! - **⚠️ BREAKING C...; [#3618](https://github.com/withastro/starlight/pull/3618) [`dcf6d09`](https://github.com/withastro/starlight/commit/dcf6d094bbcfa1f83e45742901f4178df07c2156) Thanks [@HiDeoo](https://github.com/HiDeoo)! - **⚠️ BREAKING C...

## Svelte

### Repository Ideas

- [[sources/frontend-frameworks/sveltejs-kit|sveltejs/kit]]: web development, streamlined $1](https://svelte.dev/chat) SvelteKit Web development, streamlined. Read the $1 to get started. Packages Package Changelog --------------------------------------------------------------------------- ------------------------------------------------------------- $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 are maintained by the community. Bug reporting Please make sure the issue you're reporting involves SvelteKit. Many issues related to how a project builds originate from $1, which is used to build a SvelteKit project. You can create a new Vite project with npm create vite@latest for cl...
- [[sources/frontend-frameworks/sveltejs-svelte|sveltejs/svelte]]: web development for the rest of us $1](LICENSE.md) $1](https://svelte.dev/chat) What is Svelte? Svelte is a new way to build web applications. It's a compiler that takes your declarative components and converts them into efficient JavaScript that surgically updates the DOM. Learn more at the $1, or stop by the $1. Supporting Svelte Svelte is an MIT-licensed open source project with its ongoing development made possible entirely by fantastic volunteers. If you'd like to support their efforts, please consider: - $1. Funds donated via Open Collective will be used for compensating expenses related to Svelte's development such as hosting...
- [[sources/frontend-frameworks/sveltejs-svelte-dev|sveltejs/svelte.dev]]: The Svelte omnisite svelte.dev This is the repository behind $1, the official Svelte site, and the related packages that it relies on. Documentation PRs If you're creating a documentation PR, make sure you're targeting the right repository. More specifically, changes to content within apps/svelte.dev/content/docs are synced from other repositories, and documentation changes within those folder should therefore be made in those repositories: - docs/svelte - https://github.com/sveltejs/svelte - docs/kit - https://github.com/sveltejs/kit - docs/cli - https://github.com/sveltejs/cli - docs/ai - https://github.com/sveltejs/ai-tools The t...

### Release Ideas

- [[sources/frontend-frameworks/releases/sveltejs-kit-sveltejs-kit-2-60-1|@sveltejs/kit@2.60.1]]: chore: bump `svelte` and `devalue` ([#15836](https://github.com/sveltejs/kit/pull/15836)); fix: prevent `query.batch` cross-talk ([`dadaefc`](https://github.com/sveltejs/kit/commit/dadaefc2e647a0a62f49f3ee8bc7aa46f5e27056))
- [[sources/frontend-frameworks/releases/sveltejs-svelte-svelte-5-55-7|svelte@5.55.7]]: fix: prevent XSS on `hydratable` from user contents ([`a16ebc67bbcf8f708360195687e1b2719463e1a4`](https://github.com/sveltejs/svelte/commit/a16ebc67bbcf8f708360195687e1b2719463e1a4)); chore: bump devalue ([#18219](https://github.com/sveltejs/svelte/pull/18219))
- [[sources/frontend-frameworks/releases/sveltejs-kit-sveltejs-kit-2-60-0|@sveltejs/kit@2.60.0]]: feat: allow 'submit' and 'hidden' form fields to accept numbers and booleans ([#15802](https://github.com/sveltejs/kit/pull/15802)); feat: warn on unread `form` remote function validation issues ([#15653](https://github.com/sveltejs/kit/pull/15653))
- [[sources/frontend-frameworks/releases/sveltejs-svelte-svelte-5-55-6|svelte@5.55.6]]: fix: leave stale promises to wait for a later resolution, instead of rejecting ([#18180](https://github.com/sveltejs/svelte/pull/18180)); fix: keep dependencies of `$state.eager/pending` ([#18218](https://github.com/sveltejs/svelte/pull/18218))
- [[sources/frontend-frameworks/releases/sveltejs-kit-sveltejs-kit-2-59-1|@sveltejs/kit@2.59.1]]: fix: resolve paths to route files with the letter drive on Windows ([#15793](https://github.com/sveltejs/kit/pull/15793))

## SvelteKit

### Repository Ideas

- [[sources/frontend-frameworks/sveltejs-kit|sveltejs/kit]]: web development, streamlined $1](https://svelte.dev/chat) SvelteKit Web development, streamlined. Read the $1 to get started. Packages Package Changelog --------------------------------------------------------------------------- ------------------------------------------------------------- $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 $1 are maintained by the community. Bug reporting Please make sure the issue you're reporting involves SvelteKit. Many issues related to how a project builds originate from $1, which is used to build a SvelteKit project. You can create a new Vite project with npm create vite@latest for cl...

### Release Ideas

- [[sources/frontend-frameworks/releases/sveltejs-kit-sveltejs-kit-2-60-1|@sveltejs/kit@2.60.1]]: chore: bump `svelte` and `devalue` ([#15836](https://github.com/sveltejs/kit/pull/15836)); fix: prevent `query.batch` cross-talk ([`dadaefc`](https://github.com/sveltejs/kit/commit/dadaefc2e647a0a62f49f3ee8bc7aa46f5e27056))
- [[sources/frontend-frameworks/releases/sveltejs-kit-sveltejs-kit-2-60-0|@sveltejs/kit@2.60.0]]: feat: allow 'submit' and 'hidden' form fields to accept numbers and booleans ([#15802](https://github.com/sveltejs/kit/pull/15802)); feat: warn on unread `form` remote function validation issues ([#15653](https://github.com/sveltejs/kit/pull/15653))
- [[sources/frontend-frameworks/releases/sveltejs-kit-sveltejs-kit-2-59-1|@sveltejs/kit@2.59.1]]: fix: resolve paths to route files with the letter drive on Windows ([#15793](https://github.com/sveltejs/kit/pull/15793))

## TanStack Start

### Repository Ideas

- [[sources/frontend-frameworks/tanstack-router|TanStack/router]]: 🤖 A client-first, server-capable, fully type-safe router and full-stack framework for the web (React and more). TanStack Router A modern router designed for type safety, data‑driven navigation, and seamless developer experience. - End‑to-end type safety (routes, params, loaders) - Schema‑driven search params with validation - Built‑in caching, prefetching & invalidation - Nested layouts, transitions & error boundaries $1 TanStack Start A full‑stack framework built on Router, designed for server rendering, streaming, and production‑ready deployments. - Full‑document SSR & streaming - Server functions & end‑to‑end type safety - Deplo...

### Release Ideas

- [[sources/frontend-frameworks/releases/tanstack-router-release-2026-05-16-0506|release-2026-05-16-0506]]: start: add inline CSS runtime controls and asset URL templates (#7380) (2387a2eea0) by @schiller-manuel; Fix literal underscore paths under pathless layouts (#7408) (742941e2f1) by @schiller-manuel
- [[sources/frontend-frameworks/releases/tanstack-router-tanstack-vue-start-1-168-2|@tanstack/vue-start@1.168.2]]: @tanstack/start-plugin-core@1.170.2
- [[sources/frontend-frameworks/releases/tanstack-router-tanstack-start-plugin-core-1-170-2|@tanstack/start-plugin-core@1.170.2]]: Updated dependencies \&#91;&#91;`742941e`](https://github.com/TanStack/router/commit/742941e2f1bf069c950d0a4985b2cd733639509e)]:; @tanstack/router-generator@1.167.2

## Vite

### Repository Ideas

- [[sources/frontend-frameworks/vitejs-vite|vitejs/vite]]: Next generation frontend tooling. It's fast! Vite ⚡ Next Generation Frontend Tooling - 💡 Instant Server Start - ⚡️ Lightning Fast HMR - 🛠️ Rich Features - 📦 Optimized Build - 🔩 Universal Plugin Interface - 🔑 Fully Typed APIs Vite (French word for "quick", pronounced $1, like "veet") is a build tool that aims to provide a faster and leaner development experience for modern web projects. It consists of two major parts: - A dev server that provides $1 over $1, for example extremely fast $1. - A build command that bundles your code with $1, pre-configured to output highly optimized static assets for production. In addition, Vite is...
- [[sources/frontend-frameworks/vitejs-vite-plugin-react|vitejs/vite-plugin-react]]: The all-in-one Vite plugin for React projects. Vite Plugin React See $1 and $1 Vite Plugin RSC See $1 Packages Package Version (click for changelogs) ----------------------------------------------------- :----------------------------------------------------------------------------------------------------------------------------------------- $1 $1](packages/plugin-react/CHANGELOG.md) $1 $1](packages/plugin-react-swc/CHANGELOG.md) $1 $1](packages/plugin-rsc/CHANGELOG.md) License $1.

### Release Ideas

- [[sources/frontend-frameworks/releases/vitejs-vite-plugin-react-plugin-react-swc-4-3-1|plugin-react-swc@4.3.1]]: Avoid esbuild warnings with Vite 8 $1 Fixes $1.
- [[sources/frontend-frameworks/releases/vitejs-vite-plugin-react-plugin-react-6-0-2|plugin-react@6.0.2]]: Allow all options in reactCompilerPreset ($1) This is a type only change. Only compilationMode and target options were available for reactCompilerPreset .
- [[sources/frontend-frameworks/releases/vitejs-vite-plugin-legacy-8-0-2|plugin-legacy@8.0.2]]: Please refer to $1 for details.
- [[sources/frontend-frameworks/releases/vitejs-vite-v8-0-13|v8.0.13]]: Please refer to $1 for details.
- [[sources/frontend-frameworks/releases/vitejs-vite-v8-0-12|v8.0.12]]: Please refer to $1 for details.

## VitePress

### Repository Ideas

- [[sources/frontend-frameworks/vuejs-vitepress|vuejs/vitepress]]: Vite & Vue powered static site generator. VitePress 📝💨 $1](https://github.com/vuejs/vitepress/actions/workflows/test.yml) $1](https://www.npmjs.com/package/vitepress/v/next) $1](https://nightly.akryum.dev/vuejs/vitepress) $1](https://chat.vuejs.org) --- VitePress is a Vue-powered static site generator and a spiritual successor to $1, built on top of $1. Documentation To check out docs, visit $1. Changelog Detailed changes for each release are documented in the $1. Contribution Please make sure to read the $1 before making a pull request. License $1 Copyright (c) 2019-present, Yuxi (Evan) You Special Thanks This project would not b...

### Release Ideas

- [[sources/frontend-frameworks/releases/vuejs-vitepress-v2-0-0-alpha-17|v2.0.0-alpha.17]]: Please refer to $1 for details.
- [[sources/frontend-frameworks/releases/vuejs-vitepress-v2-0-0-alpha-16|v2.0.0-alpha.16]]: Please refer to $1 for details.
- [[sources/frontend-frameworks/releases/vuejs-vitepress-v2-0-0-alpha-15|v2.0.0-alpha.15]]: Fixes a theme regression in v2-alpha.14. Please refer to $1 for details.

## Vue

### Repository Ideas

- [[sources/frontend-frameworks/vuejs-core|vuejs/core]]: 🖖 Vue.js is a progressive, incrementally-adoptable JavaScript framework for building UI on the web. vuejs/core $1](https://www.npmjs.com/package/vue) $1](https://github.com/vuejs/core/actions/workflows/ci.yml) $1](https://www.npmjs.com/package/vue) Getting Started Please follow the documentation at $1! Sponsors Vue.js is an MIT-licensed open source project with its ongoing development made possible entirely by the support of these awesome $1. If you'd like to join them, please consider $1. Special Sponsor Questions For questions and support please use $1 or $1. The issue list of this repo is exclusively for bug reports and feature...
- [[sources/frontend-frameworks/vuejs-devtools|vuejs/devtools]]: ⚙️ Browser devtools extension for debugging Vue.js applications. Vue DevTools Unleash Vue Developer Experience Note: this repository is for Vue Devtools v7 (previously known as Vue Devtools Next). The now legacy v6 version has been moved to $1. Getting Started - $1 - $1 - $1 - $1 For more details, check out the documentation at $1. Sponsors Contribution Please make sure to read the $1 before making a pull request. Thank you to all the people who already contributed to Vue DevTools! -- License $1
- [[sources/frontend-frameworks/vuejs-docs|vuejs/docs]]: 📄 Documentation for Vue 3 vuejs.org Contributing This site is built with $1 and depends on $1. Site content is written in Markdown format located in src . For simple edits, you can directly edit the file on GitHub and generate a Pull Request. For local development, $1 is preferred as package manager: This project requires Node.js to be v20 or higher. And it is recommended to enable corepack: Working on the content - See VitePress docs on supported $1 and the ability to $1. - See the $1 for our rules and recommendations on writing and maintaining documentation content. Working on the theme If changes need to be made for the theme, c...
- [[sources/frontend-frameworks/vuejs-pinia|vuejs/pinia]]: 🍍 Intuitive, type safe, light and flexible Store for Vue using the composition api with DevTools support Pinia Intuitive, type safe and flexible Store for Vue - 💡 Intuitive - 🔑 Type Safe - ⚙️ Devtools support - 🔌 Extensible - 🏗 Modular by design - 📦 Extremely light - ⛰️ Nuxt Module The latest version of pinia works with Vue 3. See the branch $1 for a version that works with Vue 2. Pinia is the most similar English pronunciation of the word pineapple in Spanish: piña . A pineapple is in reality a group of individual flowers that join together to create a multiple fruit. Similar to stores, each one is born individually, but they...
- [[sources/frontend-frameworks/vuejs-router|vuejs/router]]: 🚦 The official router for Vue.js vue-router $1](https://npmx.dev/package/vue-router) $1](https://github.com/vuejs/router/actions/workflows/test.yml) $1](https://codecov.io/gh/vuejs/router) - This is the repository for Vue Router 4 (for Vue 3) - For Vue Router 3 (for Vue 2) see $1. To see what versions are currently supported, please refer to the $1. Supporting Vue Router Vue Router is part of the Vue Ecosystem and is an MIT-licensed open source project with its ongoing development made possible entirely by the support of Sponsors. If you would like to become a sponsor, please consider: - $1 - $1 Gold Sponsors Silver Sponsors Bronze...

### Release Ideas

- [[sources/frontend-frameworks/releases/vuejs-core-v3-6-0-beta-12|v3.6.0-beta.12]]: For stable releases, please refer to $1 for details. For pre-releases, please refer to $1 of the minor branch.
- [[sources/frontend-frameworks/releases/vuejs-router-v5-0-7|v5.0.7]]: Upgrade to babel 8 &nbsp;-&nbsp; by @posva [<samp>(8d3e6)</samp>](https://github.com/vuejs/router/commit/8d3e60e7); Make `defineParamParser()` more intuitive &nbsp;-&nbsp; by @posva [<samp>(8715b)</samp>](https://github.com/vuejs/router/commit/8715b211)
- [[sources/frontend-frameworks/releases/vuejs-devtools-v8-1-2|v8.1.2]]: Bump `vite-plugin-vue-inspector` to support vapor app &nbsp;-&nbsp; by @webfansplz in https://github.com/vuejs/devtools/issues/1096 [<samp>(784c3)</samp>](https://github.com/vuejs/devtools/commit/784c3245); **devtools-kit**: Remove special handling for Router object &nbsp;-&nbsp; by @skirtles-code in https://github.com/vuejs/devtools/issues/1092 [<samp>(c2dde)</samp>](https://github.com/vuejs/devtools/commit/c2dde29f)
- [[sources/frontend-frameworks/releases/vuejs-core-v3-6-0-beta-11|v3.6.0-beta.11]]: For stable releases, please refer to $1 for details. For pre-releases, please refer to $1 of the minor branch.
- [[sources/frontend-frameworks/releases/vuejs-core-v3-5-34|v3.5.34]]: For stable releases, please refer to $1 for details. For pre-releases, please refer to $1 of the minor branch.

## Related

- [[frontend-frameworks-public]]
- [[frontend-project-shell-taxonomy]]

## Counterpoints And Gaps

- AMBIGUOUS: Release idea bullets are extracted summaries from GitHub release bodies and may omit lower-signal fixes or package-specific context.
- INFERRED: Repository summaries come from README/changelog snippets and metadata; use canonical GitHub links for full current project intent before migrating patterns.
