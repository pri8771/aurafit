# AuraFit — Project Documentation

> Historical overview. For current lifecycle, scope, architecture, risks, tests,
> release gates, and agent handoff, use the factory-governed documents in this
> directory beginning with `STATUS.md`. Code remains authoritative for implemented
> behavior.

GitHub is the source of truth for this project documentation. Notion indexes this file in the Priyansh App Factory Command Center.

## 00. Executive Summary
AuraFit is a native iOS fitness coach candidate focused on one clear coaching workflow rather than a generic tracker. It is for users who want simple guidance, progress tracking, and a private app experience. The end product should include goal setup, profile, one coaching flow, result screen, progress history, settings, and a TestFlight-ready MVP.

## 01. Product
MVP scope: goal setup, profile, one coaching flow, recommendation screen, progress/history, settings, optional premium placeholder.

## 02. Design
Clean, energetic, trustworthy, approachable. Screens: onboarding, profile/goals, input, result, progress, settings.

## 03. Frontend Technical
SwiftUI app with local data model for profile, goals, sessions, recommendations, and progress. Use special permissions only if final MVP requires them.

## 04. Backend Technical
No backend for MVP unless a service is explicitly required. Future services may include account sync, subscription validation, or remote plans.

## 05. Business
Business model: free basic experience with premium recommendations, progress insights, or personalized plans.

## 06. Marketing
Positioning: private coaching on your iPhone. Channels: creator demos, progress examples, privacy posts, beta feedback.

## 07. User Acquisition
Beta with 25-50 users with clear goals. Metrics: onboarding completion, first recommendation, repeat session, usefulness score, willingness to pay.

## 08. Execution
Plan: audit repo, choose one MVP workflow, build core screens, add progress state, run QA, prepare TestFlight.

## 09. QA
Test onboarding, profile setup, main workflow, result screen, progress screen, settings, reset, device sizes, and accessibility.

## 10. Legal / Compliance
Document data handling and permissions based on final implementation. Provide a way to reset local app data.

## 11. Operations
Release process: internal QA, small beta, feedback review, TestFlight. Post-launch: more goals, reminders, premium insights, improved onboarding.
