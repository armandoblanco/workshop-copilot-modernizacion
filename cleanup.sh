#!/bin/bash
# cleanup.sh — Elimina Resource Groups del taller post-workshop
# Uso: ./cleanup.sh [prefijo]   → elimina solo ese participante
#      ./cleanup.sh             → elimina todos los grupos del taller

set -e
PATTERN="rg-workshop-modernizacion"
PREFIX="${1:-}"

echo "=== Cleanup Workshop Modernización de Apps ==="

if [ -n "$PREFIX" ]; then
  az group delete --name "${PATTERN}-${PREFIX}" --yes --no-wait
  echo "Eliminación iniciada: ${PATTERN}-${PREFIX}"
else
  echo "Grupos encontrados:"
  az group list --query "[?starts_with(name,'${PATTERN}')].{Nombre:name}" -o table
  read -p "¿Confirmas la eliminación de todos? (s/N): " CONFIRM
  if [[ "$CONFIRM" =~ ^[sS]$ ]]; then
    az group list --query "[?starts_with(name,'${PATTERN}')].name" -o tsv | \
      while read -r G; do
        echo "Eliminando: $G"
        az group delete --name "$G" --yes --no-wait
      done
  else
    echo "Operación cancelada."
  fi
fi
