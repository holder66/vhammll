# Multiple Classifier Workflow

VHamMLL can combine several classifiers — each trained with different settings
(number of attributes, binning range, weighting, etc.) — and merge their votes to
produce a final classification that is often more accurate than any single classifier
alone. This document walks through the full workflow from building a settings file to
evaluating the combined result.

---

## Overview

The steps are:

1. **Explore** to find promising classifier settings.
2. **Save** the settings you want to combine into a settings file (`-ms`).
3. **Cross-validate or verify** using all the saved classifiers together (`-m`).
4. Optionally, run **`optimals`** to identify the best-performing subsets.

---

## Step 1 — Find good settings with `explore`

Run `explore` over a range of attributes and bins to survey what single-classifier
accuracy looks like. Use `-ms` to append the settings for selected classifiers to a
settings file as you go. The settings file is created if it does not exist; new entries
are appended if it does.

```sh
# Explore, saving the classifier settings used for each run to bcw.opts
./vhamml explore -s -ms bcw.opts ~/.vmodules/holder66/vhammll/datasets/bcw350train
```

Each row in the console output corresponds to one classifier. To save only specific
ones, note their classifier IDs and use `-m#`:

```sh
# Append only classifiers 0, 2, and 5 to the settings file
./vhamml explore -s -ms bcw.opts -m# 0,2,5 ~/.vmodules/holder66/vhammll/datasets/bcw350train
```

### Settings file format

The settings file is a plain text file with one JSON object per line. Each line
encodes the full `ClassifierSettings` for one classifier, including its parameters,
performance metrics, and a `classifier_id` field that is used to identify it in
subsequent steps. You do not normally need to edit this file by hand.

---

## Step 2 — Cross-validate using multiple classifiers together

Pass the settings file to `cross` or `verify` with the `-m` flag:

```sh
# Cross-validate using all classifiers in bcw.opts
./vhamml cross -s -m bcw.opts ~/.vmodules/holder66/vhammll/datasets/bcw350train

# Verify against a held-out test set
./vhamml verify -s -m bcw.opts \
    -t ~/.vmodules/holder66/vhammll/datasets/bcw174test \
    ~/.vmodules/holder66/vhammll/datasets/bcw350train
```

To use only a subset of the classifiers in the file, list their IDs with `-m#`:

```sh
./vhamml cross -s -m bcw.opts -m# 0,3,7 ~/.vmodules/holder66/vhammll/datasets/bcw350train
```

---

## Step 3 — Choose a combination strategy

When classifiers disagree on a case, VHamMLL resolves the conflict using one of three
strategies, selected with a flag:

| Flag | Strategy | Description |
|------|----------|-------------|
| *(none)* | default | At each Hamming radius, use a plurality/majority vote across classifiers. Falls back to the classifier with the strongest signal (highest ratio between nearest-neighbor counts). |
| `-ma` | break-on-all | Stop expanding the search radius as soon as **every** classifier has found at least one match, rather than stopping when **any** has. |
| `-mc` | combined | Pool all Hamming distances from all classifiers into a single sorted list and iterate through them jointly. |
| `-mt` | totalnn | Sum the nearest-neighbor counts across all classifiers (weighted by class prevalences) and infer the class from the totals. Takes precedence over `-mc` if both are given. |

Use `-af` (all-flags) to run all combinations automatically and compare them side by
side:

```sh
./vhamml cross -s -m bcw.opts -af ~/.vmodules/holder66/vhammll/datasets/bcw350train
```

This prints one result line per combination (3 strategies × 2 `-ma` settings = 6 rows),
making it easy to spot which combination performs best.

---

## Step 4 — Find optimal classifier subsets with `optimals`

Once you have a settings file with many classifiers, `optimals` searches all subsets
(pairs, triples, etc.) and identifies which combinations give the best balanced
accuracy, highest Matthews Correlation Coefficient (MCC), or highest correct-inference
count per class.

```sh
./vhamml optimals -s bcw.opts
```

Use `-cl` to control the minimum and maximum combination size to consider:

```sh
# Only consider pairs and triples
./vhamml optimals -s -cl 2,3 bcw.opts
```

The output lists the top-performing combinations by each criterion. You can then use
`-m# <ids>` in a `cross` or `verify` run to evaluate a specific combination more
closely.

---

## Tips

- **Start broad, then narrow.** Run `explore` over a wide range of settings, save
  everything, then use `optimals` to find the best subsets rather than guessing by
  hand.
- **Keep the settings file tidy.** Use `-m#` to select only the classifiers you want
  to append; it is easy to accumulate redundant entries otherwise.
- **Balance prevalences per-classifier.** If your dataset has unequal class sizes, you
  can set `balance_prevalences_flag` in the individual classifier settings (via `-bp`
  when running `explore -ms`). VHamMLL will honour this flag on a per-classifier basis
  during a multiple-classifier cross-validation.
- **Try `-mt` for binary classifiers first.** In practice, the `totalnn` strategy
  (`-mt`) tends to work well for two-class problems because it aggregates evidence
  across all classifiers before making a decision.
