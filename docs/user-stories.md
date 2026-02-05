---
layout: default
title: User Stories
---

## Traceability matrix

| User Story | Functional Requirement |
|------------|------------------------|
| US-01 | FR-01 |
| US-02 | FR-02 |
| US-03 | FR-03 |
| US-04 | FR-04 |
| US-05 | FR-08, FR-09 |
| US-06 | FR-13, FR-20 |
| US-07 | FR-05, FR-06 |
| US-08 | FR-07 |
| US-09 | FR-08 |
| US-10 | FR-10 |
| US-11 | FR-14 |
| US-12 | FR-12 |
| US-13 | FR-13 |
| US-14 | FR-11 |
| US-15 | FR-16, FR-18 |
| US-16 | FR-17 |
| US-17 | NFR-01 |
| US-18 | NFR-02 |


## Links between user stories and funtional and/or non-functional requirements

Here we present the user stories defined by our team. Each user story is linked with at leat one functional requirement.

## US-01 - Register account

| Field | Description |
|------|-------------|
| **ID** | US-01 |
| **Title** | Register account |
| **Description** | *AS a participant of the TECHUP Football Platform I WANT to create an account using my institutional email or my personal email if I am a family member SO THAT I can access the platform and participate in the tournament process.* |
| **Priority** | *High* |
|**Priority explanation** | *Because account registration is the entry point to the platform and is required before accessing player, team, or tournament functionalities.* |
|**Related functional requirement(s)** | *FR-01 User registration*|
|**RFR explanation** | *Registration functionality corresponds directly to the requirement that allow users to creat an account.*|



## US-02 - Log in to the platform

| Field | Description |
|------|-------------|
| **ID** | US-02 |
| **Title** | Log in to the platform |
| **Description** | *AS a registered participant I WANT to log in securely to the platform SO THAT I can access my profile and use the system functionalities according to my role.* |
| **Priority** | *High* |
| **Priority explanation** | *Because authenticated access is necessary to protect user information and ensure role-based interaction with the system.* |
| **Related functional requirement(s)** | *FR-02 User authentication* |
| **RFR explanation** | *Authentication functionality corresponds directly to the requirement that validates user credentials and grants system access.* |


## US-03 - Create sports profile

| Field | Description |
|------|-------------|
| **ID** | US-03 |
| **Title** | Create sports profile |
| **Description** | *AS a participant I WANT to create and complete my sports profile with my playing position, jersey number, and photo SO THAT captains can identify and evaluate whether I fit their team needs.* |
| **Priority** | *High* |
| **Priority explanation** | *Because the sports profile is essential for team formation and player identification within the tournament.* |
| **Related functional requirement(s)** | *FR-03 Sports profile management* |
| **RFR explanation** | *Profile management functionality allows participants to store and update their sports-related information.* |

## US-04 - Set availablity as a player

| Field | Description |
|------|-------------|
| **ID** | US-04 |
| **Title** | Set availability as a player |
| **Description** | *AS a participant I WANT to mark myself as available to join a team SO THAT captains can find me and invite me to participate in the tournament.* |
| **Priority** | *High* |
| **Priority explanation** | *Because it supports the team-building process and helps captains complete their rosters efficiently.* |
| **Related functional requirement(s)** | *FR-04 Player availability management* |
| **RFR explanation** | *Availability management allows participants to indicate their willingness to be recruited by teams.* |

## US-05 - Respond to team invitations

| Field | Description |
|------|-------------|
| **ID** | US-05 |
| **Title** | Respond to team invitations |
| **Description** | *AS a participant I WANT to accept or reject invitations sent by captains SO THAT I can decide which team I want to join and keep control over my participation in the tournament.* |
| **Priority** | *High* |
| **Priority explanation** | *Because participants must be able to confirm or decline team invitations in a traceable way.* |
| **Related functional requirement(s)** | *FR-08 Team Invitation Management, FR-09 Team membership validation* |
| **RFR explanation** | *Invitation management enables captains to invite players and allows the system to validate team membership rules.* |


## US-06 - View tournament information

| Field | Description |
|------|-------------|
| **ID** | US-06 |
| **Title** | View tournament information |
| **Description** | *AS a participant I WANT to consult tournament information such as rules, important dates, schedules, and results.* |
| **Priority** | *High* |
| **Priority explanation** | *Because centralized tournament information improves transparency and reduces confusion among participants.* |
| **Related functional requirement(s)** | *FR-13 Tournament configuration, FR-20 Tournament statistics consultation* |
| **RFR explanation** | *Tournament configuration and statistics consultation allow participants to access official competition information and results.* |


## US-07 - Create a team

| Field | Description |
|------|-------------|
| **ID** | US-07 |
| **Title** | Create a team |
| **Description** | *AS a captain I WANT to create a team with a name, crest, and uniform colors SO THAT I can organize a group of players and prepare it for tournament registration.* |
| **Priority** | *High* |
| **Priority explanation** | *Because team creation is one of the main functions of the platform and is necessary for tournament participation.* |
| **Related functional requirement(s)** | *FR-05 Team creation, FR-06 Team configuration* |
| **RFR explanation** | *Team creation and configuration allow captains to define the identity and structure of their teams.* |


## US-08 - Search players

| Field | Description |
|------|-------------|
| **ID** | US-08 |
| **Title** | Search players |
| **Description** | *AS a captain I WANT to search for players by position, semester, age, gender, name, or identification SO THAT I can find suitable players to complete my team.* |
| **Priority** | *High* |
| **Priority explanation** | *Because captains need effective search criteria to build balanced teams.* |
| **Related functional requirement(s)** | *FR-07 Player search* |
| **RFR explanation** | *Player search functionality allows captains to identify suitable participants based on specific filters.* |


## US-09 - Invite players to my team

| Field | Description |
|------|-------------|
| **ID** | US-09 |
| **Title** | Invite players to my team |
| **Description** | *AS a captain I WANT to send invitations to available players SO THAT I can complete the minimum number of players required for my team.* |
| **Priority** | *High* |
| **Priority explanation** | *Because team completion depends on the captain's ability to contact and recruit players through the platform.* |
| **Related functional requirement(s)** | *FR-08 Team invitation management* |
| **RFR explanation** | *Invitation management allows captains to recruit players directly through the platform.* |


## US-10 - Upload payment proof

| Field | Description |
|------|-------------|
| **ID** | US-10 |
| **Title** | Upload payment proof |
| **Description** | *AS a captain I WANT to upload the payment proof for my team's registration SO THAT the organizer can review it and approve my team's participation in the tournament.* |
| **Priority** | *High* |
| **Priority explanation** | *Because payment validation is required before a team can be officially approved to participate in the tournament.* |
| **Related functional requirement(s)** | *FR-10 Payment receipt upload* |
| **RFR explanation** | *Payment receipt upload allows captains to submit proof of payment for tournament registration.* |


## US-11 - Define team lineup

| Field | Description |
|------|-------------|
| **ID** | US-11 |
| **Title** | Define team lineup |
| **Description** | *AS a captain I WANT to select starters, substitutes, and the formation for each match SO THAT my team can be properly organized before the game begins.* |
| **Priority** | *High* |
| **Priority explanation** | *Because lineups are necessary to prepare each match and provide visibility for both teams before playing.* |
| **Related functional requirement(s)** | *FR-14 Team lineup management* |
| **RFR explanation** | *Team lineup management allows captains to define the players and formation that will participate in a match.* |


## US-12 - Create tournament

| Field | Description |
|------|-------------|
| **ID** | US-12 |
| **Title** | Create tournament |
| **Description** | *AS an organizer I WANT to create a tournament with basic information such as start date, end date, number of teams, cost, and status SO THAT I can initialize and manage the competition through the platform.* |
| **Priority** | *High* |
| **Priority explanation** | *Because tournament creation is the basis for all other administrative and operational processes in the platform.* |
| **Related functional requirement(s)** | *FR-12 Tournament creation* |
| **RFR explanation** | *Tournament creation enables organizers to initialize and register new competitions within the platform.* |


## US-13 - Configure tournament rules and schedule

| Field | Description |
|------|-------------|
| **ID** | US-13 |
| **Title** | Configure tournament rules and schedule |
| **Description** | *AS an organizer I WANT to define the rules, important dates, registration deadline, match schedules, fields, and sanctions SO THAT the tournament operates under clear and transparent conditions.* |
| **Priority** | *High* |
| **Priority explanation** | *Because proper tournament configuration ensures transparency, order, and consistency during the competition.* |
| **Related functional requirement(s)** | *FR-13 Tournament configuration* |
| **RFR explanation** | *Tournament configuration allows organizers to establish the operational parameters and rules of the competition.* |


## US-14 - Review payment proofs

| Field | Description |
|------|-------------|
| **ID** | US-14 |
| **Title** | Review payment proofs |
| **Description** | *AS an organizer I WANT to review the payment proofs uploaded by captains and approve or reject them SO THAT only eligible teams can participate in the tournament.* |
| **Priority** | *High* |
| **Priority explanation** | *Because payment approval is a mandatory condition for official tournament registration.* |
| **Related functional requirement(s)** | *FR-11 Payment validation* |
| **RFR explanation** | *Payment validation allows organizers to verify submitted payment receipts and determine whether a team can participate in the tournament.* |


## US-15 - Register match results

| Field | Description |
|------|-------------|
| **ID** | US-15 |
| **Title** | Register match results |
| **Description** | *AS an organizer I WANT to register match results, scorers, yellow cards, and red cards SO THAT the system can update standings and maintain tournament statistics automatically.* |
| **Priority** | *High* |
| **Priority explanation** | *Because match data is necessary for standings, statistics, and the overall progress of the tournament.* |
| **Related functional requirement(s)** | *FR-16 Match result registration, FR-18 Standings calculation* |
| **RFR explanation** | *Match result registration allows the system to store match outcomes and automatically update tournament standings.* |


## US-16 - View assigned matches

| Field | Description |
|------|-------------|
| **ID** | US-16 |
| **Title** | View assigned matches |
| **Description** | *AS a referee I WANT to view the matches assigned to me, including date, time, field, and teams SO THAT I can be properly informed before officiating each match.* |
| **Priority** | *High* |
| **Priority explanation** | *Because referees need access to their assigned match information to support the operational execution of the tournament.* |
| **Related functional requirement(s)** | *FR-17 Match consultation for referees* |
| **RFR explanation** | *Match consultation allows referees to review relevant information about the games they will officiate.* |


## US-17 - Manage roles and permissions

| Field | Description |
|------|-------------|
| **ID** | US-17 |
| **Title** | Manage roles and permissions |
| **Description** | *AS an administrator I WANT to manage user roles and permissions SO THAT the platform remains secure and each user can only access the functions allowed for their role.* |
| **Priority** | *High* |
| **Priority explanation** | *Because role-based control is essential for system security.* |
| **Related functional requirement(s)** | *NFR-01 Role-based access control* |
| **RFR explanation** | *Role-based access control ensures that users can only perform actions permitted by their assigned role in the system.* |


## US-18 - Monitor audit logs

| Field | Description |
|------|-------------|
| **ID** | US-18 |
| **Title** | Monitor audit logs |
| **Description** | *AS an administrator I WANT to review audit logs of relevant system actions SO THAT I can monitor activity, ensure traceability, and detect possible misuse of the platform.* |
| **Priority** | *Medium* |
| **Priority explanation** | *Because audit monitoring supports accountability, security, and administrative control of the platform.* |
| **Related functional requirement(s)** | *NFR-02 Audit logging* |
| **RFR explanation** | *Audit logging allows administrators to monitor important system actions and maintain traceability of platform activities.* |
