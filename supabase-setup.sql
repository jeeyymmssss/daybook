-- Run this once in Supabase → SQL Editor → New query

create table public.tasks (
  id          text primary key,
  user_id     uuid not null default auth.uid() references auth.users(id) on delete cascade,
  title       text not null,
  date        date not null,
  time        text,
  end_time    text,
  emoji       text,
  tag         text,
  notes       text,
  pinned      boolean not null default false,
  done        boolean not null default false,
  created_at  timestamptz not null default now()
);

-- Row Level Security: each user can only see and change their own tasks
alter table public.tasks enable row level security;

create policy "Read own tasks"   on public.tasks for select using (auth.uid() = user_id);
create policy "Add own tasks"    on public.tasks for insert with check (auth.uid() = user_id);
create policy "Edit own tasks"   on public.tasks for update using (auth.uid() = user_id) with check (auth.uid() = user_id);
create policy "Delete own tasks" on public.tasks for delete using (auth.uid() = user_id);

-- Live sync between devices
alter publication supabase_realtime add table public.tasks;

-- Added for alarms: minutes before the start time to ring (empty = no reminder)
alter table public.tasks add column if not exists remind integer;
