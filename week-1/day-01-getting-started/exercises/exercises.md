# Day 1 — Exercises

Try each exercise on your own before looking at the solutions.

---

## Exercise 1: Find Service Commands

Use `Get-Command` to find all commands that contain the word "Service" in their name. How many are there?

---

## Exercise 2: Explore Get-Process

Use `Get-Help` to look at the help for `Get-Process`. Find the following:
- What parameter lets you get a process by its name?
- What parameter lets you get a process by its ID?
- Show 3 examples from the help.

---

## Exercise 3: Top 10 by Memory

Write a one-liner that lists the top 10 running processes sorted by memory usage (highest first). Show only the process name and memory (WorkingSet64).

Hint: Use `Get-Process`, `Sort-Object`, `Select-Object`.

---

## Exercise 4: Alias Detective

Find all aliases that point to the `Get-ChildItem` cmdlet. How many different ways can you list files?

Hint: `Get-Alias` has a `-Definition` parameter.

---

## Exercise 5: Running Services

Write a one-liner that:
1. Gets all services
2. Filters to only the ones that are currently Running
3. Sorts them alphabetically by display name
4. Shows only the DisplayName and Status columns

This is a 4-step pipeline.
