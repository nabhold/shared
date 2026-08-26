// Entry point for @nabhold/contracts-ts.
//
// Both re-exports below point at generated code that does not exist until
// `pnpm generate` has run (buf generate + graphql-codegen). This file is
// intentionally thin — it should never contain hand-written contract types.
//
// PLACEHOLDER STATE: only the health-check contract exists right now.
// Trade Intelligence / Property Intelligence / BIE exports will be added
// here as their respective .proto/.graphql sources are authored — see
// ADR-0001 for why they are absent from this initial scaffold.

export * from './generated/nabhold/shared/v1/health';
export * from './generated/graphql';