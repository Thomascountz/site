#!/bin/bash
POSTS="./_posts/*.md"
PUBLIC="public"
METADATA_TEMPLATE="metadata.pandoc-tpl"
POST_TEMPLATE="post.pandoc-tpl"
INDEX_TEMPLATE="index.pandoc-tpl"
links=()

mkdir -p $PUBLIC

generate_new_file_name () {
  local filename=${1##*/}
  local basename=${filename%.*}
  echo "$basename.html"
}

generate_html () {
  local file
  local metadata
  local date
  local title
  local new_file_name

  for file in $POSTS
  do
    metadata=$(pandoc --template=$METADATA_TEMPLATE "$file")
    title=$(echo -ne "$metadata" | jq -r .title)
    new_file_name=$(generate_new_file_name "$file")

    echo "Processing $file -> ./$PUBLIC/$new_file_name"

    pandoc --to=html5 --standalone --template=$POST_TEMPLATE --output=./$PUBLIC/"$new_file_name" "$file"

    links+=( "\n<li><a href=\"./$new_file_name\">$title</a></li>" )
  done
}

generate_index () {
  local index="./$PUBLIC/index.html"
  touch $index
  echo "Processing $index"

  echo "<ul>" > $index
  echo -ne "${links[@]}" | sort -r >> $index
  echo "</ul>" >> $index
  pandoc --to=html5 --standalone --metadata title="Thomas Countz" --template=$INDEX_TEMPLATE --output=$index $index
}

generate_html
generate_index

