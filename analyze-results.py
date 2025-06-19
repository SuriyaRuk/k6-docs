#!/usr/bin/env python3
"""
K6 Results Analyzer
วิเคราะห์ผลลัพธ์จาก K6 load tests
"""

import json
import pandas as pd
import sys
import os
from datetime import datetime
import matplotlib.pyplot as plt
import seaborn as sns

def analyze_json_results(file_path):
    """วิเคราะห์ผลลัพธ์จากไฟล์ JSON"""
    print(f"📊 Analyzing {file_path}")
    print("=" * 50)
    
    with open(file_path, 'r') as f:
        data = []
        for line in f:
            try:
                data.append(json.loads(line))
            except json.JSONDecodeError:
                continue
    
    if not data:
        print("❌ No valid data found in file")
        return
    
    # แยกข้อมูลตาม metric type
    http_reqs = [d for d in data if d.get('metric') == 'http_reqs']
    http_req_duration = [d for d in data if d.get('metric') == 'http_req_duration']
    checks = [d for d in data if d.get('metric') == 'checks']
    
    # สรุปผลลัพธ์
    if http_reqs:
        total_requests = sum(d.get('value', 0) for d in http_reqs)
        print(f"🔢 Total Requests: {total_requests}")
    
    if http_req_duration:
        durations = [d.get('value', 0) for d in http_req_duration if d.get('value')]
        if durations:
            avg_duration = sum(durations) / len(durations)
            min_duration = min(durations)
            max_duration = max(durations)
            print(f"⏱️  Average Response Time: {avg_duration:.2f}ms")
            print(f"⏱️  Min Response Time: {min_duration:.2f}ms")
            print(f"⏱️  Max Response Time: {max_duration:.2f}ms")
    
    if checks:
        passed_checks = sum(d.get('value', 0) for d in checks if d.get('tags', {}).get('check') != 'failed')
        failed_checks = sum(d.get('value', 0) for d in checks if d.get('tags', {}).get('check') == 'failed')
        total_checks = passed_checks + failed_checks
        
        if total_checks > 0:
            success_rate = (passed_checks / total_checks) * 100
            print(f"✅ Success Rate: {success_rate:.2f}%")
            print(f"❌ Failed Checks: {failed_checks}")
    
    print()

def analyze_csv_results(file_path):
    """วิเคราะห์ผลลัพธ์จากไฟล์ CSV"""
    print(f"📈 CSV Analysis for {file_path}")
    print("=" * 50)
    
    try:
        df = pd.read_csv(file_path)
        
        if 'metric_value' in df.columns:
            # สถิติพื้นฐาน
            print("📊 Basic Statistics:")
            print(df['metric_value'].describe())
            print()
            
            # การกระจายของ metrics
            if 'metric_name' in df.columns:
                print("📋 Metrics Summary:")
                metrics_summary = df.groupby('metric_name')['metric_value'].agg(['count', 'mean', 'std', 'min', 'max'])
                print(metrics_summary)
                print()
        
    except Exception as e:
        print(f"❌ Error reading CSV file: {e}")
    
    print()

def generate_summary_report():
    """สร้างรายงานสรุปจากไฟล์ results ทั้งหมด"""
    results_dir = 'results'
    
    if not os.path.exists(results_dir):
        print("❌ Results directory not found")
        return
    
    json_files = [f for f in os.listdir(results_dir) if f.endswith('.json')]
    csv_files = [f for f in os.listdir(results_dir) if f.endswith('.csv')]
    
    print("📋 K6 Load Test Results Summary")
    print("=" * 50)
    print(f"📁 Results Directory: {results_dir}")
    print(f"📄 JSON Files: {len(json_files)}")
    print(f"📄 CSV Files: {len(csv_files)}")
    print()
    
    # วิเคราะห์ไฟล์ JSON
    for json_file in sorted(json_files):
        file_path = os.path.join(results_dir, json_file)
        analyze_json_results(file_path)
    
    # วิเคราะห์ไฟล์ CSV
    for csv_file in sorted(csv_files):
        file_path = os.path.join(results_dir, csv_file)
        analyze_csv_results(file_path)

def main():
    """Main function"""
    if len(sys.argv) > 1:
        file_path = sys.argv[1]
        if file_path.endswith('.json'):
            analyze_json_results(file_path)
        elif file_path.endswith('.csv'):
            analyze_csv_results(file_path)
        else:
            print("❌ Unsupported file format. Use .json or .csv files")
    else:
        generate_summary_report()

if __name__ == "__main__":
    main()