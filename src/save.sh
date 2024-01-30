#!/bin/bash

# Reading the entries of the register
# this command produces an array of JSON entries
readarray entries < <(yq -o=j -I=0 '.[]' files/register.yaml)

for entry in "${entries[@]}"
do
    # Extracting the current directory
    dir=$(echo "${entry}" | yq '.directory' -)
    if ! [[ -d files/"${dir}" ]]
    then
        echo "Making ${dir}..."
        mkdir files/"${dir}"
    fi

    # Reading the files of the current entry
    readarray files < <(echo "$entry" | yq -o=j -I=0 '.files[]' -)
    for file in "${files[@]}"
    do
        # Extracting the source files
        # this command uses the if yq 'syntax'
        # if a pattern is present we use it, otherwise we use a glob
        src=$(echo "${file}" | yq '.s = .location + "/*" |
            with(select(.pattern != null);
                    .s = .location + "/" + .pattern) | .s' -)
        # Extracting the destinations
        # if no label is provided we use the base directory
        # otherwise we use the label as a subdir
        dest=$(echo "${file}" | var="${dir}" yq '.d = "files/" + env(var) |
            with(select(.label != null);
                    .d = "files/" + env(var) + "/" + .label) | .d' -)
        if ! [[ -d "${dest}" ]]  # Creating the subdirs if needed
        then
            echo "Making ${dest}..."
            mkdir "${dest}"
        fi

        # Copying the files
        echo "Copying ${src} to ${dest}..."
        cp -r -t "${dest}" ${src//\~/${HOME}}
    done
done
