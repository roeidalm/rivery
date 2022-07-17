#!/bin/bash
#TODO: restore the error stop
# set -e
# # keep track of the last executed command
# trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# # echo an error message before exiting
# trap 'echo "\"${last_command}\" command filed with exit code $?."' EXIT

function bytes_for_humans {
    local -i bytes=$1;
    if [[ $bytes -lt 1024 ]]; then
        echo "${bytes}B"
    elif [[ $bytes -lt 1048576 ]]; then
        echo "$(( (bytes + 1023)/1024 ))KiB"
    else
        echo "$(( (bytes + 1048575)/1048576 ))MiB"
    fi
}

if [ $# -eq 0 ]
  then
    echo "please specifide the file name of the protected container"
    exit 1
fi
echo "recive file from the user $1"

# echo "first way:"
echo "save the data for later docker system df"
startpoint=$(docker system df)
echo "$startpoint"

echo "prune containers"
yes | docker container prune

echo "check about running container and the time of them"
echo "run with loop and check the container if them less then hour leave them"
echo "ID | State | Create at | Networks | RunningFor"
thefile=$( docker container ls -a --format "{{.ID}}|{{.State}}|{{.CreatedAt}}|{{.Networks}}|{{.RunningFor}}")
echo "$thefile"
IFS=$'\n' endArray=( $thefile )

for i in "${!endArray[@]}"
do
    echo "i: $i"
    echo "start: ${endArray[i]}"
    IFS=$'|' rowdataStart=( ${endArray[i]} )
    t1=$(date -d "$(echo "${rowdataStart[2]}" | cut -d "+" -f1)" +%s)

    # Date 2 : Current date
    dt2=$(date +%Y-%m-%d\ %H:%M:%S)
    # Compute the seconds since epoch for date 2
    t2=$(date --date="$dt2" +%s)
    
    let "tDiff=$t2-$t1"
    # Compute the approximate hour difference
    let "hDiff=$tDiff/3600"

    if [ "$hDiff" -ge 1 ]
    then
        docker container stop "$(echo "$(echo "${rowdataStart[0]}" | xargs)")" && docker container rm "$(echo "$(echo "${rowdataStart[0]}" | xargs)")"
    fi        

done    


echo "docker prune the volume if there are not in use thay will remmove"
yes | docker volume prune

echo "loop the images and remove it if they not on the list from the file"
yes | docker image prune -a

#TODO: fix the adding running dockers
# IFS=$'\n' dockerImages=( $(docker image ls --format "{{.ID}}|{{.Repository}}:{{.Tag}}") )


# protectedFile=$(cat $1)
# IFS=$'\n' protectedFile+=( $(docker inspect -f '{{.Config.Image}}' $(docker ps -q)) )


# index=0
# for element in "${dockerImages[@]}"
# do

    
#     ((index++))

#     echo "index: $index"
#     echo "element: $element" # | cut -d'|' -f2
#     grepdata="$(echo $element | cut -d'|' -f2)"
#     data="$(echo "$protectedFile"|grep "$grepdata")"
#     echo "data: $data"
#     if [ -z "$data" ] 
#     then docker image rm "$(echo "$(echo "$element" | cut -d'|' -f1)")"
#     fi
#     ((index++))
# done

echo "docker prune the network if there are not in use thay will remmove"
yes | docker network prune

echo "docker prune the Build Cache if there are not in use thay will remmove"
yes | docker builder prune




# # echo "secend way: prune all"
# # echo "save the data for later docker system df"
# # #docker system df

# # echo "docker prune All of the above, in this order: containers, volumes, images"
# # #yes | docker system prune

# # echo "docker prune the Build Cache if there are not in use thay will remmove"
# # #yes | docker builder prune

# # echo "compare the docker system df"
# # #docker system df


# echo "both ways:"
#TODO: restore the remarkes
# echo "run the docker pull for the images are not exist on the docker images after the clean up" 
# index=0
# images=(${protectedFile[@]})
# for image in "${images[@]}"
# do
#     echo "index: $index"
#     echo "$image"
#     ((index=index+1))
#     docker pull "$image"
# done

echo "compare the docker system df"
endpoint=$(docker system df)
echo "$endpoint"

echo "printing the sums"
echo "start:"
echo "$startpoint"
echo "end: "
echo "$endpoint"

#TODO: compare!
echo "comparing!!!!"

IFS=$'\n' startArray=( $startpoint )
IFS=$'\n' endArray=( $endpoint )

for i in "${!startArray[@]}"
do
    echo "i: $i"
    echo "start: ${startArray[i]}"
    echo "end: ${endArray[i]}"
    IFS=$' ' rowdataStart=( ${startArray[i]} )
    IFS=$' ' rowdataEnd=( ${endArray[i]} )
    echo "row data:"
    for j in "${!rowdataStart[@]}"
    do
      
        echo "${rowdataStart[0]}"
        echo "   $(echo "${rowdataStart[1]} - ${rowdataEnd[1]}"  | bc)"      
        # bytes_for_humans ${rowdataStart[3]}
        # bytes_for_humans ${rowdataStart[3]}      
        # if [[ ${rowdataStart[j]} =~ ^-?[0-9]+$ ]]
        # then
        #     # echo "rowdataStart: ${rowdataStart[j]}"
        #     # echo "rowdataEnd: ${rowdataEnd[j]}"
        #     echo -n "   $(echo "${rowdataStart[j]} - ${rowdataEnd[j]}"  | bc)"
        # else
        # #TODO: ignore Bits

        #     echo "rowdataStart: ${rowdataStart[j]}"
        # fi
    done
done
