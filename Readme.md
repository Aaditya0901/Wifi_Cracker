# Wi-Fi Security Auditor (Lab Only)

**Note:** This repository contains educational demos and analysis tools intended for use **only** in controlled lab environments or on networks you own and have explicit permission to test. Do **not** use this code on third-party or public networks. Unauthorized access is illegal.

## What this project is
A compact Bash-based toolkit and set of demonstrations created to help students learn about common wireless security weaknesses and defenses. The project is for **research and defensive learning only** — it illustrates how outdated protocols and misconfigurations can be exploited so administrators can mitigate risk.

## Key learning goals
- Understand the differences between legacy (e.g., WEP) and modern (e.g., WPA/WPA2) Wi-Fi protection models.
- Observe how weak keys, poor configuration, and lack of monitoring increase exposure.
- Produce reproducible lab reports that list vulnerabilities and prioritized remediation steps.
- Practice responsible disclosure and ethical testing procedures.

## Tools (high level)
- `aircrack-ng` (toolset often used in wireless security research)
- `macchanger` (used for experimenting with MAC addressing in labs)
- Packet capture and analysis utilities (e.g., Wireshark)

> These are listed for transparency. Do not publish or run the original exploit sequences on unauthorized networks.

## Scope (non-actionable)
- **WEP**: Demonstrates why legacy crypto is insecure and how reliance on it is risky. Emphasizes migration strategies.
- **WPA/WPA2 (PSK)**: Demonstrates that weak passphrases and misconfigurations reduce protection and that improved policies are needed.
- **Reporting**: The repository includes sample lab reports, vulnerability summaries, and recommended mitigation checklists — **no attack recipes**.

## Responsible use & mitigation advice
When testing in an authorized lab, focus on:
- Replacing legacy encryption (disable WEP; prefer WPA3 where possible).
- Enforcing long, random passphrases and strong SSID/guest network separation.
- Enabling network monitoring and logging (SIEM, alerts).
- Applying least-privilege for management interfaces and avoiding default credentials.
- Documenting findings and using responsible disclosure channels to report issues.

## Disclaimer
This project is educational. The authors are not responsible for misuse. Always obtain written permission before testing networks you do not own.

