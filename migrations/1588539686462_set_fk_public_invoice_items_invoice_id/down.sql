alter table "public"."invoice_items" drop constraint "invoice_items_invoice_id_fkey",
          add constraint "expenses_invoice_id_fkey"
          foreign key ("invoice_id")
          references "public"."invoices"
          ("id")
          on update restrict
          on delete restrict;
