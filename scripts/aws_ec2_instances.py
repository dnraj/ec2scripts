# Author: Raj DN
# Date: April 11, 2020
# Purpose : To print instance details and a given tag for all instances for a given region or all regions
#
# Import the SDK
import boto3
import argparse
import sys
import logging as log
from operator import itemgetter 

# Get the list of all AWS Regions
def RegionsList(AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY):
    Region_list=[]
    ec2_regions = boto3.client('ec2',aws_access_key_id=AWS_ACCESS_KEY_ID,aws_secret_access_key=AWS_SECRET_ACCESS_KEY)
    response_region = ec2_regions.describe_regions()
    for Regions_obj in response_region['Regions']:
          Region_list.append(Regions_obj['RegionName']) 
    return Region_list

def main(argv):
# Process all Arguments
      parser = argparse.ArgumentParser()
      parser.add_argument("AWS_ACCESS_KEY_ID", type=str,  help="aws access id")
      parser.add_argument("AWS_SECRET_ACCESS_KEY", type=str,  help="aws secret access key")
      parser.add_argument("--region", type=str,default="all",  help="aws region")
      parser.add_argument("--tag", type=str,default="Owner",  help="ec2 instance tag default is Owner")
      parser.add_argument("-v","--verbose", action="store_true" ,help="increase output verbosity")
      args = parser.parse_args()
      tag_key=args.tag
      if args.verbose:
         log.basicConfig(format="%(levelname)s: %(message)s", level=log.DEBUG)
         log.info("Verbose output.")
         log.info("Processing arguments .")
# Processing regions info by calling RegionsList
      AWS_ACCESS_KEY_ID=args.AWS_ACCESS_KEY_ID
      AWS_SECRET_ACCESS_KEY=args.AWS_SECRET_ACCESS_KEY
      RegionsList_ids=[]
      if args.region=="all":
         RegionsList_ids=RegionsList(AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY)
      else:
         RegionsList_ids=RegionsList(AWS_ACCESS_KEY_ID,AWS_SECRET_ACCESS_KEY)
         region_check_flag=args.region in RegionsList_ids
         if region_check_flag==True:
            RegionsList_ids=[]
            RegionsList_ids.append(args.region)
         else:
             print(args.region)
             print ("Invalid aws region. Retry again")
             sys.exit(2)
      results=[]
      for region_name_id in RegionsList_ids:
            if args.verbose:
               log.info("Processing region  "+region_name_id )
            ec2_instance = boto3.client('ec2',region_name=region_name_id,aws_access_key_id=AWS_ACCESS_KEY_ID,aws_secret_access_key=AWS_SECRET_ACCESS_KEY)
            response_instance = ec2_instance.describe_instances()
            for reservation in response_instance["Reservations"]:
                for instance in reservation["Instances"]:
                     results_tmp_dict={}
                     tag_key_value=''
#                     print(instance['InstanceId']+","+instance['InstanceType']+','+str(instance['LaunchTime'])+','+tag_key_value)
                     Tag_new_key=[]
                     try: 
                         Tag_new_key=instance['Tags']
                         for i in range(0,len(Tag_new_key)):
                             if Tag_new_key[i]['Key']==tag_key:
                                   tag_key_value=Tag_new_key[i]['Value']
                     except: 
                              tag_key_value=='unknown'
                     if tag_key_value=="":
                        tag_key_value='unknown'
                     results_tmp_dict={"InstanceId": instance['InstanceId'],"InstanceType":instance['InstanceType'],"LaunchTime":str(instance['LaunchTime']),tag_key:tag_key_value}
                     results.append(results_tmp_dict)
                     tag_key_value=''
      if args.verbose:
         log.info("Sorting the results " )
      sorted_results=[]
      sorted_results = sorted(results, key=itemgetter(tag_key),reverse = False) 
      if args.verbose:
         log.info("Print the final results " )
      print("id,instance_type,launch_time,"+tag_key)
      for sorted_results_line in range(0,len(sorted_results)):
          print (sorted_results[sorted_results_line]['InstanceId']+ ","+ sorted_results[sorted_results_line]['InstanceType']+","+ sorted_results[sorted_results_line]['LaunchTime']+","+sorted_results[sorted_results_line][tag_key])
      
if __name__ == "__main__":
   main(sys.argv[1:])
