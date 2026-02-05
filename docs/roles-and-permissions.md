---
layout: default
title: Roles and permissions
---

The TECHCUP Football Platform uses a role-based access control model to regulate
user interactions with the system. Each role has specific permissions that determine
which functionalities can be accessed.

These permissions ensure that users can only perform actions appropriate to their
responsibilities within the tournament management process.

## Roles and permissions matrix

| Functionality                | Participant| Captain| Organizer | Referee | Administrator |
|------------------------------|------------|--------|-----------|---------|---------------|
| Register account             | ✓          | ✓      | ✓         | ✓       | ✓             |
| Log in to platform           | ✓          | ✓      | ✓         | ✓       | ✓             |
| Create sports profile        | ✓          | ✓      |           |         |               |
| Set availability as player   | ✓          | ✓      |           |         |               |
| Respond to invitations       | ✓          | ✓      |           |         |               |
| View tournament information  | ✓          | ✓      | ✓         | ✓       | ✓             |
| Create team                  |            | ✓      |           |         |               |
| Configure team               |            | ✓      |           |         |               |
| Search players               |            | ✓      |           |         |               |
| Invite players               |            | ✓      |           |         |               |
| Upload payment proof         |            | ✓      |           |         |               |
| Define team lineup           |            | ✓      |           |         |               |
| Create tournament            |            |        | ✓         |         |               |
| Configure tournament         |            |        | ✓         |         |               |
| Review payment proofs        |            |        | ✓         |         |               |
| Register match results       |            |        | ✓         |         |               |
| View assigned matches        |            |        |           | ✓       |               |
| Manage roles and permissions |            |        |           |         | ✓             |
| Monitor audit logs           |            |        |           |         | ✓             |


## Use case diagrams

The permissions described above correspond to the interactions illustrated in the use case diagrams included below.

Each role interacts with the system according to the permissions defined in the roles and permissions matrix.

## Use case Participant
<img width="664" height="788" alt="image" src="/assets/images/roles/participant.png"/>

## Use case Captain
<img width="527" height="823" alt="image" src="/assets/images/roles/capitan.png"/>

## Use case Organizer
<img width="775" height="837" alt="image" src="/assets/images/roles/organizer.png"/>

## Use case Referee
<img width="715" height="635" alt="image" src="/assets/images/roles/referee.png"/>

## Use case Administrator
<img width="697" height="530" alt="image" src="/assets/images/roles/admin.png"/>
