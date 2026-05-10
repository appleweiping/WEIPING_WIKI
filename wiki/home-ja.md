---
title: Vipin Wiki 日本語
type: overview
status: active
created: 2026-05-10
updated: 2026-05-10
tags:
  - wiki
  - overview
  - ja
cssclasses:
  - dashboard
---

# Vipin Wiki

これは、素早い回答、ゆっくりした知識の蓄積、研究アイデア出し、プロジェクト記憶のための知識ダッシュボードです。

**Language:** [English](../) · [中文](../zh/) · 日本語

> [!tip] ここから始める
> `Ctrl+K` または `/` で公開 wiki 全体を検索できます。右側の graph と backlinks を使うと、単なる目次よりも関連ページをたどりやすくなります。

## コマンドセンター

| レーン | 目的 | 入口 |
| --- | --- | --- |
| 速い回答 | 広い ingest の前に、維持されたページから先に答える。 | [[index|Catalog]], [[queries-home]], [[local-project-roots]] |
| 研究 | プロジェクトを再定義し、証拠境界を確認し、より強いメカニズムを探す。 | [[research-projects]], [[research-ideation-policy]], [[2026-05-10-vipin-research-project-map]] |
| プロジェクト案内 | フォルダを wiki にコピーせず、内容の性質でローカルプロジェクトを探す。 | [[local-project-roots]], [[weipingyan-portfolio]], [[undergraduate-projects-netherlands]] |
| 永続化 | 再利用できる知識を wiki に保存する。 | [[overview]], [[log]], [[synthesis-home]] |

## アクティブな研究マップ

- [[uncertainty]] - LLM ベース推薦のための task-grounded calibrated uncertainty。
- [[truce-rec]] - 厳密な証拠ゲートを持つ不確実性感知型生成推薦。
- [[tgl-rec]] - 次のニーズ遷移に注目する temporal graph-to-language recommendation。
- [[analog-agent]] - AI4EDA のための階層型アナログ回路設計 agent。
- [[donebench]] - tool-using agent の specification grounding benchmark。
- [[uncertaintyprotein-ai4s]] - feedback shift 下の AI4S タンパク質最適化。
- [[protein-optimization-feedback-shift]] - 閉ループタンパク質配列最適化における不確実性の概念ページ。

## ショートカット

| やりたいこと | 開く |
| --- | --- |
| すべての公開ページを見る | [[index|Catalog]] |
| 保存された Q&A を読む | [[queries-home]] |
| トピック群を眺める | [[topics-home]] |
| トレードオフを比較する | [[comparisons-home]] |
| 長期的な synthesis を読む | [[synthesis-home]] |
| 最近のメンテナンスを見る | [[log]] |
| リポジトリ構造を理解する | [[overview]] |

## 最近保存された回答

- [[2026-05-08-which-umn-meal-plan-to-choose]]
- [[2026-05-08-how-to-choose-umn-apartment-vs-residence-hall-for-private-bedroom]]
- [[2026-05-08-how-to-integrate-venus-basestation-with-team-gitlab]]
- [[2026-05-05-how-to-solve-oauth-rt-rbac-security-quiz]]
- [[2026-05-05-how-to-understand-quantization-and-bit-rate]]

## 現在の問い

- 不確実性は、校正指標だけでなく意思決定をどう改善すべきか？
- どの研究プロジェクトは小さな改善ではなく、大きく再設計すべきか？
- どのトップ会議のプロジェクト、OSS、benchmark から経験を吸収すべきか？
- 繰り返し出る授業・プロジェクトの質問は、どれを安定した topic ページにすべきか？
- どの公開ページは有用だが古く、どの低価値ページは削除候補として提案すべきか？

## 運用ルール

- まず速く答え、その後に永続化する。
- 公開 `wiki/` がウェブサイトの source。private/raw 層は公開ビルドに入れない。
- 外部ローカルプロジェクトについて現在状態を述べる前に、必ず再スキャンする。
- 抽象的または general な研究・プロジェクト相談では、主流 GitHub プロジェクト、トップ会議の paper/project、benchmark から広く学び、コピーではなく独自に統合する。
- 情報を削除する前には必ずユーザーの明示的な承認を得る。有用な古い情報は、注釈・アーカイブ・統合で残す。

## このサイトの仕組み

公開サイトは、維持された Markdown wiki から Quartz で構築されます。wikilinks、検索、backlinks、tags、graph navigation を保ちながら、非公開の原素材は公開成果物から除外します。
