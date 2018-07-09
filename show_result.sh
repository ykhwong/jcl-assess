echo "[jcl]"
cat ./config/jcl.lst | more
echo
read fff
clear
for sth in missing_copy missing_include missing_jcl missing_parm missing_pgm missing_proc
do echo [$sth]
cat ./result/$sth.lst
echo
done | more
