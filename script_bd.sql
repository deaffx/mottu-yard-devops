-- ============================================================================
-- MOTTU YARD - Database Schema
-- Sistema de Gerenciamento de Pátio de Motos
-- ============================================================================

-- ============================================================================
-- Tabela: usuarios
-- Descrição: Armazena dados dos usuários autenticados via GitHub OAuth2
-- ============================================================================
CREATE TABLE usuarios (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255),
    name VARCHAR(255),
    avatar_url VARCHAR(500),
    role VARCHAR(20) NOT NULL DEFAULT 'OPERADOR',
    perfil_confirmado BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_role CHECK (role IN ('OPERADOR', 'MECANICO'))
);

COMMENT ON TABLE usuarios IS 'Usuários do sistema autenticados via GitHub OAuth2';
COMMENT ON COLUMN usuarios.id IS 'Identificador único do usuário';
COMMENT ON COLUMN usuarios.username IS 'Nome de usuário do GitHub (único)';
COMMENT ON COLUMN usuarios.email IS 'Email do usuário obtido do GitHub';
COMMENT ON COLUMN usuarios.name IS 'Nome completo do usuário do GitHub';
COMMENT ON COLUMN usuarios.avatar_url IS 'URL da foto do perfil do GitHub';
COMMENT ON COLUMN usuarios.role IS 'Papel do usuário: OPERADOR ou MECANICO';
COMMENT ON COLUMN usuarios.perfil_confirmado IS 'Indica se o usuário confirmou seu papel no sistema';
COMMENT ON COLUMN usuarios.created_at IS 'Data de criação do registro';
COMMENT ON COLUMN usuarios.updated_at IS 'Data da última atualização';

-- ============================================================================
-- Tabela: patios
-- Descrição: Armazena informações dos pátios onde as motos ficam estacionadas
-- ============================================================================
CREATE TABLE patios (
    id BIGSERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    endereco VARCHAR(255) NOT NULL,
    capacidade_maxima INTEGER NOT NULL CHECK (capacidade_maxima > 0),
    latitude DECIMAL(10, 7),
    longitude DECIMAL(10, 7),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE patios IS 'Pátios de estacionamento de motos';
COMMENT ON COLUMN patios.id IS 'Identificador único do pátio';
COMMENT ON COLUMN patios.nome IS 'Nome do pátio';
COMMENT ON COLUMN patios.endereco IS 'Endereço completo do pátio';
COMMENT ON COLUMN patios.capacidade_maxima IS 'Número máximo de motos que o pátio suporta';
COMMENT ON COLUMN patios.latitude IS 'Latitude da localização do pátio';
COMMENT ON COLUMN patios.longitude IS 'Longitude da localização do pátio';
COMMENT ON COLUMN patios.created_at IS 'Data de criação do registro';
COMMENT ON COLUMN patios.updated_at IS 'Data da última atualização';

-- ============================================================================
-- Tabela: motos
-- Descrição: Armazena informações das motos gerenciadas no sistema
-- ============================================================================
CREATE TABLE motos (
    id BIGSERIAL PRIMARY KEY,
    modelo VARCHAR(50) NOT NULL,
    placa VARCHAR(10) UNIQUE NOT NULL,
    marca VARCHAR(30) NOT NULL,
    ano_fabricacao INTEGER NOT NULL CHECK (ano_fabricacao > 1900),
    cor VARCHAR(20),
    quilometragem INTEGER DEFAULT 0 CHECK (quilometragem >= 0),
    status_moto VARCHAR(30) NOT NULL DEFAULT 'PARA_REGULARIZAR',
    patio_atual_id BIGINT NOT NULL REFERENCES patios(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_placa_format CHECK (
        placa ~ '^[A-Z]{3}[0-9][A-Z][0-9]{2}$' OR 
        placa ~ '^[A-Z]{3}[0-9]{4}$'
    ),
    CONSTRAINT chk_status_moto CHECK (
        status_moto IN ('PARA_REGULARIZAR', 'PARA_MANUTENCAO', 'NA_OFICINA', 'PARA_ALUGAR')
    )
);

COMMENT ON TABLE motos IS 'Motos gerenciadas no sistema';
COMMENT ON COLUMN motos.id IS 'Identificador único da moto';
COMMENT ON COLUMN motos.modelo IS 'Modelo da moto (ex: CB 300F)';
COMMENT ON COLUMN motos.placa IS 'Placa única da moto (formato antigo ABC1234 ou Mercosul ABC1D23)';
COMMENT ON COLUMN motos.marca IS 'Marca da moto (ex: Honda, Yamaha)';
COMMENT ON COLUMN motos.ano_fabricacao IS 'Ano de fabricação da moto';
COMMENT ON COLUMN motos.cor IS 'Cor da moto';
COMMENT ON COLUMN motos.quilometragem IS 'Quilometragem atual da moto';
COMMENT ON COLUMN motos.status_moto IS 'Status atual: PARA_REGULARIZAR, PARA_MANUTENCAO, NA_OFICINA, PARA_ALUGAR';
COMMENT ON COLUMN motos.patio_atual_id IS 'Pátio onde a moto está atualmente';
COMMENT ON COLUMN motos.created_at IS 'Data de criação do registro';
COMMENT ON COLUMN motos.updated_at IS 'Data da última atualização';

-- ============================================================================
-- Tabela: manutencoes
-- Descrição: Armazena registros de manutenções das motos
-- ============================================================================
CREATE TABLE manutencoes (
    id BIGSERIAL PRIMARY KEY,
    moto_id BIGINT NOT NULL REFERENCES motos(id),
    tipo_manutencao VARCHAR(20) NOT NULL,
    status_manutencao VARCHAR(20) NOT NULL DEFAULT 'AGENDADA',
    data_agendada TIMESTAMP,
    data_iniciada TIMESTAMP,
    data_concluida TIMESTAMP,
    descricao TEXT,
    valor_total DECIMAL(10, 2) CHECK (valor_total >= 0),
    pecas_utilizadas TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT chk_tipo_manutencao CHECK (
        tipo_manutencao IN ('PREVENTIVA', 'CORRETIVA', 'REVISAO', 'EMERGENCIAL')
    ),
    CONSTRAINT chk_status_manutencao CHECK (
        status_manutencao IN ('AGENDADA', 'EM_ANDAMENTO', 'CONCLUIDA')
    )
);

COMMENT ON TABLE manutencoes IS 'Manutenções realizadas nas motos';
COMMENT ON COLUMN manutencoes.id IS 'Identificador único da manutenção';
COMMENT ON COLUMN manutencoes.moto_id IS 'Moto que receberá/recebeu a manutenção';
COMMENT ON COLUMN manutencoes.tipo_manutencao IS 'Tipo: PREVENTIVA, CORRETIVA, REVISAO, EMERGENCIAL';
COMMENT ON COLUMN manutencoes.status_manutencao IS 'Status: AGENDADA, EM_ANDAMENTO, CONCLUIDA';
COMMENT ON COLUMN manutencoes.data_agendada IS 'Data agendada para a manutenção';
COMMENT ON COLUMN manutencoes.data_iniciada IS 'Data de início da manutenção';
COMMENT ON COLUMN manutencoes.data_concluida IS 'Data de conclusão da manutenção';
COMMENT ON COLUMN manutencoes.descricao IS 'Descrição detalhada da manutenção';
COMMENT ON COLUMN manutencoes.valor_total IS 'Valor total gasto na manutenção';
COMMENT ON COLUMN manutencoes.pecas_utilizadas IS 'Lista de peças utilizadas';
COMMENT ON COLUMN manutencoes.created_at IS 'Data de criação do registro';
COMMENT ON COLUMN manutencoes.updated_at IS 'Data da última atualização';

-- ============================================================================
-- Índices para otimização de consultas
-- ============================================================================
CREATE INDEX idx_manutencoes_moto ON manutencoes(moto_id);
CREATE INDEX idx_manutencoes_status ON manutencoes(status_manutencao);
CREATE INDEX idx_manutencoes_data_agendada ON manutencoes(data_agendada);
CREATE INDEX idx_manutencoes_tipo ON manutencoes(tipo_manutencao);

COMMENT ON INDEX idx_manutencoes_moto IS 'Índice para busca rápida de manutenções por moto';
COMMENT ON INDEX idx_manutencoes_status IS 'Índice para filtrar manutenções por status';
COMMENT ON INDEX idx_manutencoes_data_agendada IS 'Índice para ordenação por data agendada';
COMMENT ON INDEX idx_manutencoes_tipo IS 'Índice para filtrar por tipo de manutenção';

-- ============================================================================
-- Dados iniciais (opcional - para demonstração)
-- ============================================================================
-- Inserir pátio exemplo
INSERT INTO patios (nome, endereco, capacidade_maxima, latitude, longitude) 
VALUES 
    ('Pátio Central', 'Av. Paulista, 1000 - São Paulo/SP', 50, -23.5610, -46.6565),
    ('Pátio Norte', 'Rua das Flores, 200 - São Paulo/SP', 30, -23.5501, -46.6334);

-- Nota: Usuários serão criados automaticamente via OAuth2 GitHub no primeiro login
-- Nota: Para popular mais dados, use a aplicação após deployment
