# getDiag() — Short help

Brief: Collects diagnoses from one or more source tables (LPR, PSYK, PRIV, LPR3 by default) for a set of individuals and produces combined per-diagnosis datasets and an optional consolidated output dataset.

Usage (macro signature from source)
%getDiag(outlib, diaglist, diagtype=A B ALGA01 ALGA02, icd8=FALSE, indata=, fromyear=1977, outdata=, 
         SOURCE=LPR PSYK PRIV LPR3, fromdate=, todate=, admvar=start slut prioritet, diagvar=diag diagtype);

Required parameters
- outlib
  - Description: Library where result datasets will be written (e.g., WORK or a permanent libref).
  - Example: WORK or mylib
- diaglist
  - Description: Space-separated list of diagnosis indicators (defined elsewhere, e.g. with %DefineIndicator()). Each entry corresponds to a set of diagnosis codes/definitions.
  - Example: stroke diabetes

Optional parameters (with defaults and brief notes)
- diagtype (default: A B ALGA01 ALGA02)
  - Diagnosis types to include (space-separated). Accepts codes like A, B, C, G, H, + and LPR3 codes.
- icd8 (default: FALSE)
  - Include ICD-8 codes when available. TRUE/FALSE.
- indata (default: empty)
  - Input dataset of person identifiers (pnr) and optional fromdate/todate variables to restrict which persons/dates to consider.
- fromyear (default: 1977)
  - If no fromdate specified, diagnoses earlier than Jan 1 of this year are excluded.
- outdata (default: none)
  - If supplied, a combined table with selected fields (pnr, IDate, diagnose, outcome, source) is created in outlib.
- SOURCE (default: LPR PSYK PRIV LPR3)
  - Space-separated list of data sources to search. Each source must correspond to expected MASTER.<table> naming conventions (e.g., LPR_ADM, LPR_DIAG). LPR3 handling is supported specially.
- fromdate, todate (default: empty)
  - Variables (in the indata dataset) or literal dates used to restrict included records. If provided, macro rewrites them internally as c.<var> for comparisons; if not provided and fromyear set, fromdate defaults to 01JAN<fromyear>.
- admvar (default: start slut prioritet)
  - Additional admission-level variables to keep/consider (will be uppercased internally and used when copying tables).
- diagvar (default: diag diagtype)
  - Additional diagnosis-level variables to keep/consider (uppercased internally).

Behavior notes
- For each diag in diaglist, the macro creates datasets named like &outlib..LPR<diag>.ALL combining available sources. If outdata is specified the macro appends/selects pnr, start->IDate, diagnose, outcome, source into &outlib..&outdata.
- The macro attempts to harmonize differing character column lengths across source tables.
- Use %DefineIndicator() (or equivalent project conventions) to prepare definitions referenced by diaglist.

Example
%getDiag(work, stroke diabetes, icd8=TRUE, indata=mycohort, fromyear=1980, outdata=cohort_dx, SOURCE=LPR LPR3);

(See macros/getdiagv2.sas for full implementation details)
