-- Replace admin@example.com with the exact email you create in Supabase Auth.
-- Run this once in Supabase SQL Editor.

create table if not exists public.site_content (
  id text primary key check (id = 'main'),
  content jsonb not null,
  updated_at timestamptz not null default now()
);

alter table public.site_content enable row level security;
revoke all on table public.site_content from public, anon, authenticated;
grant select on table public.site_content to anon, authenticated;
grant insert, update on table public.site_content to authenticated;

drop policy if exists "Public can read site content" on public.site_content;
create policy "Public can read site content"
  on public.site_content for select to anon, authenticated
  using (true);

drop policy if exists "Configured admin can insert site content" on public.site_content;
create policy "Configured admin can insert site content"
  on public.site_content for insert to authenticated
  with check (lower(coalesce((select auth.jwt() ->> 'email'), '')) = lower('claudeuser1344@gmail.com'));

drop policy if exists "Configured admin can update site content" on public.site_content;
create policy "Configured admin can update site content"
  on public.site_content for update to authenticated
  using (lower(coalesce((select auth.jwt() ->> 'email'), '')) = lower('claudeuser1344@gmail.com'))
  with check (lower(coalesce((select auth.jwt() ->> 'email'), '')) = lower('claudeuser1344@gmail.com'));

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'site-media', 'site-media', true, 52428800,
  array['image/jpeg','image/png','image/webp','image/gif','video/mp4','video/webm','video/quicktime']
)
on conflict (id) do update set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "Configured admin uploads site media" on storage.objects;
create policy "Configured admin uploads site media"
  on storage.objects for insert to authenticated
  with check (
    bucket_id = 'site-media' and
    lower(coalesce((select auth.jwt() ->> 'email'), '')) = lower('claudeuser1344@gmail.com')
  );

drop policy if exists "Configured admin updates site media" on storage.objects;
create policy "Configured admin updates site media"
  on storage.objects for update to authenticated
  using (
    bucket_id = 'site-media' and
    lower(coalesce((select auth.jwt() ->> 'email'), '')) = lower('claudeuser1344@gmail.com')
  )
  with check (
    bucket_id = 'site-media' and
    lower(coalesce((select auth.jwt() ->> 'email'), '')) = lower('claudeuser1344@gmail.com')
  );

drop policy if exists "Configured admin deletes site media" on storage.objects;
create policy "Configured admin deletes site media"
  on storage.objects for delete to authenticated
  using (
    bucket_id = 'site-media' and
    lower(coalesce((select auth.jwt() ->> 'email'), '')) = lower('claudeuser1344@gmail.com')
  );

-- Enable live updates when the Supabase Realtime publication is available.
do $$
begin
  if exists (select 1 from pg_publication where pubname = 'supabase_realtime')
     and not exists (
       select 1 from pg_publication_tables
       where pubname = 'supabase_realtime'
         and schemaname = 'public'
         and tablename = 'site_content'
     ) then
    alter publication supabase_realtime add table public.site_content;
  end if;
end $$;
