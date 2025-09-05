# SLO-Driven Uptime Monitor
# My SRE/DevOps Reliability Project

This project demonstrates core **Site Reliability Engineering (SRE)** and **DevOps** skills by building a production-style reliability monitoring system from scratch. It’s designed to simulate what SREs do in real-world environments: defining SLOs, provisioning cloud infrastructure, automating monitoring, and surfacing insights through a status page.

---

## 🚀 Project Overview
- **Goal**: Monitor the availability and latency of web services against defined SLOs.
- **Cloud Provider**: AWS (Terraform for IaC).
- **Tech Stack**: Terraform, AWS Lambda, SNS, EventBridge, S3, Python, GitHub Actions.
- **Outputs**:
  - Alerting on SLO violations.
  - Historical uptime data stored in S3.
  - Status dashboard (to be built).

---

## 📂 Repository Structure
my-sre-devops-project/
├── infra/terraform # Infrastructure as Code (S3, DynamoDB, SNS, etc.)
├── app/checker # Service uptime checker (Lambda function)
├── app/api # API to serve monitoring results (Week 3+)
├── web/status # Frontend status page (Week 3+)
├── docs # Documentation (SLOs, postmortems)
│ └── slo.md
└── .github/workflows # CI/CD pipelines


---

## 📊 Service Level Objectives (SLOs)
- **Availability**: 99.9% over 30 days
- **Latency**: 95th percentile < 500ms
- **Error Budget**: 0.1% downtime (~43 mins / month)
- **Alerting**:
  - Fast burn: page on 2h window burn rate > 14.4
  - Slow burn: ticket on 24h burn rate > 6

Full details in [`docs/slo.md`](docs/slo.md).

---

## ✅ Completed (Week 1)
- Defined **SLOs and error budgets**
- Set up **Terraform remote state** (S3 + DynamoDB)
- Provisioned **SNS topic & subscription** for alerting
- Established repo structure + `.gitignore`

## ✅ Completed Week 2: Uptime Checker Lambda
- Built a Python Lambda function to check availability & latency for key services
- Configured SNS topic + email subscription for alerts
- Deployed Lambda via Terraform with packaging automation
- Verified monitoring works (alerts sent for non-200 responses or >500ms latency)
---

## 🛠️ Next Steps
- Week 3: Add API & status dashboard
- Week 4: CI/CD automation, chaos testing

---

## 📖 Learning Outcomes
- Infrastructure as Code with Terraform
- SLO-driven monitoring & alerting
- Serverless automation with AWS Lambda
- CI/CD pipelines and observability practices

---

### 👤 Author
Sinmisola Akinjayeju — MS ITM @ UT Dallas | Cloud, DevOps, and SRE Enthusiast
