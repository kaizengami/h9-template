---
name: shadcn-component-add
description: Install and integrate shadcn/ui components correctly. Use whenever adding a new UI primitive (button, dialog, select, command palette, sonner, etc.). Covers the exact npx command, where components land, and how to wrap for behavior changes.
paths: components/**, app/**
---

# shadcn/ui component add

Reference skill for installing and integrating shadcn/ui components.
Auto-attached when working under `components/` or `app/`.

The team's UI conventions live in
[.cursor/rules/020-shadcn-ui.mdc](../../../.cursor/rules/020-shadcn-ui.mdc).
This skill covers the **install workflow** specifically.

## The command

```bash
npx shadcn@latest add <component>
```

Run from the repo root. Example: `npx shadcn@latest add dialog`.

For multiple components in one invocation:

```bash
npx shadcn@latest add dialog dropdown-menu sonner
```

## Where the installed component lands

- `components/ui/<component>.tsx` — the primitive itself.
- `lib/utils.ts` — adds the `cn()` helper if not already present.
- `app/globals.css` — adds CSS variables for the theme tokens
  (`--background`, `--foreground`, `--input`, etc.) if missing.
- `components.json` — registers the component with shadcn's CLI.
- `tailwind.config.ts` — extends the Tailwind config if the
  component needs custom keyframes (e.g. `accordion-down`).

## Rules of engagement

1. **Don't edit `components/ui/<component>.tsx` in place.** Treat it
   as upstream code. If you need behavior changes, wrap it in a
   sibling component under `components/<feature>/`.
2. **Don't delete generated files** — the next `add` invocation
   relies on the `components.json` registry.
3. **For upstream updates**, re-run with `--overwrite`:
   ```bash
   npx shadcn@latest add dialog --overwrite
   ```
   Then review the diff and re-apply any wraps in feature components.
4. **Pin the component set in `components.json`** by committing the
   file. The team uses the same primitives across worktrees this way.

## Common primitives we'll likely need at the hackathon

- `button`, `input`, `label`, `form` — every form on day-of
- `dialog`, `sheet` — modals and side panels
- `dropdown-menu`, `command` — navigation and command palette
- `sonner` — toast notifications for success/error states
- `skeleton` — loading state per
  [.cursor/rules/020-shadcn-ui.mdc](../../../.cursor/rules/020-shadcn-ui.mdc)
- `tabs`, `accordion` — content organization

Install them lazily as needed; don't pre-install a "kitchen sink".

## Wrap pattern for behavior changes

If the design calls for, say, a confirmation dialog that auto-focuses
the destructive action, do **not** edit `components/ui/dialog.tsx`.
Instead:

```tsx
// components/confirm/destructive-confirm-dialog.tsx
'use client';

import { Dialog, DialogContent, DialogTrigger } from "@/components/ui/dialog";
import { Button } from "@/components/ui/button";

export type ConfirmProps = {
  title: string;
  onConfirm: () => void;
  trigger: React.ReactNode;
};

export function DestructiveConfirmDialog({ title, onConfirm, trigger }: ConfirmProps) {
  return (
    <Dialog>
      <DialogTrigger asChild>{trigger}</DialogTrigger>
      <DialogContent>
        <h2 className="text-lg font-semibold">{title}</h2>
        <Button variant="destructive" autoFocus onClick={onConfirm}>
          Confirm
        </Button>
      </DialogContent>
    </Dialog>
  );
}
```

This way an upstream `--overwrite` of `dialog.tsx` is safe.

## When you're done

Commit the install in its own commit so the diff is reviewable:

```bash
git add components/ui/<component>.tsx components.json lib/utils.ts app/globals.css tailwind.config.ts
git commit -m "feat(ui): add shadcn <component> primitive"
```

Then commit the feature that uses it as a separate commit.

## Don't

- Don't install shadcn primitives from inside a worktree if `main`
  hasn't seen them yet — promote the install to a `feat/ui-*` PR on
  `main` first, otherwise different worktrees diverge on
  `components.json`.
- Don't add components from non-shadcn sources via this skill — for
  those, install the dependency normally and import.
- Don't run `npx shadcn@latest init` after the team's
  `components.json` exists. It will overwrite the config.
