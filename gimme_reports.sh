#!/bin/bash
START=$(date +%s);
readableTime=$(date "+%Y-%m-%d %H:%M:%S");

echo "############################################################";
echo "gimme jira epics at $readableTime";

# urlEntities="$HOME/java/apache-tomcat-8.0.28/webapps/report/entities.json";
urlEntities="/storage/featurecompletion/entities.json";
# echo $entities;

# echo $(cat entities.json | jq '.[0].epic' );

# echo $(jq '.[].epic' entities.json);

while read -r anID; do
	jql=$(/usr/local/bin/jq '.['$anID'].jql' -r $urlEntities);
  epiclink=$(/usr/local/bin/jq '.['$anID'].epiclink' -r $urlEntities);
  epicdefinition="https://unleashedsoftware.atlassian.net/rest/api/2/search?jql=issue=$epiclink";
	url="https://unleashedsoftware.atlassian.net/rest/api/2/search?jql=$jql&fields=status&maxResults=1000";
	# echo $url;
  # 'Authorization:Basic XXXXXXXXXXXXXXXXXXXXXXXX'
	results=$(curl -s -H "Authorization: Basic XXXXXXXXXXXXXXXXXXXXXXXX" -X GET -H "Content-Type: application/json" $url)
  epicdetails=$(curl -s -H "Authorization: Basic XXXXXXXXXXXXXXXXXXXXXXXX" -X GET -H "Content-Type: application/json" $epicdefinition)
  fullname=$(echo $epicdetails |/usr/local/bin/jq .issues[].fields.reporter.displayName)
  dueDate=$(echo $epicdetails |/usr/local/bin/jq .issues[].fields.duedate)
  trimResults=$(echo $results |/usr/local/bin/jq .issues[].fields.status.name)
	echo $trimResults > $anID'.json';
    echo -n "*";
    openIssue=$(cat $anID'.json' | tr -s '\"' '\n' | grep -c 'Open' );
    todoIssue=$(cat $anID'.json' | tr -s '\"' '\n' | grep -c 'To Do' );
    reopIssue=$(cat $anID'.json' | tr -s '\"' '\n' | grep -c 'Reopened' );
    awaiIssue=$(cat $anID'.json' | tr -s '\"' '\n' | grep -c 'Awaiting' );
    inprIssue=$(cat $anID'.json' | tr -s '\"' '\n' | grep -c 'In Progress' );
    toreIssue=$(cat $anID'.json' | tr -s '\"' '\n' | grep -c 'To Review' );
    inreIssue=$(cat $anID'.json' | tr -s '\"' '\n' | grep -c 'In Review' );
    toteIssue=$(cat $anID'.json' | tr -s '\"' '\n' | grep -c 'To Test' );
    inteIssue=$(cat $anID'.json' | tr -s '\"' '\n' | grep -c 'In Testing' );
    torelIssue=$(cat $anID'.json' | tr -s '\"' '\n' | grep -c 'To Release' );
    closIssue=$(cat $anID'.json' | tr -s '\"' '\n' | grep -c 'Closed' );

    total=$(echo $results | python -mjson.tool | grep "total"); 

	response="[
    {
    \"label\": \"Open\",
    \"value\": $openIssue,
    \"color\":\"red\",
    \"fullname\":$fullname,
    \"duedate\":$dueDate,
    $total
    },              
    {
  \"label\": \"Todo\",
    \"value\" : $todoIssue,
    \"color\" : \"red\",
    \"fullname\":$fullname,
    \"duedate\":$dueDate,
     $total
    },              
    {
  \"label\": \"Reopened\",
    \"value\" : $reopIssue,
    \"color\" : \"DarkRed\",
    \"fullname\":$fullname,
    \"duedate\":$dueDate,
     $total
    },              
    {
  \"label\": \"Awaiting\",
    \"value\" : $awaiIssue,
    \"color\" : \"yellow\",
    \"fullname\":$fullname,
    \"duedate\":$dueDate,
     $total
    },              
    {
  \"label\": \"In Progress\",
    \"value\" : $inprIssue,
    \"color\" : \"Gold\",
    \"fullname\":$fullname,
    \"duedate\":$dueDate,
     $total
    },              
    {
  \"label\": \"To Review\",
    \"value\" : $toreIssue,
    \"color\" : \"Orange\",
    \"fullname\":$fullname,
    \"duedate\":$dueDate,
     $total
    },              
    {
  \"label\": \"In Review\",
    \"value\" : $inreIssue,
    \"color\" : \"Orange\",
    \"fullname\":$fullname,
    \"duedate\":$dueDate,
     $total
    },              
    {
  \"label\": \"To Test\",
    \"value\" : $toteIssue,
    \"color\" : \"DarkOrange\",
    \"fullname\":$fullname,
    \"duedate\":$dueDate,
     $total
    },              
    {
  \"label\": \"In Testing\",
    \"value\" : $inteIssue,
    \"color\" : \"DarkOrange\",
    \"fullname\":$fullname,
    \"duedate\":$dueDate,
     $total
    },              
    {
  \"label\": \"To Release\",
    \"value\" : $torelIssue,
    \"color\" : \"LimeGreen\",
    \"fullname\":$fullname,
    \"duedate\":$dueDate,
     $total
    },              
    {
  \"label\": \"Closed\",
    \"value\" : $closIssue,
    \"color\" : \"LimeGreen\",
    \"fullname\":$fullname,
    \"duedate\":$dueDate,
     $total
    }
]";



    echo $response > $anID'.json';
    echo -n "* ";
	# echo ;

	# echo $results > '$anID.json';
done < <(/usr/local/bin/jq '.[].id' -r $urlEntities)

# echo $response;

# test1time=$(curl -H "Authorization:$authorization" -H "Accept:application/json" "http://$host:$port/httpAuth/app/rest/builds/$test1id" | jsawk 'return this.finishDate');

# https://unleashedsoftware.atlassian.net/rest/api/2/search?jql= &fields=key,status&maxResults=1000

END=$(date +%s);
DIFF=$(( $END - $START ));
printf "\nEnd Parsing, it took $DIFF seconds.\n";
echo "############################################################";
