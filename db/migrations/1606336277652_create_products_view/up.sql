CREATE OR REPLACE VIEW "public"."products_view" AS 
 SELECT ii.name,
    s.name AS shop_name,
    avg(ii.cost) AS average_cost,
    sum(ii.quantity) AS total_quantity,
    count(*) AS times_bought,
    mode() WITHIN GROUP (ORDER BY c.name) AS category_name,
    stddev_pop(ii.cost) AS deviation
   FROM (((invoice_items ii
     JOIN invoices i ON ((i.id = ii.invoice_id)))
     JOIN shops s ON ((s.id = i.shop_id)))
     JOIN categories c ON ((c.id = ii.category_id)))
  GROUP BY ii.name, s.id;
