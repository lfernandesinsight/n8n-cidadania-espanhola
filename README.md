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
git clone https://github.com/lfernandesinsight/n8n-cidadania-espanhola.git
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
- Postgres: localhost:5432 (user: `cidadania`, db: `cidadania_dw`)

O schema (modelo estrela) é criado automaticamente na primeira subida do
Postgres, a partir do arquivo `ddl/001_star_schema.sql`.

## Modelo Estrela

**Fato:**
- `fato_processo` — grão: um registro por processo/expediente

**Dimensões:**
- `dim_consulado` — consulado
- `dim_anexo` — categoria do anexo (1 a 5)
- `dim_situacao` — status/situação do processo
- `dim_tempo` — datas de entrada/atualização, para agregação por mês/ano

## Sprints

### Sprint 1 — Setup do ambiente ✅
- Docker Compose com n8n + Postgres + Metabase
- DDL do modelo estrela (`ddl/001_star_schema.sql`)
- Repositório Git criado e versionado (`.gitignore`, `.env.example`)

### Sprint 2 — Conexões e fonte de dados ✅
- Metabase conectado ao Postgres, reconhecendo as 5 tabelas do modelo estrela
- Credencial OAuth2 do Google Sheets configurada no n8n (projeto no Google Cloud Console, consent screen, test user)
- Node "Get row(s) in sheet" lendo a aba "Citas Marcadas" (3187 linhas brutas)

### Sprint 3 — Limpeza dos dados ✅
- Mapeamento completo das colunas da planilha (nome, protocolo, datas, consulado, anexo, situação, espera, notas)
- Code node de limpeza: remove linha de instrução, descarta linhas vazias/lixo, normaliza texto (`empty` → `null`, trim), converte datas para ISO (`yyyy-mm-dd`)
- Resultado: 3187 → 2919 itens válidos

### Sprint 4 — Carga no Data Warehouse (em andamento)
- Nodes Postgres de upsert nas dimensões (`dim_consulado`, `dim_anexo`, `dim_situacao`)
- Node Postgres de insert/upsert em `fato_processo`, resolvendo FKs via lookup nas dimensões
- Popular `dim_tempo` a partir das datas presentes nos dados

### Sprint 5 — Relatórios no Metabase (a fazer)
- Construir dashboards: total de processos, por consulado, por situação, tempo médio de espera
- Explorar tendências por mês/ano usando `dim_tempo`

### Sprint 6 — Agendamento e automação (a fazer)
- Trocar execução manual por Schedule Trigger no n8n
- Validar comportamento de upsert em execuções repetidas (idempotência)