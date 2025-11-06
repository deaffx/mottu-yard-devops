#!/bin/bash
# ============================================================================
# Script de Limpeza - Azure Infrastructure
# Mottu Yard - Sprint 4
# ============================================================================
# Este script remove TODOS os recursos criados na Azure
# ============================================================================

set -e

# CONFIGURAÇÕES - Use os mesmos valores do provision.sh

RESOURCE_GROUP="rg-mottu-yard"

# FUNÇÕES

print_step() {
    echo ""
    echo "$1"
}

print_info() {
    echo "ℹ️  $1"
}

print_success() {
    echo "✅ $1"
}

print_error() {
    echo "❌ Erro: $1"
    exit 1
}

# VALIDAÇÕES

print_step "⚠️  ATENÇÃO - REMOÇÃO DE RECURSOS"

if ! command -v az &> /dev/null; then
    print_error "Azure CLI não encontrado"
fi

if ! az account show &> /dev/null; then
    print_error "Você não está logado no Azure. Execute: az login"
fi

SUBSCRIPTION_NAME=$(az account show --query name -o tsv)
print_info "Subscription: $SUBSCRIPTION_NAME"

# Verificar se Resource Group existe
if ! az group show --name $RESOURCE_GROUP &> /dev/null; then
    print_error "Resource Group '$RESOURCE_GROUP' não existe"
fi

# Listar recursos
echo ""
echo "📋 Recursos que serão deletados:"
az resource list --resource-group $RESOURCE_GROUP --query "[].{Name:name, Type:type}" -o table

# Confirmar remoção
echo ""
read -p "Deseja DELETAR todos estes recursos? (y/n): " confirm
if [ "$confirm" != "y" ]; then
    echo "Operação cancelada."
    exit 0
fi

# REMOVER RESOURCE GROUP (remove tudo dentro dele)

print_step "Removendo Resource Group"

print_info "Deletando Resource Group '$RESOURCE_GROUP' (pode levar alguns minutos)..."

az group delete \
    --name $RESOURCE_GROUP \
    --yes \
    --no-wait

print_success "Resource Group deletado com sucesso!"

echo ""
echo "✅ Limpeza concluída!"
echo ""
echo "Todos os recursos foram removidos:"
echo "  - Azure Container Registry (ACR)"
echo "  - PostgreSQL Flexible Server"
echo "  - Azure Container Instance (ACI)"
echo "  - Resource Group"
