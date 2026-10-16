# Advanced Agentforce Flow Administration Superbadge — Takeaways

## Core Concepts

### Agent Script Builder (Brewster)
- Brewster is authored in the Agent Script builder. The editable source is an `AiAuthoringBundle` (`.agent` file + `bundle-meta.xml`)
- Org lists drafts as `Brewster_N`, but they retrieve to a single `aiAuthoringBundles/Brewster/` folder whose `<target>` points at the committed version (e.g. `Brewster.v7`)
- Committing in the builder creates a new `BotVersion` (`vN`) plus a compiled `GenAiPlannerBundle` (`Brewster_vN`) with `localTopics` / `localActions` and per-action `input`/`output` schema.json
- The planner bundle's `agentScript/*_definition.agent` is the script base64-encoded — decode with `base64 -d` to read it
- An uncommitted draft does not change the org's planner — `GenAiPlannerDefinition` / `BotVersion` only move on commit

### Template-Triggered Prompt Flow with Manual Inputs
- `Gather_5_Most_Recent_Cases`: `processType=PromptFlow`, `triggerType=Capability`, no `capabilityTypes` — input variables (`accountInfo` Account record, `assetName` text) are created manually
- `Add Prompt Instructions` is an assignment with `elementSubtype=AddPromptInstructions` that appends to `$Output.Prompt` inside the loop
- **The prompt template must map the flow's inputs.** Inserting the flow resource without mapping leaves the flow `templateDataProvider` with no `<parameters>`; the flow runs with nulls and resolves to `[Provide:{PROMPT}]`
- Fixed mapping: `accountInfo ← {!$Input:Store}`, `assetName ← {!$Input:Asset.Name}`

### Merge Fields: Input vs Record Snapshot
- `{!$Input:Store.Name}` inserts just the field value
- `{!$RecordSnapshot:Store.snapshot}` dumps the full page-layout JSON (fields, related assets, cases, account team) — hundreds of lines of prompt bloat
- Use snapshots only when you want the model to see the whole record

### Prompt Template Called from a Flow
- `Create_Case_Brewster` calls the template via an action with `actionType=generatePromptResponse`; inputs are `Input:Asset` / `Input:Store`, which take the Get Records results
- Structured output: template `responseFormat=JSON` + `outputSchema=EquipmentRecommendation` (Lightning type → `@apexClassType/c__EquipmentRecommendationDTO`)
- Flow reads typed fields: `Get_Equipment_Recommendation.structuredResponse.recommendation` / `.rationale`

### Approval Workflow Flow
- `Approval_flow_for_Regional_Manager`: `processType=ApprovalWorkflow`, built from `orchestratedStages` with `stageSteps`
- A decision after the approval stage branches on `Regional_Manager_Approval_Step.Outputs.approvalDecision = "Approved"`; the default outcome is Rejected
- Final stages use `stepBackground` steps that launch autolaunched flows (Create Task for order vs service request)
- Exposed to the agent as an action: inputs `recordId`, `submissionComments` (required), `firstApprover`, `submitter`; output `textSummary`

## Verification Techniques

### Preview a Prompt Template via REST
Shows the fully resolved prompt (merge fields + flow output) without calling the LLM:
```bash
sf api request rest '/services/data/v67.0/einstein/prompt-templates/<Template_API_Name>/generations' --method POST -o <alias> \
  --body '{"isPreview":true,"inputParams":{"valueMap":{"Input:Store":{"value":{"id":"<AccountId>"}},"Input:Asset":{"value":{"id":"<AssetId>"}}}},"additionalConfig":{"applicationName":"PromptTemplateGenerationsInvocable"}}' \
  | jq -r '.prompt'
```
This caught the unmapped flow inputs: the flow section rendered as `[Provide:{PROMPT}]` instead of case history.

### Find What Changed Since the Last Pull
```bash
sf org list metadata -m Flow -o <alias> --json | jq -r '.result[] | select(.lastModifiedDate > "<ISO timestamp>") | .fullName'
```
Run across `Bot`, `AiAuthoringBundle`, `Flow`, `GenAiPromptTemplate`, etc. to retrieve only what each challenge touched.

## Gotchas
- `GenAiPromptTemplate` retrieves include every version; `activeVersionIdentifier` tells you which one is live — check that one, not the first `<templateVersions>` block
- `caseId` is required as a flow output in Challenge #2, but it's a reserved planner variable name — don't reuse it for an agent variable
- Agent actions in Agent Script don't populate agent variables automatically; outputs need explicit `set` mappings if later steps rely on them
