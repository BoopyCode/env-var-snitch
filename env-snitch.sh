#!/usr/bin/env bash
# Environment Variable Snitch - The tattletale for your misbehaving configs
# When your app acts weird but won't tell you why, I'm here to narc on your env vars

set -euo pipefail

# Colors for dramatic effect (because debugging should be entertaining)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color (like your app without proper config)

# The snitch's report card
report_file="env-snitch-report-$(date +%Y%m%d-%H%M%S).txt"

# Default suspects to interrogate (you can add more with -v)
suspect_vars=(
    "DATABASE_URL"
    "API_KEY"
    "SECRET_KEY"
    "DEBUG"
    "LOG_LEVEL"
    "ENVIRONMENT"
)

# Parse arguments like a detective interrogating a suspect
while getopts "v:h" opt; do
    case $opt in
        v)
            # Add custom suspects to the lineup
            suspect_vars+=("$OPTARG")
            ;;
        h)
            echo "Usage: $0 [-v VAR_NAME]..."
            echo "Snitches on your environment variables so you don't have to guess why things break."
            echo "  -v VAR_NAME  Add additional variable to check (can use multiple times)"
            exit 0
            ;;
        *)
            echo "Invalid option. Use -h for help (or just guess, like you do with env vars)"
            exit 1
            ;;
    esac
done

# The interrogation begins
printf "${YELLOW}🔍 Environment Variable Snitch Report${NC}\n"
printf "Generated: $(date)\n\n"

# Check each suspect
for var in "${suspect_vars[@]}"; do
    if [[ -z "${!var:-}" ]]; then
        printf "${RED}🚨 MISSING:${NC} $var (This variable is emptier than your excuses)\n"
    else
        # Show first 50 chars to avoid leaking your entire life story
        value="${!var}"
        preview="${value:0:50}"
        if [[ ${#value} -gt 50 ]]; then
            preview="${preview}..."
        fi
        printf "${GREEN}✅ PRESENT:${NC} $var=${preview}\n"
    fi
done

# Check for common troublemakers
printf "\n${YELLOW}🔎 Common Issues Check:${NC}\n"

# Is DEBUG set to true in what looks like production?
if [[ "${ENVIRONMENT:-}" =~ prod|production ]] && [[ "${DEBUG:-}" =~ true|True|TRUE|1 ]]; then
    printf "${RED}⚠️  WARNING:${NC} DEBUG=true in production! (Living dangerously, I see)\n"
fi

# Empty but "required" variables
empty_but_important=0
for var in "DATABASE_URL" "API_KEY" "SECRET_KEY"; do
    if [[ -z "${!var:-}" ]]; then
        empty_but_important=$((empty_but_important + 1))
    fi
done

if [[ $empty_but_important -gt 0 ]]; then
    printf "${RED}⚠️  WARNING:${NC} $empty_but_important critical variables are empty (Good luck with that)\n"
fi

# Save the evidence
{
    printf "Environment Variable Snitch Report\n"
    printf "Generated: $(date)\n\n"
    for var in "${suspect_vars[@]}"; do
        if [[ -z "${!var:-}" ]]; then
            printf "MISSING: $var\n"
        else
            printf "PRESENT: $var\n"
        fi
done
} > "$report_file"

printf "\n${GREEN}📄 Report saved to:${NC} $report_file (Evidence for when you blame the intern)\n"
printf "${YELLOW}Remember: Missing env vars are like missing socks - they cause problems and nobody knows where they went.${NC}\n"
