server "ubstage18.upb.de", user: "ubpb", roles: %w{app db web}
set :deploy_to, "/ubpb/catalog"
set :branch, "master"
