create or replace function public.create_order(
  p_shop_id uuid,
  p_address_id uuid,
  p_shipping_price integer,
  p_order_details jsonb
)
returns public.orders
language plpgsql
security definer
set search_path = public, pg_temp
as $function$
declare
  v_user_id uuid := auth.uid();
  v_order public.orders;
  v_primary_product_id uuid;
  v_primary_quantity integer;
  v_items_total integer;
  v_requested_count integer;
  v_matched_count integer;
  v_all_products_available boolean;
  v_normalized_order_details jsonb := '[]'::jsonb;
  v_input_order_details jsonb := coalesce(p_order_details, '[]'::jsonb);
begin
  if v_user_id is null then
    raise exception 'User is not authenticated';
  end if;

  if p_shop_id is null then
    raise exception 'Shop id is required';
  end if;

  if p_address_id is null then
    raise exception 'Address id is required';
  end if;

  if p_shipping_price is null or p_shipping_price < 0 then
    raise exception 'Shipping price cannot be negative';
  end if;

  if jsonb_typeof(v_input_order_details) <> 'array' then
    raise exception 'Order details must be an array';
  end if;

  if jsonb_array_length(v_input_order_details) = 0 then
    raise exception 'Order details cannot be empty';
  end if;

  if exists (
    select 1
    from jsonb_array_elements(v_input_order_details) as item(value)
    where jsonb_typeof(item.value) <> 'object'
      or nullif(trim(item.value ->> 'product_id'), '') is null
      or coalesce(item.value ->> 'quantity', '') !~ '^[1-9][0-9]*$'
      or item.value ->> 'product_id' !~* '^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$'
  ) then
    raise exception 'Order details contain invalid items';
  end if;

  if not exists (
    select 1
    from public.user_addresses
    where id = p_address_id
      and user_id = v_user_id
  ) then
    raise exception 'Address does not belong to current user';
  end if;

  select count(*)::integer
  into v_requested_count
  from jsonb_array_elements(v_input_order_details);

  select
    requested_items.product_id,
    requested_items.quantity
  into
    v_primary_product_id,
    v_primary_quantity
  from (
    select
      item.ordinality,
      (item.value ->> 'product_id')::uuid as product_id,
      (item.value ->> 'quantity')::integer as quantity
    from jsonb_array_elements(v_input_order_details) with ordinality as item(value, ordinality)
  ) as requested_items
  order by requested_items.ordinality
  limit 1;

  with requested_items as (
    select
      item.ordinality,
      (item.value ->> 'product_id')::uuid as product_id,
      (item.value ->> 'quantity')::integer as quantity
    from jsonb_array_elements(v_input_order_details) with ordinality as item(value, ordinality)
  ),
  matched_items as (
    select
      requested_items.ordinality,
      requested_items.product_id,
      requested_items.quantity,
      products.shop_id,
      products.name,
      coalesce(products.description, '') as description,
      coalesce(products.image_url, '') as image_url,
      products.price,
      products.in_stock,
      products.stock_quantity,
      products.is_visible
    from requested_items
    join public.products
      on products.id = requested_items.product_id
     and products.shop_id = p_shop_id
  )
  select
    count(*)::integer,
    coalesce(bool_and(matched_items.is_visible and matched_items.in_stock), false),
    coalesce(sum(matched_items.price * matched_items.quantity), 0)::integer,
    coalesce(
      jsonb_agg(
        jsonb_build_object(
          'product_id', matched_items.product_id,
          'quantity', matched_items.quantity,
          'unit_price', matched_items.price,
          'line_total', matched_items.price * matched_items.quantity,
          'product', jsonb_build_object(
            'id', matched_items.product_id,
            'shop_id', matched_items.shop_id,
            'name', matched_items.name,
            'description', matched_items.description,
            'image_url', matched_items.image_url,
            'price', matched_items.price,
            'in_stock', matched_items.in_stock,
            'stock_quantity', matched_items.stock_quantity,
            'is_visible', matched_items.is_visible
          )
        )
        order by matched_items.ordinality
      ),
      '[]'::jsonb
    )
  into
    v_matched_count,
    v_all_products_available,
    v_items_total,
    v_normalized_order_details
  from matched_items;

  if v_matched_count <> v_requested_count then
    raise exception 'Product is not available for this shop';
  end if;

  if not v_all_products_available then
    raise exception 'Product is hidden or out of stock';
  end if;

  insert into public.orders (
    user_id,
    shop_id,
    user_address_id,
    product_id,
    quantity,
    items_total,
    shipping_price,
    order_details
  )
  values (
    v_user_id,
    p_shop_id,
    p_address_id,
    v_primary_product_id,
    v_primary_quantity,
    v_items_total,
    p_shipping_price,
    v_normalized_order_details
  )
  returning * into v_order;

  return v_order;
end;
$function$;

revoke execute on function public.create_order(uuid, uuid, integer, jsonb) from public;
revoke execute on function public.create_order(uuid, uuid, integer, jsonb) from anon;
grant execute on function public.create_order(uuid, uuid, integer, jsonb) to authenticated;