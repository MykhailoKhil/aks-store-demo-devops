# Use the existing product-service image as base
FROM ghcr.io/azure-samples/aks-store-demo/product-service:latest

# Add a proper health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget -q --spider http://localhost:3002/health || exit 1

