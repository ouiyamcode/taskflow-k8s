# Taskflow Kubernetes Project

This project implements a microservices-based application deployed on Kubernetes, with a strong focus on **network isolation**, **controlled communication**, and **Kubernetes best practices**.

The system is split into two namespaces (`taskflow-frontend` and `taskflow-backend`) and relies on **NetworkPolicies**, **sidecars**, and **service-based communication** to enforce security, scalability, and observability.

---

## Architecture Diagram

The following diagram represents the **actual implemented architecture**, based on the deployed Kubernetes manifests and validated through runtime tests.  
All services are shown with their **container image and exposed port** (`image:port`).

```mermaid
graph TD
  %% External access
  User -->|nginx:1.25-alpine NodePort 30080| Frontend

  %% Frontend namespace
  subgraph taskflow-frontend
    Frontend[frontend<br/>nginx:1.25-alpine:80]
    Gateway[api-gateway<br/>nginx:1.25-alpine:3000]

    Frontend -->|HTTP 80→3000| Gateway
  end

  %% Backend namespace
  subgraph taskflow-backend
    Auth[auth<br/>hashicorp/http-echo:5000]
    Tasks[tasks<br/>hashicorp/http-echo:8081]
    Notifications[notifications<br/>hashicorp/http-echo:3001]
    Metrics[metrics<br/>hashicorp/http-echo:5001]

    %% Gateway to backend communication
    Gateway -->|HTTP 3000→5000| Auth
    Gateway -->|HTTP 3000→8081| Tasks
    Gateway -->|HTTP 3000→3001| Notifications
    Gateway -->|HTTP 3000→5001| Metrics

    %% Internal backend communication
    Tasks -->|HTTP 8081→5000| Auth

    %% Sidecars
    Audit[auth-audit<br/>hashicorp/http-echo:9090]
    Health[health-checker<br/>hashicorp/http-echo]

    Auth -->|localhost:9090| Audit
    Health -->|HTTP →5001| Metrics
  end
