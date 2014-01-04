#Author: Raj Desikavinayagompillai
#Created: January 3, 2014
#Purpose: Query A tag across all instances and check if a version (example tag) tag is not having values and dump all tag outputs in a file
#
Tag_Name=Version
Access_key=Acesskey
Access_key_value="AccessKeyValue"
for Region_name in `ec2-describe-regions  -O ${Access_key}   -W ${Access_key_value}  |awk ' { print $2}'`
do
echo "Processing Region" ${Region_name}
ec2-describe-instances -O ${Access_key}   -W ${Access_key_value}  -F "instance-state-code=16" --region ${Region_name} |grep -v "RESERVATION" |grep INSTANCE >>ec4tag_step1.out.${Region_name}
cat  ec4tag_step1.out.${Region_name} |sort -n |uniq >ec4tag_step1.out.uniq.${Region_name}
cat ec4tag_step1.out.uniq.${Region_name}|awk ' { print $2 }' |sort -n >ec4tag_step1.out.uniq.sort.${Region_name}

touch ec4tag_step2.out.${Region_name}
while read line
do
Instance_name=`echo $line|awk ' {print $2}'`
Region_name=`echo $line|sed -e "s/+0000/+0000#/g" |cut -d"#" -f2|awk ' {print $1}'|sort -n |awk ' { print $2,$1}'|sed -e "s/1[a-z]/1/g" -e "s/2[a-z]/2/g" |sed -e "s/ //g"`
ec2-describe-tags  -O ${Access_key}   -W ${Access_key_value}  --region ${Region_name} --filter "resource-type=instance" --filter "resource-id=$Instance_name" --filter "key=$Tag_Name"    >>ec4tag_step2.out.${Region_name}
done <ec4tag_step1.out.uniq.${Region_name}
cat ec4tag_step2.out.${Region_name} |awk ' { print $3 }' |sort -n >ec4tag_step3.out.${Region_name}
diff ec4tag_step1.out.uniq.sort.${Region_name} ec4tag_step3.out.${Region_name} >ec4tag_diff.out.${Region_name}
echo "Done Region" ${Region_name}
done
