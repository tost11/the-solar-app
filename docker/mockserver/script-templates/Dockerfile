FROM nginx:alpine

# Install jq for JSON manipulation during startup
RUN apk add --no-cache jq bash

# Copy startup script
COPY prepare-mocks.sh /docker-entrypoint.d/prepare-mocks.sh
RUN chmod +x /docker-entrypoint.d/prepare-mocks.sh

# Create work directory
RUN mkdir -p /work/templates

# Use custom entrypoint that runs prepare-mocks.sh then starts nginx
ENTRYPOINT ["/docker-entrypoint.d/prepare-mocks.sh"]
