import { describe, expect, it } from "vitest"
import { supplierOrganisationSchema } from "../src/organisation"
import { supplierCapabilityInputSchema } from "../src/capability"
import { supplierCertificationInputSchema } from "../src/certification"
import { supplierStatusEventSchema } from "../src/status-event"
import { defineCategoryRegistry } from "../src/category"

describe("supplierOrganisationSchema", () => {
  it("accepts a minimal valid organisation and defaults status to draft", () => {
    const result = supplierOrganisationSchema.parse({
      applicantIdentityRef: "customer:cus_123",
      legalName: "Acme Foods Ltd",
      countryCode: "KE",
    })
    expect(result.status).toBe("draft")
    expect(result.canonicalOrganisationId).toBeNull()
  })

  it("rejects a country code that is not two letters", () => {
    expect(() =>
      supplierOrganisationSchema.parse({
        applicantIdentityRef: "customer:cus_123",
        legalName: "Acme Foods Ltd",
        countryCode: "KEN",
      }),
    ).toThrow()
  })

  it("never requires canonicalOrganisationId to be set", () => {
    const result = supplierOrganisationSchema.parse({
      applicantIdentityRef: "customer:cus_123",
      legalName: "Acme Foods Ltd",
      countryCode: "KE",
      canonicalOrganisationId: null,
    })
    expect(result.canonicalOrganisationId).toBeNull()
  })
})

describe("supplierCapabilityInputSchema", () => {
  it("accepts a declared capability with only a category", () => {
    const result = supplierCapabilityInputSchema.parse({ category: "packaged-foods" })
    expect(result.category).toBe("packaged-foods")
  })

  it("rejects a negative lead time", () => {
    expect(() =>
      supplierCapabilityInputSchema.parse({ category: "packaged-foods", leadTimeDays: -1 }),
    ).toThrow()
  })
})

describe("supplierCertificationInputSchema", () => {
  it("requires a certification type", () => {
    expect(() => supplierCertificationInputSchema.parse({ certificationType: "" })).toThrow()
  })
})

describe("supplierStatusEventSchema", () => {
  it("requires an origin-carrying actor, not a bare name", () => {
    const result = supplierStatusEventSchema.parse({
      supplierOrganisationId: "org_1",
      fromStatus: "draft",
      toStatus: "submitted",
      actor: "customer:cus_123",
    })
    expect(result.actor).toContain(":")
  })
})

describe("defineCategoryRegistry", () => {
  it("builds an estate-specific registry without hard-coding categories in this package", () => {
    const registry = defineCategoryRegistry([
      { key: "fresh-produce", label: "Fresh Produce" },
      { key: "electronics", label: "Consumer Electronics" },
    ])
    expect(registry.isKnownCategory("fresh-produce")).toBe(true)
    expect(registry.isKnownCategory("coffee")).toBe(false)
  })
})
