<!-- Bitbucket PR template. Instantiates the portable evidence contract.
     Source of truth for fields: ../PORTABLE_PR_BODY.md
     No agent media --attach CLI for Bitbucket Cloud. Use Kind api body/transcript
     or browser Kind ui upload. Never invent a Bitbucket media attach CLI.
     On CLI/API failure: research equivalent Bitbucket CLI/API or web UI steps and retry;
     never silently skip Visual evidence or Reproduce / Verify. -->

## Summary

<!-- What changed and why (one short paragraph). -->

## Visual evidence

<!-- REQUIRED for product Kind ui (and product api when a transcript proves the path).
     Agent path: Kind api transcript in description/comment.
     Kind ui media: browser upload on the PR, then confirm forge-visible proof.
     Do not comment only local .agent-state/.../pr-evidence/ paths. -->

- [ ] Kind `api` transcript inlined below (fenced), **or**
- [ ] Kind `ui` media uploaded in the Bitbucket UI (browser), **or**
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
