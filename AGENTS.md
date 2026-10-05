# Working in PipeNotPipe

Read docs/ARCHITECTURE.md and docs/DEVELOPMENT.md before changing module boundaries.

- The root repository orchestrates two separately versioned Git submodules. Commit and push a child repository before updating its root gitlink.
- Keep GPL licenses, attribution, source history and the upstream remotes.
- Fork branding belongs in PipePipeClient/config/fork.properties. Keep the legacy source namespace until an explicit source/package migration is requested.
- New core and data code must remain independent of Android and app classes. Run scripts/check-architecture.ps1 after changes.
- Validate changed cache or loading behavior with the module tests; use scripts/build.ps1 for Android changes.
- Do not claim device or live-service verification from a successful compile.
- Preserve the signing key across releases; never commit secrets, SDK paths, APKs or generated build outputs.
- Do not mass-move inherited UI/player code just to create empty architecture layers. Extract real behavior with public-interface tests.
