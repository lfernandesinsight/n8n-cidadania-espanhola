# Pipeline ETL — Cidadania Espanhola (n8n + Postgres + Metabase)

Projeto de estudo: pipeline que lê dados de uma planilha Google Sheets sobre
cidadania espanhola, limpa e carrega em um Data Warehouse (Postgres, modelo
estrela), e disponibiliza para visualização no Metabase.

## Stack
- **n8n** — orquestração do ETL (Docker local)
- **Postgres** — Data Warehouse, modelo estrela
- **Metabase** — camada de visualização/relatórios

## Setup inicial

```bash
git clone <seu-repo>
cd n8n-cidadania-espanhola
cp .env.example .env
# edite o .env e troque a senha do Postgres
docker compose up -d
```

## Como subir (dia a dia)

```bash
docker compose up -d
```

Serviços disponíveis em:
- n8n: http://localhost:5678
- Metabase: http://localhost:3000
- Postgres: localhost:5432 (user: `cidadania`, senha: `cidadania123`, db: `cidadania_dw`)

O schema (modelo estrela) é criado automaticamente na primeira subida do
Postgres, a partir do arquivo `ddl/001_star_schema.sql`.

## Modelo Estrela

**Fato:**
- `fato_processo` — grão: um registro por processo/expediente

**Dimensões:**
- `dim_consulado` — consulado de origem e de processamento
- `dim_anexo` — categoria do anexo (1 a 5)
- `dim_situacao` — status/situação do processo
- `dim_tempo` — datas de entrada/atualização, para agregação por mês/ano

## Próximos passos

1. Configurar credencial do Google Sheets no n8n (OAuth)
2. Montar o workflow de ETL:
   - Schedule Trigger
   - Google Sheets (leitura)
   - Code node (limpeza: trim, normalização, parse de datas)
   - Code node (mapeamento para dimensões, com lookup/dedup)
   - Postgres node (upsert nas dimensões, depois na fato)
3. Conectar o Metabase ao Postgres (`cidadania_dw`) e montar os relatórios
