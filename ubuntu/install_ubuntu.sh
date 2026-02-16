#!/bin/bash
# Complete Ollama Optimization Installation Script for Ubuntu/Linux

set -e  # Exit on error

echo "╔════════════════════════════════════════════════════════════╗"
echo "║     🚀 Ollama Performance Optimization Installer          ║"
echo "║     Platform: Ubuntu/Linux                                ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}❌ Please do not run this script as root${NC}"
    echo "Run without sudo. The script will ask for sudo when needed."
    exit 1
fi

# Check if Ollama is installed
if ! command -v ollama &> /dev/null; then
    echo -e "${YELLOW}⚠️  Ollama is not installed${NC}"
    echo "Installing Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh
    echo -e "${GREEN}✅ Ollama installed${NC}"
else
    echo -e "${GREEN}✅ Ollama found: $(ollama --version 2>&1 | head -n1)${NC}"
fi

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

# Step 2: Setup systemd service
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🚀 Step 2: Systemd Service Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Install Ollama as a system service to auto-start on boot?"
echo -e "${YELLOW}This requires sudo access${NC}"
read -p "Install systemd service? (y/N): " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Installing systemd service..."
    
    # Create ollama user if doesn't exist
    if ! id -u ollama &>/dev/null; then
        echo "Creating ollama user..."
        sudo useradd -r -s /bin/false -d /usr/share/ollama ollama
    fi
    
    # Create log directory
    sudo mkdir -p /var/log/ollama
    sudo chown ollama:ollama /var/log/ollama
    
    # Stop existing ollama if running
    pkill ollama 2>/dev/null || true
    sudo systemctl stop ollama 2>/dev/null || true
    
    # Copy service file
    sudo cp ollama-optimized.service /etc/systemd/system/
    sudo chmod 644 /etc/systemd/system/ollama-optimized.service
    
    # Reload systemd and enable service
    sudo systemctl daemon-reload
    sudo systemctl enable ollama-optimized
    sudo systemctl start ollama-optimized
    
    echo -e "${GREEN}✅ Systemd service installed and started${NC}"
    sleep 2
else
    echo "Skipping systemd service. Starting Ollama manually..."
    pkill ollama 2>/dev/null || true
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
    echo "Check logs:"
    echo "  - Systemd: sudo journalctl -u ollama-optimized -f"
    echo "  - Manual: tail -f /tmp/ollama.log"
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

# Use the shared modelfiles from parent directory
cd ..
chmod +x create_optimized_models.sh
./create_optimized_models.sh
cd ubuntu

echo ""

# Step 6: Performance test
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🧪 Step 6: Performance Test"
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
echo "  ✓ Environment variables optimized for your CPU"
echo "  ✓ Ollama running with maximum performance settings"
echo "  ✓ 3 optimized model variants created"
echo "  ✓ Systemd service configured (if selected)"
echo ""
echo "🚀 Quick Test Commands:"
echo "  ollama run fast-codellama 'Write a fibonacci function'"
echo "  ollama run fast-deepseek 'Complete: def hello():'"
echo "  ollama run fast-llama3 'Explain Python decorators briefly'"
echo ""
echo "📊 Monitor Performance:"
echo "  top -p \$(pgrep ollama)"
echo "  sudo journalctl -u ollama-optimized -f"
echo ""
echo "📖 GPU Setup (NVIDIA):"
echo "  Install NVIDIA drivers and CUDA toolkit"
echo "  Ollama will automatically use GPU when available"
echo ""
echo -e "${GREEN}Happy coding! 🎉${NC}"
