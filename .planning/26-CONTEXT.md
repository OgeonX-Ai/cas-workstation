# Phase 26 Context: Test Coverage Automation & Enforcement

## Goal
Establish the 100% test coverage baseline CI gates. Generate missing unit, smoke, regression, and E2E tests for `gsd-orchestrator` and `autogen`.

## Ambiguity Resolution (Systems Analyst Expert Persona)
<ambiguity_scoring>
- **100% test coverage limits:** What if 100% cannot be reached due to framework boilerplate or external I/O?
  *Resolution required & set:* We enforce 100% logical branch coverage. Framework boilerplate and auto-generated code must be explicitly ignored using standard pragmas (`[ExcludeFromCodeCoverage]` in C#, `# pragma: no cover` in Python).
- **Resilience First:** How does CI handle and report a coverage failure?
  *Resolution required & set:* CI pipeline must fail explicitly and emit structured CAS telemetry (JSON) rather than generic non-zero exit codes.
- **CI Pipeline Performance:** Will running complete unit, smoke, regression, and E2E suites on every PR cause pipeline timeouts?
  *Resolution required & set:* Matrix strategy and parallel execution must be enforced in GitHub Actions. Unit tests must be completely isolated and run in < 2 mins.
</ambiguity_scoring>

## Key Decisions
1. **CI Locations Identified:**
   - `C:\PersonalRepo\portfolio\gsd-orchestrator\.github\workflows\ci.yml` (C# / coverlet)
   - `C:\PersonalRepo\portfolio\autogen\.github\workflows\ci.yml` (Python / pytest-cov)
2. **Tools Standardized:** `coverlet` for .NET, `pytest-cov` for Python.
3. **Enforcement Mechanism:** Branch protection rules require CI gate pass. CI gate requires 100% coverage metrics before succeeding.
4. **Retroactive Generation:** We will systematically generate tests for existing untested blocks in `gsd-orchestrator` and `autogen` to reach the 100% baseline.

## Next Steps
Proceed to `gsd-plan-phase 26` to generate the step-by-step PLAN.md for modifying the CI workflows and writing the retroactive tests.
