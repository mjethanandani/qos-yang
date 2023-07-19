#!/bin/sh

#
# Does the user have all the IETF published models.
#
if [ ! -d ../bin/yang-parameters ]; then
   rsync -avz --delete rsync.iana.org::assignments/yang-parameters ../bin/
fi

for i in ../bin/ietf-*\@$(date +%Y-%m-%d).yang
do
    name=$(echo $i | cut -f 1-3 -d '.')
    echo "Validating $name.yang using pyang"
    if test "${name#^example}" = "$name"; then
        response=`pyang --ietf --lint --strict --canonical -p ../bin/yang-parameters  -p ../bin -f tree --max-line-length=72 --tree-line-length=69 $name.yang > $name-tree.txt.tmp`
    else            
        response=`pyang --ietf --strict --canonical -p ../bin/yang-parameters  -p ../bin -f tree --max-line-length=72 --tree-line-length=69 $name.yang > $name-tree.txt.tmp`
    fi
    if [ $? -ne 0 ]; then
        printf "$name.yang failed pyang validation\n"
        printf "$response\n\n"
        echo
	rm ../bin/*-tree.txt.tmp
        exit 1
    fi
    fold -w 71 $name-tree.txt.tmp > $name-tree.txt
done
rm ../bin/*-tree.txt.tmp

for i in ../bin/ietf-*\@$(date +%Y-%m-%d).yang
do
    name=$(echo $i | cut -f 1-3 -d '.')
    echo "Validating $name.yang using yanglint"
    if test "${name#^example}" = "$name"; then
	response=`yanglint -p ../bin/yang-parameters  -p ../bin $name.yang -i`
    fi
    if [ $? -ne 0 ]; then
        printf "$name.yang failed yanglint validation\n"
        printf "$response\n\n"
        echo
        exit 1
    fi
done

for i in ../bin/ietf-*\@$(date +%Y-%m-%d).yang
do
    name=$(echo $i | cut -f 1-3 -d '.')
    echo "Generating abridged tree diagram for $name.yang"
    if test "${name#^example}" = "$name"; then
       response=`pyang --lint --strict --canonical -p ../../yang-parameters -p ../bin -f tree --tree-depth=3 --max-line-length=72 --tree-line-length=69 $name.yang > $name-sub-tree.txt.tmp`
    else            
        response=`pyang --ietf --strict --canonical -p ../bin/yang-parameters -p ../bin -f tree --tree-depth=3 --max-line-length=72 --tree-line-length=69 $name.yang > $name-sub-tree.txt.tmp`
    fi
    if [ $? -ne 0 ]; then
        printf "$name.yang failed generation of sub-tree diagram\n"
        printf "$response\n\n"
        echo
	rm ../bin/*-sub-tree.txt.tmp
        exit 1
    fi
    fold -w 71 $name-sub-tree.txt.tmp > $name-sub-tree.txt
done
rm ../bin/*-sub-tree.txt.tmp

echo "Validating examples"

for i in ../bin/example-comp[a-b]*-*\@$(date +%Y-%m-%d).yang
do
    name=$(echo $i | cut -f 1-3 -d '.')
    echo "Validating $name.yang using pyang"
    if test "${name#^example}" = "$name"; then
        response=`pyang --lint --strict --canonical -p ../bin/yang-parameters  -p ../bin -f tree --max-line-length=72 --tree-line-length=69 $name.yang > $name-tree.txt.tmp`
    else 
        response=`pyang --strict --canonical -p ../bin/yang-parameters  -p ../bin -f tree --max-line-length=72 --tree-line-length=69 $name.yang > $name-tree.txt.tmp`
    fi
    if [ $? -ne 0 ]; then
        printf "$name.yang failed pyang validation\n"
        printf "$response\n\n"
        echo
	rm ../bin/*-tree.txt.tmp
        exit 1
    fi
    fold -w 71 $name-tree.txt.tmp > $name-tree.txt
done
rm ../bin/*-tree.txt.tmp

for i in yang/example-qos-configuration-a.*.*.xml
do
    name=$(echo $i | cut -f 1-3 -d '.')
    echo "Validating $name.xml"
    response=`yanglint -ii -t config -p ../bin/yang-parameters -p ../bin ../bin/ietf-diffserv\@$(date +%Y-%m-%d).yang ../bin/ietf-qos-action\@$(date +%Y-%m-%d).yang ../bin/ietf-traffic-policy\@$(date +%Y-%m-%d).yang ../bin/ietf-scheduler-policy\@$(date +%Y-%m-%d).yang ../bin/yang-parameters/ietf-interfaces@2018-02-20.yang ../bin/yang-parameters/iana-if-type@2021-06-21.yang $name.xml`
    if [ $? -ne 0 ]; then
       printf "failed (error code: $?)\n"
       printf "$response\n\n"
       echo
       exit 1
    fi
done
