AWSTemplateFormatVersion "2010-09-09"
Parameters do
  _include 'include/params_keypair.rb'
  MySQLPassword do
    Description "Password of RDS User"
    Type "String"
    MinLength 8
    MaxLength 64
  end
  _include 'include/params_instancetype_hvm.rb'
  MasterInstanceType do
    Description "Master EC2 instance type"
    Type "String"
    Default "t2.medium"
    AllowedValues "t2.micro", "t2.small", "t2.medium", "m3.medium", "m3.large", "m3.xlarge", "m3.2xlarge", "i2.xlarge", "i2.2xlarge", "i2.4xlarge", "i2.8xlarge", "c3.large", "c3.xlarge", "c3.2xlarge", "c3.4xlarge", "c3.8xlarge", "c4.large", "c4.xlarge", "c4.2xlarge", "c4.4xlarge", "c4.8xlarge", "r3.large", "r3.xlarge", "r3.2xlarge", "r3.4xlarge", "r3.8xlarge"
    ConstraintDescription "must be a valid EC2 instance type."
  end
  RDSInstanceType do
    Description "RDS instance type"
    Type "String"
    Default "db.m3.medium"
    AllowedValues "db.t2.micro", "db.t2.small", "db.t2.medium", "db.m1.small", "db.m1.medium", "db.m1.large", "db.m1.xlarge", "db.m3.medium", "db.m3.large", "db.m3.xlarge", "db.m3.2xlarge", "db.m2.xlarge", "db.m2.2xlarge", "db.m2.4xlarge", "db.r3.large", "db.r3.xlarge", "db.r3.2xlarge", "db.r3.4xlarge", "db.r3.8xlarge"
    ConstraintDescription "must be a valid RDS instance type."
  end
  DBAllocatedStorage do
    Default 20
    Description "The size of the database (Gb)"
    Type "Number"
    MinValue 5
    MaxValue 3072
    ConstraintDescription "must be between 5 and 3072Gb."
  end
  MultiAZDatabase do
    Default "true"
    Description "Create a multi-AZ MySQL Amazon RDS database instance"
    Type "String"
    AllowedValues "true", "false"
    ConstraintDescription "must be either true or false."
  end
end
Mappings do
  _include 'include/map_ami_hvm.rb'
  _include 'include/map_az_all.rb'
end
Resources do
  AmimotoVPC do
    Type "AWS::EC2::VPC"
    Properties do
      CidrBlock "10.0.0.0/16"
      Tags [
        _{
          Key "Name"
          Value "mp-amimoto-vpc"
        }
      ]
    end
  end
  AmimotoFrontSubnet1 do
    Type "AWS::EC2::Subnet"
    Properties do
      VpcId do
        Ref "AmimotoVPC"
      end
      CidrBlock "10.0.1.0/24"
      AvailabilityZone do
        Fn__Select [
          "0",
          _{
            Fn__GetAZs do
              Ref "AWS::Region"
            end
          }
        ]
      end
      Tags [
        _{
          Key "Name"
          Value "mp-amimoto-front-subnet-1"
        }
      ]
    end
  end
  AmimotoFrontSubnet2 do
    Type "AWS::EC2::Subnet"
    Properties do
      VpcId do
        Ref "AmimotoVPC"
      end
      CidrBlock "10.0.2.0/24"
      AvailabilityZone do
        Fn__Select [
          "1",
          _{
            Fn__GetAZs do
              Ref "AWS::Region"
            end
          }
        ]
      end
      Tags [
        _{
          Key "Name"
          Value "mp-amimoto-front-subnet-2"
        }
      ]
    end
  end
  AmimotoWithRDSSubnet do
    Type "AWS::EC2::Subnet"
    Properties do
      VpcId do
        Ref "AmimotoVPC"
      end
      CidrBlock "10.0.10.0/24"
      AvailabilityZone do
        Fn__Select [
          "0",
          _{
            Fn__GetAZs do
              Ref "AWS::Region"
            end
          }
        ]
      end
      Tags [
        _{
          Key "Name"
          Value "mp-amimoto-server-subnet"
        }
      ]
    end
  end
  AmimotoRDSSubnet1 do
    Type "AWS::EC2::Subnet"
    Properties do
      VpcId do
        Ref "AmimotoVPC"
      end
      CidrBlock "10.0.101.0/24"
      AvailabilityZone do
        Fn__Select [
          "0",
          _{
            Fn__GetAZs do
              Ref "AWS::Region"
            end
          }
        ]
      end
      Tags [
        _{
          Key "Name"
          Value "mp-amimoto-rds-subnet-1"
        }
      ]
    end
  end
  AmimotoRDSSubnet2 do
    Type "AWS::EC2::Subnet"
    Properties do
      VpcId do
        Ref "AmimotoVPC"
      end
      CidrBlock "10.0.102.0/24"
      AvailabilityZone do
        Fn__Select [
          "1",
          _{
            Fn__GetAZs do
              Ref "AWS::Region"
            end
          }
        ]
      end
      Tags [
        _{
          Key "Name"
          Value "mp-amimoto-rds-subnet-2"
        }
      ]
    end
  end
  AmimotoInternetGateway do
    Type "AWS::EC2::InternetGateway"
    Properties do
      Tags [
        _{
          Key "Name"
          Value "mp-amimoto-igw"
        }
      ]
    end
  end
  AttachGateway do
    Type "AWS::EC2::VPCGatewayAttachment"
    Properties do
      VpcId do
        Ref "AmimotoVPC"
      end
      InternetGatewayId do
        Ref "AmimotoInternetGateway"
      end
    end
  end
  AmimotoRouteTable do
    Type "AWS::EC2::RouteTable"
    Properties do
      VpcId do
        Ref "AmimotoVPC"
      end
      Tags [
        _{
          Key "Name"
          Value "mp-amimoto-rtb"
        }
      ]
    end
  end
  Route do
    Type "AWS::EC2::Route"
    DependsOn "AttachGateway"
    Properties do
      RouteTableId do
        Ref "AmimotoRouteTable"
      end
      DestinationCidrBlock "0.0.0.0/0"
      GatewayId do
        Ref "AmimotoInternetGateway"
      end
    end
  end
  SubnetRouteTableAssociationFront1 do
    Type "AWS::EC2::SubnetRouteTableAssociation"
    Properties do
      SubnetId do
        Ref "AmimotoFrontSubnet1"
      end
      RouteTableId do
        Ref "AmimotoRouteTable"
      end
    end
  end
  SubnetRouteTableAssociationFront2 do
    Type "AWS::EC2::SubnetRouteTableAssociation"
    Properties do
      SubnetId do
        Ref "AmimotoFrontSubnet2"
      end
      RouteTableId do
        Ref "AmimotoRouteTable"
      end
    end
  end
  SubnetRouteTableAssociation do
    Type "AWS::EC2::SubnetRouteTableAssociation"
    Properties do
      SubnetId do
        Ref "AmimotoWithRDSSubnet"
      end
      RouteTableId do
        Ref "AmimotoRouteTable"
      end
    end
  end
  LoadBalancer do
    Type "AWS::ElasticLoadBalancing::LoadBalancer"
    Properties do
      CrossZone "true"
      Subnets [
        _{
          Ref "AmimotoFrontSubnet1"
        },
        _{
          Ref "AmimotoFrontSubnet2"
        }
      ]
      HealthCheck do
        HealthyThreshold 2
        Interval 30
        Target "TCP:80"
        Timeout 10
        UnhealthyThreshold 2
      end
      Instances [
        _{
          Ref "AmimotoWithRDS"
        }
      ]
      Listeners [
        _{
          InstancePort 80
          LoadBalancerPort 80
          Protocol "HTTP"
          InstanceProtocol "HTTP"
        },
        _{
          InstancePort 443
          LoadBalancerPort 443
          Protocol "TCP"
          InstanceProtocol "TCP"
        }
      ]
      SecurityGroups [
        _{
          Ref "sgAMIMOTO11AutogenByAWSMPELB"
        }
      ]
    end
  end
  AmimotoWithRDS do
    Type "AWS::EC2::Instance"
    Metadata do
      AWS__CloudFormation__Init do
        config do
          files do
            _path("/opt/aws/cloud_formation.json") do
              source "https://s3-ap-northeast-1.amazonaws.com/cf-amimoto-templates/cfn_file_templates/rds.json.template"
              content '{
                "rds" : {
                  "database" : "wordpress",
                  "username" : "amimoto",
                  "password" : "{{password}}",
                  "endpoint" : "{{endpoint}}",
                  "port"     : 3306
                }
              }'
              context do
                endpoint do
                  Fn__GetAtt "AmimotoRDS", "Endpoint.Address"
                end
                password do
                  Ref "MySQLPassword"
                end
                serverid "dummy(value_will_update_by_AmimotoFrontLC)"
              end
              mode "00644"
              owner "root"
              group "root"
            end
          end
        end
      end
    end
    Properties do
      DisableApiTermination "FALSE"
      ImageId do
        Fn__FindInMap [
          "MPAmimotov4",
          _{
            Ref "AWS::Region"
          },
          "AMI"
        ]
      end
      InstanceType do
        Ref "MasterInstanceType"
      end
      KeyName do
        Ref "KeyName"
      end
      Monitoring "false"
      NetworkInterfaces [
        _{
          DeviceIndex 0
          AssociatePublicIpAddress "true"
          SubnetId do
            Ref "AmimotoWithRDSSubnet"
          end
          GroupSet [
            _{
              Ref "sgAMIMOTO11AutogenByAWSMP"
            }
          ]
        }
      ]
      UserData do
        Fn__Base64 do
          Fn__Join [
            "",
            [
              "#!/bin/bash\n",
              "/opt/aws/bin/cfn-init -s ",
              _{
                Ref "AWS::StackName"
              },
              " -r AmimotoWithRDS ",
              " --region ",
              _{
                Ref "AWS::Region"
              },
              "\n"
            ]
          ]
        end
      end
      Tags [
        _{
          Key "Name"
          Value "mp-amimoto-rds"
        }
      ]
    end
  end
  AmimotoDBSubnetGroup do
    Type "AWS::RDS::DBSubnetGroup"
    Properties do
      DBSubnetGroupDescription "Subnets available for the RDS DB Instance"
      SubnetIds [
        _{
          Ref "AmimotoRDSSubnet1"
        },
        _{
          Ref "AmimotoRDSSubnet2"
        }
      ]
    end
  end
  AmimotoRDS do
    Type "AWS::RDS::DBInstance"
    Properties do
      AutoMinorVersionUpgrade "true"
      DBInstanceClass do
        Ref "RDSInstanceType"
      end
      Port 3306
      AllocatedStorage do
        Ref "DBAllocatedStorage"
      end
      BackupRetentionPeriod 1
      DBName "wordpress"
      Engine "mysql"
      MultiAZ do
        Ref "MultiAZDatabase"
      end
      MasterUsername "amimoto"
      MasterUserPassword do
        Ref "MySQLPassword"
      end
      PreferredBackupWindow "00:00-00:30"
      PreferredMaintenanceWindow "sun:16:00-sun:17:30"
      VPCSecurityGroups [
        _{
          Ref "sgAMIMOTO11AutogenByAWSMPforRDB"
        }
      ]
      Tags [
        _{
          Key "workload-type"
          Value "other"
        }
      ]
      DBSubnetGroupName do
        Ref "AmimotoDBSubnetGroup"
      end
    end
  end
  sgAMIMOTO11AutogenByAWSMPELB do
    Type "AWS::EC2::SecurityGroup"
    Properties do
      GroupDescription "This security group was generated by AWS Marketplace and is based on recommended settings for AMIMOTO version 11 provided by DigitalCube Co Ltd"
      VpcId do
        Ref "AmimotoVPC"
      end
      SecurityGroupIngress [
        _{
          IpProtocol "tcp"
          FromPort 80
          ToPort 80
          CidrIp "0.0.0.0/0"
        },
        _{
          IpProtocol "tcp"
          FromPort 443
          ToPort 443
          CidrIp "0.0.0.0/0"
        }
      ]
    end
  end
  sgAMIMOTO11AutogenByAWSMP do
    Type "AWS::EC2::SecurityGroup"
    Properties do
      GroupDescription "This security group was generated by AWS Marketplace and is based on recommended settings for AMIMOTO version 11 provided by DigitalCube Co Ltd"
      VpcId do
        Ref "AmimotoVPC"
      end
      SecurityGroupIngress [
        _{
          IpProtocol "tcp"
          FromPort 22
          ToPort 22
          CidrIp "0.0.0.0/0"
        },
        _{
          IpProtocol "tcp"
          FromPort 80
          ToPort 80
          CidrIp "0.0.0.0/0"
        }
      ]
    end
  end
  sgAMIMOTO11AutogenByAWSMPforRDB do
    Type "AWS::EC2::SecurityGroup"
    Properties do
      GroupDescription "This security group was generated by AWS Marketplace and is based on recommended settings for AMIMOTO JINKEI version 11 provided by DigitalCube Co Ltd"
      VpcId do
        Ref "AmimotoVPC"
      end
      SecurityGroupIngress [
        _{
          IpProtocol "tcp"
          FromPort 3306
          ToPort 3306
          SourceSecurityGroupId do
            Ref "sgAMIMOTO11AutogenByAWSMP"
          end
        },
        _{
          IpProtocol "tcp"
          FromPort 3306
          ToPort 3306
          SourceSecurityGroupId do
            Ref "sgAMIMOTO11AutogenByAWSMP"
          end
        }
      ]
    end
  end
end
Description ""
Outputs do
  WebSiteURL do
    Description "WordPress Site URL (Please wait a few minutes for the upgrade of WordPress to access for the first time.)"
    Value do
      Fn__Join [
        "",
        [
          "http://",
          _{
            Fn__GetAtt "LoadBalancer", "DNSName"
          }
        ]
      ]
    end
  end
  RDSEndpoint do
    Description "Endpoint of RDS"
    Value do
      Fn__GetAtt "AmimotoRDS", "Endpoint.Address"
    end
  end
  InstanceIDforConfirmation do
    Description "Instance Id for confirmation. "
    Value do
      Fn__GetAtt "AmimotoRDS", "Endpoint.Address"
    end
  end
end
