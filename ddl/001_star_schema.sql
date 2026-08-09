-- ============================================
-- Modelo Estrela — Cidadania Espanhola
-- ============================================

-- DIMENSÃO: Consulado
CREATE TABLE IF NOT EXISTS dim_consulado (
    id_consulado    SERIAL PRIMARY KEY,
    nome_consulado  TEXT NOT NULL UNIQUE
);

-- DIMENSÃO: Anexo
CREATE TABLE IF NOT EXISTS dim_anexo (
    id_anexo        SERIAL PRIMARY KEY,
    categoria_anexo TEXT NOT NULL UNIQUE
);

-- DIMENSÃO: Situação
CREATE TABLE IF NOT EXISTS dim_situacao (
    id_situacao     SERIAL PRIMARY KEY,
    descricao       TEXT NOT NULL UNIQUE
);

-- DIMENSÃO: Tempo (uma linha por data, facilita agregação no BI)
CREATE TABLE IF NOT EXISTS dim_tempo (
    id_tempo        SERIAL PRIMARY KEY,
    data            DATE NOT NULL UNIQUE,
    ano             INT NOT NULL,
    mes             INT NOT NULL,
    nome_mes        TEXT NOT NULL,
    trimestre       INT NOT NULL
);

-- FATO: Processo
CREATE TABLE IF NOT EXISTS fato_processo (
    id_processo             SERIAL PRIMARY KEY,
    codigo_processo         TEXT NOT NULL UNIQUE,   -- identificador original vindo da planilha
    id_consulado_origem     INT REFERENCES dim_consulado(id_consulado),
    id_consulado_processamento INT REFERENCES dim_consulado(id_consulado),
    id_anexo                INT REFERENCES dim_anexo(id_anexo),
    id_situacao             INT REFERENCES dim_situacao(id_situacao),
    id_tempo_entrada        INT REFERENCES dim_tempo(id_tempo),
    id_tempo_atualizacao    INT REFERENCES dim_tempo(id_tempo),
    dias_em_espera          INT,
    finalizado              BOOLEAN DEFAULT FALSE,
    criado_em               TIMESTAMP DEFAULT NOW(),
    atualizado_em           TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_fato_situacao ON fato_processo(id_situacao);
CREATE INDEX IF NOT EXISTS idx_fato_consulado_origem ON fato_processo(id_consulado_origem);
CREATE INDEX IF NOT EXISTS idx_fato_anexo ON fato_processo(id_anexo);
