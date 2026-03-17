# d365fo.copilot.code-review

![Platform](https://img.shields.io/badge/platform-D365FO-blue)
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
![Status](https://img.shields.io/badge/status-Development-yellow)

AI-powered X++ code review integrated into Azure DevOps gated check-in pipelines.

## 📌 Overview

Code quality in X++ is often validated **too late in the development lifecycle**, typically during or after pull requests. This leads to:

- Late discovery of performance issues  
- Increased debugging and refactoring time  
- Violations of best practices reaching shared branches  

This project aims to **shift code review left** by introducing an **automated AI-based review during gated check-in** using Copilot CLI.

## 🧠 Architecture

The solution integrates **AI-assisted code review directly into Azure DevOps pipelines**.

### High-Level Flow

1. Gated check-in is triggered  
2. Azure DevOps pipeline starts  
3. PowerShell task invokes **Copilot CLI**  
4. Only modified X++ code is analyzed  
5. AI evaluates code using predefined and custom prompts  
6. Pipeline returns **Success / Failed** based on findings  

Additionally:

- A **DevOps Work Item** is created with detailed findings  
- The pipeline can optionally be **blocked on critical issues**

---

## ⚙️ Getting Started

### 1. Install the Extension

Install from Visual Studio Marketplace:

👉 https://marketplace.visualstudio.com/manage/publishers/diegomancassola/extensions/d365fo-copilot-code-review

Steps:

- Go to **Azure DevOps → Organization Settings**
- Open **Extensions**
- Click **Browse Marketplace**
- Install the extension

---

### 2. Add Task to Pipeline

Add the **Code Review task** to your:

- Gated check-in pipeline (TFVC supported)
- Classic or YAML pipeline (YAML available in repo)

---

## 🔐 Configuration

### Full Parameters List

| Parameter | Required | Description |
|-----------|----------|-------------|
| **GitHub PAT** | ✅ Yes | Token used to authenticate GitHub Copilot CLI. Required to access AI capabilities. |
| **Azure DevOps PAT** | ⚠️ Depends | Token used to read Azure DevOps context. Required for on-prem, optional in cloud. |
| **Use System Access Token** | ⚠️ Depends | Uses pipeline OAuth token instead of Azure DevOps PAT (recommended for Azure DevOps Services). |
| **Organization** | ✅ Yes | Azure DevOps organization name (cloud scenario). | https://dev.azure.com/myorg
| **Collection URI** | ✅ Yes | Full Azure DevOps collection URL (e.g. `$(System.CollectionUri)`). |
| **Project** | ✅ Yes | Azure DevOps project name (e.g. `$(System.TeamProject)`). |
| **Repository** | ✅ Yes | Repository containing the changes (e.g. `$(Build.Repository.Name)`). |
| **Timeout (minutes)** | ✅ Yes | Maximum allowed time for the Copilot review run (default: 15). |
| **Copilot Model** | ✅ Yes | AI model used for analysis (e.g. `claude-sonnet-4.6`). |
| **Fail Pipeline on Blocking Findings** | ⚠️ Depends | If enabled, the pipeline fails when blocking issues are detected. |
| **Custom Prompt File** | ❌ No | File-based custom prompt (legacy mode). |
| **Custom Prompt** | ❌ No | Inline custom prompt text (legacy mode). |
| **Warning Checks Prompt** | ⚠️ Depends | Inline non-blocking checks (reported as warnings only). |
| **Warning Checks Prompt File** | ❌ No | File-based warning checks. |
| **Blocking Checks Prompt** | ⚠️ Depends | Inline blocking checks (violations cause failure). |
| **Blocking Checks Prompt File** | ❌ No | File-based blocking checks. |
| **Raw Prompt** | ❌ No | Full raw prompt passed directly to Copilot (advanced mode). |
| **Raw Prompt File** | ❌ No | File-based raw prompt (advanced mode). |
| **Author Filter** | ❌ No | Comma-separated author emails to limit when the task runs. |

---

### 🔑 Notes

- **GitHub PAT is mandatory** for Copilot CLI authentication  
- Prefer **System Access Token** over Azure DevOps PAT in cloud scenarios  
- **Prompts drive the AI behavior** → use Warning/Blocking strategically  
- Use **Raw Prompt** only for advanced/custom scenarios
---

## 🧩 Prompt Strategy

The tool includes a **default embedded prompt**.

### Priority Rule

👉 If a **custom prompt is provided**, it **overrides the default one**.

This allows customization for:

- Project-specific rules  
- Coding standards  
- Performance constraints  
- Architecture guidelines  

---

## ⚠️ Warning vs Blocking Checks

### Warning Checks

- Non-blocking  
- Reported as warnings  
- Pipeline continues  

Example:

```
Classify as WARNING only issues related to code style and maintainability that do NOT impact runtime behavior, data correctness, or system stability. Examples: inconsistent naming, formatting/style issues, method/member ordering, missing or improvable comments, minor stylistic inconsistencies. Never escalate these cases to BLOCKING.
```

---

### ❌ Blocking Checks

- Critical violations  
- Pipeline fails  
- Check-in rejected  

Example:

```
Classify as BLOCKING any performance or reliability best-practice violation with real runtime impact. Examples: queries inside loops, N+1 queries, non-optimized selects on large datasets, missing proper where/index usage in critical paths, repeated expensive calls, patterns causing performance degradation, timeouts, or lock contention. If unsure, assess risk under production-like data volume: if risk is medium/high, keep it BLOCKING. For each blocking issue, provide: title, technical evidence, expected impact (latency/throughput/resource usage), and a concrete high-priority fix.
```

Typical cases:

- Queries inside loops  
- N+1 queries  
- Inefficient selects  
- Missing indexes  
- Performance anti-patterns  

---

## ▶️ How It Works

1. Developer performs check-in from Visual Studio  
2. Gated check-in triggers pipeline  
3. AI review task executes  
4. Only changed X++ code is analyzed  
5. Result:

| Scenario | Outcome |
|--------|--------|
| No blocking issues | ✅ Pipeline succeeds |
| Blocking issues found | ❌ Pipeline fails |

---

## 🧾 Output

- Pipeline logs (Markdown-based)
- DevOps Work Item:
  - Assigned to author  
  - Contains detailed findings  
  - Linked to parent task (if available)

---

## 🔮 Future Improvements

Planned enhancements:

- Native **Pull Request integration**
- Inline comments on code
- Better UI than Markdown output
- Alignment with Microsoft DevOps guidelines

---

## 📌 Disclaimer

This project and documentation were created with the support of AI tools.

All technical aspects have been **personally reviewed and validated** to ensure correctness and real-world applicability.

---

## 🙏 Credits

This project was inspired by:

👉 https://github.com/little-fort/ado-copilot-code-review

Adapted and extended for:

- Dynamics 365 Finance & Operations  
- X++ best practices  
- Gated check-in workflows  
