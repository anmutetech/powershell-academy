# Day 5 — Exercises

## Exercise 1: Directory Inventory
Write a script that takes a directory path and produces a summary:
- Total number of files and folders
- Total size in MB
- Largest file (name and size)
- Most common file extension
- List of files modified in the last 7 days

## Exercise 2: CSV Data Processor
Given a CSV file with columns `Name, Email, Department, Salary`:
1. Import the CSV
2. Find the highest-paid employee
3. Calculate average salary by department
4. Export a filtered list (salary > $80,000) to a new CSV

## Exercise 3: Log Analyzer
Write a script that reads a log file and:
1. Counts occurrences of each log level (INFO, WARN, ERROR)
2. Extracts all unique IP addresses
3. Finds the time range (first and last timestamps)
4. Outputs a summary report

## Exercise 4: Config File Editor
Write a function that:
1. Reads a JSON config file
2. Allows updating a specific key's value
3. Writes the updated config back to the file
4. Creates a `.bak` backup before modifying

Example: `Update-Config -Path "config.json" -Key "database.port" -Value 3306`

## Exercise 5: Bulk File Renamer
Write a function that renames files in a directory using regex:
- Takes a `-Path`, `-Pattern` (regex to match), and `-Replacement` parameters
- Supports `-WhatIf` to preview changes
- Handles naming conflicts

Example: Convert `IMG_20260315_001.jpg` to `2026-03-15_001.jpg`
