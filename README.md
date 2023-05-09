# Cargo Agent R

The cargo agent is an integrated analysis sub-module for MoveApps. It is excecuted on the data output after each run of an App and provides the user with a quick overview of the output that has been created by an App. It is indicated by a green 'bobble' on the top-right corner of an App container and can be opened by clicking on it. Usually, it gives an overview of the number of animals, tracks and locations, the time interval, bounding box and attribute names. Depending on the output type of an App, these properties can differ. 

When a new IO type is requested for MoveApps for the first time, the person submitting it is required to provide cargo agent analysis code that produces a json overview list of the most important properties of the data type, so that anyone using Apps with this IO type as output can quickly evaluate obtained results.

## How to request a new IO type?

### 1. Prepare your new MoveApps IO type

1. What is a good **title** for the IO type?
Provide a sensible label for the IO type that you request. Please follow our convention to include the package name and class name like `move::moveStack` or `ctmm::telemetry.list`. This title is intendend for MoveApps-User.
1. What is a good **slug** for the IO type? Your IO type must be referenced in a file-path-save way. For example a slug for the label `ctmm::telemetry.list` would be `ctmm_telementry_list`. This slug is intended for other App-Developer.
1. What is the file-extension of this IO type?
Provide the extension of the file in which the new IO type can be transferred to the user during download. This file-extension is intended for MoveApp-User.

Summary:

- Title (referenced in the following document as `{IO_TYPE_TITLE}`)
- Slug (`{IO_TYPE_SLUG}`)
- File-Extension (`{IO_TYPE_FILE_EXTENSION}`)

### 2. Fork this repository

Please do not work on our `main` branch, but fork the repository and add files that are necessary to extent MoveApps by your requested IO type. After that submit a **Pull-Request** to this repository with your changes. See below the files that are necessary: 

- analyzer code, 
- example data,
- documentation
- unit tests

### 3. Add analysis code for the IO type overview

Location: `src/analyzer/{IO_TYPE_SLUG}/{IO_TYPE_SLUG}.R`

Implement code to extract a useful list of overview properties of your new IO type in a new separate sub-folder below `src/analyzer`. Copy an existing analysing function, rename, adapt and include it into the repository. Make sure that a proper list of useful information is created by your code (with useful keys). At the end this list will be serialized by `jsonlite` and presented to any MoveApps user that runs Apps of this new IO (output) type in a workflow.

<details>
    <summary>An example output of a (serialized json) list</summary>

    ```
    {
        "sensor_types":[
            "GPS"
        ],
        "taxa":[
            "Anser albifrons"
        ],
        "animals_total_number":[
            2
        ],
        "animal_attributes":[
            "individual.local.identifier",
            "visible",
            "individual.id",
            "deployment.id",
            "tag.id",
            "study.id",
            "sensor.type.id",
            "tag.local.identifier",
            "individual.taxon.canonical.name",
            "study.name",
            "sensor.type",
            "sex",
            "taxon.canonical.name",
            "timestamp.start",
            "timestamp.end",
            "number.of.events",
            "number.of.deployments",
            "sensor.type.ids",
            "animalName"
        ],
        "positions_total_number":[
            4653
        ],
        "track_attributes":[
            "event.id",
            "timestamp",
            "location.long",
            "location.lat",
            "heading",
            "height.above.ellipsoid",
            "migration.stage",
            "migration.stage.standard"
        ],
        "timestamps_range":[
            "2013-09-30 08:30:48",
            "2014-10-25 08:30:44"
        ],
        "animal_names":[
            "2704",
            "2731"
        ],
        "positions_bounding_box":[
            {
                "min":6.2172,
                "max":39.4644,
                "_row":"coords.x1"
            },
            {
                "min":51.4005,
                "max":63.9659,
                "_row":"coords.x2"
            }
        ],
        "tracks_total_number":[
            2
        ],
        "projection":[
            "+proj=longlat +datum=WGS84 +no_defs"
        ],
        "track_names":[
            "X2704",
            "X2731"
        ],
        "number_positions_by_track":[
            {
                "positions_number":706,
                "animal":"X2704"
            },
            {
                "positions_number":3947,
                "animal":"X2731"
            }
        ]
    }
    ```
</details>

### 4. Add documentation about the requested IO type

Location: `src/analyzer/{IO_TYPE_SLUG}/README.md`

Please document your IO type. If public available documentation for your IO type already exists feel free to provide a link to this document in the `README.md`

### 5. Add test input data of the requested IO type

Location: `tests/testthat/data/{IO_TYPE_SLUG}/{IO_TYPE_SLUG}.rds`

Example data of a new IO type are useful to understand their uses and properties. Provide 2-3 example files that properly work with your cargo agent analyser code.

### 6. Add unit tests

Location: `tests/testthat/analyzer/{IO_TYPE_SLUG}/{IO_TYPE_SLUG}.R`

Unit tests ensure that edge cases are considered sufficiently by open code like the cargo agent of a new IO type. This code needs to run properly, as it is used within the MoveApps system each time an App with the respective IO type as output is run. Please include unit tests, using the R package testthat, for all simple edge cases. If you are unsure, have a look at test files of other IO types.

### 7. Integrate your new analyzer

Location: `app.R` > function `analyze`.

Please add a `else` branch to this function in order to call your analyzer code. As the analyzer will be choosen by the **ID** of the IO-Type this step can only be prepared at this moment. The MoveApps-Administrators will adjust your PR later as soon as you requested the IO type at MoveApps (see below).

In the meantime please extend the function with an placeholder ID `"TODO"`

```
} else if (output_type_id == "6597caa7-4ad3-4103-bbf3-4e6f7b03d1a4") {
    log_debug("analyzing the RDS for `{output_type_label}`...")
    writeResult(analyzeMove2Move2_loc(rds = rds))
# start of new IO type integration
} else if (output_type_id == "TODO") {
    log_debug("analyzing the RDS for `{output_type_label}`...")
    writeResult(YOUR_NEW_ANALYER_FUNCTION_NAME(rds = rds))
# end of new IO type integration
} else {
    log_warn("unexpected OUTPUT_TYPE {output_type_label} ({output_type_id}). Can not handle it.")
    root <- list(n = NA)
    writeResult(root)
}
```

### 8. Create a pull request

After you have created a pull request of our GitHub repository, our administrators will evaluate all files and get back to you with comments and/or approve the new IO type by merging your branch. Finally, our GitHub workflow will execute all tests and initialises to build a Docker image.

### 9. Request the new IO type at MoveApps

With the pull request link from above, you are able to request the IO type on MoveApps. This can be done during _initialization_ of a new App at MoveApps and following the link for _requesting a new IO type_. You need the information from the _first step of this document (Preparation)_ and the link to your _Pull Request_.
