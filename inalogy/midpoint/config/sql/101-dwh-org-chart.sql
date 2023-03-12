CREATE TABLE "sample_org_chart" (
     code varchar NOT NULL,
     org_unit varchar NOT NULL,
     parent_code varchar NULL,
     CONSTRAINT "sample_org_chart_pk" PRIMARY KEY (code)
);

