#!/bin/bash
# Ollama Performance Optimization Script for Mac
# Optimized for 8-core/16-thread, 32GB RAM system

echo "🚀 Setting up Ollama for Maximum Performance..."

# Create config directory if it doesn't exist
mkdir -p ~/.ollama

# Create environment configuration file
cat > ~/.ollama/env_config.sh << 'EOF'
# Ollama Performance Environment Variables

# CPU Optimization - use all logical cores
export OLLAMA_NUM_PARALLEL=4              # Run up to 4 models in parallel
export OLLAMA_MAX_LOADED_MODELS=4         # Keep 4 models in memory

# Thread optimization for your 16-thread CPU
export OLLAMA_NUM_THREAD=16               # Use all logical cores

# Memory optimization for 32GB RAM
export OLLAMA_MAX_QUEUE=512               # Larger request queue

# GPU/Metal acceleration (Mac-specific)
export OLLAMA_METAL=1                     # Enable Metal GPU acceleration

# Network optimization
export OLLAMA_HOST=127.0.0.1:11434        # Local host binding
export OLLAMA_ORIGINS="*"                 # Allow all origins for IDE access

# Performance tuning
export OLLAMA_KEEP_ALIVE=30m              # Keep models loaded for 30 minutes
export OLLAMA_FLASH_ATTENTION=1           # Enable flash attention for faster inference

# Logging (set to 0 for production speed)
export OLLAMA_DEBUG=0

# Load balancing for concurrent requests
export OLLAMA_MAX_VRAM=24                 # Reserve VRAM in GB (adjust based on your GPU)

EOF

# Source the config
source ~/.ollama/env_config.sh

# Add to shell profile for persistence
SHELL_PROFILE=""
if [ -f ~/.zshrc ]; then
    SHELL_PROFILE=~/.zshrc
elif [ -f ~/.bash_profile ]; then
    SHELL_PROFILE=~/.bash_profile
fi

if [ -n "$SHELL_PROFILE" ]; then
    if ! grep -q "source ~/.ollama/env_config.sh" "$SHELL_PROFILE"; then
        echo "" >> "$SHELL_PROFILE"
        echo "# Ollama Performance Configuration" >> "$SHELL_PROFILE"
        echo "source ~/.ollama/env_config.sh" >> "$SHELL_PROFILE"
        echo "✅ Added Ollama config to $SHELL_PROFILE"
    fi
fi

echo "✅ Environment configuration created at ~/.ollama/env_config.sh"
echo ""
echo "🔧 Next steps:"
echo "1. Run: source ~/.ollama/env_config.sh"
echo "2. Restart Ollama: pkill ollama && ollama serve"
echo "3. Or install as launchd service for automatic startup"
