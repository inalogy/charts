CREATE TABLE "sample_position" (
    code varchar NOT NULL,
    "position" varchar NOT NULL,
    org_unit_code varchar NOT NULL,
    gestor varchar NULL,
    "user" varchar NULL,
    CONSTRAINT "sample_position_pk" PRIMARY KEY (code)
);