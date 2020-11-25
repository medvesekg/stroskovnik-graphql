CREATE TABLE "public"."user_settings"("id" serial NOT NULL, "type" text NOT NULL, "data" jsonb NOT NULL, "user_id" text NOT NULL, PRIMARY KEY ("id") );
