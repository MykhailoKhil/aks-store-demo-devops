# Use the existing order-service image as base
FROM ghcr.io/azure-samples/aks-store-demo/order-service:latest

# Add a proper health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget -q --spider http://localhost:3000/health || exit 1
