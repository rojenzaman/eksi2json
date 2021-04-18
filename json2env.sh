#!/bin/bash
[ -x "$(command -v jq)" ] || { echo "jq not found, please install it." ; exit 1 ;}

#REGEX RULE: regex rule to 'bkz's url
foo='href=\\\"\/?q='
bar='href=\\\"https\:\/\/eksisozluk\.com\/?q='

#CREATE LOCAL VALUES
JSON="$1"
AUTHOR="${JSON%.*}"
num_rows=$(jq -r '.profile[].count' $JSON)
ENTRY_COUNT=$num_rows
DATE=$(date +%s)
QUOTE=$(cat $JSON | sed "s/$foo/$bar/g" | jq -r '.profile[].quote | gsub("\\s+";" ";"g") | @base64')
QUOTE_TITLE=$(jq -r '.profile[].quote_title' $JSON)
QUOTE_SLUG=$(echo "$QUOTE_SLUG" | iconv -t ascii//TRANSLIT | sed -r s/[~\^]+//g | sed -r s/[^a-zA-Z0-9]+/-/g | sed -r s/^-+\|-+$//g | tr A-Z a-z)
QUOTE_DATE=$(jq -r '.profile[].quote_date' $JSON)
{ post_year=$(echo "${QUOTE_DATE}" | head -c 10 | awk -v FS=. -v OFS=- '{print $3,$2,$1}') ; post_hour="${QUOTE_DATE: -5}" ; }
QUOTE_DATE_FORMAT="${post_year}T${post_hour}:00+03:00" #convert date: 01.01.1970 00:01 to 1970-01-01T00:01:00+03:00
QUOTE_LINK=$(jq -r '.profile[].quote_link' $JSON)
BADGES=$(cat $JSON | sed "s/$foo/$bar/g" | jq -r '.profile[].badges | gsub("\\s+";" ";"g") | @base64')
_ENTRY_COUNT=$(jq -r '.entries[].title' $JSON | wc -l)
[[ ! $ENTRY_COUNT == $_ENTRY_COUNT ]] && { ENTRY_COUNT=$_ENTRY_COUNT ; num_rows=$_ENTRY_COUNT ; }
AUTHOR_SLUG=$(echo "$AUTHOR" | iconv -t ascii//TRANSLIT | sed -r s/[~\^]+//g | sed -r s/[^a-zA-Z0-9]+/-/g | sed -r s/^-+\|-+$//g | tr A-Z a-z)


#CREATE ARRAY
readarray -t title < <( jq -r '.entries[].title' $JSON)
readarray -t url_slug < <( jq -r '.entries[].title' $JSON | iconv -t ascii//TRANSLIT | sed -r s/[~\^]+//g | sed -r s/[^a-zA-Z0-9]+/-/g | sed -r s/^-+\|-+$//g | tr A-Z a-z)
readarray -t date < <( jq -r '.entries[].date' $JSON)
readarray -t link < <( jq -r '.entries[].link' $JSON)
readarray -t entry < <( cat $JSON | sed "s/$foo/$bar/g" | jq -r '.entries[].entry | gsub("\\s+";" ";"g") |@base64')


#WRITE METADATA
cat > $DATE.ENV <<EOT
#META
AUTHOR="$AUTHOR"
AUTHOR_SLUG=$AUTHOR_SLUG
ENTRY_COUNT=$ENTRY_COUNT
DATE=$DATE
QUOTE="$QUOTE"
QUOTE_TITLE="$QUOTE_TITLE"
QUOTE_DATE="$QUOTE_DATE"
QUOTE_DATE_FORMAT=$QUOTE_DATE_FORMAT
QUOTE_LINK="$QUOTE_LINK"
BADGES="$BADGES"
#EOF META

EOT


#WRITE ENTRIES DATA
for (( i = 0; i < num_rows; i++ )); do
#convert date: 01.01.1970 00:01 to 1970-01-01T00:01:00+03:00
{ post_year=$(echo "${date[$i]}" | head -c 10 | awk -v FS=. -v OFS=- '{print $3,$2,$1}') ; post_hour="${date[$i]: -5}" ; }
DATE_FORMAT="${post_year}T${post_hour}:00+03:00"

cat >> $DATE.ENV <<EOT
title[$i]="${title[$i]}"
url_slug[$i]="${url_slug[$i]}"
date[$i]="${date[$i]}"
date_format[$i]=$DATE_FORMAT
link[$i]="${link[$i]}"
entry[$i]="${entry[$i]}"

EOT
done


#WRITE START DATE
#convert date: 01.01.1970 00:01 to 1970-01-01T00:01:00+03:00
{ post_year="${date[$((ENTRY_COUNT-1))]}" | head -c 10 | awk -v FS=. -v OFS=- '{print $3,$2,$1}' ; post_hour="${date[$((ENTRY_COUNT-1))]: -5}" ; }
DATE_FORMAT="${post_year}T${post_hour}:00+03:00"

cat >> $DATE.ENV <<EOT
START_DATE=$DATE_FORMAT
#EOF FILE
EOT
