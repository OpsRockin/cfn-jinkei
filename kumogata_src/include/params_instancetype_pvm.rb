InstanceType do
  Description "EC2 instance type"
  Type "String"
  Default "m1.small"
  AllowedValues "t1.micro",
                "m1.small",
                "m1.medium",
                "m1.large",
                "m1.xlarge",
                "c1.medium",
                "c1.xlarge",
                "hi1.4xlarge",
                "hs1.8xlarge",
                "m3.medium",
                "m3.large",
                "m3.xlarge",
                "m3.2xlarge",
                "c3.large",
                "c3.xlarge",
                "c3.2xlarge",
                "c3.4xlarge",
                "c3.8xlarge"
  ConstraintDescription "must be a valid EC2 instance type."
end
