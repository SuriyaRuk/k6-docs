#!/bin/bash

# K6 Results Analyzer Script
# ใช้สำหรับวิเคราะห์ผลลัพธ์จากการทดสอบ

echo "📊 K6 Results Analyzer"
echo "====================="

# ตรวจสอบว่ามี results directory หรือไม่
if [ ! -d "results" ]; then
    echo "❌ Results directory not found. Please run tests first."
    exit 1
fi

# นับจำนวนไฟล์ผลลัพธ์
json_count=$(find results -name "*.json" | wc -l)
csv_count=$(find results -name "*.csv" | wc -l)

echo "📁 Found $json_count JSON files and $csv_count CSV files"
echo ""

# Function สำหรับแสดงข้อมูลพื้นฐานจากไฟล์ JSON
analyze_json_basic() {
    local file=$1
    echo "📄 Analyzing: $(basename $file)"
    echo "---"
    
    # ใช้ jq เพื่อดึงข้อมูลสำคัญ (หาก jq มีอยู่)
    if command -v jq &> /dev/null; then
        echo "🔍 Quick Stats:"
        
        # HTTP requests
        http_reqs=$(cat "$file" | jq -r 'select(.metric=="http_reqs") | .value' | awk '{sum+=$1} END {print sum}')
        echo "  Total HTTP Requests: ${http_reqs:-0}"
        
        # Average response time
        avg_duration=$(cat "$file" | jq -r 'select(.metric=="http_req_duration") | .value' | awk '{sum+=$1; count++} END {if(count>0) print sum/count; else print 0}')
        echo "  Average Response Time: ${avg_duration:-0}ms"
        
        # Checks
        checks_passed=$(cat "$file" | jq -r 'select(.metric=="checks" and .tags.check != "failed") | .value' | awk '{sum+=$1} END {print sum}')
        checks_failed=$(cat "$file" | jq -r 'select(.metric=="checks" and .tags.check == "failed") | .value' | awk '{sum+=$1} END {print sum}')
        
        if [[ "${checks_passed:-0}" -gt 0 ]] || [[ "${checks_failed:-0}" -gt 0 ]]; then
            total_checks=$((${checks_passed:-0} + ${checks_failed:-0}))
            if [[ $total_checks -gt 0 ]]; then
                success_rate=$(echo "scale=2; ${checks_passed:-0} * 100 / $total_checks" | bc -l)
                echo "  Success Rate: ${success_rate}%"
            fi
        fi
    else
        echo "  ⚠️  Install 'jq' for detailed JSON analysis"
        echo "  File size: $(du -h "$file" | cut -f1)"
        echo "  Lines: $(wc -l < "$file")"
    fi
    
    echo ""
}

# Function สำหรับแสดงข้อมูลพื้นฐานจากไฟล์ CSV
analyze_csv_basic() {
    local file=$1
    echo "📄 Analyzing: $(basename $file)"
    echo "---"
    
    if [[ -s "$file" ]]; then
        lines=$(wc -l < "$file")
        echo "  Total lines: $lines"
        echo "  File size: $(du -h "$file" | cut -f1)"
        
        # แสดง header
        echo "  Headers:"
        head -1 "$file" | tr ',' '\n' | nl
    else
        echo "  ⚠️  File is empty"
    fi
    
    echo ""
}

# Menu
echo "Select analysis option:"
echo "1) Quick summary of all results"
echo "2) Detailed analysis using Python script"
echo "3) Analyze specific file"
echo "4) List all result files"

read -p "Enter your choice (1-4): " choice

case $choice in
    1)
        echo "🔍 Quick Summary:"
        echo "=================="
        
        # วิเคราะห์ไฟล์ JSON
        for json_file in results/*.json; do
            if [[ -f "$json_file" ]]; then
                analyze_json_basic "$json_file"
            fi
        done
        
        # วิเคราะห์ไฟล์ CSV
        for csv_file in results/*.csv; do
            if [[ -f "$csv_file" ]]; then
                analyze_csv_basic "$csv_file"
            fi
        done
        ;;
        
    2)
        echo "🐍 Running Python analysis..."
        if command -v python3 &> /dev/null; then
            python3 analyze-results.py
        else
            echo "❌ Python3 not found. Please install Python3 for detailed analysis."
        fi
        ;;
        
    3)
        echo "📁 Available files:"
        ls -la results/
        echo ""
        read -p "Enter filename to analyze: " filename
        
        if [[ -f "results/$filename" ]]; then
            if [[ "$filename" == *.json ]]; then
                analyze_json_basic "results/$filename"
            elif [[ "$filename" == *.csv ]]; then
                analyze_csv_basic "results/$filename"
            else
                echo "📄 File content preview:"
                head -20 "results/$filename"
            fi
        else
            echo "❌ File not found: results/$filename"
        fi
        ;;
        
    4)
        echo "📁 All result files:"
        echo "==================="
        ls -lah results/
        ;;
        
    *)
        echo "❌ Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "💡 Tips:"
echo "- Use 'jq' for advanced JSON analysis"
echo "- Use Python script with pandas for detailed statistics"
echo "- Import CSV files to Excel/Google Sheets for visualization"