#!/bin/bash

cd C:/Jenkins/workspace/TrailheadBranchDemo
echo 'Starting file diff from create_changes '
echo 'Creating destructive changes'
sed -n /^D/p diff.txt | sed 's/^..//' | sed /^src/p | sed /^src\\/package\.xml/d > destructive.txt
echo 'Destructive changes created'
echo 'Creating change list'
sed /^D/d diff.txt | sed 's/^..//' | sed /^src/p | sed /^src\\/package\.xml/d | sed 's/.*\ ->\ //' > temp.txt
echo 'Splitting changes'
sed -n '/-meta.xml$/p' temp.txt > meta.txt
sed '/-meta.xml$/d' temp.txt > orig.txt
echo 'Creating pair names'
sed 's/$/-meta.xml/' orig.txt > final.txt
sed 's/.........$//' meta.txt >> final.txt
echo 'Joining changes'
cat temp.txt >> final.txt
echo 'Making unique'
sort -uo final.txt final.txt
echo 'Unique'
cat final.txt
echo 'File diff done.'
echo $1
cat final.txt | xargs -I {} cp --parents {} C:/Jenkins/workspace/deploy
echo 'Changes created.'