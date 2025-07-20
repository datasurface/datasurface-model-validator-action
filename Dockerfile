FROM alpine/git:latest

# Install Docker CLI to run DataSurface container
RUN apk add --no-cache docker-cli

# Copy the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"] 