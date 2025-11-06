# Guia: VS Code PostgreSQL Extension

## Instalação

1. No VS Code, abra Extensions (Ctrl+Shift+X)
2. Busque: **PostgreSQL** (by Chris Kolkman)
3. Clique em **Install**

## Conectar ao Banco Azure

1. Clique no ícone **PostgreSQL** na sidebar esquerda
2. Clique em **"+"** (Add Connection)
3. Preencha:
   - **Host**: Veja no `.env` a variável `DB_SERVER_NAME`
   - **Port**: `5432`
   - **Database**: `challenge`
   - **Username**: Veja no `.env` a variável `DB_ADMIN_USER`
   - **Password**: Veja no `.env` a variável `DB_ADMIN_PASSWORD`
   - **SSL**: `Enabled`
4. Clique em **Connect**

## Consultas Rápidas

Após conectar, crie uma **New Query** e execute:

### Verificar tabelas criadas
```sql
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY table_name;
```

### Ver dados
```sql
SELECT * FROM patios;
SELECT * FROM motos;
SELECT * FROM manutencoes;
SELECT * FROM usuarios;
```

### Contar registros
```sql
SELECT 
    (SELECT COUNT(*) FROM patios) as total_patios,
    (SELECT COUNT(*) FROM motos) as total_motos,
    (SELECT COUNT(*) FROM manutencoes) as total_manutencoes,
    (SELECT COUNT(*) FROM usuarios) as total_usuarios;
```

---