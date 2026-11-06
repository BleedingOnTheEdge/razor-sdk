#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# BleedingOnTheEdge - Razor SDK NuGet Publishing Script
# Organization: BleedingOnTheEdge (sina1vali@gmail.com)
# Package: BleedingOnTheEdge.Razor.Sdk
# -----------------------------------------------------------------------------
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${REPO_ROOT}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

VERSION=""
API_KEY="${NUGET_API_KEY:-}"
SKIP_TESTS=false
DRY_RUN=false
PUSH_GITHUB=false
NUGET_SOURCE="https://api.nuget.org/v3/index.json"
GITHUB_SOURCE="https://nuget.pkg.github.com/BleedingOnTheEdge/index.json"

print_header() {
  echo -e "${CYAN}${BOLD}====================================================================${NC}"
  echo -e "${CYAN}${BOLD}       BleedingOnTheEdge.Razor.Sdk - NuGet Package Publisher             ${NC}"
  echo -e "${CYAN}${BOLD}====================================================================${NC}"
  echo -e "Organization: ${BOLD}BleedingOnTheEdge${NC} (sina1vali@gmail.com)"
  echo -e "Package ID:   ${BOLD}BleedingOnTheEdge.Razor.Sdk${NC}"
  echo ""
}

print_usage() {
  echo "Usage: ./scripts/publish-nuget.sh [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  -v, --version <version>    Version to publish (e.g. 1.0.0, 1.0.1-preview1)"
  echo "  -k, --api-key <key>        NuGet API key (or set NUGET_API_KEY env var)"
  echo "  --skip-tests               Skip running unit & integration tests before pack"
  echo "  --dry-run                  Build and pack the package without pushing to NuGet"
  echo "  --github                   Also publish to GitHub Packages"
  echo "  -h, --help                 Show this help message"
  echo ""
  echo "Environment Variables:"
  echo "  NUGET_API_KEY              API Key from nuget.org"
  echo "  GITHUB_TOKEN               GitHub PAT with write:packages scope (for --github)"
}

while [[ $# -gt 0 ]]; do
  case $1 in
    -v|--version)
      VERSION="$2"
      shift 2
      ;;
    -k|--api-key)
      API_KEY="$2"
      shift 2
      ;;
    --skip-tests)
      SKIP_TESTS=true
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --github)
      PUSH_GITHUB=true
      shift
      ;;
    -h|--help)
      print_usage
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"
      print_usage
      exit 1
      ;;
  esac
done

print_header

# Resolve version if not passed
if [ -z "$VERSION" ]; then
  # Extract version from Sdk.csproj if present
  VERSION=$(grep -oPm1 "(?<=<Version>)[^<]+" src/Sdk/Sdk.csproj 2>/dev/null || true)
  if [ -z "$VERSION" ]; then
    VERSION="1.0.0"
  fi
  echo -e "Target version resolved to: ${BOLD}${VERSION}${NC}"
fi

# Pre-publish automated verification
if [ "$SKIP_TESTS" = false ]; then
  echo -e "\n${CYAN}▶ 1. Running automated test suites before release...${NC}"
  dotnet test tests/Sdk.UnitTests/Sdk.UnitTests.csproj -c Release --nologo -v q
  dotnet test tests/Sdk.IntegrationTests/Sdk.IntegrationTests.csproj -c Release --nologo -v q
  echo -e "${GREEN}✓ All SDK test suites passed successfully.${NC}"
else
  echo -e "\n${YELLOW}⚠ Skipping test execution as requested.${NC}"
fi

# Clean and build release package
echo -e "\n${CYAN}▶ 2. Building and packaging BleedingOnTheEdge.Razor.Sdk v${VERSION}...${NC}"
rm -rf dist/nupkg
mkdir -p dist/nupkg

dotnet pack src/Sdk/Sdk.csproj \
  -c Release \
  -p:Version="${VERSION}" \
  -p:IncludeSymbols=true \
  -p:SymbolPackageFormat=snupkg \
  -o dist/nupkg \
  --nologo

NUPKG_PATH="dist/nupkg/BleedingOnTheEdge.Razor.Sdk.${VERSION}.nupkg"
SNUPKG_PATH="dist/nupkg/BleedingOnTheEdge.Razor.Sdk.${VERSION}.snupkg"

if [ ! -f "$NUPKG_PATH" ]; then
  echo -e "${RED}Error: Expected package file not found at ${NUPKG_PATH}${NC}"
  exit 1
fi

echo -e "${GREEN}✓ Successfully created package: ${BOLD}${NUPKG_PATH}${NC}"
if [ -f "$SNUPKG_PATH" ]; then
  echo -e "${GREEN}✓ Successfully created symbols: ${BOLD}${SNUPKG_PATH}${NC}"
fi

# Dry run exit
if [ "$DRY_RUN" = true ]; then
  echo -e "\n${YELLOW}[DRY RUN] Package created at ${NUPKG_PATH}. Skipping remote upload.${NC}"
  exit 0
fi

# Check API Key
if [ -z "$API_KEY" ]; then
  echo ""
  echo -e "${YELLOW}====================================================================${NC}"
  echo -e "${YELLOW}               NuGet API Key Required                              ${NC}"
  echo -e "${YELLOW}====================================================================${NC}"
  echo "To publish BleedingOnTheEdge.Razor.Sdk to nuget.org:"
  echo "1. Sign in to https://www.nuget.org with account: sina1vali@gmail.com"
  echo "2. Go to: https://www.nuget.org/account/apikeys"
  echo "3. Create a key with 'Push new packages and package versions' scope"
  echo "   for the 'BleedingOnTheEdge' organization or 'BleedingOnTheEdge.Razor.Sdk*'"
  echo "4. Export or pass the key:"
  echo "     export NUGET_API_KEY=\"<your-api-key>\""
  echo "     ./scripts/publish-nuget.sh -v ${VERSION}"
  echo ""
  
  if [ -t 0 ]; then
    read -rp "Enter your NuGet API key now (or press Enter to cancel): " USER_KEY
    if [ -n "$USER_KEY" ]; then
      API_KEY="$USER_KEY"
    else
      echo -e "${RED}Aborted. No API key provided.${NC}"
      exit 1
    fi
  else
    echo -e "${RED}Error: Non-interactive session and NUGET_API_KEY environment variable is not set.${NC}"
    exit 1
  fi
fi

# Push to NuGet.org
echo -e "\n${CYAN}▶ 3. Pushing BleedingOnTheEdge.Razor.Sdk v${VERSION} to NuGet Gallery (nuget.org)...${NC}"
dotnet nuget push "$NUPKG_PATH" \
  --api-key "$API_KEY" \
  --source "$NUGET_SOURCE" \
  --skip-duplicate

echo -e "${GREEN}${BOLD}✓ Published successfully to NuGet!${NC}"
echo -e "Public listing: ${BOLD}https://www.nuget.org/packages/BleedingOnTheEdge.Razor.Sdk/${VERSION}${NC}"

# Optional Push to GitHub Packages
if [ "$PUSH_GITHUB" = true ]; then
  echo -e "\n${CYAN}▶ 4. Pushing to GitHub Packages...${NC}"
  GH_KEY="${GITHUB_TOKEN:-$API_KEY}"
  dotnet nuget push "$NUPKG_PATH" \
    --api-key "$GH_KEY" \
    --source "$GITHUB_SOURCE" \
    --skip-duplicate || echo -e "${YELLOW}⚠ Notice: GitHub Packages push skipped or failed.${NC}"
fi

echo -e "\n${GREEN}${BOLD}====================================================================${NC}"
echo -e "${GREEN}${BOLD}      Deployment Completed Successfully!                           ${NC}"
echo -e "${GREEN}${BOLD}====================================================================${NC}"
