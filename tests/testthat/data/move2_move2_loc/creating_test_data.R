library(move2)
in4 <- readRDS("/home/ascharf/AllGitSYNC/MoveAppsGit/Template_R_Function_App/data/raw/input4_move2loc_LatLon.rds")
in3 <- readRDS("/home/ascharf/AllGitSYNC/MoveAppsGit/Template_R_Function_App/data/raw/input3_move2loc_LatLon.rds")
stk <- mt_stack(in3,in4)
mt_track_id(stk) <- "individual_local_identifier"
saveRDS(stk,"~/AllGitSYNC/MoveAppsGit/cargo-agent-r/tests/testthat/data/move2_move2_loc/test_data_move2_loc.rds")
