# --- Build ---
FROM golang:1.25-alpine AS builder

RUN apk add --no-cache git
RUN apk add --no-cache tzdata

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o /app/main ./cmd/api

# --- Runtime ---
FROM alpine:latest
RUN apk --no-cache add ca-certificates tzdata

WORKDIR /app

# Copy the binary
COPY --from=builder /app/main .

# Copy the JSON file from the builder stage
COPY --from=builder /app/firebase-admin.json .

ENV PORT=8080
ENV TZ=Asia/Kolkata

EXPOSE 8080

CMD ["./main"]