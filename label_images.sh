#!/bin/bash
folder=$1
FILES=$folder/*.jpg

html_content="<html>
<head>
<title>
Google Vision API Results
</title>
<basefont font-family: "Helvetica">
</head>
<body>
<table border="1" cellpadding="10">
"

for f in $FILES
do
    echo "Processing $f file..."
    img_b64=$(base64 $f)
    file_base_name=$(basename $f .jpg)
    file_name=$(basename $f)

    if (( $# < 2 ));
    then
        max_results=5
    else
        max_results=$2
    fi

    json_label="{ 
                    \"requests\":[ 
                        {\"image\": {
                            \"content\":\"$img_b64\"
                        },
                    \"features\":[
                    {
                        \"type\":\"LABEL_DETECTION\",
                        \"maxResults\":${max_results}
                    }
                ]
            }
        ]
    }"

    echo $json_label > json_label_file.txt

    output_file="${file_base_name}_output.txt"

    api_result=$(curl -v -k -s -H "Content-Type: application/json" https://vision.googleapis.com/v1/images:annotate?key=<key> --data-binary @json_label_file.txt | grep 'description\|score')

    api_result=${api_result//\"description\":/\<br>}
    api_result=${api_result//\"score\"/}
    api_result=${api_result//,/}

    html_content+="<tr><td><img src="${file_name}" height="300"></td>"
    html_content+="<td>$api_result</td><tr></tr>"

done

html_content+="
</table>
</body>
</html>"

rm json_label_file.txt
echo $html_content > $folder/images_labelling_results.html
