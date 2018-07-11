#!/usr/bin/ksh
echo "Creating a tree diagram file in ./result directory... (It may take few minutes)"
LANG=C
BASE_DIR="./structure"
LIST_GRP="calltree_copy.lst calltree_include.lst calltree_parm.lst calltree_pgm.lst calltree_proc.lst"
HOME_DIR=$PWD

rm -rf $BASE_DIR
if [ ! -d $BASE_DIR ]; then
	mkdir $BASE_DIR
fi

for sth in `cat config/jcl.lst`
do
	mkdir "$BASE_DIR/JCL.$sth"
done

TMP_IFS=$IFS
IFS=' '
for sth in $LIST_GRP
do
	TYPE=`echo $sth | sed 's/calltree_//' | sed 's/\.lst//' | awk '{print toupper($0)}'`
	IFS='
'
	for sth2 in `cat ./result/$sth`
	do
		TYPE_FILE="${TYPE}."`echo $sth2 | awk -F' : ' '{print $NF}'`
		if [ `echo $sth2 | grep -cP '^JCL : '` -ne 0 ]; then
			JCL_FILE="JCL."`echo $sth2 | awk -F' : ' '{print $2}'`
			mkdir -p "$BASE_DIR/$JCL_FILE/$TYPE_FILE"
		fi
	done
done

for _ in `seq 2`
do
	IFS='
'
	for sth in `find $BASE_DIR -type d -print`
	do
		BASENAME=`basename $sth`
		TYPE=
		if [ `echo $BASENAME | grep -cP '^COPY.'` -ne 0 ]; then
			TYPE="COPY"
		elif [ `echo $BASENAME | grep -cP '^INCLUDE.'` -ne 0 ]; then
			TYPE="INCLUDE"
		elif [ `echo $BASENAME | grep -cP '^PARM.'` -ne 0 ]; then
			TYPE="PARM"
		elif [ `echo $BASENAME | grep -cP '^PGM.'` -ne 0 ]; then
			TYPE="PGM"
		elif [ `echo $BASENAME | grep -cP '^PROC.'` -ne 0 ]; then
			TYPE="PROC"
		else
			continue
		fi # Finds TYPE from the existing directories

		IFS=' '
		for sth2 in $LIST_GRP
		do
			TYPE2=`echo $sth2 | sed 's/calltree_//' | sed 's/\.lst//' | awk '{print toupper($0)}'`
			IFS='
'
			for sth3 in `grep -P "^${TYPE} : " "./result/$sth2"`
			do
				FIRST=`echo $sth3 | awk -F' : ' '{print $2}'` # TYPE's
				ENDING=`echo $sth3 | awk -F' : ' '{print $NF}'` # TYPE2's
				if [ `echo $BASENAME | grep -cP "${TYPE}.${FIRST}"` -ne 0 ]; then
					mkdir -p "$sth/${TYPE2}.${ENDING}"
				fi
			done
		done
	done
done
IFS=$TMP_IFS

find $BASE_DIR -print | sed -e "s;$BASE_DIR;\.;g;s;[%/]*\/;|__;g;s;__|; |;g" | perl -pe 's/^(\S+)(\|__)/" " x length($1) . $2/gei'
rm -rf $BASE_DIR
