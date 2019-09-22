#!/bin/bash
FILES="./posts/*.md"
PUBLIC_DIR="public"
links=()

mkdir -p $PUBLIC_DIR

generate_new_file_name () {
  local filename=${1##*/}
  local basename=${filename%.*}
  echo "$2_$basename.html"
}

generate_html () {
  local file
  for file in $FILES
  do
    local metadata=$(pandoc --template=metadata.pandoc-tpl $file)
    local date=$(echo -ne $metadata | jq -r .date)
    local title=$(echo -ne $metadata | jq -r .title)
    local new_file_name=$(generate_new_file_name $file $date)

    echo "Processing $file -> ./$PUBLIC_DIR/$new_file_name"

    pandoc --to=html5 --standalone --output=./$PUBLIC_DIR/$new_file_name $file

    links+=( "\n<li><a href=\"./$new_file_name\">$title</a></li>" )

  done
}

generate_index () {
  local index="./$PUBLIC_DIR/index.html"
  touch $index
  echo "Processing $index"

  echo "<ul>" > $index
  echo -ne "${links[@]}" | sort -r >> $index
  echo "</ul>" >> $index
  pandoc --to=html5 --standalone --metadata pagetitle="Whiteboard" --output=$index $index
}

generate_html
generate_index

