(() => {
  const config = window.SITE_CONFIG || {};
  const projectUrl = (config.supabaseUrl || '').replace(/\/+$/, '');
  const adminEmail = (config.adminEmail || '').trim().toLowerCase();
  const configured = !!(
    window.supabase &&
    /^https:\/\/[a-z0-9-]+\.supabase\.co$/i.test(projectUrl) &&
    config.supabaseAnonKey && !config.supabaseAnonKey.includes('YOUR_') &&
    adminEmail && !adminEmail.includes('example.com')
  );
  const client = configured
    ? window.supabase.createClient(projectUrl, config.supabaseAnonKey)
    : null;

  window.SITE_CLOUD = {
    configured,
    config: { ...config, supabaseUrl: projectUrl, adminEmail },
    client,
    async loadContent() {
      if (!client) return { data: null, error: new Error('Cloud configuration is missing') };
      const { data, error } = await client
        .from('site_content')
        .select('content')
        .eq('id', 'main')
        .maybeSingle();
      return { data: data?.content || null, error };
    },
    async saveContent(content) {
      if (!client) throw new Error('Cloud configuration is missing');
      const { error } = await client
        .from('site_content')
        .upsert({ id: 'main', content, updated_at: new Date().toISOString() }, { onConflict: 'id' });
      if (error) throw error;
    },
    async uploadMedia(file) {
      if (!client) throw new Error('Cloud configuration is missing');
      const ext = (file.name.split('.').pop() || 'bin').toLowerCase().replace(/[^a-z0-9]/g, '');
      const path = `${crypto.randomUUID()}.${ext}`;
      const { error } = await client.storage.from('site-media').upload(path, file, {
        cacheControl: '3600',
        contentType: file.type || 'application/octet-stream',
        upsert: false
      });
      if (error) throw error;
      return client.storage.from('site-media').getPublicUrl(path).data.publicUrl;
    }
  };
})();
