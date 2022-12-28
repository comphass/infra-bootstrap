include {
  path = find_in_parent_folders()
}

terraform {
    source = "../../../module_kms"
}

inputs = {
    name = "alias/ec2key"
    description = "EC2 instance encrypt key"
    deletition_window_in_days = 10
}