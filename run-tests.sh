#!/bin/bash

# K6 Load Test Runner Script
# ใช้สำหรับรัน K6 tests พร้อมเก็บผลลัพธ์

echo "🚀 K6 Load Test Runner"
echo "====================="

# ตรวจสอบและแนะนำการปรับแต่ง OS
check_os_tuning() {
    echo "🔧 Checking OS tuning..."
    
    local fd_limit=$(ulimit -n)
    local proc_limit=$(ulimit -u)
    
    if [ "$fd_limit" -lt 65536 ] || [ "$proc_limit" -lt 65536 ]; then
        echo "⚠️  OS tuning recommended for better performance:"
        echo "   Current file descriptor limit: $fd_limit"
        echo "   Current process limit: $proc_limit"
        echo "   Run: sudo ./scripts/tune-os.sh"
        echo ""
        read -p "Continue without OS tuning? (y/N): " continue_without_tuning
        if [[ ! "$continue_without_tuning" =~ ^[Yy]$ ]]; then
            echo "❌ Exiting. Please run OS tuning first."
            exit 1
        fi
    else
        echo "✅ OS tuning detected (fd: $fd_limit, proc: $proc_limit)"
    fi
    echo ""
}

# เรียกใช้ function ตรวจสอบ OS tuning
check_os_tuning

# สร้าง results directory หากยังไม่มี
mkdir -p results

# Function สำหรับรัน test พร้อมเก็บผลลัพธ์
run_test() {
    local script_name=$1
    local test_name=$2
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    
    echo "📊 Running $test_name..."
    
    # รัน test พร้อมเก็บผลลัพธ์ทั้ง JSON และ CSV พร้อม OS tuning
    docker run --rm \
        --ulimit nofile=65536:65536 \
        --sysctl net.core.somaxconn=65535 \
        --sysctl net.ipv4.tcp_fin_timeout=30 \
        --sysctl net.ipv4.tcp_tw_reuse=1 \
        --privileged \
        -v $(pwd)/scripts:/scripts \
        -v $(pwd)/results:/results \
        -e K6_OUT=json=/results/${test_name}_${timestamp}.json,csv=/results/${test_name}_${timestamp}.csv \
        grafana/k6 run /scripts/${script_name}
    
    echo "✅ $test_name completed. Results saved to results/ directory"
    echo ""
}

# Menu สำหรับเลือก test
echo "Select test to run:"
echo "1) Basic Test (10 users, 30s)"
echo "2) Load Test (Gradual increase to 200 users)"
echo "3) Stress Test (Up to 400 users)"
echo "4) Spike Test (Sudden spike to 1400 users)"
echo "5) API Test (CRUD operations)"
echo "6) Run All Tests"

read -p "Enter your choice (1-6): " choice

case $choice in
    1)
        run_test "basic-test.js" "basic-test"
        ;;
    2)
        run_test "load-test.js" "load-test"
        ;;
    3)
        run_test "stress-test.js" "stress-test"
        ;;
    4)
        run_test "spike-test.js" "spike-test"
        ;;
    5)
        run_test "api-test.js" "api-test"
        ;;
    6)
        echo "🔄 Running all tests..."
        run_test "basic-test.js" "basic-test"
        run_test "load-test.js" "load-test"
        run_test "stress-test.js" "stress-test"
        run_test "spike-test.js" "spike-test"
        run_test "api-test.js" "api-test"
        echo "🎉 All tests completed!"
        ;;
    *)
        echo "❌ Invalid choice. Please run the script again."
        exit 1
        ;;
esac

echo "📁 Check results in the 'results/' directory"
echo "📈 Use analyze-results.sh to view detailed analysis"