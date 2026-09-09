# 5G Core Handoff — Open5GS + UERANSIM (Validated)

## Status
Core is fully deployed and validated end-to-end on a manual Ubuntu 24.04.4 LTS VM build.
Confirmed working: UE registration, authentication, PDU session establishment
(real IP assigned by SMF/UPF). This is the "primary milestone" from the project
proposal, achieved via UERANSIM (temporary simulated RAN) — will later be
replaced with OAI's disaggregated CU/DU.

## Startup order matters — NRF must start FIRST
Every other NF registers itself with NRF on startup. If NRF isn't up yet,
everything else will crash-loop or fail to register. Correct order:
nrf -> scp -> amf -> smf -> upf -> ausf -> udm -> udr -> pcf -> bsf -> nssf

## Key config values (must match across all components)
- PLMN: MCC 999, MNC 70
- TAC: 1
- Test subscriber IMSI: 999700000000001
- Subscriber key (K): 465B5CE8B199B49FAA5F0A2EE238A6BC
- Subscriber OPc: E8ED289DEBA952E4283B54E88E6183CA
- DNN: internet
- UPF session subnet: 10.45.0.0/16

## IMPORTANT bug we hit — subscriber creation command
Use this command to add a subscriber:
    open5gs-dbctl add <imsi> <key> <opc>

Do NOT use `add_ue_with_slice` — it forces an explicit SD value (e.g. SD:0x0)
that mismatches what UERANSIM/OAI UEs typically request (no SD / 0xffffff),
causing a "No Allowed-NSSAI" registration rejection. Cost us significant
debugging time. Verify subscriber's slice info with:
    open5gs-dbctl showall

## Containerization notes for DevOps
- All NFs can share ONE built image (same Open5GS binaries); each container
  just runs a different daemon as its command (e.g. `open5gs-amfd -c amf.yaml`)
- MongoDB should be a separate container (official `mongo` image is fine)
- **UPF needs `NET_ADMIN` capability (or `--privileged`)** — it creates a
  virtual tunnel interface (`ogstun`) at runtime, which requires elevated
  network privileges inside the container
- In containers, configs must reference other services by container/service
  name (Docker DNS) instead of the loopback IPs (127.0.0.x) used in this
  manual VM setup — that's the main config difference to account for

## Known non-blocking issue (informational only)
On this VM, outbound internet traffic from the UE's IP range (10.45.0.0/16)
was blocked specifically by VirtualBox's NAT engine (confirmed via
iptables/nftables/tcpdump/Wireshark — traffic reaches the UPF's tunnel
interface correctly but VirtualBox's virtual NIC drops packets sourced
from IPs outside the VM's primary assigned IP). This is a local VM
limitation, not a Core/config issue, and is expected to disappear once
deployed on AWS/EKS with a real network interface.

## Files in this folder
All 11 Open5GS NF configs (as currently running) + UERANSIM gNB/UE configs
used for the successful test.
