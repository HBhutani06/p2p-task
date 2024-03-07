# Stage 1: Build the Go binary
FROM golang:1.20-alpine AS build

# Set the working directory
WORKDIR /app

# Copy the source code into the container
COPY main.go .

# Build the Go app
RUN go build -o myapp main.go

# Stage 2: Final lightweight container
FROM alpine:edge

# Create a non-root user
RUN adduser -D -g '' myuser

WORKDIR /app

# Copy the Pre-built binary file from the previous stage
COPY --from=build /app/myapp .

RUN apk --no-cache add ca-certificates tzdata

# Expose port 3000
EXPOSE 3000

# Add a health check
HEALTHCHECK --interval=30s --timeout=5s CMD wget --quiet --tries=1 --spider http://localhost:3000/ || exit 1

# Switch to non-root user
USER myuser

# Entry point
ENTRYPOINT ["/app/myapp"]
