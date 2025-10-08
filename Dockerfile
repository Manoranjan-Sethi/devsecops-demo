# Build stage
FROM node:20.10.0-alpine3.18 AS build

WORKDIR /app

# Copy package files first to leverage Docker's layer caching
COPY package.json package-lock.json ./

# Install dependencies clean install
RUN npm ci
COPY . .
RUN npm run build  

# Production stage
# Use a hardened, non-root user image like `nginxinc/nginx-unprivileged` for enhanced security.
FROM nginxinc/nginx-unprivileged:alpine-slim

# Copy the built application from the 'build' stage
COPY --from=build /app/dist /usr/share/nginx/html

# Copy the custom nginx configuration
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose the port (8080 is the default for unprivileged Nginx images)
EXPOSE 8080

# The default user is already set to `nginx` in the base image,
# which is a good security practice. We don't need to specify `USER nginx`.

# Define the command to run the container
CMD ["nginx", "-g", "daemon off;"]