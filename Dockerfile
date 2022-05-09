FROM golang:alpine3.15

# Create non-root user for security reasons
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser

COPY main.go .
ENTRYPOINT [ "go", "run", "main.go" ]