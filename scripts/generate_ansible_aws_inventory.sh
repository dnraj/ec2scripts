# Script Name: generate_ansible_aws_inventory.sh
# Author: Raj Desikavinayagompillai
# Purpose: Create an ansible host yaml file for AWS hosts for Tag Server-type 
# Prerequisites: AWS cli commands should be working prior to executing this script
mkdir -p ./tmp ./yaml
_AddLocal()
{
LOCAL_IP=`ip a|grep eth0|grep inet|awk ' { print $2}'|cut -d"/" -f1`
echo " [local]" >./yaml/hosts
echo "  "${LOCAL_IP} >>./yaml/hosts
}
_AddAll()
{
APP_TYPE=`aws ec2 describe-instances --filters "Name=tag:Server-type,Values=*" --query 'Reservations[].Instances[].[ Tags[?Key==\`Server-type\`].Value]'  --output text`
for servertype in ${APP_TYPE}
do
echo " [${servertype}]" >./tmp/${servertype}.tmp
SERVERSLIST=`aws ec2 describe-instances --filters "Name=tag:Server-type,Values=${servertype}" --query 'Reservations[].Instances[].[PrivateIpAddress]'  --output text`
for ipaddress in ${SERVERSLIST}
do
echo "  "${ipaddress} ansible_ssh_user=ansible >>./tmp/${servertype}.tmp
done
cp ./tmp/${servertype}.tmp ./yaml/${servertype}.yaml.tmp
cp /dev/null ./tmp/${servertype}.tmp 
done
}
_AddLocal
_AddAll
cat ./yaml/*.yaml.tmp >>./yaml/hosts
cp /dev/null *.yaml.tmp
