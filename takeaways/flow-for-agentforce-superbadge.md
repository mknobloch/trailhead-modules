# Flow for Agentforce Superbadge — Takeaways

## Core Concepts

### Flow-First Agent Actions
- All agent actions built as Autolaunched Flows (no Apex)
- Flows handle verification, refund processing, and sentiment analysis
- Template-Triggered Prompt Flow for conversation summarization

### Customer Verification Pattern
- Multi-step: collect email → send verification code → verify code → log verification
- Security: never disclose whether a user/email exists — always return a generic "if valid, you'll receive a code" message
- Once verified in a session, don't re-verify

### Planner Bundle — Newer Format
- Topics (`localTopics`) and actions (`localActions`) are embedded directly inside the `GenAiPlannerBundle` XML
- No separate `GenAiPlugin` or `GenAiFunction` metadata files — everything is self-contained in the bundle
- Topic links (`localTopicLinks`) and action links (`localActionLinks`) wire them to the planner
- This is the format used by the newer Agentforce Builder (vs Legacy builder which uses separate GenAiPlugin metadata)

### Attribute Mappings
- Planner bundle `attributeMappings` pass data between subagents and actions
- `mappingType=Variable` passes stored values (e.g. verified contact ID) to downstream actions
- `mappingType=ContextVariable` passes session context (e.g. RoutableId → messagingSessionId)

### Prompt Flow for Transcripts
- `Send_Esso_Messaging_Session_Transcript` — a template-triggered prompt flow
- Uses `Summarize_Esso_Messaging_Session` prompt template (record summary type)
- Pattern: summarize conversation → send email with transcript

## Metadata Format Differences vs Apex Superbadge

| Aspect | Apex Superbadge (Legacy Builder) | Flow Superbadge (New Builder) |
|--------|----------------------------------|-------------------------------|
| Topics | Separate `GenAiPlugin` metadata files | Embedded `localTopics` in planner bundle |
| Actions | Separate `GenAiFunction` metadata files | Embedded `localActions` in planner bundle |
| Linking | DML on `GenAiPlannerFunctionDef` | `localTopicLinks` / `localActionLinks` in XML |
| Deployability | Topics deploy independently, then link | Bundle is self-contained, deploys atomically |

## Gotcha
- Retrieved planner bundles may contain nil `functionName` entries in `localActionLinks` that fail on deploy — strip them before redeploying.
