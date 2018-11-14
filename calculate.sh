re='^[0-9]+$'
ctr=0
tick=1
if [ $# == 0 ]; then
echo "Enter the argument for POOL ID ! "

elif ! [[ $1 =~ $re ]] ; then
   echo "error: Its not a POOL ID " >&2; exit 1
else

for j in `sudo ceph df | awk '{print$2}'`
do
	if [ $j == $1 ]; then
	pool1=$1
	echo $pool1

	SIZE=0

	for i in `sudo ceph pg dump | awk '$1 ~ /^'$pool1'./'  | awk '{print$1}'`
	do
		primary_osd_num="$(sudo ceph pg $i query | grep \"up_primary\" | head -n 1  | awk -F ":" '{print $2}' | awk -F " " '{print $1}' | awk -F "," '{print $1}')"
		IP="$(sudo ceph osd find $primary_osd_num | grep ip | awk 'BEGIN{FS=" "} {print $2}' | cut -d':' -f1| tr -d \")"
		h="_head"
		size_pg="$(ssh $IP sudo du -bs /var/lib/ceph/osd/ceph-$primary_osd_num/current/$i$h | awk 'BEGIN{FS=" "} {print $1}')"
		SIZE=$[SIZE + size_pg]
	done
	ctr=$[ctr + tick]
	echo $SIZE bytes
	
	fi

done
fi
if [ $ctr == 0 ] ; then
echo "Pool does not exist "
fi

