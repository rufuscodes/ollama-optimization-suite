#!/bin/bash
# Create optimized Ollama models from Modelfiles

echo "🚀 Creating optimized Ollama models..."

# Check if Ollama is running
if ! curl -s http://localhost:11434/api/version > /dev/null 2>&1; then
    echo "❌ Ollama is not running. Please start Ollama first:"
    echo "   ollama serve"
    exit 1
fi

# Create fast-codellama
echo "📦 Creating fast-codellama..."
ollama create fast-codellama -f Modelfile.fast-codellama

# Create fast-deepseek
echo "📦 Creating fast-deepseek..."
ollama create fast-deepseek -f Modelfile.fast-deepseek

# Create fast-llama3
echo "📦 Creating fast-llama3..."
ollama create fast-llama3 -f Modelfile.fast-llama3

echo ""
echo "✅ Optimized models created!"
echo ""
echo "Available models:"
ollama list
echo ""
echo "Test them with:"
echo "  ollama run fast-codellama 'Write a hello world in Python'"
echo "  ollama run fast-deepseek 'Complete: def fibonacci(n):'"
echo "  ollama run fast-llama3 'Explain recursion briefly'"
