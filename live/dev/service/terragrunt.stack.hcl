locals {
	units_dir = "${dirname(find_in_parent_folders("root.hcl"))}/units"
}

unit "api" {
	source = "${local.units_dir}/api"
	path   = "service/api"
}

unit "db" {
	source = "${local.units_dir}/db"
	path   = "storage/db"
}
