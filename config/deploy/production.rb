server "ubpegasus18.upb.de", user: "ubpb", roles: %w{app web db}
server "ubperseus18.upb.de", user: "ubpb", roles: %w{app web}
set :branch, "production"
set :deploy_to, "/ubpb/catalog"
