# quake-telegram-bot
Simple quake bot for reporting match results via a telegram group bot for nQuake servers.
Users that join the telegram bot group will receive match results once a match has ended via telegram.

# Example
![image](https://user-images.githubusercontent.com/34740414/116304108-1be92b00-a79a-11eb-93c0-b9505d7be881.png)

# nQuake
- nQuake:         https://www.nquake.com/
- nQuake server:  https://github.com/nQuake/server-linux

# Telegram
- Telegram client: https://telegram.org/

# How it works:
When a match finishes in a nQuake server, a demo is saved to the nquakesv/ktx/demo folder. The script run by the cron job called 'send_results.sh' checks for new demos being added to the demo folder, and if so:
- Parses the <demoname>.txt file and pushes this to a S3 bucket
- Signals a SNS topic to trigger the notification_function lambda
- The 'notification_function' lambda will then take that file from s3 and post it to any telegram chats that are subscribed

# How its made:
The bot is made using telegram & AWS (free tier only)
This project uses AWS features to host the nQuake server and push bot notifications
AWS features used:
  - Lambda
  - SNS
  - S3
  - EC2

# Creating your own bot using this repo:
  - Download Telegram for either Windows, Linux, Andriod, ios, etc...
  - Setup a telegram bot via Botfather: https://core.telegram.org/bots
  - Add the new bot to a chat or group chat
  - Create an AWS Ubuntu EC2 instance with a public facing IP
  - Create an AWS S3 bucket
  - Create an AWS SNS topic
  - Create an AWS lambda function
  - Edit the new lambda function:
      - Insert contents of 'notification_function.py'
      - Replace value of 'BUCKET' with your s3 bucket name
      - Replace value of 'TELE_TOKEN' with your created bots token
      - Replace value of 'CHAT_ID' with the ID of the chat that contains the bot (https://www.wikihow.com/Know-Chat-ID-on-Telegram-on-Android) 
      - Set lambda trigger as your created SNS topic
  - SSH into your new EC2 instance
  - Install the nQuake server: https://github.com/nQuake/server-linux
  - Ensure nQuake server is running and visible via the in-game server browser
  - Clone this repo locally (then ftp the edited files to the EC2 instance)
  - Edit 'send_results.sh': 
      - Replace the value of 'BUCKET' with your S3 bucket name
      - Replace the value of 'SNS' with your created SNS topic's ARN
  - Setup a cron to run 'send_results.sh' periodically (See cron_example.txt)
  - Play a match until end on your nQuake server
  - Observe that the match results are posted to your telegram bot

# Future considerations:
  - If I were to revisit this in future I would automate most of the of the steps above such as: Setting up the AWS environment and creating a bash installation file to prompt the user for required ID's.

  - I would also create a sign-up lambda function that would receive chat_id's and save them to a table. Then modify the notification lambda to send results to a list of chat id's, Because as of right now the notification lambda can only send messages to one chat.
