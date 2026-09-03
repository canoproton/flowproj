-- Criar usuário
INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    confirmation_sent_at,
    raw_user_meta_data,
    created_at,
    updated_at
) VALUES (
    '00000000-0000-0000-0000-000000000000',
    gen_random_uuid(),
    'authenticated',
    'authenticated',
    'tst@fp.com',
    crypt('@12345678', gen_salt('bf')),
    NOW(),
    NOW(),
    '{"name":"Teste"}',
    NOW(),
    NOW()
);

-- Verificar
SELECT id, email, email_confirmed_at FROM auth.users WHERE email = 'tst@fp.com';