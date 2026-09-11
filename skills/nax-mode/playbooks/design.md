### Design

**You own the design read and the taste bar.** Classify surface and kind, dispatch to that row, then verify on the rendered page. For "design this page", "redesign this", "build this screenshot", "make it neobrutalist", or "not generic AI slop".

Pixel-exact matching of two implementations is Visual parity. A throwaway layout sketch is Prototype.

1. Name both axes before any code.
   - **Surface.** Marketing (landing, portfolio, editorial, product page) or product UI (dashboard, table, settings, multi-step flow). This decides whether `design-taste-frontend` fires at all.
   - **Kind.** One of `greenfield`, `redesign`, `image-match`, `named-style`. A request can carry two, such as a redesign in a named style. Run both rows and take the union of their skills.

2. Dispatch on the row. A skill outside the row does not fire. A skill inside it gets read in full.

| Kind | Blocking gate | Marketing surface | Product UI surface |
|---|---|---|---|
| `greenfield` | none | `design-taste-frontend`, design read and dials before layout | `web-design-guidelines` as the build spec, not as a review pass |
| `redesign` | audit the current page. Write down load-bearing brand, copy, and conversion path | `design-taste-frontend` on its audit-first path | `web-design-guidelines` over the current code, then fix by finding |
| `image-match` | the reference image exists and you have read it | `image-to-code` | `image-to-code` for layout extraction only. Behavior stays with `web-design-guidelines` |
| `named-style` | resolve the style word to a catalog slug, step 3 | the style skill plus `design-taste-frontend` for page structure | the style skill for surface treatment only. `web-design-guidelines` still owns behavior |

   A style the user named outranks your taste. A style that fights the audience does not. Say so (the **experience-first** principle skill). `design-taste-frontend` never appears in the product UI column.

3. `named-style` only, and blocking. Fetch one skill via `design-style-catalog`. When two or three slugs are plausible, do not ask. Build one variant per slug through **Prototype** and let the user point at the winner (the **never-block-on-the-human** principle skill).

4. Build from tokens, not from literals. Name palette, type ramp, spacing, and motion first, then components (the **model-the-domain** principle skill). Sections can fan out after tokens land.

5. Verify on the rendered page (the **prove-it-works** principle skill). Screenshot sections at narrow, laptop, and wide through `control-ui`. Drive the interactive states. Run `web-design-guidelines` on both surfaces. Fetch the pinned guidelines URL in `skills/web-design-guidelines/SKILL.md`. If fetch fails, read `skills/web-design-guidelines/references/command.md`. Marketing also clears the `design-taste-frontend` pre-flight. Findings you leave get a reason. Silence reads as a pass.

6. Present the work. Do not commit or open a PR unless the user asked. If they did, run **Opening a PR**.

**Reply:** design read as one line, the row and skills that fired, catalog slug if any, screenshots, guideline findings fixed and left, and whether anything was committed.
