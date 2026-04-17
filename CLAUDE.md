# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

Sandbox for hands-on work from Salesforce Trailhead modules. Each Trailhead module (or set of related challenges) is developed on its own branch, typically named after the release and track (e.g. `spring25Admin`, `winter24AppBuilder`, `w24PlatformDev`, `spring24Admin`), then merged into `master` via PR. When starting new module work, create a new branch rather than committing directly to `master`.

## Salesforce DX layout

- Single default package directory: `force-app` (`sfdx-project.json`), source API version **60.0**, no namespace, login URL `login.salesforce.com`.
- Metadata lives under `force-app/main/default/` organized by type: `classes/`, `lwc/`, `aura/`, `objects/`, `flows/`, `flexipages/`, `layouts/`, `permissionsets/`, `permissionsetgroups/`, `quickActions/`, `customMetadata/`, `restrictionRules/`, `email/`.
- Scratch org shape: `config/project-scratch-def.json` (Developer edition, surveys enabled, `EnableSetPasswordInApi`).
- Ad-hoc scripts: `scripts/apex/*.apex` for anonymous Apex, `scripts/soql/*.soql` for queries — these are execution helpers, not deployable metadata.
- `.forceignore` deliberately excludes `package.xml`, LWC config/TypeScript files, and `__tests__/` from source push/pull — LWC Jest tests stay local and are not deployed.

## Common commands

Deploy / source sync (use the modern `sf` CLI):

```
sf org login web -a <alias>                         # authorize an org/scratch
sf org create scratch -f config/project-scratch-def.json -a <alias> -d   # create scratch org (optional)
sf project deploy start -d force-app                # deploy source to default org
sf project retrieve start -d force-app              # pull changes from org
sf apex run -f scripts/apex/hello.apex              # execute anonymous Apex
sf data query -f scripts/soql/account.soql         # run a SOQL file
sf apex run test -l RunLocalTests -c -r human      # run Apex tests with coverage
sf apex run test -n QueryContactTest -r human      # run a single Apex test class
```

Local JS tooling (LWC):

```
npm run test:unit                # sfdx-lwc-jest once
npm run test:unit:watch          # watch mode
npm run test:unit:debug          # debug mode
npm run test:unit:coverage       # with coverage
npm run lint                     # eslint on lwc/ and aura/
npm run prettier                 # format apex, lwc, xml, etc.
npm run prettier:verify          # check formatting without writing
```

Run a single LWC Jest test:

```
npx sfdx-lwc-jest -- -t "name of test" path/to/component/__tests__/file.test.js
```

Pre-commit: Husky runs `lint-staged`, which runs Prettier on all supported files and ESLint on anything under `aura/` or `lwc/`. If a commit fails on the hook, fix and re-stage — do not use `--no-verify`.

## Apex code notes

Existing classes in `force-app/main/default/classes/`:

- `QueryContact` / `QueryContactTest` — demonstrates both legacy `Database.query` with `:binding` and the newer `Database.queryWithBinds(..., AccessLevel.USER_MODE)` pattern. When adding dynamic SOQL, prefer `queryWithBinds` with `USER_MODE` to enforce FLS/sharing, matching `getContactIDWithBinds`.
- `ApexSecurityRest` — REST-exposed class; treat as a security-review example.
- `CountryCodeHelper` + `Country_Code__mdt` custom metadata — lookup pattern via Custom Metadata Type.
- `TestFactory` / `DataGenerationTest` — shared test data factory; new Apex tests should reuse `TestFactory` rather than inlining record setup.

The `QueryContact.getContactID` method has a `//do not modify any code above this line` comment preserved from the Trailhead challenge — leave Trailhead-provided scaffolding intact and only modify below the marked line.

## Branch / PR workflow

The recent history shows a consistent pattern: a seasonal feature branch (`spring25Admin`, `winter24AppBuilder`, …) is opened for each module, commits land there, and the branch is merged into `master` via GitHub PR ("Merge pull request #N from mknobloch/<branch>"). Preserve this flow — don't squash-merge or commit directly to `master`.
