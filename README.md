# Trailhead Modules

Sandbox for hands-on work from Salesforce Trailhead certification maintenance modules and skill badges. Each module is developed on its own branch, then merged into `master` via PR.

## Completed Modules

| Season | Module | Branch | URL |
|--------|--------|--------|-----|
| Winter '21 | Platform Developer I Cert Maintenance | `w21PD1` | Retired |
| Winter '21 | Platform App Builder Cert Maintenance | `w21AppBuilder` | Retired |
| Spring '22 | Administrator Cert Maintenance | `spring22Admin` | [Link](https://trailhead.salesforce.com/content/learn/modules/administrator-certification-maintenance-spring-22) |
| Winter '22 | Platform App Builder Cert Maintenance | `winter22AppBuilder` | [Link](https://trailhead.salesforce.com/content/learn/modules/platform-app-builder-certification-maintenance-winter-22) |
| Winter '22 | Platform Developer I Cert Maintenance | `w22PlatformDev` | Retired |
| Spring '23 | Administrator Cert Maintenance | `spring23Admin` | [Link](https://trailhead.salesforce.com/content/learn/modules/administrator-certification-maintenance-spring-23) |
| 2023 | Platform App Builder Cert Maintenance | `appBuilder23` | Retired |
| 2023 | Platform Developer I Cert Maintenance | `platformDev23` | Retired |
| Spring '24 | Administrator Cert Maintenance | `spring24Admin` | Retired |
| Winter '24 | Platform App Builder Cert Maintenance | `winter24AppBuilder` | Retired |
| Winter '24 | Platform Developer I Cert Maintenance | `w24PlatformDev` | Retired |
| Spring '25 | Administrator Cert Maintenance | `spring25Admin` | [Link](https://trailhead.salesforce.com/content/learn/modules/administrator-certification-maintenance-spring-25) |
| 2026 | Quick Start: Apex Coding for Admins | `apexCodingForAdmins` | [Link](https://trailhead.salesforce.com/content/learn/projects/quick-start-apex-coding-for-admins) |

*Retired = module removed from Trailhead after the maintenance window closed.*

## Project Structure

```
force-app/main/default/
  classes/        # Apex classes
  triggers/       # Apex triggers
  objects/        # Custom objects and fields
  profiles/       # Profile metadata (FLS)
  tabs/           # Custom tabs
  lwc/            # Lightning Web Components
  aura/           # Aura components
  flows/          # Flows
  flexipages/     # Lightning pages
  permissionsets/ # Permission sets
scripts/
  apex/           # Anonymous Apex execution scripts
  soql/           # SOQL query files
```
