# glasser_LR_overlap

## Overlap

The parcellation and surface files were downloaded from [BALSA][1] on June 16,
2026, see [Glasser (2016)][3].

Files were converted to have more readable names and then mirrored using code
from [TrevorKMDay/crossotope_mapping/][2] and converted back from a `dscalar`
to a `dlabel`.

Then, the overlap between the LH ROIs and the RH-to-LH mirror was calculated
using a Dice coefficient. Note that the L/R ROIs differ in size compared to
their homologue, which is further changed in the mirroring process.

### Results

The Dice coefficients ranged from .45 (`LIPd`) to .96 (`3b`).

## Symmetric parcellations

We also wanted to create symmetric parcellations for sensitivity testing. 
We created files where the left parcels were projected onto the right (`LL`) 
and vice versa (`RR`).

This code is in `01b-create_LLRR_glasser.sh` and the resutling label files
are in `LLRR/`, with some intermediate files not uploaded to GitHub.

 [1]: https://balsa.wustl.edu/reference/6V6gD
 [2]: https://github.com/TrevorKMDay/crossotope_mapping
 [3]: https://doi.org/10.1038/nature18933
