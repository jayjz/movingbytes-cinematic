# Notion Database Template for DevLab Experiments

## Database Structure

Create a Notion database with these properties:

### Properties
1. **Name** (Title) - Experiment name/ID
2. **Date** (Date) - When experiment ran
3. **Status** (Select) - SUCCESS, PARTIAL, FAILED, IN_PROGRESS
4. **Hypothesis** (Text) - One-line hypothesis
5. **Duration** (Number) - Minutes
6. **Tags** (Multi-select) - Add tags as needed
7. **Code Path** (URL) - Link to code in experiments/
8. **Results Summary** (Text) - Brief results
9. **Learnings** (Text) - Key takeaways
10. **Next Steps** (Text) - Follow-up actions
11. **Telegram Msg ID** (Text) - For reference
12. **Synced At** (Date) - Last sync timestamp

### Page Template Content
```
## Experiment: {{NAME}}

**Date:** {{DATE}}
**Status:** {{STATUS}}
**Duration:** {{DURATION}} min

### Hypothesis
{{HYPOTHESIS}}

### Approach
{{APPROACH}}

### Results
{{RESULTS}}

### Key Learnings
{{LEARNINGS}}

### Artifacts
- Code: {{CODE_PATH}}
- Full Report: {{REPORT_PATH}}

### Next Steps
{{NEXT_STEPS}}
```

## Setup Instructions

1. Create new database in Notion
2. Add properties as listed above
3. Get database ID from URL: `https://notion.so/{workspace}/{DATABASE_ID}?v=...`
4. Add database ID to OpenClaw config: `plugins.entries.notion.config.databaseId`
5. Share database with your Notion integration

## API Integration

When pushing from DevLab, use:
```json
{
  "parent": { "database_id": "YOUR_DB_ID" },
  "properties": {
    "Name": { "title": [{ "text": { "content": "EXP-001: Test" } }] },
    "Date": { "date": { "start": "2024-01-01" } },
    "Status": { "select": { "name": "SUCCESS" } },
    ...
  }
}
```
