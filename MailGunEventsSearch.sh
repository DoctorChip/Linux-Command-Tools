#!/usr/bin/env sh

credentials="''"
domain=""

r=$(curl -s --user $credentials -G https://api.eu.mailgun.net/v3/$domain/events --data-urlencode event='rejected')
items=$(echo "${r}" | jq .items)
next=$(echo "${r}" | jq .paging.next? | sed -e 's/^"//' -e 's/"$//')
hasNext=$(echo "${r}" | jq "if (.items[0]) != null then 1 else 0 end")

echo $items >> output.json

true=1
false=0
while [ $hasNext -eq $true ]; do
    echo "Found more..."
    r=$(curl -s --user $credentials -G ${next})
    items=$(echo "${r}" | jq .items)

    next=$(echo "${r}" | jq .paging.next? | sed -e 's/^"//' -e 's/"$//')
    hasNext=$(echo "${r}" | jq "if (.items[0]) != null then 1 else 0 end")

    echo $items >> output.json
done

echo "Found all"
return 0
