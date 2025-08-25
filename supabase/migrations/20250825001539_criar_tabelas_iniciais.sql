-- Tabela 1: Empresas Clientes
CREATE TABLE public.empresas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome TEXT NOT NULL,
    tipo_empresa TEXT,
    plano TEXT DEFAULT 'Básico'
);

-- Tabela 2: Setores da Empresa
CREATE TABLE public.setores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    empresa_id UUID REFERENCES public.empresas(id) ON DELETE CASCADE,
    nome TEXT NOT NULL
);

-- Tabela 3: Cargos da Empresa
CREATE TABLE public.cargos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    empresa_id UUID REFERENCES public.empresas(id) ON DELETE CASCADE,
    nome TEXT NOT NULL
);

-- Tabela 4: Perfis de Usuários (Gestores e Colaboradores)
CREATE TABLE public.perfis (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    auth_uid UUID REFERENCES auth.users(id) ON DELETE CASCADE UNIQUE,
    empresa_id UUID REFERENCES public.empresas(id) ON DELETE CASCADE,
    nome TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'colaborador', -- "gestor" ou "colaborador"
    setor_id UUID REFERENCES public.setores(id),
    cargo_id UUID REFERENCES public.cargos(id)
);

-- Tabela 5: Categorias de Risco (Dados Fixos)
CREATE TABLE public.categorias (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome TEXT NOT NULL UNIQUE
);

-- Tabela 6: Vetores de Risco
CREATE TABLE public.vetores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    categoria_id UUID REFERENCES public.categorias(id),
    nome TEXT NOT NULL
);

-- Tabela 7: Fatores de Risco (Dados Fixos da Metodologia)
CREATE TABLE public.fatores_def (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    sigla TEXT NOT NULL UNIQUE, -- P, I, V, G, U, T, Atr, Mot, Dep
    rotulo_publico TEXT NOT NULL,
    peso NUMERIC NOT NULL
);

-- Tabela 8: Análises de Risco
CREATE TABLE public.avaliacoes_risco (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    empresa_id UUID REFERENCES public.empresas(id) ON DELETE CASCADE,
    data_inicio TIMESTAMPTZ DEFAULT now() NOT NULL,
    data_fim TIMESTAMPTZ,
    status TEXT NOT NULL DEFAULT 'em_andamento', -- "em_andamento", "concluida"
    nota_global NUMERIC
);

-- Tabela 9: Respostas dos Questionários
CREATE TABLE public.respostas (
    id BIGSERIAL PRIMARY KEY,
    avaliacao_id UUID REFERENCES public.avaliacoes_risco(id) ON DELETE CASCADE,
    perfil_id UUID REFERENCES public.perfis(id) ON DELETE CASCADE,
    vetor_id UUID REFERENCES public.vetores(id),
    fator_id UUID REFERENCES public.fatores_def(id),
    valor_1a5 NUMERIC NOT NULL
);

-- Tabela 10: Índices Calculados
CREATE TABLE public.indices (
    id BIGSERIAL PRIMARY KEY,
    avaliacao_id UUID REFERENCES public.avaliacoes_risco(id) ON DELETE CASCADE,
    categoria_id UUID REFERENCES public.categorias(id),
    vetor_id UUID REFERENCES public.vetores(id), -- NULL para o índice da categoria
    indice_0a100 NUMERIC NOT NULL
);

-- Tabela 11: Cursos (Catálogo Global)
CREATE TABLE public.cursos (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    nome TEXT NOT NULL,
    descricao TEXT,
    duracao_min INT
);

-- Tabela 12: Aulas de cada Curso
CREATE TABLE public.aulas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    curso_id UUID REFERENCES public.cursos(id) ON DELETE CASCADE,
    titulo TEXT NOT NULL,
    url_video TEXT,
    ordem INT
);

-- Tabela 13: Trilhas de Capacitação
CREATE TABLE public.trilhas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    empresa_id UUID REFERENCES public.empresas(id) ON DELETE CASCADE,
    nome TEXT NOT NULL,
    descricao TEXT,
    origem TEXT NOT NULL, -- "manual" ou "automatica"
    status TEXT NOT NULL -- "pendente", "ativa", "inativa"
);

-- Tabela 14: Junção de Trilhas e Cursos
CREATE TABLE public.trilhas_cursos (
    trilha_id UUID REFERENCES public.trilhas(id) ON DELETE CASCADE,
    curso_id UUID REFERENCES public.cursos(id) ON DELETE CASCADE,
    ordem INT,
    PRIMARY KEY (trilha_id, curso_id)
);

-- Tabela 15: Alertas de Segurança
CREATE TABLE public.alertas (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    empresa_id UUID REFERENCES public.empresas(id) ON DELETE CASCADE,
    tipo TEXT NOT NULL, -- "GAP", "Risco Crítico", "Trilha Atrasada"
    risco_detectado TEXT,
    categoria TEXT,
    descricao TEXT,
    status TEXT NOT NULL -- "pendente", "em_progresso", "resolvido"
);