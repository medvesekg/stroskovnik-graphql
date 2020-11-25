alter table "public"."user_settings" drop constraint "user_settings_pkey";
alter table "public"."user_settings"
    add constraint "user_settings_pkey" 
    primary key ( "id" );
