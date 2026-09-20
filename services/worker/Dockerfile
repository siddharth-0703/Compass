# Build Stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copy root configurations
COPY package*.json tsconfig.json ./

# Copy packages and services
COPY packages/ ./packages/
COPY services/worker/ ./services/worker/

# Install dependencies
RUN npm install

# Build shared packages
RUN npm run build --workspace=@rural/logger
RUN npm run build --workspace=@rural/types
RUN npm run build --workspace=@rural/database

# Build Worker service
RUN npm run build --workspace=@rural/worker

# Production Stage
FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production

# Copy built assets and dependencies from builder
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/packages ./packages
COPY --from=builder /app/services/worker ./services/worker

# Start the Worker
CMD ["npm", "start", "--workspace=@rural/worker"]
