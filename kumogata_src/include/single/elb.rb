LoadBalancer do
    Type "AWS::ElasticLoadBalancing::LoadBalancer"
    Properties do
      AvailabilityZones [
        _{
          Fn__GetAtt args[:instance], "AvailabilityZone"
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
          Ref args[:instance]
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
    end
  end

