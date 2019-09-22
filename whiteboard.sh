#!/bin/bash
FILES="./_posts/*.md"
PUBLIC_DIR="public"
POST_CSS="../_styles/post.css"
links=()

mkdir -p $PUBLIC_DIR

generate_new_file_name () {
  local filename=${1##*/}
  local basename=${filename%.*}
  echo "$2_$basename.html"
}

generate_html () {
  local file
  local metadata
  local date
  local title
  local new_file_name

  for file in $FILES
  do
    metadata=$(pandoc --template=metadata.pandoc-tpl "$file")
    date=$(echo -ne "$metadata" | jq -r .date)
    title=$(echo -ne "$metadata" | jq -r .title)
    new_file_name=$(generate_new_file_name "$file" "$date")

    echo "Processing $file -> ./$PUBLIC_DIR/$new_file_name"

    pandoc --to=html5 --standalone --css=$POST_CSS --output=./$PUBLIC_DIR/"$new_file_name" "$file"

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
  pandoc --to=html5 --standalone --metadata title="Thomas Countz" --metadata pagetitle="Thomas Countz" --output=$index $index
}

generate_html
generate_index

