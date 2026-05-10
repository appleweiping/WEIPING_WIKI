import { QuartzConfig } from "./quartz/cfg"
import * as Plugin from "./quartz/plugins"

const config: QuartzConfig = {
  configuration: {
    pageTitle: "vipin wiki",
    pageTitleSuffix: "",
    enableSPA: true,
    enablePopovers: true,
    analytics: null,
    locale: "en-US",
    baseUrl: "appleweiping.github.io/vipin-wiki",
    ignorePatterns: [
      "**/_templates/**",
      "**/*.json",
      "**/*.html",
      "**/*.js",
      "**/*.css",
      "**/*.pdf",
      "**/*.{png,jpg,jpeg,gif,webp,svg,mp3,mp4,mov,wav,m4a}",
      "LICENSE-*",
      "knowledge-graph",
    ],
    defaultDateType: "modified",
    theme: {
      fontOrigin: "googleFonts",
      cdnCaching: true,
      typography: {
        header: "Schibsted Grotesk",
        body: "Source Sans Pro",
        code: "IBM Plex Mono",
      },
      colors: {
        lightMode: {
          light: "#fbfaf7",
          lightgray: "#e7e2db",
          gray: "#b9b0a5",
          darkgray: "#4d5250",
          dark: "#1f2524",
          secondary: "#2f5d62",
          tertiary: "#8f6f3f",
          highlight: "rgba(47, 93, 98, 0.13)",
          textHighlight: "#f5d76e66",
        },
        darkMode: {
          light: "#171918",
          lightgray: "#353937",
          gray: "#6f7471",
          darkgray: "#d6d2ca",
          dark: "#f1eee8",
          secondary: "#8db8bd",
          tertiary: "#d2aa67",
          highlight: "rgba(141, 184, 189, 0.14)",
          textHighlight: "#b38b2c88",
        },
      },
    },
  },
  plugins: {
    transformers: [
      Plugin.FrontMatter(),
      Plugin.CreatedModifiedDate({
        priority: ["frontmatter", "git", "filesystem"],
      }),
      Plugin.SyntaxHighlighting({
        theme: {
          light: "github-light",
          dark: "github-dark",
        },
        keepBackground: false,
      }),
      Plugin.ObsidianFlavoredMarkdown({ enableInHtmlEmbed: false }),
      Plugin.GitHubFlavoredMarkdown(),
      Plugin.TableOfContents(),
      Plugin.CrawlLinks({ markdownLinkResolution: "shortest" }),
      Plugin.Description(),
      Plugin.Latex({ renderEngine: "katex" }),
    ],
    filters: [Plugin.RemoveDrafts()],
    emitters: [
      Plugin.AliasRedirects(),
      Plugin.ComponentResources(),
      Plugin.ContentPage(),
      Plugin.FolderPage(),
      Plugin.TagPage(),
      Plugin.ContentIndex({
        enableSiteMap: true,
        enableRSS: true,
      }),
      Plugin.Assets(),
      Plugin.Static(),
      Plugin.Favicon(),
      Plugin.NotFoundPage(),
    ],
  },
}

export default config
