#!/bin/bash
# Complete Ollama Optimization Installation Script

set -e  # Exit on error

echo "╔════════════════════════════════════════════════════════════╗"
echo "║     🚀 Ollama Performance Optimization Installer          ║"
echo "║     Optimized for: 8-core/16-thread, 32GB RAM Mac        ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Ollama is installed
if ! command -v ollama &> /dev/null; then
    echo -e "${RED}❌ Ollama is not installed${NC}"
    echo "Install it with: brew install ollama"
    exit 1
fi

echo -e "${GREEN}✅ Ollama found: $(ollama --version 2>&1 | grep -o 'version is.*')${NC}"
echo ""

# Step 1: Setup environment variables
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📝 Step 1: Setting up environment variables..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

chmod +x setup_ollama_performance.sh
./setup_ollama_performance.sh

source ~/.ollama/env_config.sh

echo -e "${GREEN}✅ Environment variables configured${NC}"
echo ""

# Step 2: Ask about LaunchD service
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Step 2: LaunchD Service (Optional)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Install Ollama as a system service to auto-start on boot?"
echo -e "${YELLOW}This requires sudo access${NC}"
read -p "Install LaunchD service? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing LaunchD service..."
    
    # Stop existing Ollama if running
    pkill ollama 2>/dev/null || true
    
    # Copy plist
    sudo cp com.ollama.optimized.plist /Library/LaunchDaemons/
    sudo chown root:wheel /Library/LaunchDaemons/com.ollama.optimized.plist
    sudo chmod 644 /Library/LaunchDaemons/com.ollama.optimized.plist
    
    # Load service
    sudo launchctl load /Library/LaunchDaemons/com.ollama.optimized.plist
    
    echo -e "${GREEN}✅ LaunchD service installed and started${NC}"
    sleep 2
else
    echo "Skipping LaunchD service. Starting Ollama manually..."
    ollama serve > /tmp/ollama.log 2>&1 &
    echo -e "${GREEN}✅ Ollama started manually${NC}"
    sleep 3
fi

echo ""

# Step 3: Verify Ollama is running
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 Step 3: Verifying Ollama is running..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

for i in {1..10}; do
    if curl -s http://localhost:11434/api/version > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Ollama is running and responding${NC}"
        break
    fi
    echo "Waiting for Ollama to start... ($i/10)"
    sleep 1
done

if ! curl -s http://localhost:11434/api/version > /dev/null 2>&1; then
    echo -e "${RED}❌ Ollama failed to start${NC}"
    echo "Check logs: tail -f /tmp/ollama.log"
    exit 1
fi

echo ""

# Step 4: Pull base models if needed
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Step 4: Checking required models..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

MODELS=("codellama:13b" "deepseek-coder:6.7b" "llama3:latest")

for model in "${MODELS[@]}"; do
    if ollama list | grep -q "$model"; then
        echo -e "${GREEN}✅ $model already available${NC}"
    else
        echo -e "${YELLOW}📥 Pulling $model (this may take a while)...${NC}"
        ollama pull "$model"
        echo -e "${GREEN}✅ $model downloaded${NC}"
    fi
done

echo ""

# Step 5: Create optimized models
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "⚡ Step 5: Creating optimized model variants..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

chmod +x create_optimized_models.sh
./create_optimized_models.sh

echo ""

# Step 6: IDE configuration info
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎨 Step 6: IDE Configuration"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Configuration files are ready for your IDEs:"
echo ""
echo "📁 Cursor:"
echo "   File: $(pwd)/cursor_settings.json"
echo "   Path: ~/Library/Application Support/Cursor/User/settings.json"
echo ""
echo "📁 VSCode:"
echo "   File: $(pwd)/vscode_settings.json"
echo "   Path: ~/Library/Application Support/Code/User/settings.json"
echo ""
echo "📁 Windsurf:"
echo "   File: $(pwd)/windsurf_settings.json"
echo "   Path: Check your Windsurf settings location"
echo ""
echo -e "${YELLOW}⚠️  Merge these settings manually with your existing IDE settings${NC}"
echo ""

# Step 7: Performance test
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 Step 7: Performance Test"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
read -p "Run performance test? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Testing fast-codellama..."
    echo ""
    time ollama run fast-codellama "Write a Python hello world function" --verbose
    echo ""
fi

# Success summary
echo ""
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                  ✅ Installation Complete!                 ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""
echo "🎯 What's configured:"
echo "  ✓ Environment variables optimized for 16 threads"
echo "  ✓ Ollama running with maximum performance settings"
echo "  ✓ 3 optimized model variants created"
echo "  ✓ IDE configuration files ready"
echo ""
echo "🚀 Quick Test Commands:"
echo "  ollama run fast-codellama 'Write a fibonacci function'"
echo "  ollama run fast-deepseek 'Complete: def hello():'"
echo "  ollama run fast-llama3 'Explain Python decorators briefly'"
echo ""
echo "📊 Monitor Performance:"
echo "  top -pid \$(pgrep ollama)"
echo "  tail -f /tmp/ollama.log"
echo ""
echo "📖 Full documentation:"
echo "  cat $(pwd)/README.md"
echo ""
echo -e "${GREEN}Happy coding! 🎉${NC}"
