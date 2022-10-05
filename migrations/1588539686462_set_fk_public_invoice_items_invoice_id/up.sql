alter table "public"."invoice_items" drop constraint "expenses_invoice_id_fkey",
             add constraint "invoice_items_invoice_id_fkey"
             foreign key ("invoice_id")
             references "public"."invoices"
             ("id") on update cascade on delete cascade;
