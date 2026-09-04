SELECT 'profiles' as tabela, COUNT(*) as total FROM public.profiles
UNION ALL
SELECT 'tb_ocont', COUNT(*) FROM public.tb_ocont
UNION ALL
SELECT 'modules', COUNT(*) FROM public.modules
UNION ALL
SELECT 'permissions', COUNT(*) FROM public.permissions;