CREATE FUNCTION public.set_current_timestamp_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  _new record;
BEGIN
  _new := NEW;
  _new."updated_at" = NOW();
  RETURN _new;
END;
$$;
CREATE TABLE public.categories (
    id integer NOT NULL,
    name text NOT NULL,
    category_group_id integer
);
CREATE TABLE public.category_groups (
    id integer NOT NULL,
    name text NOT NULL,
    parent_id integer
);
CREATE SEQUENCE public.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.categories_id_seq OWNED BY public.category_groups.id;
CREATE TABLE public.invoice_items (
    id integer NOT NULL,
    name text NOT NULL,
    cost numeric NOT NULL,
    category_id integer NOT NULL,
    quantity numeric DEFAULT 1 NOT NULL,
    invoice_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    total numeric GENERATED ALWAYS AS ((cost * quantity)) STORED
);
CREATE TABLE public.invoices (
    id integer NOT NULL,
    file text,
    date date NOT NULL,
    shop_id integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);
CREATE VIEW public.expenses_by_day AS
 SELECT (d.date)::date AS date,
    COALESCE(ii.sum, (0)::numeric) AS sum
   FROM (( SELECT date.date
           FROM generate_series((( SELECT min(invoices.date) AS min
                   FROM public.invoices))::timestamp with time zone, (CURRENT_DATE)::timestamp with time zone, '1 day'::interval) date(date)) d
     LEFT JOIN ( SELECT invoices.date,
            sum((invoice_items.cost * invoice_items.quantity)) AS sum
           FROM (public.invoice_items
             JOIN public.invoices ON ((invoices.id = invoice_items.invoice_id)))
          GROUP BY invoices.date) ii ON ((ii.date = d.date)));
CREATE SEQUENCE public.expenses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.expenses_id_seq OWNED BY public.invoice_items.id;
CREATE VIEW public.invoice_sums AS
 SELECT i.id AS invoice_id,
    sum((ii.cost * ii.quantity)) AS sum
   FROM (public.invoices i
     JOIN public.invoice_items ii ON ((ii.invoice_id = i.id)))
  GROUP BY i.id;
CREATE VIEW public.invoice_totals AS
 SELECT i.id AS invoice_id,
    sum((ii.cost * ii.quantity)) AS sum,
    count(*) AS count,
    sum(ii.quantity) AS quantity
   FROM (public.invoices i
     JOIN public.invoice_items ii ON ((ii.invoice_id = i.id)))
  GROUP BY i.id;
CREATE SEQUENCE public.invoices_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.invoices_id_seq OWNED BY public.invoices.id;
CREATE TABLE public.shops (
    id integer NOT NULL,
    name text NOT NULL
);
CREATE VIEW public.item_popularity AS
 SELECT ii.name AS item_name,
    count(*) AS times_bought,
    sum(ii.quantity) AS total_quantity,
    date_trunc('month'::text, (i.date)::timestamp with time zone) AS month
   FROM ((public.invoice_items ii
     JOIN public.invoices i ON ((i.id = ii.invoice_id)))
     JOIN public.shops s ON ((s.id = i.shop_id)))
  GROUP BY ii.name, (date_trunc('month'::text, (i.date)::timestamp with time zone));
CREATE VIEW public.monthly_expenses_breakdown_by_category AS
 SELECT c.id AS category_id,
    c.name,
    sub.month,
    sub.sum
   FROM (( SELECT ii.category_id,
            (date_trunc('month'::text, (i.date)::timestamp with time zone))::date AS month,
            sum((ii.cost * ii.quantity)) AS sum
           FROM (public.invoice_items ii
             JOIN public.invoices i ON ((i.id = ii.invoice_id)))
          GROUP BY ii.category_id, ((date_trunc('month'::text, (i.date)::timestamp with time zone))::date)) sub
     JOIN public.categories c ON ((c.id = sub.category_id)));
CREATE VIEW public.monthly_expenses_breakdown_by_shop AS
 SELECT s.id AS shop_id,
    s.name,
    sub.month,
    sub.sum
   FROM (( SELECT i.shop_id,
            (date_trunc('month'::text, (i.date)::timestamp with time zone))::date AS month,
            sum((ii.cost * ii.quantity)) AS sum
           FROM (public.invoice_items ii
             JOIN public.invoices i ON ((i.id = ii.invoice_id)))
          GROUP BY i.shop_id, ((date_trunc('month'::text, (i.date)::timestamp with time zone))::date)) sub
     JOIN public.shops s ON ((s.id = sub.shop_id)));
CREATE VIEW public.monthly_running_total AS
 SELECT d.date,
    COALESCE(sum(ii2.cost), (0)::numeric) AS sum
   FROM ((( SELECT (date.date)::date AS date
           FROM generate_series((( SELECT min(invoices.date) AS min
                   FROM public.invoices))::timestamp with time zone, (CURRENT_DATE)::timestamp with time zone, '1 day'::interval) date(date)) d
     LEFT JOIN ( SELECT i.date,
            sum((ii_1.cost * ii_1.quantity)) AS cost
           FROM (public.invoice_items ii_1
             JOIN public.invoices i ON ((i.id = ii_1.invoice_id)))
          GROUP BY i.date) ii ON ((ii.date = d.date)))
     LEFT JOIN ( SELECT i.date,
            sum((ii_1.cost * ii_1.quantity)) AS cost
           FROM (public.invoice_items ii_1
             JOIN public.invoices i ON ((i.id = ii_1.invoice_id)))
          GROUP BY i.date) ii2 ON (((ii2.date <= d.date) AND (ii2.date >= date_trunc('month'::text, (d.date)::timestamp with time zone)))))
  GROUP BY d.date
  ORDER BY d.date;
CREATE TABLE public.products (
    id integer NOT NULL,
    name text NOT NULL,
    ean_code integer
);
CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;
CREATE VIEW public.shop_popularity AS
SELECT
    NULL::integer AS id,
    NULL::text AS name,
    NULL::bigint AS times_visited,
    NULL::numeric AS items_bought,
    NULL::timestamp with time zone AS month;
CREATE SEQUENCE public.shops_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.shops_id_seq OWNED BY public.shops.id;
CREATE SEQUENCE public.subcategories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE public.subcategories_id_seq OWNED BY public.categories.id;
ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.subcategories_id_seq'::regclass);
ALTER TABLE ONLY public.category_groups ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);
ALTER TABLE ONLY public.invoice_items ALTER COLUMN id SET DEFAULT nextval('public.expenses_id_seq'::regclass);
ALTER TABLE ONLY public.invoices ALTER COLUMN id SET DEFAULT nextval('public.invoices_id_seq'::regclass);
ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);
ALTER TABLE ONLY public.shops ALTER COLUMN id SET DEFAULT nextval('public.shops_id_seq'::regclass);
ALTER TABLE ONLY public.category_groups
    ADD CONSTRAINT categories_name_key UNIQUE (name);
ALTER TABLE ONLY public.category_groups
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT expenses_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.shops
    ADD CONSTRAINT shops_name_key UNIQUE (name);
ALTER TABLE ONLY public.shops
    ADD CONSTRAINT shops_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.categories
    ADD CONSTRAINT subcategories_name_key UNIQUE (name);
ALTER TABLE ONLY public.categories
    ADD CONSTRAINT subcategories_pkey PRIMARY KEY (id);
CREATE OR REPLACE VIEW public.shop_popularity AS
 SELECT s.id,
    s.name,
    count(*) AS times_visited,
    sum(i.item_count) AS items_bought,
    date_trunc('month'::text, (i.date)::timestamp with time zone) AS month
   FROM (public.shops s
     JOIN ( SELECT i_1.id,
            i_1.file,
            i_1.date,
            i_1.shop_id,
            i_1.created_at,
            i_1.updated_at,
            count(*) AS item_count
           FROM (public.invoices i_1
             JOIN public.invoice_items ii ON ((ii.invoice_id = i_1.id)))
          GROUP BY i_1.id) i ON ((i.shop_id = s.id)))
  GROUP BY s.id, (date_trunc('month'::text, (i.date)::timestamp with time zone));
CREATE TRIGGER set_public_invoice_items_updated_at BEFORE UPDATE ON public.invoice_items FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_invoice_items_updated_at ON public.invoice_items IS 'trigger to set value of column "updated_at" to current timestamp on row update';
CREATE TRIGGER set_public_invoices_updated_at BEFORE UPDATE ON public.invoices FOR EACH ROW EXECUTE FUNCTION public.set_current_timestamp_updated_at();
COMMENT ON TRIGGER set_public_invoices_updated_at ON public.invoices IS 'trigger to set value of column "updated_at" to current timestamp on row update';
ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT expenses_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT expenses_subcategory_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_shop_id_fkey FOREIGN KEY (shop_id) REFERENCES public.shops(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
ALTER TABLE ONLY public.categories
    ADD CONSTRAINT subcategories_category_id_fkey FOREIGN KEY (category_group_id) REFERENCES public.category_groups(id) ON UPDATE RESTRICT ON DELETE RESTRICT;
