<!-- GitHub PR template. Instantiates the portable evidence contract.
     Source of truth for fields: ../PORTABLE_PR_BODY.md
     Attach via gh only when ultragentic doctor says forge is github and attach is supported.
     On CLI failure: research equivalent gh syntax (--help / docs) and retry; never silently skip. -->

## Summary

<!-- What changed and why (one short paragraph). -->

## Visual evidence

<!-- REQUIRED for product Kind ui (and product api when a transcript proves the path).
     Prefer: gh pr create|comment --attach <file> when doctor/help lists --attach.
     Else: Kind api transcript in body, or Kind none/redacted with Reason.
     Do not comment only .agent-state/.../pr-evidence/ paths. -->

- [ ] Screenshot or video attached with `gh … --attach`, **or**
- [ ] Kind `api` transcript inlined below (fenced), **or**
- [ ] Kind `none` / `Kind: redacted` with Reason

```text
Kind: <!-- api | ui | none | redacted -->
Summary: <!-- matches MANIFEST Summary when api/ui -->
Reason: <!-- required for none/redacted -->
```

## Reproduce / Verify

<!-- REQUIRED step-by-step for Kind ui (and critical product api). -->

1.
2.
3.

## Test plan

- [ ]
