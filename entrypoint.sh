#!/bin/sh

cp /config/nitter.conf /src/nitter.conf
cat /src/nitter.conf
echo $NITTER_GUEST_ACCOUNTS > /src/guest_accounts.json

# echo "NITTER_GUEST_ACCOUNTS_URL=$NITTER_GUEST_ACCOUNTS_URL"
# wget -O /src/guest_accounts.json "$NITTER_GUEST_ACCOUNTS_URL" || exit 1

# Redis host and port
MAX_ATTEMPTS=30  # 5 minutes with 10-second intervals
REDIS_HOST="127.0.0.1"
REDIS_PORT=6379

attempt=1
while [ $attempt -le $MAX_ATTEMPTS ]
do
    echo "Checking if Redis is up (Attempt: $attempt)..."
    # Try to ping the Redis server
    if redis-cli -h "$REDIS_HOST" -p "$REDIS_PORT" ping | grep -q "PONG"
    then
        echo "Redis is up! Starting nitter"
        ./nitter
    fi

    # Wait for 10 seconds before retrying
    sleep 10
    attempt=$((attempt+1))
done

echo "Redis did not start within the expected time."
exit 1
