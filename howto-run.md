fly launch
cat .env | fly secrets import
fly scale count 1
fly deploy --ha=false
fly deploy
