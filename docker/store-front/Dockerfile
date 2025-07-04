# Use the existing store-front image as base
FROM ghcr.io/azure-samples/aks-store-demo/store-front:latest

# Add a proper health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD wget -q --spider http://localhost:8080/health || exit 1

