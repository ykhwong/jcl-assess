FILES="calltree_missing_copy.lst calltree_missing_include.lst calltree_missing_parm.lst calltree_missing_pgm.lst calltree_missing_proc.lst"

for sth in $FILES
do
NAME=`echo $sth | sed 's/calltree_//'`
cp ./result/$sth ./result/$NAME
perl -pi -e 's/.+ : //g' ./result/$NAME
sort -u ./result/$NAME > ./result/$NAME.bak
mv ./result/$NAME.bak ./result/$NAME
done
