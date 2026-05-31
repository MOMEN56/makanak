# App Remote Config Setup

هذا الملف يشرح إعداد جدول `app_remote_config` في Supabase وكيفية اختبار ميزة
Force Update وMaintenance Mode وSoft Update محليًا بدون أي مفاتيح سرية داخل
الكود.

## Supabase SQL

```sql
create extension if not exists pgcrypto;

create table if not exists public.app_remote_config (
  id uuid primary key default gen_random_uuid(),
  platform text not null check (platform in ('android', 'ios')),
  min_supported_version text not null,
  latest_version text,
  blocked_versions jsonb not null default '[]'::jsonb,
  maintenance_mode boolean not null default false,
  force_update_message text not null,
  soft_update_message text,
  maintenance_message text not null,
  update_url text not null,
  is_active boolean not null default true,
  created_at timestamptz not null default timezone('utc', now()),
  updated_at timestamptz not null default timezone('utc', now())
);

create unique index if not exists app_remote_config_one_active_per_platform_idx
  on public.app_remote_config (platform)
  where is_active = true;

create or replace function public.set_app_remote_config_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = timezone('utc', now());
  return new;
end;
$$;

drop trigger if exists app_remote_config_set_updated_at
  on public.app_remote_config;

create trigger app_remote_config_set_updated_at
before update on public.app_remote_config
for each row
execute function public.set_app_remote_config_updated_at();

alter table public.app_remote_config enable row level security;

revoke all on table public.app_remote_config from anon, authenticated;
grant select on table public.app_remote_config to anon, authenticated;

drop policy if exists "app_remote_config_read_active_rows"
  on public.app_remote_config;

create policy "app_remote_config_read_active_rows"
on public.app_remote_config
for select
to anon, authenticated
using (is_active = true);
```

## Example Rows

استبدلي `update_url` برابط المتجر الصحيح الخاص بتطبيقك:

```sql
insert into public.app_remote_config (
  platform,
  min_supported_version,
  latest_version,
  blocked_versions,
  maintenance_mode,
  force_update_message,
  soft_update_message,
  maintenance_message,
  update_url,
  is_active
)
values
  (
    'android',
    '1.0.0',
    '1.0.1',
    '["0.9.0"]'::jsonb,
    false,
    'يرجى تحديث التطبيق للاستمرار.',
    'يوجد إصدار أحدث من التطبيق.',
    'التطبيق تحت الصيانة حاليًا. حاول مرة أخرى لاحقًا.',
    'https://play.google.com/store/apps/details?id=com.example.app',
    true
  ),
  (
    'ios',
    '1.0.0',
    '1.0.1',
    '[]'::jsonb,
    false,
    'يرجى تحديث التطبيق للاستمرار.',
    'يوجد إصدار أحدث من التطبيق.',
    'التطبيق تحت الصيانة حاليًا. حاول مرة أخرى لاحقًا.',
    'https://apps.apple.com/app/id000000000',
    true
  )
on conflict do nothing;
```

إذا كان عندك صف قديم لنفس المنصة، عدّلي `is_active` بدل إضافة صف نشط جديد.

## Local Testing Steps

1. افتحي `pubspec.yaml` وعدّلي `version` إلى النسخة التي تريدين اختبارها.
2. شغّلي `flutter pub get` ثم أعيدي بناء التطبيق بالكامل.
3. نفّذي SQL أعلاه في Supabase SQL Editor.
4. حدّثي صف المنصة الحالية فقط (`android` أو `ios`) حسب السيناريو المطلوب.
5. أغلقي التطبيق تمامًا ثم شغّليه من جديد، لأن فحص الـ remote config يتم مرة
   واحدة فقط في بداية كل تشغيل.

## Test Scenarios

### Scenario A: Normal startup

- `pubspec.yaml` version = `1.0.0+1`
- `min_supported_version = 1.0.0`
- `blocked_versions = []`
- `maintenance_mode = false`
- Expected: التطبيق يفتح بشكل طبيعي.

### Scenario B: Force update بسبب الحد الأدنى

- `pubspec.yaml` version = `1.0.0+1`
- `min_supported_version = 1.0.1`
- Expected: شاشة Force Update تظهر ولا يمكن تجاوزها.

### Scenario C: Force update بسبب blocked version

- `pubspec.yaml` version = `1.0.0+1`
- `blocked_versions = ["1.0.0"]`
- Expected: شاشة Force Update تظهر ولا يمكن تجاوزها.

### Scenario D: Maintenance mode

- `maintenance_mode = true`
- Expected: شاشة الصيانة تظهر مع زر إعادة المحاولة.

### Scenario E: Soft update

- `pubspec.yaml` version = `1.0.0+1`
- `min_supported_version = 1.0.0`
- `latest_version = 1.0.1`
- Expected: نافذة Soft Update تظهر مرة واحدة فقط في بداية التشغيل، وزر
  `لاحقًا` يكمل الدخول للتطبيق.

## Offline and Failure Behavior

- إذا فشل طلب Supabase أو انتهت مهلة الـ 5 ثوانٍ:
  يتم استخدام آخر config ناجح محفوظ محليًا إن وجد.
- إذا لم توجد نسخة محفوظة:
  التطبيق يكمل بشكل طبيعي.
- لا يتم حظر المستخدم فقط بسبب مشكلة شبكة أو مشكلة خادم.
