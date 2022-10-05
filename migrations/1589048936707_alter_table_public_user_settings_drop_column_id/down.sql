ALTER TABLE "public"."user_settings" ADD COLUMN "id" int4;
ALTER TABLE "public"."user_settings" ALTER COLUMN "id" DROP NOT NULL;
ALTER TABLE "public"."user_settings" ALTER COLUMN "id" SET DEFAULT nextval('user_settings_id_seq'::regclass);
