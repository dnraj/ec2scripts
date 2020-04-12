ec2scripts
==========

Script Name: aws_ec2_instances.sh
Purpose:  To print instance details and specific tag of all instances for a given region 

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

Script Name: aws_ec2_instances.py
Purpose:  To print instance details and specific tag of all instances for a given region 

Usage: ./aws_ec2_instances.py  AWS_KEY AWS_SECRET --region <REGIONNAME-OptionalParameter> --tag <TagName>
Example:
         1. Specific to a region 
                    python3 ./aws_ec2_instances.py  AWS_KEY AWS_SECRET --region us-east-2  --tag Owner 
         2. For all regions
                    python3 ./aws_ec2_instances.py  AWS_KEY AWS_SECRET   --tag Owner
         3. For verbosity
                    python3 ./aws_ec2_instances.py  AWS_KEY AWS_SECRET  --tag Owner --v
         4. For help
                python3     ./aws_ec2_instances.py  AWS_KEY AWS_SECRET   --h

