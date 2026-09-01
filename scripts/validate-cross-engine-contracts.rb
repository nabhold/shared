# frozen_string_literal: true

require "json"
require "time"
require "uri"
require "yaml"

ROOT = File.expand_path("..", __dir__)
UUID_PATTERN = /\A[0-9a-f]{8}-[0-9a-f]{4}-[1-8][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i

def fail_contract(message)
  warn "cross-engine contract validation failed: #{message}"
  exit 1
end

def load_json(path)
  JSON.parse(File.read(File.join(ROOT, path)))
end

def load_yaml(path)
  YAML.safe_load_file(File.join(ROOT, path), aliases: false)
end

def absolute_uri?(value)
  URI.parse(value).absolute?
rescue URI::InvalidURIError
  false
end

envelope = load_json("contracts/events/v1/envelope.schema.json")
control_plane_profile = load_json("contracts/control-plane/v1/event-envelope.schema.json")
canonical_event = load_json("contracts/control-plane/v1/examples/provisioning-started.json")
provisioning_payload = load_json("contracts/control-plane/v1/provisioning-started.schema.json")
legacy_event = load_json("contracts/events/v1/compatibility/legacy-control-plane-event.json")
legacy_trade_erp_event = load_json("contracts/events/v1/compatibility/legacy-trade-erp-event.json")
domain = load_json("contracts/control-plane/v1/domain.schema.json")
problem = load_json("contracts/errors/v1/problem-details.schema.json")
problem_example = load_json("contracts/errors/v1/examples/insufficient-entitlement.json")
idempotency = load_yaml("contracts/idempotency/v1/policy.yaml")
openapi = load_yaml("contracts/control-plane/v1/openapi.yaml")

canonical_envelope_ref = "../../events/v1/envelope.schema.json"
unless control_plane_profile["$ref"] == canonical_envelope_ref
  fail_contract("Control Plane envelope path must reference the canonical cross-engine envelope")
end

required_event_fields = envelope.fetch("required")
event_properties = envelope.fetch("properties")
missing_event_fields = required_event_fields - canonical_event.keys
unknown_event_fields = canonical_event.keys - event_properties.keys
fail_contract("canonical event misses: #{missing_event_fields.join(', ')}") unless missing_event_fields.empty?
fail_contract("canonical event has unknown fields: #{unknown_event_fields.join(', ')}") unless unknown_event_fields.empty?

core_attributes = %w[specversion id type source subject time datacontenttype dataschema data]
extension_attributes = event_properties.keys - core_attributes
extension_attributes.each do |attribute|
  unless attribute.match?(/\A[a-z][a-z0-9]{0,19}\z/)
    fail_contract("#{attribute.inspect} is not a CloudEvents-compatible extension name")
  end
end

fail_contract("specversion must be CloudEvents 1.0") unless canonical_event["specversion"] == "1.0"
fail_contract("event id must be a UUID") unless UUID_PATTERN.match?(canonical_event.fetch("id"))
event_type_pattern = Regexp.new(event_properties.dig("type", "pattern"))
fail_contract("event type is not versioned reverse DNS") unless event_type_pattern.match?(canonical_event.fetch("type"))
event_major = canonical_event.fetch("type").match(/\.v([1-9][0-9]*)\z/)&.captures&.first
fail_contract("event source must be an absolute logical URI") unless absolute_uri?(canonical_event.fetch("source"))
fail_contract("event dataschema must be an absolute URI") unless absolute_uri?(canonical_event.fetch("dataschema"))
unless canonical_event.fetch("dataschema") == provisioning_payload.fetch("$id")
  fail_contract("event dataschema must identify the data payload schema, not the envelope or message")
end
unless canonical_event.fetch("dataschema").include?("/v#{event_major}/")
  fail_contract("event type major and dataschema major must agree")
end
fail_contract("event time must be UTC") unless canonical_event.fetch("time").end_with?("Z")
begin
  Time.iso8601(canonical_event.fetch("time"))
rescue ArgumentError
  fail_contract("event time is not ISO 8601")
end

%w[correlationid].each do |field|
  fail_contract("#{field} must be a UUID") unless UUID_PATTERN.match?(canonical_event.fetch(field))
end
if canonical_event.key?("causationid") && !UUID_PATTERN.match?(canonical_event.fetch("causationid"))
  fail_contract("causationid must be omitted for a root event or contain a UUID")
end

tenant_pattern = Regexp.new(domain.dig("$defs", "tenantId", "pattern"))
if canonical_event.fetch("baobabscope") == "tenant"
  fail_contract("tenant-scoped event is missing tenantid") unless canonical_event.key?("tenantid")
  fail_contract("tenantid is not canonical") unless tenant_pattern.match?(canonical_event.fetch("tenantid"))
end
scope_rule = envelope.fetch("allOf").first
unless scope_rule.dig("then", "required") == ["tenantid"] &&
       scope_rule.dig("else", "not", "required") == ["tenantid"]
  fail_contract("tenant scope must require tenantid and platform scope must forbid it")
end

traceparent_pattern = Regexp.new(event_properties.dig("traceparent", "pattern"))
if canonical_event.key?("traceparent") && !traceparent_pattern.match?(canonical_event.fetch("traceparent"))
  fail_contract("traceparent is invalid or uses an unsupported version")
end
idempotency_pattern = Regexp.new(event_properties.dig("idempotencykey", "pattern"))
if canonical_event.key?("idempotencykey")
  key = canonical_event.fetch("idempotencykey")
  limits = event_properties.fetch("idempotencykey")
  valid_length = key.length.between?(limits.fetch("minLength"), limits.fetch("maxLength"))
  fail_contract("event idempotencykey is invalid") unless valid_length && idempotency_pattern.match?(key)
end

payload = canonical_event.fetch("data")
payload_missing = provisioning_payload.fetch("required") - payload.keys
payload_unknown = payload.keys - provisioning_payload.fetch("properties").keys
fail_contract("provisioning payload misses: #{payload_missing.join(', ')}") unless payload_missing.empty?
fail_contract("provisioning payload has unknown fields: #{payload_unknown.join(', ')}") unless payload_unknown.empty?
fail_contract("payload tenant identity differs from envelope tenant context") unless payload.fetch("tenant_id") == canonical_event.fetch("tenantid")

legacy_missing = required_event_fields - legacy_event.keys
legacy_unknown = legacy_event.keys - event_properties.keys
if legacy_missing.empty? && legacy_unknown.empty?
  fail_contract("legacy snake_case Control Plane event unexpectedly satisfies the canonical envelope")
end
legacy_snake_case = %w[correlation_id causation_id tenant_id]
unless (legacy_event.keys & legacy_snake_case).sort == legacy_snake_case.sort
  fail_contract("legacy compatibility fixture no longer represents the migration source")
end
legacy_trade_erp_required = %w[event_id event_type schema_version occurred_at source correlation_id tenant_id entity_id payload]
unless (legacy_trade_erp_required - legacy_trade_erp_event.keys).empty?
  fail_contract("legacy Trade/ERP fixture no longer represents the migration source")
end
trade_erp_missing = required_event_fields - legacy_trade_erp_event.keys
trade_erp_unknown = legacy_trade_erp_event.keys - event_properties.keys
if trade_erp_missing.empty? && trade_erp_unknown.empty?
  fail_contract("legacy Trade/ERP event unexpectedly satisfies the canonical envelope")
end

required_problem_fields = problem.fetch("required")
problem_properties = problem.fetch("properties")
missing_problem_fields = required_problem_fields - problem_example.keys
unknown_problem_fields = problem_example.keys - problem_properties.keys
fail_contract("problem example misses: #{missing_problem_fields.join(', ')}") unless missing_problem_fields.empty?
fail_contract("problem example has unknown fields: #{unknown_problem_fields.join(', ')}") unless unknown_problem_fields.empty?
fail_contract("problem type must be an absolute URI") unless absolute_uri?(problem_example.fetch("type"))
status_limits = problem_properties.fetch("status")
status = problem_example.fetch("status")
unless status.is_a?(Integer) && status.between?(status_limits.fetch("minimum"), status_limits.fetch("maximum"))
  fail_contract("problem status is outside the HTTP error range")
end
error_code_pattern = Regexp.new(problem_properties.dig("code", "pattern"))
fail_contract("problem code is not canonical") unless error_code_pattern.match?(problem_example.fetch("code"))
fail_contract("problem correlation_id must be a UUID") unless UUID_PATTERN.match?(problem_example.fetch("correlation_id"))
trace_id_pattern = Regexp.new(problem_properties.dig("trace_id", "pattern"))
if problem_example.key?("trace_id") && !trace_id_pattern.match?(problem_example.fetch("trace_id"))
  fail_contract("problem trace_id is invalid")
end
fail_contract("problem retryable must be boolean") unless [true, false].include?(problem_example["retryable"])

problem_ref = "../../errors/v1/problem-details.schema.json"
unless openapi.dig("components", "schemas", "ProblemDetails", "$ref") == problem_ref
  fail_contract("Control Plane OpenAPI must consume the canonical problem-details schema")
end

trace_header = openapi.dig("components", "parameters", "Traceparent", "schema", "pattern")
unless trace_header == event_properties.dig("traceparent", "pattern")
  fail_contract("HTTP and event traceparent grammars must agree")
end
trace_state_header = openapi.dig("components", "parameters", "Tracestate", "schema")
trace_state_event = event_properties.fetch("tracestate")
unless trace_state_header["pattern"] == trace_state_event["pattern"] &&
       trace_state_header["maxLength"] == trace_state_event["maxLength"]
  fail_contract("HTTP and event tracestate constraints must agree")
end
%w[BadRequest Unauthorized Forbidden Conflict].each do |response_name|
  response_ref = openapi.dig("components", "responses", response_name, "content", "application/problem+json", "schema", "$ref")
  unless response_ref == "#/components/schemas/ProblemDetails"
    fail_contract("OpenAPI response #{response_name} does not use canonical problem details")
  end
end

unless idempotency.dig("events", "delivery_identity") == %w[source id]
  fail_contract("event delivery identity must be source plus id")
end
idempotency_header = openapi.dig("components", "parameters", "IdempotencyKey", "schema")
policy_key = idempotency.dig("http_commands", "key")
unless idempotency_header["pattern"] == policy_key["allowed_pattern"] &&
       idempotency_header["minLength"] == policy_key["min_length"] &&
       idempotency_header["maxLength"] == policy_key["max_length"]
  fail_contract("Control Plane Idempotency-Key header has drifted from canonical policy")
end
unless idempotency.dig("events", "command_consequence", "envelope_attribute") == "idempotencykey"
  fail_contract("command consequence idempotency metadata has drifted from the envelope")
end
unless idempotency.dig("http_commands", "replay", "incompatible_request", "status") == 409
  fail_contract("incompatible idempotency replay must return HTTP 409")
end
unless idempotency.dig("http_commands", "replay", "incompatible_request", "error_code") == "IDEMPOTENCY_KEY_REUSED"
  fail_contract("incompatible idempotency replay must use the canonical error code")
end
fail_contract("idempotency keys must not be logged") unless idempotency.dig("security", "log_keys") == false

puts "Cross-engine envelope, error, trace and idempotency contracts passed"
