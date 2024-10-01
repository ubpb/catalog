server "ubpegasus18.upb.de", user: "ubpb", roles: %w{app web}
server "ubperseus18.upb.de", user: "ubpb", roles: %w{app web}
server "app1.ub.upb.de",     user: "ubpb", roles: %w{app web}
server "app2.ub.upb.de",     user: "ubpb", roles: %w{app web}
server "batch.ub.upb.de",    user: "ubpb", roles: %w{app db}
set :branch, "production"
set :deploy_to, "/ubpb/catalog"
