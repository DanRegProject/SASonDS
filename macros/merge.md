# Help: %merge and %reduce macros (macros/mergegeneric.sas)

Source: [macros/mergegeneric.sas](https://github.com/DanRegProject/SASonDS/blob/a188c8537aef13100d847dc67e7ae4efd49e9aa5/macros/mergegeneric.sas)

## Overview

This file documents two SAS macros implemented in `macros/mergegeneric.sas`:

- `%merge(...)` — orchestrates merging of external event/record datasets into a base cohort dataset by `pnr` (person identifier) and an optional `IndexDate`. For each named input "set" it selects and maps variables, calls `%reduce` to compute first/last/aggregate values relative to an index date, then merges the reduced results into the base dataset.
- `%reduce(indata, outdata, type, outcome, IndexDate, varlist, datevar)` — internal helper used by `%merge` that reduces a time-ordered table by person (and optionally index date) to produce first/last/after-index summaries for a list of variables.

These macros are designed for registry / longitudinal datasets where `pnr` links records and `IndexDate` represents an inclusion/event date to compute before/after summaries.

## Location

macros/mergegeneric.sas  
(See file at the Source link above.)

## High-level behavior

1. Validate required parameters and `type` argument (must be one of: `LPR`, `LMDB`, `OPR`, `UBE`, `PATO`, `LAB`, `CAR`).
2. Optionally deduplicate `sets` via `%nonrep` (if > 2 sets).
3. For each "set" token in `sets`:
   - Look for a dataset named `&inlib..&type&var.ALL`
   - Create a temporary table joining the input set to `basedata` by `pnr` (and applying `&subset` if given)
   - Map each `invar` to the corresponding `outvar` (default `outvar = invar` when not supplied)
   - Call `%reduce` to compute first/last/after-index values and save the result to `&outlib..&type&var&postfix&IndexDate`
4. After processing all sets, sort `&basedata` and merge all generated reduced files into `&basedata` by `pnr` (and `&IndexDate` if specified). Final `&basedata` replaces the original dataset in place.
5. Temporary tables are cleaned up with `%cleanup`.

Note: The macros assume `pnr` is the person identifier present both in the input sets and in `basedata`.

## Key parameters

%merge(
  basedata=,   /* REQUIRED: Base cohort dataset (libname.dataset or dataset in current lib). Must contain pnr (and IndexDate if used) */
  inlib=work,  /* Library where input raw datasets live (default: work) */
  outlib=work, /* Library to write intermediate reduced outputs (default: work) */
  IndexDate=,  /* Optional: date variable in basedata used to compute before/after summaries */
  type=,       /* REQUIRED: one code identifying the classification of input datasets. Allowed values: LPR LMDB OPR UBE PATO LAB CAR */
  datevar=,    /* REQUIRED: date variable in the input datasets (the event date to use for ordering) */
  sets=,       /* REQUIRED: space-separated list of set name tokens. For each token `var`, macro looks for dataset &inlib..&type&var.ALL */
  invar=,      /* REQUIRED: space-separated list of variables to extract from input datasets */
  outvar=,     /* OPTIONAL: space-separated list of output variable names to use in the reduced files. Defaults to same as invar. Must have same number of elements as invar */
  subset=,     /* OPTIONAL: expression applied to the join (e.g. a.date >= '01jan2010'd). Added as an `AND` clause when joining to &basedata. Use macro-safe quoting where needed. */
  postfix=     /* OPTIONAL: postfix to append to intermediate reduced dataset names */
);

%reduce(
  indata=,     /* Input detailed dataset (temporary table built by %merge) */
  outdata=,    /* Output reduced dataset (created by reduce) */
  type=,       /* Passed through from caller (used only in labels/text) */
  outcome=,    /* Outcome name used as prefix for generated variable names */
  IndexDate=,  /* Optional index date; when empty reduce follows a simpler logic without index-date grouping */
  varlist=,    /* Space-separated list of variables to reduce (variables present in indata) */
  datevar=     /* Date variable used for ordering in the input table (same as the `datevar` passed to %merge) */
);

## Variable naming convention produced by %reduce

Given `outcome` and a reduced variable `var`, `%reduce` creates variables with names based on whether variables are character/numeric and whether `IndexDate` was specified. Examples of generated names:

- &outcome.&var.AF&IndexDate — First (after) value for `var` after the index (or simply "first after" when IndexDate is blank). (AF = after)
- &outcome.FI&var.Be&IndexDate — First `var` before the index (only if IndexDate given).
- &outcome.LA&var.Be&IndexDate — Last `var` before the index (only if IndexDate given).

When `IndexDate` is blank, `%reduce` reduces only by person (no before/after split) and uses a single set of "AF" variables.

Note: Character and numeric variables are handled separately. Array initialization retains character variables as `""` and numeric as `.`.

## Preconditions / Requirements

- `&basedata` must exist and contain `pnr`. If you provide `IndexDate`, `&basedata` must contain that variable.
- For each token `var` in `sets`, an input dataset named `&inlib..&type&var.ALL` is expected. The macro will warn if the dataset does not exist and skip it.
- `invar` and `outvar` must have equal numbers of tokens (unless `outvar` omitted altogether).
- The following auxiliary macros must be available (they are called by `%merge` and `%reduce`):
  - `%NewDatasetName(...)` — to create temporary dataset names
  - `%nonrep(...)` — optional deduplication of the `sets` list
  - `%RunQuit` / `%runquit` — error-handling wrapper used after PROC SQL/other steps
  - `%reduce` (present in same file)
  - `%cleanup(...)` — deallocate / delete temporary datasets
  - `%varexist(...)` and `%fmtinfo(...)` — used by `%reduce` to detect variable types and formats
- The macros assume SAS SQL and DATA step behavior (PROC SQL, DATA step arrays, BY-group processing).

## Return / Side-effects

- `%merge` writes reduced intermediate result datasets to `&outlib` named: `&outlib..&type&var&postfix&IndexDate` for each `var` in `sets`. Example: if `type=LPR`, `var=HOSP1`, `postfix=_v1`, `IndexDate=inc_date`, the generated dataset name will be `&outlib..LPRHOSP1_v1inc_date`.
- `%merge` updates/overwrites the dataset referenced by `basedata` — it sorts & merges the reduced outputs into `&basedata` and replaces it.
- Temporary intermediate tables (work tables) are removed via `%cleanup`.

## Error messages / warnings you may see

- "merge ERROR: Required arguments not specified..." — one or more required macro parameters missing.
- "merge ERROR: Only one type allowed" — `type` parameter contained multiple tokens.
- "merge ERROR: type (&type) not one of : LPR LMDB OPR UBE PATO LAB CAR" — invalid `type`.
- "merge ERROR: number of variables for input and output not equal." — `invar` and `outvar` lists differ in length.
- "merge WARNING: &inlib..&type&var.ALL data set not available." — specific input dataset missing; the macro skips processing that set.

## Examples

1) Simple use (default outvar = invar):
```sas
%merge(
  basedata=work.cohort,
  inlib=raw,
  outlib=work,
  IndexDate=inc_date,
  type=LPR,
  datevar=adm_date,
  sets=HOSP1 HOSP2,
  invar=diag_code proc_code,
  subset=a.adm_date >= '01JAN2010'd,
  postfix=_v1
);
```
- For each set token (`HOSP1`, `HOSP2`), the macro looks for `raw.LPRHOSP1.ALL` and `raw.LPRHOSP2.ALL`.
- It will compute first/last/after-index summaries for `diag_code` and `proc_code` and merge these variables into `work.cohort`.

2) Using custom output variable names:
```sas
%merge(
  basedata=lib.cohort,
  inlib=raw,
  outlib=lib,
  IndexDate=index_dt,
  type=LAB,
  datevar=lab_date,
  sets=LBCHEM LBHEM,
  invar=lab_value lab_flag,
  outvar=chem_value chem_flag,
  subset=a.lab_date <= b.index_dt,
  postfix=_reduced
);
```

## Notes & implementation details

- The macro performs a `PROC SQL` join between each input dataset (`a`) and the `basedata` (`b`) to associate each event row with the base row(s) by `pnr`. The SQL output is ordered by person and event date and passed to `%reduce` for summarization.
- `%reduce` computes different array dimensions and output variables depending on whether `IndexDate` is specified. When `IndexDate` is present the macro computes before/after summaries relative to the inclusion event.
- `%reduce` attempts to preserve date formats for numeric date variables (uses `%fmtinfo` / format info when available).
- The macro uses file/dataset naming concatenations that may create long names — ensure the resulting names do not exceed your SAS environment's name length limits (SAS default 32 characters).
- Pay attention to macro quoting and expression evaluation when supplying `subset=`; it's injected into the SQL WHERE clause.

## Recommended checks before running

- Confirm `pnr` and any `IndexDate` variable exist in `basedata`.
- Inspect the names of source datasets for the expected pattern `&inlib..&type&<SET>.ALL`.
- Confirm `invar` variables exist in the source datasets and their types (character vs numeric) — `%reduce` treats them differently.
- Run the macros on a small test cohort first to verify naming and values.

## Troubleshooting tips

- If you see unexpected missing or duplicated values, check sorting keys and whether `IndexDate` is present and correctly populated.
- If reduce output variables do not appear, re-check that `invar` tokens match variable names in the joined SQL table and that datasets exist.
- If macro reports missing auxiliary macros (`%NewDatasetName`, `%cleanup`, `%nonrep`, `%RunQuit`, `%varexist`, `%fmtinfo`), ensure those utility macros are in your autocall/catalog path or include their definitions prior to calling `%merge`.

## Contact / maintenance notes

- The macro is intended for reuse in this codebase. If you modify variable-naming logic or the SQL selection, update this documentation accordingly.
- When adapting to other datasets, be careful with library prefixes and dataset name patterns.
