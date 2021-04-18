# eksi2json

Get all entries and profile data of an eksisozluk.com user as JSON or UNIX env format.

## Usage

First install the dependencies:

```bash
npm install
```

and run:

```bash
node eksi2json.js "username"
```

User data will be saved to the `username.json` file.

## JSON Object Structure

```json
{
  "entries": [
    {
      "title": "",
      "entry": "",
      "date": "",
      "link": ""
    }
  ],
  "profile": [
    {
      "quote": "",
      "quote_title": "",
      "quote_date": "",
      "quote_link": "",
      "badges": "",
      "count": ""
    }
  ]
}
```

## Convert JSON data to UNIX environment file

```bash
json2env.sh username.json
```

and use it:

```bash
. ${epoch}.ENV
```

```bash
for (( i = 0; i < ENTRY_COUNT; i++ )); do
cat <<EOT
${title[$i]}
${url_slug[$i]}
$(echo "${entry[$i]}" | base64 -d)
${link[i]}
${date_format[$i]}
$AUTHOR_SLUG
$AUTHOR


EOT
done
```

### UNIX ENV Structure:

```bash
#META
AUTHOR=""
AUTHOR_SLUG=             
ENTRY_COUNT=  
DATE=          
QUOTE=""
QUOTE_TITLE=""
QUOTE_DATE=""
QUOTE_DATE_FORMAT=                    
QUOTE_LINK=""
BADGES=""
#EOF META

title[i]=""
url_slug[i]=""
date[i]=""
date_format[i]=                    
link[i]=""
entry[i]=""

START_DATE=                    
#EOF FILE
```

## Convert other formats:

 - [eksi2hugo](https://github.com/rojenzaman/eksi2hugo)

## TODO

 - Get twitter user name.
 - Get user uploaded images as link.
 - Get title of "el emeği göz nuru" entries.
