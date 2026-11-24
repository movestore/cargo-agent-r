R CTMM Model with Data

This IO type is to work with the R ctmm package, that requires a fitted ctmm model as input. This IO type consists of a named list with two elements, in this order:

1. `model`: a list with a fitted ctmm model for each animal.
2. `data`: a list of ctmm telemetry objects, one for each animal (see also the IO type ctmm telemetry list).

The element names are required, because the cargo agent reads the elements by name.

Reference to ctmm package: https://ctmm-initiative.github.io/ctmm/reference/index.html

Reference to details about ctmm model: https://ctmm-initiative.github.io/ctmm/reference/ctmm.fit.html
Reference to details about telemetry object: https://ctmm-initiative.github.io/ctmm/reference/as.telemetry.html
