# frozen_string_literal: true

require "json"
require "yaml"

ROOT = File.expand_path("..", __dir__)

def fail_contract(message)
  warn "contract validation failed: #{message}"
  exit 1
end

def load_yaml(path)
  YAML.safe_load_file(File.join(ROOT, path), aliases: false)
end

def load_json(path)
  JSON.parse(File.read(File.join(ROOT, path)))
end

registry = load_yaml("contracts/legal-entity/registry.yaml")
tenancy = load_yaml("contracts/tenancy/tenancy.yaml")
domain = load_json("contracts/control-plane/v1/domain.schema.json")
register_example = load_json("contracts/control-plane/v1/examples/register-tenant.json")
context_example = load_json("contracts/control-plane/v1/examples/resolve-context.json")
provisioning_example = load_json("contracts/control-plane/v1/examples/provisioning-started.json")

entities = registry.fetch("entities")
entity_ids = entities.map { |entity| entity.fetch("id") }
fail_contract("legal-entity identifiers must be unique") unless entity_ids.uniq == entity_ids

legal_entity_patterns = domain.dig("$defs", "legalEntityId", "oneOf")
fail_contract("legalEntityId must declare canonical and legacy-compatible grammars") unless legal_entity_patterns&.length == 2
canonical_entity_pattern = Regexp.new(legal_entity_patterns.first.fetch("pattern"))

entity_ids.each do |entity_id|
  fail_contract("#{entity_id.inspect} is not a canonical legal-entity identifier") unless canonical_entity_pattern.match?(entity_id)
end

product_pattern = Regexp.new(domain.dig("$defs", "productId", "pattern"))
entities.each do |entity|
  products = entity.fetch("baobab_products", [])
  if entity.fetch("baobab_tenant") && products.empty?
    fail_contract("#{entity.fetch('id')} declares tenant intent without a product-consumption intent")
  end

  products.each do |entry|
    product_id = entry.fetch("product")
    fail_contract("#{product_id.inspect} is not a valid product identifier") unless product_pattern.match?(product_id)
  end
end

definition = tenancy.fetch("tenant_definition")
fail_contract("legal entity must remain the default tenant boundary") unless definition["legal_entity_is_default_boundary"] == true
fail_contract("legal entity and tenant must not be synonyms") unless definition["legal_entity_is_tenant_synonym"] == false
fail_contract("digital estates must not confer tenancy") unless definition["digital_estate_confers_tenancy"] == false
fail_contract("product consumption must require tenancy") unless definition["product_consumption_requires_tenant"] == true

tenant_pattern = Regexp.new(tenancy.dig("identifiers", "tenant_id", "exact_format"))
example_tenant_ids = [
  register_example.fetch("tenant_id"),
  context_example.dig("response", "tenant_id"),
  provisioning_example.fetch("tenant_id"),
  provisioning_example.dig("data", "tenant_id")
]
example_tenant_ids.each do |tenant_id|
  fail_contract("#{tenant_id.inspect} is not an opaque tenant identifier") unless tenant_pattern.match?(tenant_id)
end
fail_contract("examples must use one tenant identity") unless example_tenant_ids.uniq.length == 1

example_entity_id = register_example.fetch("legal_entity_id")
fail_contract("registration example references an unknown legal entity") unless entity_ids.include?(example_entity_id)
fail_contract("tenant_id must not equal legal_entity_id") if register_example.fetch("tenant_id") == example_entity_id
semantic_entity_tokens = entity_ids.map { |id| id.downcase.delete("-") }
if semantic_entity_tokens.any? { |token| register_example.fetch("tenant_id").include?(token) }
  fail_contract("new tenant identifiers must not embed a legal-entity name")
end

example_products = register_example.fetch("requested_products") + [
  context_example.dig("request", "product_id"),
  context_example.dig("response", "product_id")
]
example_products.each do |product_id|
  fail_contract("#{product_id.inspect} is not a valid product identifier") unless product_pattern.match?(product_id)
end
fail_contract("context example request and response products differ") unless context_example.dig("request", "product_id") == context_example.dig("response", "product_id")

nabhold = entities.find { |entity| entity.fetch("id") == "NABHOLD" }
fail_contract("NABHOLD registry entry is required") unless nabhold
fail_contract("NABHOLD must declare approved tenant intent") unless nabhold["baobab_tenant"] == true
nabhold_erp = nabhold.fetch("baobab_products").find { |entry| entry["product"] == "baobab-erp" }
fail_contract("NABHOLD must declare confirmed baobab-erp consumption") unless nabhold_erp&.fetch("confirmed") == true

puts "Governance contract validation passed"
