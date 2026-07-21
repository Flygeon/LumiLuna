# Debug Session: epub-manifest-missing

Status: [OPEN]

## Symptom

Opening an EPUB fails with `Incorrect EPUB manifest: item with href = "Text\\Volume_0.xhtml" is missing.`

## Hypotheses

1. ZIP entries use backslashes while the EPUB parser expects forward slashes.
2. `normalizeEpub` normalizes ZIP entry names but does not normalize manifest `href` values.
3. The manifest path differs from the ZIP entry by case or relative-path normalization.
4. The EPUB genuinely lacks the manifest-referenced XHTML entry.

## Plan

1. Add minimal instrumentation around EPUB archive names and manifest references.
2. Reproduce by opening the failing EPUB and inspect runtime evidence.
3. Apply the smallest evidence-backed fix.
4. Rebuild and compare behavior.
