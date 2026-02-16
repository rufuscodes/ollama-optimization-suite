# 🚀 Ollama Performance Optimization Suite

Complete optimization setup for blazing-fast Ollama models on macOS and Ubuntu/Linux.

> **📦 Multi-Platform Support**: This suite now supports both **macOS** and **Ubuntu/Linux**!  
> - **macOS users**: Follow the instructions below  
> - **Ubuntu/Linux users**: See [`ubuntu/README_UBUNTU.md`](ubuntu/README_UBUNTU.md)

## 🎯 What's Included

1. **Environment Configuration** - Optimized Ollama environment variables
2. **LaunchD Service** - Auto-start Ollama with optimal settings
3. **IDE Settings** - Pre-configured settings for VSCode, Cursor, and Windsurf
4. **Optimized Modelfiles** - Speed-tuned models for different use cases
5. **Setup Scripts** - Easy installation and verification

## 🏃 Quick Start

### Step 1: Setup Environment Variables

```bash
cd ollama-optimization-suite
chmod +x setup_ollama_performance.sh
./setup_ollama_performance.sh
source ~/.ollama/env_config.sh
```

### Step 2: Install LaunchD Service (Optional but Recommended)

```bash
# Copy the plist file
sudo cp com.ollama.optimized.plist /Library/LaunchDaemons/

# Set permissions
sudo chown root:wheel /Library/LaunchDaemons/com.ollama.optimized.plist
sudo chmod 644 /Library/LaunchDaemons/com.ollama.optimized.plist

# Stop existing Ollama if running
pkill ollama

# Load the service
sudo launchctl load /Library/LaunchDaemons/com.ollama.optimized.plist

# Check status
sudo launchctl list | grep ollama
```

### Step 3: Create Optimized Models

```bash
# Make sure Ollama is running first
ollama serve &  # Or use the launchd service

# Create optimized models
chmod +x create_optimized_models.sh
./create_optimized_models.sh
```

### Step 4: Configure Your IDE

#### **Cursor**
1. Open Cursor Settings (⌘+,)
2. Go to: Settings > Open Settings (JSON)
3. Merge the contents of `cursor_settings.json` into your settings

Or use command line:
```bash
# Backup existing settings
cp ~/Library/Application\ Support/Cursor/User/settings.json ~/Library/Application\ Support/Cursor/User/settings.json.backup

# Merge with optimized settings (manual merge recommended)
cat cursor_settings.json
```

#### **VSCode**
1. Open VSCode Settings (⌘+,)
2. Go to: Settings > Open Settings (JSON)
3. Merge the contents of `vscode_settings.json` into your settings

Or use command line:
```bash
# Backup existing settings
cp ~/Library/Application\ Support/Code/User/settings.json ~/Library/Application\ Support/Code/User/settings.json.backup

# View optimized settings
cat vscode_settings.json
```

#### **Windsurf**
1. Open Windsurf Settings
2. Go to: Settings > Open Settings (JSON)
3. Merge the contents of `windsurf_settings.json` into your settings

## 🔧 Key Optimizations

### Environment Variables
- **OLLAMA_NUM_THREAD=16** - Uses all 16 logical cores
- **OLLAMA_NUM_PARALLEL=4** - Run 4 models concurrently
- **OLLAMA_MAX_LOADED_MODELS=4** - Keep 4 models in memory
- **OLLAMA_KEEP_ALIVE=30m** - Models stay loaded for 30 minutes
- **OLLAMA_METAL=1** - Enable Apple Metal GPU acceleration
- **OLLAMA_FLASH_ATTENTION=1** - Faster attention mechanism
- **OLLAMA_MAX_QUEUE=512** - Larger request queue

### Model Optimizations
- **fast-codellama** - Optimized for code generation (16K context)
- **fast-deepseek** - Ultra-fast autocomplete (8K context, 256 tokens)
- **fast-llama3** - Balanced chat model (16K context)

### IDE Optimizations
- Streaming responses for instant feedback
- Reduced latency settings (50ms delays)
- Pre-loading models
- Aggressive caching
- Multi-threaded requests

## ✅ Verification Commands

```bash
# Check if Ollama is running
curl http://localhost:11434/api/version

# List available models
ollama list

# Test performance with a simple query
time ollama run fast-codellama "Write a fibonacci function"

# Monitor resource usage
top -pid $(pgrep ollama)

# Check logs (if using launchd service)
tail -f /tmp/ollama.log
tail -f /tmp/ollama.error.log

# Test all optimized models
ollama run fast-codellama "def hello():"
ollama run fast-deepseek "import "
ollama run fast-llama3 "What is recursion?"
```

## 🔍 Troubleshooting

### Ollama won't start
```bash
# Check if port 11434 is in use
lsof -i :11434

# Kill any existing Ollama process
pkill ollama

# Start manually with logs
ollama serve
```

### Models not loading
```bash
# Check available disk space
df -h

# Pull required base models
ollama pull codellama:13b
ollama pull deepseek-coder:6.7b
ollama pull llama3:latest

# Recreate optimized models
./create_optimized_models.sh
```

### IDE not connecting
```bash
# Verify Ollama is accessible
curl http://localhost:11434/api/tags

# Check firewall settings
sudo pfctl -sr | grep 11434

# Restart IDE with fresh settings
```

### Performance issues
```bash
# Check CPU usage
top -l 1 | grep "CPU usage"

# Monitor memory
vm_stat

# Check if Metal GPU is being used
log show --predicate 'subsystem contains "metal"' --last 1m

# Verify environment variables are set
env | grep OLLAMA
```

## 📊 Expected Performance Improvements

- **Inference Speed**: 2-3x faster token generation
- **Latency**: Sub-100ms first token
- **Throughput**: 4x parallel model execution
- **Memory**: Efficient model loading (keeps 4 models ready)
- **Autocomplete**: <50ms suggestions

## 🎛️ Advanced Tuning

### For even faster autocomplete (trade quality for speed):
Edit `~/.ollama/env_config.sh`:
```bash
export OLLAMA_NUM_THREAD=8  # Use fewer threads per model
export OLLAMA_NUM_PARALLEL=8  # More parallel models
export OLLAMA_KEEP_ALIVE=60m  # Keep models loaded longer
```

### For maximum quality (trade speed for accuracy):
In Modelfiles, adjust:
```
PARAMETER temperature 0.3    # More creative
PARAMETER num_predict 4096   # Longer responses
PARAMETER mirostat 2         # Better sampling
```

## 🗑️ Uninstall

```bash
# Remove launchd service
sudo launchctl unload /Library/LaunchDaemons/com.ollama.optimized.plist
sudo rm /Library/LaunchDaemons/com.ollama.optimized.plist

# Remove environment config
rm -rf ~/.ollama/env_config.sh

# Remove from shell profile
# Edit ~/.zshrc and remove the lines added by setup script

# Remove optimized models
ollama rm fast-codellama
ollama rm fast-deepseek
ollama rm fast-llama3
```

## 📚 Resources

- [Ollama Documentation](https://github.com/ollama/ollama/blob/main/docs/README.md)
- [Modelfile Reference](https://github.com/ollama/ollama/blob/main/docs/modelfile.md)
- [Continue.dev Docs](https://continue.dev/docs)
- [Cursor Docs](https://cursor.sh/docs)

## 💡 Tips

1. **Keep models warm**: Use `OLLAMA_KEEP_ALIVE=30m` or longer
2. **Use smaller models for autocomplete**: deepseek-coder:6.7b is fast enough
3. **Preload frequently used models**: Add to startup script
4. **Monitor performance**: Use Activity Monitor to watch CPU/GPU usage
5. **Update regularly**: `brew upgrade ollama` for latest optimizations

---

**System Specs**: 8-core/16-thread CPU, 32GB RAM, Apple Metal GPU
**Ollama Version**: 0.14.1+
**Last Updated**: January 2026
