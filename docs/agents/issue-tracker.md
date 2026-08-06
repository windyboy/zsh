# Issue tracker: Linear

Issues 和 PRDs 在本仓库通过 Linear 跟踪，所有操作经由当前运行时已配置的 Linear MCP 完成。

## Conventions

- **创建**: `linear_save_issue`（必填 `title` + `team`），描述用真实换行的 Markdown。
- **读取**: `linear_get_issue <identifier>`（如 LIN-123），可带 `includeRelations`。
- **列出**: `linear_list_issues`，配合 `query` / `state` / `assignee` / `team` 过滤。
- **评论**: `linear_save_comment`（传 `issueId` + `body`）。
- **标签**: `linear_save_issue` 的 `labels` 字段（替换完整标签集）。
- **状态**: `linear_save_issue` 的 `state` 字段（类型/名称/ID）。

Team/项目/cycle 名称一律通过 Linear MCP 查询解析，不要硬编码。

## When a skill says "publish to the issue tracker"

用 `linear_save_issue` 创建 Linear issue。

## When a skill says "fetch the relevant ticket"

用 `linear_get_issue <identifier>`。

## Wayfinding operations

- **Map**: 一个 issue 作为 map；child ticket 通过 `parentId` 关联。
- **Child ticket**: `linear_save_issue` 设 `parentId` 为 map；labels `wayfinder:<type>`（research/prototype/grilling/task）。
- **Blocking**: `linear_save_issue` 的 `blockedBy` / `blocks`（append-only）。
- **Frontier query**: 列出 map 的 open children，剔除有 blocker 或已 assign 的；按 map 顺序取第一个。
- **Claim**: `linear_save_issue` 设 `assignee: me`。
- **Resolve**: `linear_save_comment` 记录答案 → 更新 state → 在 map 的 decisions-so-far 追加指针。
