-- ============================================
-- CRIAR USUÁRIO NO AUTH.USERS
-- ============================================
-- Nota: Isso deve ser feito via API do Supabase, não via SQL direto
-- Mas podemos usar a função interna do Supabase

-- Opção 1: Usar a função do Supabase (recomendado)
SELECT supabase.auth.admin_create_user(
    '{
        "email": "tst@fp.com",
        "password": "senha123",
        "email_confirm": true,
        "user_metadata": {"name": "Usuário Teste"}
    }'::jsonb
);

-- Opção 2: Se o usuário já existe mas não está confirmado
UPDATE auth.users 
SET 
    confirmed_at = NOW(),
    email_confirmed_at = NOW(),
    raw_user_meta_data = jsonb_set(
        COALESCE(raw_user_meta_data, '{}'::jsonb),
        '{name}',
        '"Usuário Teste"'
    )
WHERE id = '4ec8b22d-53a2-4737-8920-f0050681aeb3';