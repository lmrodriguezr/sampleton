# Sampleton

A community sample simulator for the evaluation of alpha- and beta-diversity
metrics.

# Influence of sampling in the estimation of beta-diversity

This package generates simulations to measure the influence of sampling alone
in beta-diversity estimations. This influence can be understood as the effect of
sampling stochasticity into observed values of beta-diversity. Note, however,
that this is at odds with the traditional interpretation of stochasticity in the
neutral model of community assembly, in which the term is used to characterize
random species re-assortments resulting in real differences between communities,
which are assumed to be directly quantifiable. Here, the underlying assumption
is that any observed differences between communities is purely due to a
methodological insuficiency, but there is no real difference between
communities. In other words, the stochasticity in the neutral model has an
effect on the real beta-diversity that is directly measurable by the observed
beta-diversity. On the other hand, the stochasticity in the current study has no
effect on real beta-diversity but a measurable effect on the observed
beta-diversity. These two forms of stochasticity are termed ecologic
stochasticity and sampling stochasticity, respectively, whenever necessary for
clarity.

## Community parameters

The extant diversity in the sampled community is important to estimate the
actual degree of sampling stochasticity. This diversity can be coded in several
ways founded on different underlying distributions of abundance. However, there
are compeling theoretical arguments supporting the use of the lognormal
distribution to describe prokaryotic abundance. For example, see [Curtis2002][1]
for use and defense of this distribution. Also, note that the family of
distributions proposed by [Hubbell2001][2] in the Unified Neutral Theory of
Biodiversity and Biogeography (UNTB) deals with real differences between samples
(real beta-diversity > 0). These differences are assumed to be non-existent in the
current study, hence we refrain from using UNTB as the underlying hypothesis for
abundance distributions, not to confound the ecologic stochasticity (assumed in
UNTB) with the sampling stochasticity.

### Lognormal characterized by `NT/Nmax`

The work of [Curtis2002][1] allows one to estimate the complete individuals
curve by using the measurable index `NT/Nmax` and an ancillary assumption.

#### `NT/Nmax`

This is simply the reciprocal of the relative abundance of the most abundant
species in the community.

#### `NT/Nmax` ancillary assumption

One of two assumptions can be used to estimate the individuals curve of a
community given `NT/Nmax` and a lognormal distribution:

1. One is Preston's cannonical hypothesis (see [Preston1948][3]), assuming
   ecologic and evolutionary homogeneity, and stating that the peak of the
   individuals curve coincides with `Nmax` (see also [Sugihara1980][4]).

2. The second is that the least abundant species has one individual (_i.e._,
   `Nmin=1`) and only one species has this abundance (_i.e._, `S(Nmin)=1`).
   This assumption is defended by [Curtis2002][1] for "small" samples, but is
   also extended ("with care") in the same work to global scale.

### Lognormal characterized by `St`, `a`, and `N0`

In some cases, the abovementioned assumptions are unreasonable for a given
simulation; _e.g._, if ecologic and evolutionary homogeneity cannot be assumed
and `S(Nmin) >> 1` or `Nmin >> 1`. In other cases, `NT/Nmax` may be an inadequate
estimator of the abundance distribution; _e.g._, if the abundance of the most
abundant member of the community is a clear outlier in the fit to a lognormal
distribution. Finally, in some cases the estimations of `St`, `a`, and `N0` from
the data are trivial; _e.g._, if unbiased top-subsets of abundance profiles are
available (and the total number of cells in the environment can be estimated).
In all these cases, a preferred parametrization of the lognormal distribution is
by directly using the total number of species in the community (`St`), the
reciprocal of dispersion (`a`), and the modal abundance in individuals (`N0`).

#### Estimating lognormal parameters from the species distribution

It is important to know `NT` (total individuals in the community), because usually
the abundance profiles are expressed in relative abundance, but the X-axis must be
expressed in number of individuals (cells). If the species curve is represented with
`log(cells)` in the X-axis and number of species in the Y-axis, the resulting histogram
can be fit to a normal distribution with parameters `mu` and `sigma`. The mean estimates
the modal abundance in logarithmic units (`N0 = exp(mu)`). On the other hand, the
variance can be used to calculate the `a` parameter. First, we must calculate the variance
in units of cells: `cell_var = [exp(sigma^2) - 1] * exp(2 * mu + sigma^2)`. Finally, we
calculate `a` from the cell distribution variance: `a = sqrt(2 * ln(2 * cells_var))`.

Lastly, `St` is almost always underestimated, even after applying corrections like Chao's
[Chao1984][5]. If the estimate of richness (`St`) is robust, it can be directly used (_e.g._,
upon rarefaction analysis). However, it can be alternatively estimated as the number of
species with abundance above `N0` times two, since the modal abundance `N0` represents
the distribution median (not the mean).

## Sampling parameters

The sampling stochasticity can emerge in multiple steps of the sample collection
and processing. In order to distinguish between steps, and to allow replication
at different steps, we define the following parameters independently:

### Sampling effect (Environment to Sample)
Number of cells in the sample divided by the total number of cells in the
community. For example, the number of cells in 20L of water out of the total
number of cells in a lake.

### Filtering effect (Sample to Filter)
Number of cells captured by filtration (post-dilution, if it applies) divided by
the total number of cells in the sample. For example, the number of cells in a
paper filter out of the total number of cells in 20L of filtered water.

### Extraction effect (Filter to DNA extraction)
Number of DNA genome equivalents extracted divided by the total number of cells
in the filter. This number can be approximated as the measured extracted DNA
divided by the total DNA in the cells of the sample by assuming a given
(constant) DNA content per cell.

### Library effect (DNA extraction to DNA library)
DNA used in the library preparation divided by the total DNA extracted.

### Amplification effect (DNA library to Amplified DNA library)


### Sequencing effect (Amplified DNA library to Sequences)
Number of residues (bp) sequenced divided by the total number of residues in the
(amplified) library.

### Annotation effect (Sequences to Annotation)
Number of annotated residues (bp) divided by the total number of sequenced
residues. If the length of reads is nearly constant, this is equivalent to the
number of reads annotated divided by the total number of sequencing reads when,
for example, using mapping to annotate. If the measurements are made directly in
the read space (e.g., beta diversity measured from k-mer profiles) this ratio
should, instead, account for the reduction in read length (and abundance) in the
trimming and clipping steps; i.e., total number of bp passing quality thresholds
divided by the total number of bp in the sequencing data set.

[1]: http://dx.doi.org/10.1073/pnas.142680199
[2]: https://pup.princeton.edu/chapters/s7105.html
[3]: http://dx.doi.org/10.2307/1930989
[4]: http://dx.doi.org/10.1086/283669
[5]: http://www.jstor.org/stable/4615964
