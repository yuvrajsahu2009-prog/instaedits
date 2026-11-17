# Turn on sign-in and cloud sync

The site is static on GitHub Pages, so this setup uses Supabase Auth, Postgres, and Storage. The browser receives only the Supabase project URL and publishable/anon key. Database row-level security limits writes to the single admin email you configure.

## 1. Create the Supabase project and admin account

1. Create a Supabase project.
2. In **Authentication → Users**, create your admin account with your email and a strong password. Mark the account confirmed if Supabase offers that option. Keep public sign-ups disabled.
3. In **Project Settings → API**, copy the Project URL and the publishable key (or legacy anon key). Never use a `service_role` or secret key in the website.

## 2. Create the protected data table and media bucket

1. Open **SQL Editor** in Supabase.
2. In [supabase-setup.sql](supabase-setup.sql), replace every occurrence of `admin@example.com` with the admin account email.
3. Run the SQL.

The public site can read the single site-content row. Only the configured Auth email can insert or update it and upload or delete media. The media bucket is public so the public website can display uploaded assets; do not store private files there.

## 3. Configure the website

Edit [supabase-config.js](supabase-config.js) and set:

- `supabaseUrl` to your Project URL.
- `supabaseAnonKey` to your publishable/anon key.
- `adminEmail` to the exact email used in the SQL policy.

These are browser-visible values. Do not add a service role key, database password, or other secret to this file.

## 4. Deploy the connected files

Upload `index.html`, `admin.html`, `login.html`, `site-cloud.js`, `supabase-config.js`, and this guide to the same published folder in your GitHub Pages repository. The login page links to this guide until the backend is configured. `supabase-setup.sql` is for setup and does not need to be published.

Open `login.html` beside your deployed `index.html`, sign in, and manage content. The first authorized admin visit seeds the cloud row from the starter content if the table is empty. Later edits and media uploads save to Supabase. Visitors read the shared content, and open pages receive updates through Realtime when enabled.
