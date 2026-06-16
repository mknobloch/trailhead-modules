# Start Trailhead Module

Use this skill when the user wants to begin a new Trailhead module, superbadge, or trail. It handles org authentication, project structure setup, branch creation, and initial metadata retrieval.

## Trigger phrases
- "start a new module"
- "new trailhead module"
- "set up for [module name]"
- "let's do [trailhead URL]"

## Steps

### 1. Gather Information

Ask the user for:
- **Module name or URL** — the Trailhead module/superbadge they're working on
- **Org login URL** — the instance URL for the Developer Edition org (e.g. `https://xxx-dev-ed.develop.my.salesforce.com`)
- **Org alias** — a short alias to use for the org (suggest one based on the module name, camelCase, e.g. `apexForAgentforceSuperbadge`)

### 2. Authenticate the Org

```bash
sf org login web -a <alias> -r <loginUrl>
```

Wait for the user to complete the browser auth flow. Verify success:

```bash
sf org display -o <alias>
```

### 3. Create Branch

Create a feature branch named after the module alias:

```bash
git checkout -b <alias>
```

### 4. Set Up Module Directory

Do NOT add the module directory to `sfdx-project.json` — leave only `legacyModules` as the package directory. This keeps `-r` retrieves working cleanly.

Just create the directory:

```bash
mkdir -p <alias>
```

### 5. Retrieve Existing Metadata

Use `-r <alias>` to retrieve metadata into the module's directory. This works because the module directory is NOT in `sfdx-project.json`.

```bash
sf project retrieve start -m "ApexClass:MyClass" -r <alias> -o <alias>
```

Retrieve multiple types:
```bash
sf project retrieve start -m "ApexClass:Foo" -m "ApexClass:Bar" -m "PermissionSet:MyPermSet" -r <alias> -o <alias>
```

### 6. Deploy Pattern

Deploy specific components:
```bash
sf project deploy start -d <alias>/classes/MyClass.cls -d <alias>/classes/MyClass.cls-meta.xml -o <alias>
```

Deploy a whole metadata type directory:
```bash
sf project deploy start -d <alias>/permissionsets -o <alias>
```

### 7. Commit Pattern

**Superbadges** (sequential numbered challenges): Commit after each challenge passes:
```
Challenge #N: <short description>

- Bullet points of what was done
- Keep it concise

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
```

**Modules/Trails** (no sequential challenges): Commit at logical completion points:
```
Complete <module name>: <what was built>

- Bullet points of what was done

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
```

### 8. Full Dependency Pull

Before closing out, recursively pull all supporting metadata so the module directory is self-contained and deployable to any org. Trace dependencies from:

- **Flows** referenced by GenAiFunctions or bot config
- **Custom objects/fields** referenced in those flows, Apex classes, and permission sets
- **Custom fields on standard objects** (e.g. `MessagingSession.Email__c`, `CampaignMember.Booking__c`)
- **Prompt templates** invoked from Apex

```bash
sf project retrieve start -m "Flow:My_Flow" -m "CustomObject:My_Object__c" -m "CustomField:StandardObj.Custom__c" -r <alias> -o <alias>
```

Note: Routing flows may contain hardcoded org-specific IDs (queues, service channels) that won't port — call this out in the commit message.

### 9. Close Out — Push & PR

Push the branch and create a PR to merge into `master`:

```bash
git push -u origin <alias>
gh pr create --title "<Module/Superbadge name>" --body "## Summary
- <what was built>

## Challenges completed
- Challenge #1: ...
- Challenge #2: ...

🤖 Generated with [Claude Code](https://claude.com/claude-code)"
```

After merge, the branch pattern stays consistent with the repo history (e.g. `spring25Admin`, `apexForAgentforceSuperbadge`).

---

## Key Learnings

- **`-r` flag** cannot target a path that overlaps a package directory in `sfdx-project.json`. Keep module dirs out of packageDirectories, or remove temporarily for retrieves.
- **`-d` flag** (source-dir) on retrieve means "re-retrieve what's already at this local path" — it does NOT accept `-m` simultaneously.
- **`-d` flag** on deploy works from any directory regardless of `sfdx-project.json`.
- **Org alias** is used everywhere: `-o <alias>` on every sf command.
- **Agent metadata** (GenAiPlugin, GenAiFunction, GenAiPlannerBundle) deploys fine. GenAiPlanner type may not be available depending on API version.
- **Bot context variables** use `dataType=Text` for custom fields, `developerName` cannot end with `__c` or contain consecutive underscores.
- **Linking topics to planners** requires DML insert on `GenAiPlannerFunctionDef` (PlannerId + Plugin fields) — not metadata deploy.
- **ConnectApi for prompt templates** uses `ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate()` not `ConnectApi.EinsteinPromptTemplateGenerations`.
