############Sampme Terraform code snippets and examples#######

###MAP Function and refernce from map####

variable "plans" {
  type = map
  default = {
    "5USD"  = "1xCPU-1GB"
    "10USD" = "1xCPU-2GB"
    "20USD" = "2xCPU-4GB"
  }
}

var.plans ["10USD"]  ##should return  "1xCPU-2GB"

or

plans = lookup (var.plans, "10USD", "error") #if it doesnt find value will display errori



########Merge function################


locals {
  common_tags = {
    BillingCode = var.billing_code_tag 
    Environment = var.environment_tag # set to DEV im vars file
  }


tags = merge(local.common_tags, { Name = "${var.environment_tag}-vpc" })
 #this shows a merge of common tags so this would be called DEV-VPC


 ###############Lists######

 data "aws_availability_zones" "available" {} #will create a list of AZ's

 resource "aws_subnet" "subnet2" {
  cidr_block              = var.subnet2_address_space
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = "true"
  availability_zone       = data.aws_availability_zones.available.names[1]  #Will look at list value and create instance in 1b

  tags = merge(local.common_tags, { Name = "${var.environment_tag}-subnet${count.index + 1}" }) #in this instancew wea are adding 1 to inex count so it will be called subnet1 rather than subnet0

  #another simple example###

  variable "users" {
  type    = list
  default = ["root", "user1", "user2"]
}


#####modulo ##########
#below shows aws_subnet.subnet[count.index % var.subnet_count].id We have a count of 2 instances and 2 subnets and want to place 1 instance in each subnet
# so 2 % 2 would pacle the second instance in subnet 0 .  Instance 3 would be subnet 1 . odds in subnet 0 evens in subnet1



resource "aws_instance" "nginx" {
  count                  = var.instance_count
  ami                    = data.aws_ami.aws-linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet[count.index % var.subnet_count].id

###########spalt example list all##############


#below shows an example of listing all subnets all isnstance ids that a load balancer will span\send traffic to
#by putting all subnets in as a list object [*] will return all list elements

resource "aws_elb" "web" {
  name = "nginx-elb"

  subnets         = aws_subnet.subnet[*].id
  security_groups = [aws_security_group.elb-sg.id]
  instances       = aws_instance.nginx[*].id


  #################Slice##########################

  azs             = slice(data.aws_availability_zones.available.names, 0, var.subnet_count[terraform.workspace])



  #######outputs##########

    output "aws_elb_public_dns" {
    value = aws_elb.web.dns_name
  } #outputs elb public dns name
