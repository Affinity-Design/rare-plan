#!/bin/bash

# Daily Progress Report Generator for Rare Coin Project
# Run at 8am and 8pm UTC

REPORT_DIR="/home/node/.openclaw/workspace/rare-plan"
TODO_FILE="$REPORT_DIR/TODO.md"
LOG_DIR="$REPORT_DIR/logs"

# Get current time
NOW=$(date +"%Y-%m-%d %H:%M:%S UTC")
REPORT_TYPE="Progress Report"

echo "=========================================="
echo "📊 RARE COIN - $REPORT_TYPE"
echo "📅 $NOW"
echo "=========================================="
echo ""

# Count completed tasks today
COMPLETED_TODAY=$(git log --since="today 00:00:00" --oneline 2>/dev/null | wc -l)
TOTAL_COMMITS=$(git log --oneline 2>/dev/null | wc -l)

echo "📈 TODAY'S ACTIVITY"
echo "-------------------"
echo "Commits today: $COMPLETED_TODAY"
echo "Total commits: $TOTAL_COMMITS"
echo ""

# Show recent commits
echo "📝 RECENT COMMITS (Last 5)"
echo "---------------------------"
git log --oneline -5 2>/dev/null || echo "No commits yet"
echo ""

# Parse TODO for status
echo "📋 TASK STATUS"
echo "--------------"
if [ -f "$TODO_FILE" ]; then
    echo "From TODO.md:"
    grep -c "✅" "$TODO_FILE" 2>/dev/null && echo "completed tasks" || echo "0 completed tasks"
    grep -c "🟡" "$TODO_FILE" 2>/dev/null && echo "in progress tasks" || echo "0 in progress"
    grep -c "⏳" "$TODO_FILE" 2>/dev/null && echo "pending tasks" || echo "0 pending"
    grep -c "🔴" "$TODO_FILE" 2>/dev/null && echo "blocked tasks" || echo "0 blocked"
fi
echo ""

# Show blockers
echo "🚫 CURRENT BLOCKERS"
echo "-------------------"
if [ -f "$TODO_FILE" ]; then
    grep -A1 "Blockers" "$TODO_FILE" 2>/dev/null | head -5 || echo "No blockers listed"
fi
echo ""

# Next priorities
echo "🎯 NEXT PRIORITIES"
echo "------------------"
echo "1. Fix rare-fyi visual issues (audit live site)"
echo "2. Complete staking contract audit (waiting for source)"
echo "3. Run Supabase migration"
echo "4. Continue blog content creation"
echo "5. Update footer component"
echo ""

echo "=========================================="
echo "Report generated at $NOW"
echo "Next report: $(date -d '+12 hours' +' %Y-%m-%d %H:%M:%S UTC' 2>/dev/null || echo 'in 12 hours')"
echo "=========================================="
