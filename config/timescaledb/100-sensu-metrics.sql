CREATE EXTENSION IF NOT EXISTS timescaledb CASCADE;
CREATE TABLE metrics (
  time    TIMESTAMPTZ         NOT NULL,
  name    TEXT                NOT NULL,
  value   DOUBLE PRECISION    NULL,
  source  TEXT                NOT NULL,
  tags    JSONB
);