# Apex for Agentforce Superbadge — Takeaways

## Core Concepts

### Agentforce Architecture
- **Subagents (Topics)** are `GenAiPlugin` metadata with `pluginType=Topic` — they group actions + instructions under a classification
- **Actions** are `GenAiFunction` metadata pointing to flows or Apex classes via `invocationTarget`
- **Planner** orchestrates topics; linking a topic to a planner requires a DML insert on `GenAiPlannerFunctionDef`, not a metadata deploy
- **Context variables** on the Bot definition surface fields (like `MessagingSession.Email__c`) into the agent's prompt

### Invocable Apex for Agents
- `@InvocableMethod` makes a class callable as an agent action
- `@InvocableVariable(required=true description='...')` on input wrapper fields — description is mandatory for agent discoverability
- Output wrapper uses `@InvocableVariable(label='status' ...)` to name the output for the planner
- Exception handling is critical — unhandled exceptions produce generic "I can't help" responses with no debug info

### Prompt Template Invocation from Apex
- `ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(templateApiName, input)` — the class is `EinsteinLLM`, not `EinsteinPromptTemplateGenerations`
- Input params keyed by the template's `referenceName` (e.g. `'Input:experience'`)
- Response comes back as `generationsOutput.generations[0].text` — raw JSON string to deserialize

### Permission Model
- Agent actions need explicit Apex class access on the permission set assigned to the `EinsteinServiceAgent User`
- Field-level security on every object the action touches must be granted

## Learnings for Claude Code Workflow

### Source Format / Project Structure
- Keep module directories OUT of `sfdx-project.json` — enables `-r <dir>` retrieves without conflicts
- `-d <dir>/path` deploys work from any directory regardless of project config
- Full dependency pull before closing out makes the source self-contained and portable

### CLAUDE.md Evolutions
- The existing CLAUDE.md guidance on agent metadata (section 6) held up well
- Confirmed: `GenAiPlanner` type isn't retrievable in all API versions — use `GenAiPlannerBundle` instead
- New pattern discovered: DML on setup objects (`GenAiPlannerFunctionDef`) as a deployment mechanism when metadata API doesn't support the association
