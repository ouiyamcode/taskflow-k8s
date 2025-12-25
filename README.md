# Taskflow Kubernetes Project

This project implements a microservices-based application deployed on Kubernetes, with a strong focus on **network isolation**, **controlled communication**, and **Kubernetes best practices**.

The system is split into two namespaces (`frontend` and `backend`) and uses **NetworkPolicies**, **sidecars**, and **service-based communication** to enforce security and observability.

---

## Architecture Diagram

The following diagram represents the **actual implemented architecture**, based on the deployed Kubernetes manifests and validated through runtime tests.

```mermaid
graph TD
  %% External access
  User -->|NodePort 30080| Gateway

  %% Frontend namespace
  subgraph taskflow-frontend
    Frontend -->|HTTP| Gateway
  end

  %% Backend namespace
  subgraph taskflow-backend
    Gateway -->|HTTP| Auth
    Gateway -->|HTTP| Tasks
    Gateway -->|HTTP| Notifications
    Gateway -->|HTTP| Metrics

    %% Internal backend communication
    Tasks -->|HTTP| Auth

    %% Sidecars
    Auth -->|localhost:9090| AuditSidecar
    Tasks -->|HTTP health checks| Metrics
  end

