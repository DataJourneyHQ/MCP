FROM ghcr.io/gleam-lang/gleam:v1.12.0-erlang-alpine

WORKDIR /app/

COPY . ./

RUN gleam deps download \
    && gleam build

# Default to 8080 if unset.
EXPOSE 8080

CMD ["sh", "-lc", "gleam run"]
