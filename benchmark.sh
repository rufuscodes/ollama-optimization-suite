#!/bin/bash
# Benchmark Ollama Performance

echo "⚡ Ollama Performance Benchmark"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if Ollama is running
if ! curl -s http://localhost:11434/api/version > /dev/null 2>&1; then
    echo "❌ Ollama is not running. Start it first:"
    echo "   ollama serve"
    exit 1
fi

# Test prompt
PROMPT="Write a Python function to calculate fibonacci numbers using recursion"

# Function to benchmark a model
benchmark_model() {
    local model=$1
    echo "Testing: $model"
    echo "Prompt: $PROMPT"
    echo ""
    
    # Warm up
    echo "Warming up..."
    ollama run "$model" "test" > /dev/null 2>&1
    
    # Benchmark
    echo "Running benchmark..."
    local start=$(date +%s%N)
    ollama run "$model" "$PROMPT" > /tmp/ollama_response.txt 2>&1
    local end=$(date +%s%N)
    
    # Calculate duration
    local duration_ns=$((end - start))
    local duration_ms=$((duration_ns / 1000000))
    local duration_s=$(echo "scale=2; $duration_ms / 1000" | bc)
    
    # Count tokens (approximate)
    local tokens=$(wc -w < /tmp/ollama_response.txt)
    local tokens_per_sec=$(echo "scale=2; $tokens / $duration_s" | bc)
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Results:"
    echo "  Duration: ${duration_s}s"
    echo "  Tokens: ~$tokens"
    echo "  Speed: ~${tokens_per_sec} tokens/sec"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# Models to benchmark
MODELS=(
    "fast-codellama"
    "fast-deepseek"
    "fast-llama3"
)

echo "🚀 Starting benchmarks for ${#MODELS[@]} models..."
echo ""

for model in "${MODELS[@]}"; do
    if ollama list | grep -q "$model"; then
        benchmark_model "$model"
        sleep 2  # Cool down
    else
        echo "⚠️  Skipping $model (not found)"
        echo ""
    fi
done

echo "✅ Benchmark complete!"
echo ""
echo "💡 Tips for better performance:"
echo "  • Keep models warm with OLLAMA_KEEP_ALIVE=30m"
echo "  • Use smaller models for autocomplete (deepseek:6.7b)"
echo "  • Monitor with: top -pid \$(pgrep ollama)"
echo "  • Check GPU usage: log show --predicate 'subsystem contains \"metal\"' --last 1m"
