# -----------------------------
# Build stage
# -----------------------------
FROM node:18-alpine AS builder

WORKDIR /app

# Install pnpm via corepack (Node 16.19+/18+ has corepack preinstalled)
RUN corepack enable && corepack prepare pnpm@8.15.3 --activate

# Copy package definition and install deps with pnpm
COPY package.json ./
COPY pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# Copy source and build
COPY . .
RUN pnpm build

# -----------------------------
# Runner stage
# -----------------------------
FROM node:18-alpine AS runner

WORKDIR /app
ENV NODE_ENV=production
ENV PORT=8080

# Install pnpm runtime (small footprint)
RUN corepack enable && corepack prepare pnpm@8.15.3 --activate

# Copy the minimal standalone output
COPY --from=builder /app/.next/standalone ./

# Copy static assets from .next/static
COPY --from=builder /app/.next/static ./.next/static

EXPOSE 8080
CMD ["node", "server.js"] 