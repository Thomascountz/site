#!/bin/bash
FILES="./posts/*.md"
PUBLIC_DIR="public"

mkdir -p $PUBLIC_DIR

generate_new_file_name () {
  file=$1;date=$2
  filename=${file##*/}
  basename=${filename%.*}
  echo "$date_${basename}.html"
}

generate_html () {
  for file in $FILES
  do
    date=$(pandoc --template=metadata.pandoc-tpl $file | jq -r .date)
    new_file_name=$(generate_new_file_name $file $date)
    echo "Processing $file -> $generate_new_file_name"
    pandoc --to=html5 --standalone --output=./$PUBLIC_DIR/$new_file_name $file
  done
  count=$(find . -type f -name "*.md" | wc -l)
  echo "Processed $count files"
}

generate_html
