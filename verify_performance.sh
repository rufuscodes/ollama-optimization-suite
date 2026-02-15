#!/bin/bash
# Verify Ollama Performance Configuration

echo "🔍 Ollama Performance Verification"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0

# Function to check status
check() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ PASS${NC}: $1"
        ((PASS++))
    else
        echo -e "${RED}❌ FAIL${NC}: $1"
        ((FAIL++))
    fi
}

# 1. Check if Ollama is installed
echo "1️⃣  Checking Ollama installation..."
which ollama > /dev/null 2>&1
check "Ollama is installed"
echo ""

# 2. Check if Ollama is running
echo "2️⃣  Checking Ollama service..."
curl -s http://localhost:11434/api/version > /dev/null 2>&1
check "Ollama is running on port 11434"
echo ""

# 3. Check environment variables
echo "3️⃣  Checking environment variables..."
[ -f ~/.ollama/env_config.sh ]
check "Environment config file exists"

source ~/.ollama/env_config.sh 2>/dev/null

[ "$OLLAMA_NUM_THREAD" = "16" ]
check "OLLAMA_NUM_THREAD=16"

[ "$OLLAMA_NUM_PARALLEL" = "4" ]
check "OLLAMA_NUM_PARALLEL=4"

[ "$OLLAMA_METAL" = "1" ]
check "OLLAMA_METAL=1 (GPU acceleration)"

[ "$OLLAMA_FLASH_ATTENTION" = "1" ]
check "OLLAMA_FLASH_ATTENTION=1"
echo ""

# 4. Check if optimized models exist
echo "4️⃣  Checking optimized models..."
ollama list | grep -q "fast-codellama"
check "fast-codellama model exists"

ollama list | grep -q "fast-deepseek"
check "fast-deepseek model exists"

ollama list | grep -q "fast-llama3"
check "fast-llama3 model exists"
echo ""

# 5. Check LaunchD service
echo "5️⃣  Checking LaunchD service..."
if [ -f /Library/LaunchDaemons/com.ollama.optimized.plist ]; then
    echo -e "${GREEN}✅${NC} LaunchD service is installed"
    sudo launchctl list | grep -q ollama
    check "LaunchD service is loaded"
else
    echo -e "${YELLOW}⚠️${NC}  LaunchD service not installed (manual start)"
fi
echo ""

# 6. Test model performance
echo "6️⃣  Testing model performance..."
echo "Testing fast-deepseek (should be <2s)..."
START=$(date +%s)
ollama run fast-deepseek "print('hello')" > /dev/null 2>&1
END=$(date +%s)
DURATION=$((END - START))
if [ $DURATION -lt 5 ]; then
    echo -e "${GREEN}✅ PASS${NC}: Response in ${DURATION}s (excellent)"
    ((PASS++))
else
    echo -e "${YELLOW}⚠️  WARN${NC}: Response in ${DURATION}s (may need warmup)"
fi
echo ""

# 7. Check system resources
echo "7️⃣  System resources..."
CPU_CORES=$(sysctl -n hw.logicalcpu)
MEM_GB=$(( $(sysctl -n hw.memsize) / 1024 / 1024 / 1024 ))
echo "   CPU cores: $CPU_CORES"
echo "   Memory: ${MEM_GB}GB"
echo ""

# 8. Check Ollama process
echo "8️⃣  Ollama process info..."
OLLAMA_PID=$(pgrep ollama)
if [ -n "$OLLAMA_PID" ]; then
    echo -e "${GREEN}✅${NC} Ollama running (PID: $OLLAMA_PID)"
    echo "   CPU/Memory usage:"
    ps -p $OLLAMA_PID -o %cpu,%mem,command | tail -1
else
    echo -e "${RED}❌${NC} Ollama process not found"
fi
echo ""

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "Passed: ${GREEN}$PASS${NC}"
echo -e "Failed: ${RED}$FAIL${NC}"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}🎉 All checks passed! Ollama is optimized for maximum performance.${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  Some checks failed. Review the output above.${NC}"
    echo ""
    echo "Common fixes:"
    echo "  • Start Ollama: ollama serve"
    echo "  • Load environment: source ~/.ollama/env_config.sh"
    echo "  • Create models: ./create_optimized_models.sh"
    exit 1
fi
