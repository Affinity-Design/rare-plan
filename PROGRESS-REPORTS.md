# Daily Progress Report System

## Overview

This system generates progress reports at 8am and 8pm UTC daily, showing:
- Tasks completed
- Tasks in progress
- Blockers
- Next priorities

---

## Cron Configuration

Add this to your crontab (`crontab -e`):

```bash
# Daily progress reports for Rare Coin project
0 8 * * * cd /home/node/.openclaw/workspace/rare-plan && ./scripts/progress-report.sh >> logs/progress-$(date +\%Y-\%m-\%d).log 2>&1
0 20 * * * cd /home/node/.openclaw/workspace/rare-plan && ./scripts/progress-report.sh >> logs/progress-$(date +\%Y-\%m-\%d).log 2>&1
```

---

## Report Schedule

| Time (UTC) | Report Type |
|------------|-------------|
| 08:00 | Morning briefing - What's done, what's next |
| 20:00 | Evening recap - Day's progress, tomorrow's priorities |

---

## Report Format

Each report includes:
1. ✅ Completed since last report
2. 🟡 In progress now
3. 🚫 Current blockers
4. 📋 Next priorities
5. 📊 Stats (commits, files changed, etc.)

---

## Manual Report Generation

Run anytime:
```bash
cd /home/node/.openclaw/workspace/rare-plan
./scripts/progress-report.sh
```

Or ask Felix: "Generate progress report"

---

*Setup by: Felix*
*Date: 2026-02-24*
