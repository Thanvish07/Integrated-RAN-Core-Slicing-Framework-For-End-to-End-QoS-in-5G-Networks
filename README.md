This project proposes an **Integrated RAN-Core Slicing Framework** for 5G Standalone (SA) networks, enabling **end-to-end Quality of Service (QoS)** across heterogeneous 5G applications, including **Ultra-Reliable Low Latency Communications (URLLC)**, **enhanced Mobile Broadband (eMBB)**, and **massive Machine Type Communications (mMTC)**. The architecture leverages **Open5GS** as the Core Network and **UERANSIM** for the RAN, supporting **dynamic slice orchestration**, **cross-domain policy enforcement**, and **performance-aware resource management**. Monitoring and visualization are facilitated via **Prometheus** and **Grafana**.

---

## 🧩 **System Overview**

**Technology Stack**:
- **Open5GS** – Simulated 5G Core Network (AMF, SMF, UPF, PCF, NSSF)
- **UERANSIM** – Simulated 5G gNB and UE
- **Prometheus** – Time-series metrics collection and monitoring
- **Grafana** – Real-time dashboard visualization
- **Wireshark** – Network packet capture and protocol analysis
- **Ubuntu Linux** – Target deployment environment

---

## 🔐 **Architecture Overview**

![Architecture Diagram](https://github.com/user-attachments/assets/8c49ade4-9095-4b07-a932-58d9812c6a14)

---

## 🔁 **Integrated Slicing Model**

![Slicing Diagram](https://github.com/user-attachments/assets/8bbd9df3-95a8-43d5-b91a-96cc1c4086e1)

### 🔧Key Components:

- **RAN Slicing**: Enables radio resource isolation and prioritization across services.
- **Core Slicing**: Differentiates core network functionalities using S-NSSAI for each service class.
- **Cross-Domain Orchestration**: Implements unified slice policy management across RAN and Core.
- **QoS Enforcement**: Policy Control Function (PCF) enforces SLA-specific QoS rules based on service requirements.

---

## 🧠 **Core Network Functions**

- **Access and Mobility Management Function (AMF)**: Manages UE registration and mobility procedures.
- **Session Management Function (SMF)**: Handles session lifecycle, including IP allocation and QoS rules.
- **User Plane Function (UPF)**: Forwards user traffic with QoS classification and enforcement.
- **Network Slice Selection Function (NSSF)**: Allocates appropriate network slices based on S-NSSAI.
- **Policy Control Function (PCF)**: Manages slice-aware policy decisions and QoS parameters.

![Core Functional Architecture](https://github.com/user-attachments/assets/cf021f44-a914-4f23-a4c3-ae9ca54185cf)

---

## 🧱 **Prerequisites**

### 📦 **Hardware Requirements**

- **Core Machine**:
  - CPU: ≥ 8 Cores
  - RAM: 16–32 GB
  - Storage: SSD preferred
  - Network: 10 Gbps NIC recommended
- **gNB/UE VM Instance**:
  - CPU: ≥ 4 Cores
  - RAM: ≥ 8 GB
- All components must reside on the same subnet/local area network.

### 💽 **Software Requirements**

- **Operating System**: Ubuntu 20.04 LTS or later
- **Open5GS**: Built from source to ensure compatibility and customization
- **UERANSIM**: Built from source with appropriate PLMN configuration
- **Monitoring Tools**:
  - Prometheus (metrics collection)
  - Grafana (dashboard visualization)
- **Wireshark**: For traffic inspection and protocol analysis

---

## 🛠️ **Setup Instructions**

To begin setting up the 5G Standalone network, follow the comprehensive installation guide for **Open5GS** and **UERANSIM** available [here](https://github.com/mhradhika/5GTrial/wiki/1.Open5Gs-and-UERANSIM).

Once installation is complete, verify the services by executing the following commands:

```bash
sudo systemctl status open5gs-*
sudo systemctl status mongod
```
These commands ensure the Open5GS core services and MongoDB database are active and functioning as expected.

---

## ⚙️ **Configuration Guide**

This section outlines the essential configurations required to enable integrated RAN-Core slicing with end-to-end QoS management using Open5GS and UERANSIM.

## 🧠 **Open5GS Configuration**

### 👤 **Subscriber Registration via Web UI**
1. Open the Open5GS WebUI in your browser:
http://localhost:9999

2. Login Credentials:
`Username: admin`
`Password: 1234`

3. Navigate to the Subscribers section and register the desired UE by specifying its IMSI, such as 001010000000001. The configuration may vary depending on the target network slice (eMBB, URLLC, mMTC).

- 📸 Below are example subscriber configurations:
<img width="1554" height="854" alt="UE-1_Info" src="https://github.com/user-attachments/assets/6d3fa87d-0fd3-4bd4-8111-4ebd3f271095" />
<img width="1554" height="854" alt="UE-2_Info" src="https://github.com/user-attachments/assets/c5989561-592e-43f3-804c-f15fcacb00d6" />
<img width="1554" height="854" alt="UE-3_Info" src="https://github.com/user-attachments/assets/97f6c45a-b93f-4f1e-861f-6d4c9c8b570d" />


### 📝 **Config Files**
Below are the sample configuration templates for each 5G Core function. All files must be placed under /etc/open5gs/ unless otherwise specified.

- **AMF.yaml**:
Handles UE registration, mobility, slice selection, and supports inter-gNB handovers.
```
logger:
  file:
    path: /var/log/open5gs/amf.log
    level: debug
#  level: info   # fatal|error|warn|info(default)|debug|trace

global:
  max:
    ue: 1024  # The number of UE can be increased depending on memory size.
#    peer: 64

amf:
  sbi:
    server:
      - address: 127.0.0.5
        port: 7777
    client:
      nrf:
        - uri: http://127.0.0.10:7777
  ngap:
    server:
      - address: 10.2.22.85
  metrics:
    server:
      - address: 127.0.0.5
        port: 9090
  guami:
    - plmn_id:
        mcc: "001"
        mnc: "01"
      amf_id:
        region: 202
        set: 1016
  tai:
    - plmn_id:
        mcc: "001"
        mnc: "01"
      tac: 1
    - plmn_id:
        mcc: "001"
        mnc: "01"
      tac: 2
  plmn_support:
    - plmn_id:
        mcc: "001"
        mnc: "01"
      s_nssai:
        - sst: 1
        - sst: 2
        - sst: 3
  location_service:
    enable: true
    periodic_reporting: true
    reporting_interval: 10
  security:
    integrity_order : [ NIA2, NIA1 ]
    ciphering_order : [ NEA0, NEA1, NEA2 ]
  network_name:
    full: Open5GS
  amf_name: open5gs-amf0
  time:
    t3512:
      value: 540     # 9 minutes * 60 = 540 seconds
  support_features:
    enable: true
    features:
      - feature_name: "Slice Selection Support"
  handover:
    enable: true
    gnb_handover:
      - from_gnb: 10.2.22.89
        to_gnb: 10.2.22.93
        handover_type: "Inter-gNB Handover"
      - from_gnb: 10.2.22.93
        to_gnb: 10.2.22.89
        handover_type: "Inter-gNB Handover"
  session:
    sessionEstablishmentTimeout: 5 # Time for session startup
    sessionModificationTimeout: 5 # Time for session modification
  reestablishment:
    retries: 3 # Maximum number of retries if UE disconnects from one gnb
    timeout: 10 # Timeout before attempting reestablishment to other gnb
```

- **SMF.yaml**:
Responsible for session management, QoS enforcement, and slice-aware subnet configuration.
```
logger:
  file:
    path: /var/log/open5gs/smf.log
    level: debug
#  level: info   # fatal|error|warn|info(default)|debug|trace

global:
  max:
    ue: 1024  # The number of UE can be increased depending on memory size.
#    peer: 64

smf:
  sbi:
    server:
      - address: 127.0.0.4
        port: 7777
    client:
      scp:
        - uri: http://127.0.0.200:7777
  pfcp:
    server:
      - address: 127.0.0.4
    client:
      upf:
        - address: 127.0.0.7
  gtpc:
    server:
      - address: 127.0.0.4
  gtpu:
    server:
      - address: 127.0.0.4
  metrics:
    server:
      - address: 127.0.0.4
        port: 9090
  s_nssai:
      - sst: 1
      - sst: 2
      - sst: 3
  session:
    - subnet: 10.45.0.0/16
      gateway: 10.45.0.1
      s_nssai:
        sst: 1
        dnn: embb
    - subnet: 2001:db8:cafe::/48
      gateway: 2001:db8:cafe::1
      s_nssai:
        sst: 2
        dnn: urllc
    - subnet: fe80::6d84:386b:620b:1/64
      gateway: fe80::6d84:386b:620b:1
      s_nssai:
        sst: 3
        dnn: crit
  qos_profiles:
    - sst: 1
      5qi: 9
      arp: 2
      gbr: 100Mbps #High Throughput
      mbr: 1Gbps
    - sst: 2
      5qi: 1
      arp: 1
      gbr: 1Mbps #Ultra Low Throughput
      mbr: 3Mbps
    - sst: 3
      5qi: 7
      arp: 10
      gbr: 25Mbps #Low Throughput
      mbr: 50Mbps
  dns:
     - 8.8.8.8
     - 8.8.4.4
     - 2001:4860:4860::8888
     - 2001:4860:4860::8844
  mtu: 1400
  freeDiameter: /etc/freeDiameter/smf.conf
```

- **UPF.yaml**:
Manages user-plane forwarding, GTP-U tunneling, and session-based QoS allocation.
```
logger:
  file:
    path: /var/log/open5gs/upf.log
    level: debug
#  level: info   # fatal|error|warn|info(default)|debug|trace

global:
  max:
    ue: 1024  # The number of UE can be increased depending on memory size.
#    peer: 64

upf:
  pfcp:
    server:
      - address: 127.0.0.7
    client:
  gtpu:
    server:
      - address: 10.2.22.85
  session:
    - subnet: 10.45.0.0/16
      gateway: 10.45.0.1
      s_nssai:
        sst: 1
        dnn: embb
    - subnet: 2001:db8:cafe::/48
      gateway: 2001:db8:cafe::1
      s_nssai:
        sst: 2
        dnn: urllc
    - subnet: fe80::6d84:386b:620b:1/64
      gateway: fe80::6d84:386b:620b:1
      s_nssai:
        sst: 3
        dnn: crit
  nssai:
      s_nssai:
          - sst: 1
          - sst: 2
          - sst: 3
  qos_profiles:
    - sst: 1
      5qi: 9
      arp: 2
      gbr: 100Mbps
      mbr: 1Gbps
    - sst: 2
      5qi: 1
      arp: 1
      gbr: 1Mbps
      mbr: 3Mbps
    - sst: 3
      5qi: 7
      arp: 10
      gbr: 25Mbps
      mbr: 50Mbps
  metrics:
    server:
      - address: 127.0.0.7
        port: 9090
```

- **NRF.yaml**:
Supports service discovery and registration for core functions using the SBI interface.
```
logger:
  file:
    path: /var/log/open5gs/nrf.log
    level: debug
#  level: info   # fatal|error|warn|info(default)|debug|trace

global:
  max:
    ue: 1024  # The number of UE can be increased depending on memory size.
#    peer: 64

nrf:
  serving:  # 5G roaming requires PLMN in NRF
    - plmn_id:
        mcc: "001"
        mnc: "01"
  sbi:
    server:
      - address: 127.0.0.10
        port: 7777
```

- **NSSF.yaml**:
Implements network slice selection logic, supporting mapping between S-NSSAI and DNN.
```
logger:
  file:
    path: /var/log/open5gs/nssf.log
    level: debug
#  level: info   # fatal|error|warn|info(default)|debug|trace

global:
  max:
    ue: 1024  # The number of UE can be increased depending on memory size.
#    peer: 6

nssf:
  sbi:
    server:
      - address: 127.0.0.14
        port: 7777
    client:
      nrf:
        - uri: http://127.0.0.10:7777
      nsi:
        - uri: http://127.0.0.19:7777
          s_nssai:
            sst: 1
            #sd: "000001"  # Slice 1
          mapping:
            dnn: embb
        - uri: http://127.0.0.10:7777
          s_nssai:
            sst: 2
            #sd: "000002"  # Slice 2
          mapping:
            dnn: urllc
        - uri: http://127.0.0.11:7777
          s_nssai:
            sst: 3
            #sd: "000003"  # Slice 3
          mapping:
            dnn: crit
    nssai:
        supported_nssai:
            - sst: 1
              #sd: "000001"
            - sst: 2
              #sd: "000002"
            - sst: 3
              #sd: "000003"
    amf_nssai_availability:
        - sst: 1
          #sd: "000001"
        - sst: 2
          #sd: "000002"
        - sst: 3
          #sd: "000003"
    tai_list:
      - plmn_id:
          mcc: 001
          mnc: 01
        tac: 1
```

- **PCF.yaml**:
Defines policies for different slice types and manages QoS enforcement using pre-defined ARP and 5QI profiles.
```
db_uri: mongodb://localhost/open5gs
logger:
  file:
    path: /var/log/open5gs/pcf.log
#  level: info   # fatal|error|warn|info(default)|debug|trace

global:
  max:
    ue: 1024  # The number of UE can be increased depending on memory size.
#    peer: 64

pcf:
  sbi:
    server:
      - address: 127.0.0.13
        port: 7777
    client:
      nrf:
        - uri: http://127.0.0.10:7777
      scp:
        - uri: http://127.0.0.200:7777
  metrics:
    server:
      - address: 127.0.0.13
        port: 9090
  policy:
    - plmn_id:
        mcc: 001
        mnc: 01
      slice:
        - sst: 1  # Slice/Service Type for Immersive AR/VR and Cloud Gaming
          default_indicator: true
          session:
            - name: embb
              type: 3  # 1:IPv4, 2:IPv6, 3:IPv4v6
              ambr:
                downlink:
                  value: 1
                  unit: 3 # 0:bps, 1:Kbps, 2:Mbps, 3:Gbps, 4:Tbps
                uplink:
                  value: 1
                  unit: 3
              qos:
                index: 9  # 1, 2, 3, 4, 65, 66, 67, 75, 71, 72, 73, 74, 76, 5, 6, 7, 8, 9, 69, 70, 79, 80, 82, 83, 84, 85, 86
                arp:
                  priority_level: 2  # 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
                  pre_emption_vulnerability: 1  # 1: Disabled, 2:Enabled
                  pre_emption_capability: 1  # 1: Disabled, 2:Enabled
        - sst: 2  # Slice/Service Type for Autonomous Vehicles and V2X Communications
          default_indicator: true
          session:
            - name: urllc
              type: 3  # 1:IPv4, 2:IPv6, 3:IPv4v6
              ambr:
                downlink:
                  value: 1
                  unit: 2  # 0:bps, 1:Kbps, 2:Mbps, 3:Gbps, 4:Tbps
                uplink:
                  value: 1
                  unit: 2
              qos:
                index: 1  # 1, 2, 3, 4, 65, 66, 67, 75, 71, 72, 73, 74, 76, 5, 6, 7, 8, 9, 69, 70, 79, 80, 82, 83, 84, 85, 86
                arp:
                  priority_level: 1  # 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
                  pre_emption_vulnerability: 1  # 1: Disabled, 2:Enabled
                  pre_emption_capability: 1  # 1: Disabled, 2:Enabled
        - sst: 3  # Slice/Service Type for Real-Time Control in Smart Manufacturing
          default_indicator: true
          session:
            - name: crit
              type: 3  # 1:IPv4, 2:IPv6, 3:IPv4v6
              ambr:
                downlink:
                  value: 25
                  unit: 2  # 0:bps, 1:Kbps, 2:Mbps, 3:Gbps, 4:Tbps
                uplink:
                  value: 25
                  unit: 2
              qos:
                index: 7  # 1, 2, 3, 4, 65, 66, 67, 75, 71, 72, 73, 74, 76, 5, 6, 7, 8, 9, 69, 70, 79, 80, 82, 83, 84, 85, 86
                arp:
                  priority_level: 10  # 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
                  pre_emption_vulnerability: 1  # 1: Disabled, 2:Enabled
                  pre_emption_capability: 1  # 1: Disabled, 2:Enabled
  qos_profiles:
    - sst: 1
      5qi: 9
      arp: 2
      gbr: 100Mbps
      mbr: 1Gbps
    - sst: 2
      5qi: 1
      arp: 1
      gbr: 1Mbps
      mbr: 3Mbps
    - sst: 3
      5qi: 7
      arp: 10
      gbr: 25Mbps
      mbr: 50Mbps
```
**📌 Notes**:
1. Ensure MongoDB is running before launching Open5GS components.
2. All IP addresses and interface bindings in .yaml files should be tailored based on your system's local network configuration.
3. QoS parameters (5QI, ARP, GBR, MBR) must align with the service type (eMBB, URLLC, mMTC).
4. All core functions (AMF, SMF, UPF, NRF, NSSF, PCF) must be registered and discoverable via NRF for full-service orchestration.
5. For additional logs and troubleshooting:
```bash
tail -f /var/log/open5gs/*.log
```
This will help monitor service activity and diagnose potential configuration errors.

### 🧰 **Open5GS Service Scripts**

This section provides utility bash scripts to streamline the management of Open5GS services.

**restart.sh**
Script to restart all Open5GS components systematically.
```bash
#!/bin/bash
sudo systemctl restart open5gs-mmed
sudo systemctl restart open5gs-sgwcd
sudo systemctl restart open5gs-sgwud
sudo systemctl restart open5gs-smfd
sudo systemctl restart open5gs-amfd
sudo systemctl restart open5gs-upfd
sudo systemctl restart open5gs-hssd
sudo systemctl restart open5gs-pcrfd
sudo systemctl restart open5gs-nrfd
sudo systemctl restart open5gs-scpd
sudo systemctl restart open5gs-ausfd
sudo systemctl restart open5gs-udmd
sudo systemctl restart open5gs-pcfd
sudo systemctl restart open5gs-nssfd
sudo systemctl restart open5gs-bsfd
sudo systemctl restart open5gs-udrd
sudo systemctl restart open5gs-webui
```

**stop.sh**
Script to gracefully stop all Open5GS services.
```bash
#!/bin/bash
sudo systemctl stop open5gs-mmed
sudo systemctl stop open5gs-sgwcd
sudo systemctl stop open5gs-smfd
sudo systemctl stop open5gs-amfd
sudo systemctl stop open5gs-sgwud
sudo systemctl stop open5gs-upfd
sudo systemctl stop open5gs-hssd
sudo systemctl stop open5gs-pcrfd
sudo systemctl stop open5gs-nrfd
sudo systemctl stop open5gs-scpd
sudo systemctl stop open5gs-ausfd
sudo systemctl stop open5gs-udmd
sudo systemctl stop open5gs-pcfd
sudo systemctl stop open5gs-nssfd
sudo systemctl stop open5gs-bsfd
sudo systemctl stop open5gs-udrd
sudo systemctl stop open5gs-webui
```
### 🧱 **Iptables Settings**

Ensure that routing rules allow GTP-U traffic for proper data plane functionality:

![iptables_1](https://github.com/mhradhika/5GTrial/assets/107171044/ff70c46b-e24d-45f6-9dcb-4d624b6f74be)
![iptables_2](https://github.com/mhradhika/5GTrial/assets/107171044/f924e794-3875-4b2e-88eb-0df60087ece4)

---

## 📊 **Prometheus & Grafana Setup Guide**
Integrate Prometheus and Grafana to enable real-time monitoring and visualization of Open5GS performance metrics.

### 🐘 **Prometheus**

### **💾 Installation**
```bash
sudo useradd --no-create-home --shell /bin/false prometheus
wget https://github.com/prometheus/prometheus/releases/latest/download/prometheus-*.linux-amd64.tar.gz
tar -xvf prometheus-*.linux-amd64.tar.gz
cd prometheus-*
sudo mv prometheus /usr/local/bin/
sudo mv promtool /usr/local/bin/
sudo mkdir -p /etc/prometheus /var/lib/prometheus
sudo mv consoles/ console_libraries/ prometheus.yml /etc/prometheus/
```
#### **🛠️ Configuration**
Edit the Prometheus config file:

```yaml
# /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'open5gs'
    static_configs:
      - targets: ['localhost:9090']
```
Replace `localhost:9090` with the actual IP and port of the metrics exporter (if using open5gs-exporter or custom Flask exporter).
Adjust targets as per your metrics exporter configuration.

#### **🚀 Running Prometheus**
```bash
prometheus --config.file=/etc/prometheus/prometheus.yml
```
Prometheus will be accessible at: `http://<server-ip>:9090`

### 📈 **Grafana**

#### **💾 Installation**
```bash
sudo apt install -y software-properties-common
sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo apt update
sudo apt install grafana
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
```

#### **📊 Configuration**
1. Open Grafana in browser: `http://<server-ip>:3000`
2. Login with default credentials:
   - **Username**: `admin`
   - **Password**: `admin`
3. Add Prometheus as a data source:
   - Go to ⚙️ → **Data Sources**
   - Select **Prometheus**
   - Set URL to `http://localhost:9090` (or actual Prometheus IP)
   - Click **Save & Test**

#### **🗂️ Importing Dashboard**
You can import prebuilt Open5GS dashboards or create your own:

1. Go to ➕ → **Import**.
2. Enter dashboard ID or upload a `.json` file.
3. Select Prometheus as the data source.

#### **✅ Recommended Metrics to Visualize**

1. `open5gs_amf_connected_ues` -> Connected UEs to AMF.        
2. `open5gs_smf_pdu_sessions`  -> Active PDU sessions per SMF.        
3. `open5gs_upf_traffic_bytes` -> Traffic handled by UPF.        
4. `open5gs_slice_throughput`  -> Throughput per slice.        
5. `open5gs_qos_latency_ms`    -> Latency per QoS Flow.        

#### **🧪 Validation**

1. Check Prometheus targets at `http://<server-ip>:9090/targets`
2. Verify Grafana panels update with live Open5GS metrics
3. Inspect logs if no data appears (`journalctl -u grafana-server`)

### **📌 Notes**

1. Make sure firewalls allow port `9090` (Prometheus) and `3000` (Grafana)
2. If using remote exporters, allow them in Prometheus static config
3. Consider using `node_exporter` for server-level metrics

### **📚 Further Enquiry**
1. [Prometheus Docs](https://prometheus.io/docs/)
2. [Grafana Docs](https://grafana.com/docs/)

---

## 📶 **UERANSIM Configuration**
This section outlines the configuration details for the UERANSIM components (gNB and UEs) used in integration with the Open5GS 5G Core. Ensure IP addresses and PLMN parameters are aligned with your network topology and Open5GS setup.

### 📡 **gNB Config File**
Ensure the following gNB configuration file is updated to reflect the correct AMF IP and slice details:
```
mcc: "001"  # Primary PLMN MCC
mnc: "01"  # Primary PLMN MNC
nci: '0x000000010'  # gNB NCI
idLength: 32  # gNB ID length
tac: 1  # Tracking Area Code for PLMN 001/01
linkIp: 10.2.22.89  # gNB IP address for NGAP
ngapIp: 10.2.22.89  # gNB IP address for NGAP
gtpIp: 10.2.22.89  # gNB IP address for GTP-U

# AMF configurations
amfConfigs:
  - address: 10.2.22.85  # AMF IP address
    port: 38412  # AMF port

ignoreStreamIds: true

# System information broadcast (true/false)
systemInfo:
  broadcast: true

# gNB Search List (list of AMFs that the gNB can contact)
gnbSearchList:
  - 10.2.22.85

# Barred flag (used to block the gNB)
barred: false

# PLMN list configuration
plmnList:
  - plmn:
      mcc: "001"
      mnc: "01"
    tac: 1

# Slices configuration
slices:
  - sst: 1  # Slice/Service Type for Immersive AR/VR and Cloud Gaming
    qos:
      5qi: 9
      arp: 2
      priority: 2
      gbr: 100Mbps  # High throughput
      mbr: 1Gbps
      latency: 50ms  # High latency
      packet_loss: 0.01 # Low packet loss
  - sst: 2  # Slice/Service Type for Autonomous Vehicles and V2X Communications
    qos:
      5qi: 1
      arp: 1
      priority: 1
      gbr: 1Mbps  # Moderate throughput
      mbr: 3Mbps
      latency: 0.0001ms  # Ultra-low latency
      packet_loss: 0.000001 # Minimal packet loss
  - sst: 3  # Slice/Service Type for Real-Time Control in Smart Manufacturing
    qos:
      5qi: 7
      arp: 10
      priority: 3
      gbr: 25Mbps  # Low throughput
      mbr: 50Mbps
      latency: 10000ms  # latency
      packet_loss: 10000 # Tolerable packet loss

# Target gNB configuration file example (gnb2.yaml)
handover:
  enabled: true
  source_gnbs:
    - gnbId: 2
      address: 10.2.22.93
      port: 38412
```

### 📱 **UE Config Files**
The following sections detail configuration templates for various UEs targeting different network slices. Ensure supi, keys, and slice configurations align with the Open5GS subscribers and network definitions.

- **🟩 UE-1 eMBB Slice**
```
supi: 'imsi-001010000000001'
mcc: "001"
mnc: "01"
protectionScheme: 0
homeNetworkPublicKey: '5a8d38864820197c3394b92613b20b91633cbd897119273bf8e4a6f4eec0a650'
homeNetworkPublicKeyId: 1
routingIndicator: '0000'
key: '465B5CE8B199B49FAA5F0A2EE238A6BC'  # Ensure key matches AMF
op: 'E8ED289DEBA952E4283B54E88E6183CA'  # Ensure OP matches AMF
opType: 'OPC'
amf: '8000'
imei: '356938035643803'
imeiSv: '4370816125816151'

gnbSearchList:
  - 10.2.22.93  # gNB IP (ensure it is correct)
  - 10.2.22.89

session:
  - s_nssai:
      sst: 1
    dnn: 'embb'
  - s_nssai:
      sst: 2
    dnn: 'urllc'
  - s_nssai:
      sst: 3
    dnn: 'crit'

uacAic:
  mps: false
  mcs: false

uacAcc:
  normalClass: 0
  class11: false
  class12: false
  class13: false
  class14: false
  class15: false

# Integrity and Ciphering Algorithms (matching AMF configuration)
integrity:
  IA2: true
  IA1: true
  IA3: false  # Disabled IA3 as it is not part of AMF's supported integrity list

ciphering:
  EA0: true
  EA1: true
  EA2: true  # Updated to match AMF's ciphering algorithm order
  EA3: false  # Disabled EA3 as it is not part of AMF's supported ciphering list

integrityMaxRate:
  uplink: 'full'
  downlink: 'full'

# Session information (type of connection)
sessions:
  - type: 'IPv4'
    apn: 'embb'  # APN for eMBB
    s_nssai:
      sst: "1"
    dnn: 'embb'

location_service:
  enable: true
#  periodic_reporting: true
#  reporting_interval: 60  # Report location every 60 seconds

nas:
  t3412: 5  # Set a short TAU timer for quick reattachment
  periodic_location_reporting: true  # Enable periodic location reporting for better mobility handling
  location_reporting_interval: 5  # Frequency of location updates in seconds
  tau_retries: 3  # Optional: Number of retries for tracking area updates
  attach_retries: 3  # Optional: Number of retries for the attach procedure
  detach_retries: 2  # Optional: Number of retries for detaching from the gNB

measurement:
  gap: 5  # Measurement gap in milliseconds
  period: 120  # Measurement period in milliseconds

log:
  level: debug
```

- **🟨 UE-2 URLLC Slice**
```
supi: 'imsi-001010000000002'  # Correct IMSI for UE2
mcc: "001"
mnc: "01"
protectionScheme: 0
homeNetworkPublicKey: '5a8d38864820197c3394b92613b20b91633cbd897119273bf8e4a6f4eec0a650'
homeNetworkPublicKeyId: 1
routingIndicator: '0000'
key: '465B5CE8B199B49FAA5F0A2EE238A6BC'  # Ensure key matches AMF
op: 'E8ED289DEBA952E4283B54E88E6183CA'  # Ensure OP matches AMF
opType: 'OPC'
amf: '8000'
#imei: '356938035643803'
#imeiSv: '4370816125816151'

gnbSearchList:
  - 10.2.22.93  # gNB IP (ensure it is correct)
  - 10.2.22.89

session:
  - s_nssai:
      sst: 1
    dnn: 'embb'
  - s_nssai:
      sst: 2
    dnn: 'urllc'
  - s_nssai:
      sst: 3
    dnn: 'crit'

uacAic:
  mps: false
  mcs: false

uacAcc:
  normalClass: 0
  class11: false
  class12: false
  class13: false
  class14: false
  class15: false

# Integrity and Ciphering Algorithms (matching AMF configuration)
integrity:
  IA2: true
  IA1: true
  IA3: false  # Disabled IA3 as it is not part of AMF's supported integrity list

ciphering:
  EA0: true
  EA1: true
  EA2: true  # Updated to match AMF's ciphering algorithm order
  EA3: false  # Disabled EA3 as it is not part of AMF's supported ciphering list

integrityMaxRate:
  uplink: 'full'
  downlink: 'full'

# Session information (type of connection)
sessions:
  - type: 'IPv4'
    apn: 'urllc'  # APN for URLLC
    s_nssai:
      sst: "2"
    dnn: 'urllc'

location_service:
  enable: true
#  periodic_reporting: true
#  reporting_interval: 60  # Report location every 60 seconds

nas:
  t3412: 5  # Set a short TAU timer for quick reattachment
  periodic_location_reporting: true  # Enable periodic location reporting for better mobility handling
  location_reporting_interval: 5  # Frequency of location updates in seconds
  tau_retries: 3  # Optional: Number of retries for tracking area updates
  attach_retries: 3  # Optional: Number of retries for the attach procedure
  detach_retries: 2  # Optional: Number of retries for detaching from the gNB

measurement:
  gap: 5  # Measurement gap in milliseconds
  period: 120  # Measurement period in milliseconds

log:
  level: debug
```

- **🟦 UE-3 mMTC Slice**
```
supi: 'imsi-001010000000003'  # Correct IMSI for UE3
mcc: "001"
mnc: "01"
protectionScheme: 0
homeNetworkPublicKey: '5a8d38864820197c3394b92613b20b91633cbd897119273bf8e4a6f4eec0a650'
homeNetworkPublicKeyId: 1
routingIndicator: '0000'
key: '465B5CE8B199B49FAA5F0A2EE238A6BC'  # Ensure key matches AMF
op: 'E8ED289DEBA952E4283B54E88E6183CA'  # Ensure OP matches AMF
opType: 'OPC'
amf: '8000'
#imei: '356938035643803'
#imeiSv: '4370816125816151'

gnbSearchList:
  - 10.2.22.89  # gNB IP (ensure it is correct)
  - 10.2.22.93

session:
  - s_nssai:
      sst: 1
    dnn: 'embb'
  - s_nssai:
      sst: 2
    dnn: 'urllc'
  - s_nssai:
      sst: 3
    dnn: 'crit'

uacAic:
  mps: false
  mcs: false

uacAcc:
  normalClass: 0
  class11: false
  class12: false
  class13: false
  class14: false
  class15: false

# Integrity and Ciphering Algorithms (matching AMF configuration)
integrity:
  IA2: true
  IA1: true
  IA3: false  # Disabled IA3 as it is not part of AMF's supported integrity list

ciphering:
  EA0: true
  EA1: true
  EA2: true  # Updated to match AMF's ciphering algorithm order
  EA3: false  # Disabled EA3 as it is not part of AMF's supported ciphering list

integrityMaxRate:
  uplink: 'full'
  downlink: 'full'

# Session information (type of connection)
sessions:
  - type: 'IPv4'
    apn: 'crit'  # APN for critical
    s_nssai:
      sst: "3"
    dnn: 'crit'

location_service:
  enable: true
#  periodic_reporting: true
#  reporting_interval: 60  # Report location every 60 seconds

nas:
  t3412: 5  # Set a short TAU timer for quick reattachment
  periodic_location_reporting: true  # Enable periodic location reporting for better mobility handling
  location_reporting_interval: 5  # Frequency of location updates in seconds
  tau_retries: 3  # Optional: Number of retries for tracking area updates
  attach_retries: 3  # Optional: Number of retries for the attach procedure
  detach_retries: 2  # Optional: Number of retries for detaching from the gNB

measurement:
  gap: 5  # Measurement gap in milliseconds
  period: 120  # Measurement period in milliseconds

log:
  level: debug
```

---
### 🧰 **UERANSIM Service Scripts**

Use the following bash script to launch gNB and three UE instances in separate terminals for parallel operation.
```bash
#!/bin/bash

# Open first terminal and run the first command
gnome-terminal -- bash -c "sudo ./build/nr-gnb -c config/open5gs-gnb.yaml; exec bash"

# Open second terminal and run the second command
gnome-terminal -- bash -c "sudo ./build/nr-ue -c config/open5gs-ue.yaml; exec bash"

# Open third terminal and run the third command
gnome-terminal -- bash -c "sudo ./build/nr-ue -c config/open5gs-ue1.yaml; exec bash"

# Open fourth terminal and run the fourth command
gnome-terminal -- bash -c "sudo ./build/nr-ue -c config/open5gs-ue2.yaml; exec bash"
```
Ensure gnome-terminal is installed and the working directory contains UERANSIM build and config files.

### **📌 Note**
- All IPs, ports, and configuration values must be adjusted based on your actual testbed environment.
- All configurations are subject to alignment with the Open5GS subscriber database and must reflect accurate keys, SUPIs, PLMN details, and slice associations for seamless network registration and session establishment.

---

## **🖥️ Results**
This section presents experimental results from the integration of UERANSIM with Open5GS, focusing on gNB/UE connectivity, RAN-Core slice mapping, handover events, QoS metrics, and visualization dashboards.

### 📡 **gNB and UE Connection Establishment**
The gNB successfully establishes a connection with the 5G Core (AMF), followed by UE registration and PDU session establishment for each slice-specific UE.
<img width="1841" height="1031" alt="GNB_UE_Connection" src="https://github.com/user-attachments/assets/f3e3b403-62ea-4f4d-8d42-92f96445d8fe" />

https://github.com/user-attachments/assets/41ea5d42-e497-40d7-9385-e584f13e0e8b

### 🧩 **RAN and Core Slice Mapping (via Wireshark)**

- **RAN Slice Mapping for UE-1 eMBB Slice**:
<img width="1920" height="1080" alt="RAN_Slice-1" src="https://github.com/user-attachments/assets/f2a894dc-186a-4c31-920a-fd0f85dc4cae" />

- **Core Slice Mappingfor UE-1 eMBB Slice**:
<img width="1920" height="1080" alt="Core_Slice-1" src="https://github.com/user-attachments/assets/2ba8f3fa-0d78-4fd1-9f20-ab9468f760b2" />


- **RAN Slice Mapping for UE-2 URLLC Slice**:
<img width="1920" height="1080" alt="Ran_Slice-2" src="https://github.com/user-attachments/assets/7061d2d0-8766-435d-8f28-d8ccb612a0e4" />

- **Core Slice Mapping for UE-2 URLLC Slice**:
<img width="1920" height="1080" alt="Core_Slice-2" src="https://github.com/user-attachments/assets/26db2ca9-8401-412c-8360-5eea47468722" />


- **RAN Slice Mapping for UE-3 mMTC Slice**:
<img width="1920" height="1080" alt="RAN_Slice-3" src="https://github.com/user-attachments/assets/727d4fa5-3f29-4501-8020-7d37d0677f8c" />


-**Core Slice Mapping for UE-3 mMTC Slice**:
<img width="1920" height="1080" alt="Core_Slice-3" src="https://github.com/user-attachments/assets/fe405781-f88f-47d0-ae14-813b62385c57" />


### 🔄 **gNB Handover Session**
The handover procedure from gNB-1 to gNB-2 was executed successfully without any disruption to ongoing PDU sessions. The session continuity validates seamless mobility support.
<img width="1842" height="925" alt="Gnb_handover-1" src="https://github.com/user-attachments/assets/0377a4c8-224a-4692-8ea5-d7298670c0b5" />
<img width="1842" height="846" alt="Gbb_handover-2" src="https://github.com/user-attachments/assets/d116f8ee-28a2-48be-9fae-ee392718ced9" />

https://github.com/user-attachments/assets/c1c230af-7ab7-4167-8706-6b46492574ba

### 📶 **QoS Evaluation: Throughput and Latency**

- 📥 **Throughput Analysis**
Testing of all three UEs showed differentiated throughput according to slice characteristics:
<img width="586" height="916" alt="Throughput_Checks" src="https://github.com/user-attachments/assets/bd55f94a-11e9-48ab-baac-6cf71020388c" />

- ⏱️ Latency for all 3 slices before constraint (When running each slice individually):
<img width="1129" height="252" alt="Latency_Before" src="https://github.com/user-attachments/assets/7d369a8a-afdd-4840-9147-61cc75bdff4e" />

- ⏱️ Latency for all 3 slices after constraint (When running all slices simultaneously):
<img width="1129" height="252" alt="Latency_After" src="https://github.com/user-attachments/assets/3e6aafe0-d1d5-4275-b87c-3cf8587a79cf" />

https://github.com/user-attachments/assets/f06d1820-436e-4a00-9d53-0545dc4b02d3

### 📉 **Grafana-Based Monitoring**
Grafana dashboards were utilized for real-time telemetry collection and performance visualization. The Prometheus stack was used to scrape metrics from various system exporters.

- ✅ **AMF Registration Events**
Shows successful initial and periodic UE registrations with the AMF.
<img width="1224" height="456" alt="AMF_Registration" src="https://github.com/user-attachments/assets/b9427719-27bb-49b1-929f-695b147cefe3" />

- 🔁 **Periodic Re-Registration on gNB Failure**
Captures the re-registration activity when the gNB connection is disrupted.
<img width="1205" height="706" alt="Periodic_registration" src="https://github.com/user-attachments/assets/93716848-ae3b-486b-8b06-ea70479d8bc0" />

- 🔄 **Session Establishment Count**
Number of session establishment attempts across UEs.
<img width="1205" height="735" alt="Session_establishment" src="https://github.com/user-attachments/assets/e8356042-ff82-4c18-ae8a-50491f9b07b7" />

- 📦 **PDU Session Allocation per UE**
Visualizes the dynamic allocation of PDU sessions.
<img width="1221" height="456" alt="Slices_grafana" src="https://github.com/user-attachments/assets/f0fb97f0-df53-4e64-b4b1-ef165ef3b523" />

- 📊 **Throughput Per UE**
Throughput patterns across slices during simultaneous transmission.
<img width="1226" height="666" alt="Throughput_Graph" src="https://github.com/user-attachments/assets/6924f12c-2e8e-4912-914a-6a23f7c064f6" />


---

## ⚠️  **Common Issues & Troubleshooting**

### 1️⃣ **UERANSIM Not Connecting to Core**  
**🔍 Cause**: Mismatch in MCC/MNC or missing UE subscription.  
**🛠️ Fix**: Check that `ue.yaml` and Open5GS subscriber DB use the same MCC/MNC and IMSI.
<img width="1842" height="212" alt="mcc_mnc_error" src="https://github.com/user-attachments/assets/ca72e93d-067f-4cd1-a92c-6474dacb616c" />

### 2️⃣ **Slice Selection Not Triggering** 
**🔍 Cause**: Improper or missing S-NSSAI configuration.
**🛠️ Fix**: Ensure S-NSSAI is defined and matches in both `ue.yaml` and `nssf.yaml`.
<img width="1842" height="925" alt="dnn_error" src="https://github.com/user-attachments/assets/a09ac9bb-459b-486d-bfab-d8460dc0bcf3" />


### 3️⃣ **Grafana Shows No Data**  
**🔍 Cause**: Prometheus not scraping or misconfigured targets.  
**🛠️ Fix**: Verify `prometheus.yml` has the correct job target; ensure exporters are running.

### 4️⃣ **UE Authentication Fails**  
**🔍 Cause**: IMSI/key mismatch between UE and Core DB.  
**🛠️ Fix**: Confirm values in `ue.yaml` match the Open5GS WebUI or MongoDB.
<img width="1851" height="465" alt="imsi_error" src="https://github.com/user-attachments/assets/1f97e21c-1206-4f1f-b392-1814f71c6cc2" />


---

## 🔭 **Future Work**

- 🏭 Transition to commercial-grade 5G hardware platforms for performance benchmarking  
- 🧠 Integrate AI-based slice orchestration for real-time adaptive resource allocation  
- 🌐 Extend to cross-domain slice federation and inter-PLMN slicing scenarios

---

## 💡 **Encountering issues?**  
> If you run into a problem not listed here, feel free to [open an issue on the official Open5GS repository](https://github.com/open5gs/open5gs/issues) for community support or troubleshooting help.

