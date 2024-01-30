#!/bin/bash

# Basically doing the opposite of the `save` script

# Reading the entries of the register
# this command produces an array of JSON entries
readarray entries < <(yq -o=j -I=0 '.[]' files/register.yaml)

for entry in "${entries[@]}"
do
    # Extracting the current entry's directory
    dir=$(echo "${entry}" | yq '.directory' -)

    # Reading the files of the current entry
    readarray files < <(echo "$entry" | yq -o=j -I=0 '.files[]' -)
    for file in "${files[@]}"
    do
        # Extracting the source
        src=$(echo "${file}" | var="${dir}" yq '.s = "files/" + env(var) |
            with(select(.label != null);
                    .s = "files/" + env(var) + "/" + .label) | .s + "/."' -)

        # Extracting the destination
        dest=$(echo "${file}" | yq '.location' -)
        dest=${dest//\~/${HOME}}

        # Checking if the destination exists
        if ! [[ -d ${dest} ]]
        then
            echo "Making ${dest}..."
            mkdir "${dest}"
        fi

        echo "Copying ${src} to ${dest}"
        cp -rt ${dest} ${src}
    done
done
