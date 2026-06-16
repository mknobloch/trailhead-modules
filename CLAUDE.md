# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository purpose

Sandbox for hands-on work from Salesforce Trailhead modules. Each Trailhead module (or set of related challenges) is developed on its own branch, typically named after the release and track (e.g. `spring25Admin`, `winter24AppBuilder`, `w24PlatformDev`, `spring24Admin`), then merged into `master` via PR. When starting new module work, create a new branch rather than committing directly to `master`.

## 0. Ground Rules for Claude Code Behavior

### 0.1 Never Lie About Deploys
Do not claim a deployment succeeded without verification. After every `sf project deploy`, confirm success by:
1. Checking the command exit code
2. Reading the deployment status output for errors/warnings
3. For critical components, querying the org to verify the artifact exists

If a deploy fails, own the problem. Debug the error, fix it, and retry. Do NOT tell the user to go build it manually unless the limitation is a genuine platform constraint (see §0.4).

### 0.2 The Golden Rule: REST → Metadata → UI
When building or modifying Salesforce configuration, follow this priority order:
1. **REST API / Tooling API** — for operations that support it (CRUD on records, quick metadata reads)
2. **Metadata API (sf project deploy)** — for declarative config (objects, fields, flows, agents, permissions)
3. **Manual UI steps** — ONLY when the platform requires it (see §0.4 for the exhaustive list)

Never skip to manual steps because an API approach is harder. Figure it out.

### 0.3 Verify, Don't Trust
After deploying metadata:
```bash
# Confirm the component landed
sf org open -p "/lightning/setup/FlowList/home"
sf data query -q "SELECT Id, DeveloperName FROM [object] WHERE DeveloperName = '[name]'" -o [alias]
```
After creating data:
```bash
sf data query -q "SELECT COUNT(Id) FROM [Object]" -o [alias]
```

### 0.4 Manual-Only Setup Steps (Platform Constraints)
These genuinely cannot be automated via CLI/API and must be done in the UI:
- Enabling Einstein / Agentforce features (org-level toggles)
- Activating Omni-Channel routing configurations
- Enabling Messaging channels and linking to Experience Cloud
- Data Cloud activation and initial stream setup
- Some Prompt Builder lightning-type bindings
- Experience Cloud site publishing (first publish)

If it's not on this list, don't tell the user to do it manually.

### 0.5 Own Problems, Don't Punt
If a build or deploy fails, debug it. Check error messages, review metadata XML, fix and retry. Saying "you may need to manually configure this" is a last resort, not a first instinct.

### 0.6 Skill Awareness
You may have Salesforce-specific skills installed (e.g., `/sf-ai-agentforce`, `/sf-ai-agentscript`, Jaganpro skills). Check what's available before building from scratch. If a skill exists for the task, use it. If skills conflict or overlap, the project-level CLAUDE.md takes precedence.

---

## 1. Project Structure & Conventions

### 1.1 Org Aliases
Always use the org alias defined in the project CLAUDE.md or `sfdx-project.json`. Never hardcode org IDs. Pattern:
```bash
sf org display -o [alias]          # verify connection
sf project deploy start -o [alias] # deploy
sf data query -q "..." -o [alias]  # query
```

### 1.2 SPEC.md Discipline
Maintain a `SPEC.md` at project root with the demo/build plan. During the build, periodically review and update it to keep the spec in sync with what's actually deployed. This prevents drift between intent and implementation.

### 1.3 Session Documentation
For complex multi-session projects, document what changed per session directly in the project CLAUDE.md or a `SESSIONS.md` file. Include: what was built, what broke, what workarounds were applied. Future sessions (or other engineers) depend on this.

### 1.4 Git Hygiene
- Never use `git add -A` or `git add .` — stage files explicitly
- Review `git diff --staged` before committing
- Use descriptive commit messages referencing the build step

---

## 2. Data Model

### 2.1 Picklist Fields and Agentic Experiences
**Avoid restricted picklist fields** on any object that will be referenced by Agentforce agents, Prompt Builder templates, or Flow actions invoked by agents.

Why: Restricted picklists enforce value validation at the API level. When an agent's LLM generates a response that doesn't exactly match a restricted value (casing, whitespace, abbreviation), the operation fails silently or throws a runtime error.

Mitigations if you must use restricted picklists:
- Normalize the LLM output to the restricted values in your prompt instructions
- Add validation in the Flow or Apex action before the DML
- Better yet: just use unrestricted picklists for agentic-facing fields

### 2.2 Non-Breaking Spaces and Special Characters
Agent-retrieved data (especially from Knowledge articles, XML, or external sources) can contain `\xa0` (non-breaking spaces) and other invisible characters. These will break string comparisons, SOQL filters, and picklist matching. Always sanitize:
```apex
String clean = rawValue.normalizeSpace().trim();
```

### 2.3 Field-Level Security (FLS) Checklist
After creating custom fields, always ensure:
- Permission Set or Profile grants Read (and Edit if needed) access
- If using a dedicated permission set (recommended), assign it to the appropriate users/integration user
- For packaged or managed orgs, check FLS on both the field and the parent object

Pattern:
```xml

    true
    MyObject__c.MyField__c
    true

```

---

## 3. Apex

### 3.1 General Conventions
- Regex patterns: define as `private static final Pattern` class-level constants, not inline
- Bulkify all triggers and handlers — no SOQL/DML inside loops
- Use `@AuraEnabled(cacheable=false)` for any method called after DML operations. `cacheable=true` is browser-cached even on imperative wire calls — stale data will haunt you
- Test classes: aim for 85%+ coverage with meaningful assertions, not just line coverage

### 3.2 Apex in Agent Orchestration
When building Apex actions for Agentforce:
- Keep actions focused and single-purpose — one action = one capability
- Return structured results (wrapper classes or custom types) not raw strings
- Handle all exceptions gracefully — an unhandled Apex exception in an agent action produces a generic "I can't help with that" response with no debugging info
- Log inputs and outputs for debugging (see §6.3)

### 3.3 The Fan-Out Pattern (Chain of Specialization)
For complex agent tasks that need multiple LLM analyses (e.g., summarize a document AND check compliance):
1. Define specialist Prompt Builder templates for each analysis type
2. Invoke them in sequence from Apex (or parallel if latency allows)
3. Assemble results in Apex into a single output record
4. Return the assembled result to the agent/user

Example from legislative analysis:
billSummary template → summary result
cpaChecks template  → compliance result
Apex assembles both → Bill_Analysis__c record

---

## 4. Lightning Web Components (LWCs)

### 4.1 Prefer uiRecordApi Before Apex
Before writing an Apex controller for an LWC, check if `lightning/uiRecordApi` can handle it:
- `getRecord` / `getFieldValue` for reads
- `updateRecord` / `createRecord` for writes
- `getPicklistValues` for picklist options

Only reach for Apex when you need: complex queries, cross-object operations, callouts, or DML on multiple objects. Claude Code tends to over-engineer with Apex when wire adapters would suffice.

### 4.2 The Cacheable Trap
```javascript
// WRONG — data will be stale after any DML
@AuraEnabled(cacheable=true)
public static List<Case> getCases() { ... }

// RIGHT — fresh data every call
@AuraEnabled(cacheable=false)
public static List<Case> getCases() { ... }
```
`cacheable=true` serves from the browser's LDS cache. Even imperative `.call()` invocations use the cache. Only use `cacheable=true` for truly static reference data.

### 4.3 Aura Wrapper Pattern
When overriding standard buttons (New, Edit) with an LWC, you need an Aura component as the "controller" that hosts the LWC. This is a platform requirement:
AuraWrapper.cmp  →  embeds  →  ActualLWC
(implements override interface)    (does all the work)

### 4.4 Experience Cloud LWC Gotchas
- `@wire` adapters behave differently in Experience Cloud vs. Lightning App Builder
- Guest user profiles have severely restricted FLS — test with the actual guest profile
- MessagingSession and ConversationEntry objects have non-obvious permission requirements; ConversationEntry often needs explicit permission set grants even when the parent MessagingSession is accessible
- localStorage/sessionStorage: add rehydration guards. Experience Cloud pages reload unpredictably

---

## 5. Flows

### 5.1 Flow Type Selection
Match the flow type to the use case. Claude Code defaults to Autolaunched Flow for everything — this is wrong.

| Use Case | Correct Flow Type |
|---|---|
| Screen-based user interaction | Screen Flow |
| Triggered by record change | Record-Triggered Flow |
| Called from Apex/other Flows | Autolaunched Flow |
| Omni-Channel routing logic | Omni-Channel Flow (not Autolaunched) |
| Scheduled batch operations | Scheduled Flow |
| Agent action / Agentforce | Autolaunched Flow (invocable) |

### 5.2 Deployment Failure Patterns

| Error Pattern | Likely Cause | Fix |
|---|---|---|
| `Cannot find FlowTemplate` | Referenced subflow missing | Deploy dependency first |
| `Invalid field` on Flow variable | Field API name wrong/missing | Verify field in org |
| `Unsupported process type` | Wrong flow type in XML | Check `processType` value |
| `Missing description` | Some types require it | Add `<description>` element |

### 5.3 Agent Email Triage via Flow
For email-to-case agent scenarios, a Record-Triggered Flow on EmailMessage can bypass the planner entirely:
1. EmailMessage created → triggers Flow
2. Flow extracts subject/body, runs classification logic
3. Flow creates/updates Case with structured fields
4. No planner involvement — faster, more predictable

Use this when email handling follows deterministic rules. Reserve the planner for conversational interactions.

---

## 6. Agentforce & AI Agents

### 6.1 The #1 Rule: Edit Agent Config via Metadata XML Only
**Never edit Agentforce agent configuration through the UI if you're managing it in source.** UI edits and metadata deploys will conflict, and the merge behavior is unpredictable.

All configuration lives in:
force-app/main/default/genAiPlanners/
force-app/main/default/genAiPlannerBundles/
force-app/main/default/genAiPlugins/
force-app/main/default/genAiFunctions/

Pull before editing. Deploy after changes. Never hand-edit in Setup between pulls.

### 6.2 Planner Bundle Structure
```xml
<GenAiPlannerBundle>
    <masterLabel>My Agent</masterLabel>
    <plannerType>GenAiPlanner</plannerType>
    <attributeMappings>
        <attributeMapping>
            <mappingKey>myVariable</mappingKey>
            <mappingValue>actionInputField</mappingValue>
        </attributeMapping>
    </attributeMappings>
</GenAiPlannerBundle>
```

**Critical gotcha:** `caseId` is a reserved planner variable name. Do not use it as a custom variable — it will silently conflict with the platform's internal case routing.

### 6.3 Linking Topics to Planners
The metadata API has no element to associate a GenAiPlugin (topic) with a planner. Instead, insert a record on the `GenAiPlannerFunctionDef` setup object:
```bash
sf data create record -s GenAiPlannerFunctionDef -v "PlannerId=<ID> Plugin=<ID>" -o [alias]
```
Query `GenAiPlannerDefinition` and `GenAiPluginDefinition` to get the IDs.

### 6.5 Debugging Agent "I Can't Help With That"
This is the generic fallback for any unhandled error. Debug path:
1. Query `GenAiInteractionLog` or `SetupAuditTrail` for the session
2. Check if the action (Apex/Flow) threw an unhandled exception
3. Check if the planner couldn't match user intent to a configured action
4. Check if a picklist or field validation rejected the LLM's generated value
5. Check FLS on every field the action touches for the agent's running user

You can query the agent session information to help identify the failure point.

### 6.6 Multi-Surface Agent Architecture
- **Chat/Messaging**: Uses ContextResolver + Planner. Full conversational flow with intent matching
- **Email**: Can bypass the planner via Record-Triggered Flow on EmailMessage. More deterministic, avoids planner failure modes

Design your agent to use the right surface for the right interaction type. Don't force everything through the planner.

### 6.7 Prompt Builder / Prompt Templates

**Version Identifiers:** The `<versionIdentifier>` in prompt template metadata must use the server's hash-suffix format, not arbitrary strings. Pull the template after UI creation to get the correct format.

**Lightning Types:** For complex input/output bindings, create custom Lightning Types in the Prompt Builder UI — currently the most reliable approach. Pull metadata into source after creation.

**Template Design for Agents:**
- One template = one analysis task
- Include explicit output format instructions
- Reference merge fields for dynamic data
- Test in Prompt Builder preview before wiring into agents

---

## 7. Deployment Patterns

### 7.1 Verified Multi-Phase Deploy
For complex orgs with interdependent metadata:
```bash
# Phase 1: Objects, fields, custom metadata types
sf project deploy start -d force-app/main/default/objects -o [alias]

# Phase 2: Permission sets (depend on fields)
sf project deploy start -d force-app/main/default/permissionsets -o [alias]

# Phase 3: Apex classes (depend on objects)
sf project deploy start -d force-app/main/default/classes -o [alias]

# Phase 4: Flows (depend on fields + Apex)
sf project deploy start -d force-app/main/default/flows -o [alias]

# Phase 5: Agent config (depends on everything above)
sf project deploy start -d force-app/main/default/genAiPlanners -o [alias]
sf project deploy start -d force-app/main/default/genAiPlugins -o [alias]

# Phase 6: Experience Cloud / FlexiPages
sf project deploy start -d force-app/main/default/flexipages -o [alias]

# Phase 7: Data seeding
sf data import tree -f data/plan.json -o [alias]
```
Verify after each phase before proceeding.

### 7.2 Destructive Deployments
```bash
sf project deploy start --metadata-dir destructive/ --manifest destructive/package.xml \
  --post-destructive-changes destructive/destructiveChanges.xml -o [alias]
```
destructive/
package.xml              # empty <Package> with API version only
destructiveChanges.xml   # lists components to delete

### 7.3 First Deploy Failures Are Normal
Almost every complex deploy fails the first attempt — dependency ordering, missing references, API version mismatches. When it happens: read the error, fix the root cause, retry. Don't panic, don't shortcut to manual.

---

## 8. Data Cloud

### 8.1 REST API Patterns
```bash
sf api request rest '/services/data/v67.0/ssot/queryable-objects' -o [alias]
sf api request rest '/services/data/v67.0/ssot/query' \
  -b '{"sql":"SELECT ..."}' -o [alias] --method POST
```

### 8.2 Metadata Types
- `DataSource` — connection definitions
- `DataStream` — ingestion mappings
- `DataTransform` — transformation logic
- `CalculatedInsight` — computed metrics

Initial Data Cloud activation and stream enablement must be done in the UI (see §0.4).

---

## 9. Heroku Integration

### 9.1 The 30-Second Timeout
Heroku enforces a 30-second request timeout. For long operations:
- Async processing with a worker dyno
- Return a job ID immediately, poll for results
- Or chunk the work to fit within the timeout

### 9.2 Separate Git Repos
Heroku apps deploy from their own repos, not the Salesforce DX project:
my-project/          # Salesforce DX source
my-project-heroku/   # Heroku app (Python/Node)

---

## 10. Demo Building Tips

### 10.1 Multi-Channel Planning
Build a single scenario with channel-specific variants — full email version AND shorter chat version. Choose the right medium on demo day.

### 10.2 Analytics
Describe dashboard components; Claude Code can structure the data model and seed data. Skew intentionally: positive for "good" metrics, negative for "problem areas."

### 10.3 Structured Intake
Say "Let's talk more about [thing]" to trigger a structured interview before building. Prevents assumption-driven builds.

### 10.4 Model Selection
Opus is significantly better than Sonnet for Salesforce builds — fewer hallucinated deploys, better architecture decisions, more reliable metadata XML. Use Opus for agents and complex Apex; Sonnet is fine for data seeding and simple LWCs.

---

## Appendix: Quick Reference

### SF CLI Commands
```bash
sf org list                              # connected orgs
sf org display -o [alias]                # org details + token
sf project deploy start -o [alias]       # deploy source
sf project retrieve start -o [alias]     # retrieve from org
sf apex run -f scripts/myScript.apex -o [alias]  # anonymous Apex
sf data query -q "SELECT ..." -o [alias] # SOQL query
sf data import tree -f data/plan.json -o [alias] # import data
sf org open -o [alias]                   # open org in browser
sf org open -p "/lightning/setup/..." -o [alias]  # specific page
```

### Common Metadata Paths
force-app/main/default/
objects/           # Custom objects and fields
classes/           # Apex classes
triggers/          # Apex triggers
flows/             # Flows
permissionsets/    # Permission sets
flexipages/        # Lightning pages
lwc/               # Lightning Web Components
aura/              # Aura components
genAiPlanners/     # Agentforce planner configs
genAiPlugins/      # Agentforce plugin configs
genAiFunctions/    # Agentforce function configs
prompts/           # Prompt Builder templates
experiences/       # Experience Cloud sites

## Branch / PR workflow

The recent history shows a consistent pattern: a seasonal feature branch (`spring25Admin`, `winter24AppBuilder`, …) is opened for each module, commits land there, and the branch is merged into `master` via GitHub PR ("Merge pull request #N from mknobloch/<branch>"). Preserve this flow — don't squash-merge or commit directly to `master`.
