include "root" {
	path   = find_in_parent_folders("root.hcl")
	expose = true
}

locals {
	project_name = include.root.locals.project_name

	environment_hcl = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
	environment     = local.environment_hcl.locals.environment

	parent_dir   = get_parent_terragrunt_dir("root")

	dist_dir       = "${local.parent_dir}/dist"
	source_dir     = "${local.parent_dir}/src"
	
	package_script = "./package.sh"

	cur_dir_name = basename(get_terragrunt_dir())
}

feature "architecture" {
	default = "x86_64"
}

terraform {
	source = "${local.parent_dir}/modules/api"

	before_hook "package" {
		commands = ["plan", "apply"]
		execute  = [local.package_script, local.source_dir, local.dist_dir, feature.architecture.value]
	}
}

dependency "db" {
	config_path = "../../storage/db"

	# Mock outputs allow us to continue to plan on the apply of the api module
	# even though the db module has not yet been applied.
	mock_outputs_allowed_terraform_commands = ["plan", "destroy"] 
	mock_outputs = {
		name = "mock-table"
		arn  = "arn:aws:dynamodb:us-west-2:123456789012:table/mock-table"
	}
}

inputs = {
	name = "${local.project_name}-${local.cur_dir_name}-${local.environment}"

	filename = "${local.dist_dir}/package.zip"

	dynamodb_table = dependency.db.outputs.name
	dynamodb_arn   = dependency.db.outputs.arn

	architectures = [feature.architecture.value]
}
