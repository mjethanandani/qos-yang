#!/bin/bash

for i in yang/*.yang
do
    echo $i
    gsed 's/jhaas at pfrc.org/jhaas at juniper dot net/' < $i >> $i.2
    diff $i $i.2
done

