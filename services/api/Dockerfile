# Build Stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copy root configurations
COPY package*.json tsconfig.json ./

# Copy packages and services
COPY packages/ ./packages/
COPY services/api/ ./services/api/

# Install dependencies
RUN npm install

# Build shared packages
RUN npm run build --workspace=@rural/logger
RUN npm run build --workspace=@rural/types
RUN npm run build --workspace=@rural/database
RUN npm run build --workspace=@rural/auth

# Build API service
RUN npm run build --workspace=@rural/api

# Production Stage
FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production

# Copy built assets and dependencies from builder
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/packages ./packages
COPY --from=builder /app/services/api ./services/api

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Start the API
CMD ["npm", "start", "--workspace=@rural/api"]
