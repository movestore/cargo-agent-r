# Cargo Agent R

The cargo agent is an integrated analysis sub-module for MoveApps. It is excecuted on the data output after each run of an App and provides the user with a quick overview of the output that has been created by an App. It is indicated by a green 'bobble' on the top-right corner of an App container and can be opened by clicking on it. Usually, it gives an overview of the number of animals, tracks and locations, the time interval, bounding box and attribute names. Depending on the output type of an App, these properties can differ. 

When a new IO type is requested for MoveApps for the first time, the person submitting it is required to provide cargo agent analysis code that produces a json overview of the most important properties of the data type, so that anyone using Apps with this IO type as output can quickly evaluate obtained results.

## How to request a new IO type?

### 0. Plan your new MoveApps IO type

1. What is a good name for the IO type?
Provide a sensible label for the IO type that you request. Please follow our convention to include the package name and class name like `move::moveStack` or `ctmm::telemetry.list`.
1. What is the file-extension of this IO type?
Provide the extension of the file in which the new IO type can be transferred to the user during download.
1. Where is the IO type documented?
Provide a link to the original public repository site that documents your requested IO type

### 1. Fork this repository

Please do not work on our master branch, but fork the repository and add files that are necessary to extent MoveApps by your requested IO type. After that submit a Pull-Request to this repository with your changes. 

### 2. Add analyis code for the IO type overview

Location: `src/analyzer/{io_type_label}.R`

Implement code to extract a useful list of overview properties of your new IO type. Copy an existing analysing function, rename, adapt and include it into the repository. Make sure that a proper list of useful information is created by your code (with useful keys).

At the end this list will be serialized by `jsonlite` and presented to the MoveApps user using Apps of this new IO (output) type.

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

### 3. Add test input data of the requested IO type

Location: `tests/testthat/data/{io_type_label}/{io_type_label}.rds`

Example data of a new IO type are useful to understand their uses and properties. Provide 2-3 example files that properly work with your cargo agent code.

### 4. Add unit tests

Location: `tests/testthat/analyzer/{io_type_label}.R`

Unit tests ensure that edge cases are considered sufficiently by open code like the cargo agent of a new IO type. This code needs to run properly, as it is used within the MoveApps system each time an App with the respective IO type as output is run.

### 5. Create a pull request

Our administrators will then evaluate all files, get back to you with comments and/or approve the new IO type by merging your branch.
Our GitHub workflow will execute all tests and tries to build a Docker image.

### 6. Request the new IO type at MoveApps

With the PR from 5. you are able to request the IO type at MoveApps. Therefore _initialize_ a new App at MoveApps and follow the link for _requesting a new IO type_.

You need the information from _0. Plan your new MoveApps IO type_ and the link to your _Pull Request_.
