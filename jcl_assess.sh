OPT=$@
DO_NOT_COPY=0

for sth in $OPT
do
	if [ `echo $sth | grep -cP '(-|--)do-not-copy'` -eq 1 ]; then
		echo "DO_NOT_COPY_MODE enabled"
		DO_NOT_COPY=1;
	fi
done

if [ $DO_NOT_COPY -eq 0 ]; then
	DIRS="result cobol copy include jcl proc parm cics bms"
	for sth in $DIRS
	do
		if [ ! -d $sth ]; then
			mkdir $sth
		fi
		rm -f ./$sth/* 2>/dev/null
	done
else
	if [ ! -d "result" ]; then
		mkdir result
	fi
	rm -f ./result/* 2>/dev/null
fi

time perl jcl_assess.pl $OPT
RETCODE=$?
if [ $RETCODE -ne 0 ]; then
	exit $RETCODE
fi

for sth in `ls ./result/*.lst`
do
	sort -u ${sth} > ${sth}.bak
	mv ${sth}.bak ${sth}
done
sh result_split.sh
#sh make_tree.sh > ./result/tree.lst
