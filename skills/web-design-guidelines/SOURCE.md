Skill wrapper adapted from [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills/tree/main/skills/web-design-guidelines) at `063bee94c3f4df8453406c830b0a7df0f2860278`. Retrieved 2026-09-11. That repository has no LICENSE file.

Guidelines snapshot in `references/command.md` comes from [vercel-labs/web-interface-guidelines](https://github.com/vercel-labs/web-interface-guidelines) at `e3d624baaf29dc1fc645aff3e38f03e564d2d6b1`. Retrieved 2026-09-11. MIT. Copyright (c) 2025 Vercel Labs. See `LICENSE` in this folder.

The skill fetches that pinned `command.md` first and uses the snapshot if fetch fails. Never fetch `main`.
