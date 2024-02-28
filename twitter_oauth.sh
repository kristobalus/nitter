#!/bin/bash
# Grab oauth token for use with Nitter (requires Twitter account).
# results: {"oauth_token":"xxxxxxxxxx-xxxxxxxxx","oauth_token_secret":"xxxxxxxxxxxxxxxxxxxxx"}

username=$1
password=$2

if [[ -z "$username" || -z "$password" ]]; then
  echo "needs username and password"
  exit 1
fi

echo "username=$username"
echo "password=$password"

bearer_token='AAAAAAAAAAAAAAAAAAAAAFXzAwAAAAAAMHCxpeSDG1gLNLghVe8d74hl6k4%3DRUMF4xAQLsbeBhTSRrCiQpJtxoGWeyHrDb5te2jpGskWDFW82F'
guest_token=$(curl -s -XPOST https://api.twitter.com/1.1/guest/activate.json -H "Authorization: Bearer ${bearer_token}" -H 'Connection: close' | jq -r '.guest_token')
echo "guest_token=$guest_token"

header=(-H "Authorization: Bearer ${bearer_token}" -H "Content-Type: application/json" -H "User-Agent: TwitterAndroid/10.21.1" -H "X-Guest-Token: ${guest_token}")
echo "header=$header"

task_1=$(curl -si -XPOST 'https://api.twitter.com/1.1/onboarding/task.json?flow_name=login&api_version=1&known_device_token=&sim_country_code=us' "${header[@]}" \
  -d '{"flow_token": null, "input_flow_data": {"country_code": null, "flow_context": {"referrer_context": {"referral_details": "utm_source=google-play&utm_medium=organic", "referrer_url": ""}, "start_location": {"location": "deeplink"}}, "requested_variant": null, "target_user_id": 0}}')
echo "task_1=$task_1"

att=$(sed -En 's/att: (.*)/\1/p' <<< "${task_1}")
echo "att=$att"

flow_token=$(sed -En 's/(.*flow_token.*)/\1/p' <<< "${task_1}" | jq -r .flow_token)
echo "flow_token=$flow_token"

token_2=$(curl -s -XPOST 'https://api.twitter.com/1.1/onboarding/task.json' -H "att: ${att}" "${header[@]}" \
  -d "{\"flow_token\": \"${flow_token}\", \"subtask_inputs\": [{\"enter_text\": {\"suggestion_id\": null, \"text\": \"${username}\", \"link\": \"next_link\"}, \"subtask_id\": \"LoginEnterUserIdentifier\"}]}" | jq -r .flow_token)
echo "token_2=$token_2"

token_3=$(curl -s -XPOST 'https://api.twitter.com/1.1/onboarding/task.json' -H "att: ${att}" "${header[@]}" \
  -d "{\"flow_token\": \"${token_2}\", \"subtask_inputs\": [{\"enter_password\": {\"password\": \"${password}\", \"link\": \"next_link\"}, \"subtask_id\": \"LoginEnterPassword\"}]}" | jq -r .flow_token)
echo "token_3=$token_3"

curl -s -XPOST 'https://api.twitter.com/1.1/onboarding/task.json' -H "att: ${att}" "${header[@]}" \
  -d "{\"flow_token\": \"${token_3}\", \"subtask_inputs\": [{\"check_logged_in_account\": {\"link\": \"AccountDuplicationCheck_false\"}, \"subtask_id\": \"AccountDuplicationCheck\"}]}" | jq -c '.subtasks[0]|if(.open_account) then {oauth_token: .open_account.oauth_token, oauth_token_secret: .open_account.oauth_token_secret} else empty end'
