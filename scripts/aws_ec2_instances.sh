#/bin/bash
# Author: Raj DN
# Date: April 10, 2020
# Purpose : To print instance details and tag of all instances for a given region

# for REGION in $REGION_NAME 
# Use the above two if you want to do all regions and use the following only for these two regions
show_help()
 {
cat << EOF
Usage: ./aws_ec2_instances.sh  AWS_KEY AWS_SECRET <REGIONNAME-Optional> --tag <TagName>
Example: 
         1. Specific to a region 
                    ./aws_ec2_instances.sh  AWS_KEY AWS_SECRET us-east-2  --tag Owner 
         2. For all regions
                    ./aws_ec2_instances.sh  AWS_KEY AWS_SECRET   --tag Owner 
         3. For verbosity
                    ./aws_ec2_instances.sh  AWS_KEY AWS_SECRET  --tag Owner --v 
         4. For help
                    ./aws_ec2_instances.sh  AWS_KEY AWS_SECRET   --h 

To run the above script use the usage and replace AWS_KEY with an AWS key and AWS_SECRET with a value within doublequotes 

-h          display this help and exit
-v          verbose mode. Can be used multiple times for increased verbosity.
-tag        displays the tag information in addition to instance information
EOF
}
_nodebug()
{
echo id,instance_type,launch_time,${TAG}
#for REGION in us-east-2 us-west-2 us-east-1
for REGION in ${REGIONS}
do
#  echo $REGION
  aws ec2 describe-instances  --region=${REGION} --query "Reservations[*].Instances[*].{Id:InstanceId,Instance_type:InstanceType,Launch_time:LaunchTime,Tag_Owner:Tags[?Key=='${TAG}']|[0].Value}"  --output=text|awk 'BEGIN{OFS=",";}    { print $1,$2,$3,$4}'|sed -e "s/,None$/,unknown/g"|sort  -n -k4 -t ','
done
}
_debug()
{
echo "Printing Debug info"
#for REGION in us-east-2 us-west-2 us-east-1
for REGION in ${REGIONS}
do
  aws ec2 describe-instances  --debug --region=${REGION} --query "Reservations[*].Instances[*].{Id:InstanceId,Instance_type:InstanceType,Launch_time:LaunchTime,Tag_${TAG}:Tags[?Key=='$TAG']|[0].Value}"  --output=text|awk 'BEGIN{OFS=",";}    { print $1,$2,$3,$4}'|sed -e "s/,None$/,unknown/g"
done
echo
echo
echo "Printing Outputs"
echo
echo
_nodebug
}
export AWS_ACCESS_KEY_ID=$1
export AWS_SECRET_ACCESS_KEY=$2
REGION_NAME=$3
RGN=`aws ec2 describe-regions --all-regions --query "Regions[].{Name:RegionName}" --output text|grep -v "me-south-1"|grep -v "ap-east-1" |tr ["\n"] [" "]  `
#echo $RGN
region_flag='False'
for region in $RGN
do
if [ $REGION_NAME == $region ]
then
   region_flag='True'
fi
done

if [ $region_flag == 'True' ]
then
   REGIONS=$REGION_NAME     
   shift
else
   REGIONS=$RGN    
#   REGIONS="us-east-1"

fi
unset DEBUG TAG
shift
shift
while :
do
  case $1 in
    -h|--h)  show_help;exit 0 ;;
    -v|--v) DEBUG='True'; shift 1 ;;
    -tag|--tag)  TAG="$2"; shift 2 ;;
    --) shift; break ;;
    "") shift; break ;;
  esac
done
DEBUG_FLAG=`echo debug:$DEBUG `


if [ $DEBUG_FLAG == "debug:" ]
then
    _nodebug
    exit 0
else
    _debug
    exit 0
fi

