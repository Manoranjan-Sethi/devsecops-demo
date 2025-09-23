# Build stage
# Using a specific, pinned version for better reproducibility and security
FROM node:20.10.0-alpine3.18 AS build

# Set working directory
WORKDIR /app

# Copy package files first to leverage Docker's layer caching
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci

# Copy all source files
COPY . .

# Build the application
RUN npm run build

# Production stage
# Use a hardened, non-root user image like `nginxinc/nginx-unprivileged` for enhanced security.
FROM nginxinc/nginx-unprivileged:alpine-slim

# Copy the built application from the 'build' stage
COPY --from=build /app/dist /usr/share/nginx/html

# Copy the custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose the port (8080 is the default for unprivileged Nginx images)
EXPOSE 80

# The default user is already set to `nginx` in the base image,
# which is a good security practice. We don't need to specify `USER nginx`.

# Define the command to run the container
CMD ["nginx", "-g", "daemon off;"]