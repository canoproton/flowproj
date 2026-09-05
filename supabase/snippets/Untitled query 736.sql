SELECT
    conname,
    conrelid::regclass AS table_name,
    confrelid::regclass AS foreign_table
FROM pg_constraint
WHERE conname = 'fk_profiles_user_id';