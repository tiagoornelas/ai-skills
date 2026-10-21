# File Tree: Annotated Layout

The tree answers where code lives on disk and whether that layout reflects the architecture. It does not show dependencies; the module map does. Reuse its module IDs so both views read as one model.

## 1. Format

Plain fenced block without a language tag, in every destination. Keep lines within 80 columns.

```
ai-skills/
├── global/
│   └── AGENTS.md                        [1]
├── skills/
│   ├── coding/                          [2]
│   │   ├── SKILL.md
│   │   │   ! links ../../docs/rules/language.md
│   │   └── references/  … 9 files
│   ├── visualize-it/                    [4]
│   │   ├── ~ SKILL.md
│   │   └── references/
│   │       ├── module-map.md
│   │       └── + file-tree.md
│   └── … 17 more skills
└── docs/rules/language.md               (repo-only)
```

`[n]` module ID · `+` new · `~` modified · `−` removed · `!` deviation · `…` pruned

Observe that only `coding/SKILL.md` is flagged and the new file sits beside its siblings.

## 2. Rules

- **Prune to the decision**: keep the path to each changed or flagged item and collapse everything else as `… N files` or `… N more <things>`.
- **IDs on folders**: place the `[n]` of the owning module on the folder that holds it, aligned in one column. Folders that are not modules carry no ID; mark notable ones in parentheses, such as `(repo-only)`.
- **Faithful to disk**: real nesting and real order. Never regroup folders by responsibility; that belongs to the map's boundaries.
- **Markers in rendered Markdown**: use 🆕 🔧 🗑️ ⚠️ in destinations that render Markdown, keeping the same block. In terminal replies use the one-column markers, which keep alignment.
- **Deviation note**: at most one short line under the flagged item, naming the broken boundary. Explain the consequence in the paragraph below the tree.
- **Before / After**: for a restructuring, draw two trees with the same pruning, the second one carrying the change markers.

## 3. Validation

- [ ] The tree is justified by a structural change, an explicit request, or a location that breaks a boundary.
- [ ] Pruned to what matters, with collapsed branches counted.
- [ ] Nesting and order match the disk.
- [ ] IDs match the module index of the accompanying map.
- [ ] Markers match the destination, and every marker used is in the legend.
