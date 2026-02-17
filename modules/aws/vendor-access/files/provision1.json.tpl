{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AcceptVpcPeering",
      "Effect": "Allow",
      "Action": [
        "ec2:AcceptVpcPeeringConnection"
      ],
      "Resource": "*"
    },
    {
      "Sid": "EndpointConnectionAccess",
      "Effect": "Allow",
      "Action": [
        "ec2:*VpcEndpointConnections"
      ],
      "Resource": "*"
    },
    {
      "Sid": "RunInst",
      "Effect": "Allow",
      "Action": [
        "ec2:RunInstances"
      ],
      "Resource": "*",
      "Condition": {
        "ArnLikeIfExists": {
          "ec2:Vpc": ${vpc_ids}
        }
      }
    },
    {
      "Sid": "ReqResrcTag",
      "Effect": "Allow",
      "Action": [
        "ec2:AssignPrivateIpAddresses",
        "ec2:AttachInternetGateway",
        "ec2:CreateNatGateway",
        "ec2:CreateNetworkInterface",
        "ec2:CreateRoute",
        "ec2:CreateRouteTable",
        "ec2:ReplaceRoute",
        "ec2:ReplaceRouteTableAssociation",
        "ec2:CreateSubnet",
        "ec2:CreateVpcEndpoint",
        "vpce:AllowMultiRegion",
        "ec2:DescribeVpcPeeringConnections",
        "ec2:CreateVpcPeeringConnection",
        "ec2:DeleteVpcPeeringConnection"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:ResourceTag/Vendor": "StreamNative"
        }
      }
    }
  ]
}