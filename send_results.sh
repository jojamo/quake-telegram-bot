#!/bin/bash

PATH='/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin'

BUCKET='YOUR-BUCKET-NAME'
SNS='YOUR-SNS-TOPIC-ARN'

JSON='quake-match-results.json'
RESULTS='quake-match-results.txt'

cd /home/ubuntu/nquakesv

FINDER=(`find /home/ubuntu/nquakesv/ktx/demos -maxdepth 1 -name "*.txt"`)

if [ ${#FINDER[@]} -gt 0 ]; then
    echo "Found file, pushing results"

    # move to demos folder
    cd ktx/demos

    # Change demo file into the name format we need
    mv "$FINDER" "$JSON"
    touch $RESULTS

    COUNT=$(jq '.players | length' $JSON)
    let "COUNT-=1"
    i=0
    while [ $i -le $COUNT ]
    do
        DATA=$(cat $JSON | jq --arg i $i '.players[$i|tonumber].name')
        echo "Player $i" >> $RESULTS
        echo "Name: $DATA" >> $RESULTS

        DATA=$(cat $JSON | jq --arg i $i '.players[$i|tonumber].stats.frags')
        echo "Frags: $DATA" >> $RESULTS

        DATA=$(cat $JSON | jq --arg i $i '.players[$i|tonumber].stats.deaths')
        echo "Deaths: $DATA" >> $RESULTS

        echo "" >> $RESULTS
        let "i+=1"
    done

    # push results to s3
    aws s3 cp "$RESULTS" s3://$BUCKET/

    # cleanup
    rm $RESULTS
    rm $JSON

    # Signal lambda to execute
    aws sns publish --topic-arn "$SNS" --region eu-west-1 --message go
else
    echo "No server recording found, exiting"
    exit
fi
