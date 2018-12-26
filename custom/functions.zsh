# Hide desktop icons
function hide() { 
	defaults write com.apple.finder CreateDesktop false
	killall Finder
}

# Unhide desktop icons
function unhide(){
	defaults write com.apple.finder CreateDesktop true
	killall Finder
}

# Create a new directory and enter it
function mkd() {
	mkdir -p "$@" && cd "$_";
}

# Determine size of a file or total size of a directory
function fs() {
	if du -b /dev/null > /dev/null 2>&1; then
		local arg=-sbh;
	else
		local arg=-sh;
	fi
	if [[ -n "$@" ]]; then
		du $arg -- "$@";
	else
		du $arg .[^.]* *;
	fi;
}

# Run `dig` and display the most useful info
function digga() {
	dig +nocmd "$1" any +multiline +noall +answer;
}

# `s` with no arguments opens the current directory in Sublime Text, otherwise
# opens the given location
function s() {
	if [ $# -eq 0 ]; then
		subl .;
	else
		subl "$@";
	fi;
}

# `v` with no arguments opens the current directory in Vim, otherwise opens the
# given location
function v() {
	if [ $# -eq 0 ]; then
		vim .;
	else
		vim "$@";
	fi;
}

function count_files() {
  find ./ -type f | wc -l
}

function spoof_mac() {
  sudo ifconfig en0 ether f4:$((RANDOM%10))f:24:07:ee:$((RANDOM%89 + 10))
}

function dip() {
  docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$@"
}

### Docker Management ###
function drl(){
	for i in $(seq 1 $1); do docker rm $(docker ps -lq); done
}

function dl(){
	docker logs $1
}

function dla(){
	for id in $(docker ps -aq -n $1); do dl $id; done
}

### Localstack || Kinesis | Lambda | SNS | DynamoDB ###

function reload_executer() {
#	read -p "Please provide a 10 digit phone number to use on local:" phone
#	read -p "Please provide a valid email to use on local:" email

	delete_lambda "$1Executer"
	package_lambda "$1Executer"
	create_lambda "$1Executer" $2,LOCAL_PHONE=8317893159,LOCAL_EMAIL=james@endpointclosing.com,NODE_ENV=development
	subscribe_to_sns_topic "$1Executer" local-events
}

function reload_validator() {
	delete_lambda "$1Validator"
	package_lambda "$1Validator"
	create_lambda "$1Validator" $2
	toggle_stream $1
	create_ddb_stream_to_lambda_mapping $1
}

function delete_lambda() {
	awslocal lambda delete-function --function-name=$1
}

function package_lambda() {
	npm run copyLib && npm i && zip -r $1.zip .
}

function create_lambda() {
	awslocal lambda create-function --function-name=$1 --runtime=nodejs8.10 --role=arn:aws:iam:local --handler=index.lambda_handler --zip-file=fileb://$1.zip --environment Variables="{NODE_ENV=development,AUTH0_AES=gatsby$2}"
}

function toggle_stream() {
	disable_stream $1
	enable_stream $1
}

function disable_stream() {
	awslocal dynamodb update-table --table-name development.$1 --stream-specification '{ "StreamEnabled": false }'
}

function enable_stream() {
	 awslocal dynamodb update-table --table-name development.$1 --stream-specification '{ "StreamEnabled": true, "StreamViewType": "NEW_AND_OLD_IMAGES" }'
}

function create_ddb_stream_to_lambda_mapping() {
	awslocal lambda create-event-source-mapping --function-name "$1Validator" --event-source $(create_ddb_stream_arn $1)	--batch-size 100 --starting-position TRIM_HORIZON
}

function create_ddb_stream_arn() {
	echo "$(create_kinesis_stream_arn_prefix):stream/__ddb_stream_development.$1"
}

function create_kinesis_stream_arn_prefix() {
	echo arn:aws:kinesis:us-west-2:000000000000
}

function subscribe_to_sns_topic() {
	awslocal sns subscribe --topic-arn "$(create_sns_topic_arn_prefix)local-events" --protocol lambda --notification-endpoint "$(create_lambda_arn_prefix)$1"
}

function create_sns_topic_arn_prefix() {
	echo arn:aws:sns:us-east-1:123456789012:
}

function create_lambda_arn_prefix() {
	echo arn:aws:lambda:us-west-2:000000000000:function:
}

function unsubscribe_from_sns() {
	awslocal sns unsubscribe --subscription-arn $1
}

function list_subscriptions() {
	awslocal sns list-subscriptions
}

function list_functions() {
	awslocal lambda list-functions
}

function items_in_table(){
	awslocal dynamodb describe-table --table-name "development.$1" | grep ItemCount | sed 's/[^0-9]*//g'
}

function create_sns_topic(){
	awslocal sns create-topic --name $1
}