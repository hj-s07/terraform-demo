#!/bin/bash

export terraform_test_dns=$(terraform output -raw alb_dns_name)
curl $terraform_test_dns

if [ $? == 0 ]
  then echo success
fi