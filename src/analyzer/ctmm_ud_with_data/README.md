R CTMM UD with Data and Model

This IO type is to work with the R ctmm package, that requires a utilization distribution (UD) as input/output. This IO type consists of a named list with three elements, in this order:

1. `model`: a list with a fitted ctmm model for each animal.
2. `uds`: a list with a fitted ctmm UD for each animal.
3. `data`: a list of ctmm telemetry objects, one for each animal (see also the IO type ctmm telemetry list).

The element names are required, because the cargo agent reads the elements by name.

Reference to ctmm package: https://ctmm-initiative.github.io/ctmm/reference/index.html

Reference to details about ctmm model: https://ctmm-initiative.github.io/ctmm/reference/ctmm.fit.html
Reference to details about ctmm UD: https://ctmm-initiative.github.io/ctmm/reference/akde.html and https://ctmm-initiative.github.io/ctmm/reference/occurrence.html
Reference to details about telemetry object: https://ctmm-initiative.github.io/ctmm/reference/as.telemetry.html
