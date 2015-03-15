VPC do
  Type "AWS::EC2::VPC"
  Properties do
    EnableDnsSupport "true"
    EnableDnsHostnames "true"
    CidrBlock do
      Fn__FindInMap "SubnetConfig", "VPC", "CIDR"
    end
    Tags [
      _{
        Key "Application"
        Value do
          Ref "AWS::StackName"
        end
      },
      _{
        Key "Network"
        Value "Public"
      }
    ]
  end
end
PublicSubnet do
  Type "AWS::EC2::Subnet"
  Properties do
    VpcId do
      Ref "VPC"
    end
    CidrBlock do
      Fn__FindInMap "SubnetConfig", "Public", "CIDR"
    end
    Tags [
      _{
        Key "Application"
        Value do
          Ref "AWS::StackName"
        end
      },
      _{
        Key "Network"
        Value "Public"
      }
    ]
  end
end
InternetGateway do
  Type "AWS::EC2::InternetGateway"
  Properties do
    Tags [
      _{
        Key "Application"
        Value do
          Ref "AWS::StackName"
        end
      },
      _{
        Key "Network"
        Value "Public"
      }
    ]
  end
end
GatewayToInternet do
  Type "AWS::EC2::VPCGatewayAttachment"
  Properties do
    VpcId do
      Ref "VPC"
    end
    InternetGatewayId do
      Ref "InternetGateway"
    end
  end
end
PublicRouteTable do
  Type "AWS::EC2::RouteTable"
  Properties do
    VpcId do
      Ref "VPC"
    end
    Tags [
      _{
        Key "Application"
        Value do
          Ref "AWS::StackName"
        end
      },
      _{
        Key "Network"
        Value "Public"
      }
    ]
  end
end
PublicRoute do
  Type "AWS::EC2::Route"
  DependsOn "GatewayToInternet"
  Properties do
    RouteTableId do
      Ref "PublicRouteTable"
    end
    DestinationCidrBlock "0.0.0.0/0"
    GatewayId do
      Ref "InternetGateway"
    end
  end
end
PublicSubnetRouteTableAssociation do
  Type "AWS::EC2::SubnetRouteTableAssociation"
  Properties do
    SubnetId do
      Ref "PublicSubnet"
    end
    RouteTableId do
      Ref "PublicRouteTable"
    end
  end
end
