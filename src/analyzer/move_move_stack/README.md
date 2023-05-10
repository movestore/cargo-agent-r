R moveStack

The moveStack has been the original IO type for MoveApps. It is based on the R move package and contains one or multiple tracks of location data. Its structure has been designed to keep working with tracking data straight forward and less error-prone. 

Most dependencies of the R move package will be deprecating at the end of 2023. Therefore, the package move2 (gitlab/bartk/move) has been designed, which will soon be committed to CRAN. Note that all Apps on MoveApps will soon be migrated to move2. Do not use this IO type for new Apps, but instead select move2_loc.

Reference to the move package: https://cran.r-project.org/web/packages/move/vignettes/move.html
