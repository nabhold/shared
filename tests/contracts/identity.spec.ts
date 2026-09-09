import { describe, expect, it } from 'vitest';
import { validate } from 'json-schema';
import principalSchema from '../../contracts/identity/v1/principal.schema.json';
import actorTypeSchema from '../../contracts/identity/v1/actor-type.schema.json';
// ... import other schemas

describe('Identity schemas', () => {
  it('validates a valid principal', () => {
    const validPrincipal = {
      id: '123e4567-e89b-12d3-a456-426614174000',
      actor_type: 'human',
      status: 'ACTIVE',
      created_at: '2026-09-09T10:00:00Z',
      updated_at: '2026-09-09T10:00:00Z'
    };
    const validator = new Ajv();
    const validate = validator.compile(principalSchema);
    expect(validate(validPrincipal)).toBe(true);
  });

  it('rejects an invalid principal (missing id)', () => {
    const invalid = { actor_type: 'human' };
    const validator = new Ajv();
    const validate = validator.compile(principalSchema);
    expect(validate(invalid)).toBe(false);
  });
});