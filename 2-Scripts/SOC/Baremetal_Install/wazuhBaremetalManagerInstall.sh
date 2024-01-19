# Wazuh Manager IP and Port
$WAZUH_MANAGER_IP = "your_manager_ip"
$WAZUH_MANAGER_PORT = "1515"

# Registration token obtained from Wazuh manager
$REGISTRATION_TOKEN = "your_registration_token"

# Path to the Wazuh agent installation directory
$AGENT_INSTALLATION_PATH = "C:\Program Files\ossec-agent"

# Set the manager IP and port in ossec.conf
(Get-Content "$AGENT_INSTALLATION_PATH\ossec.conf") -replace "MANAGER_IP", "$WAZUH_MANAGER_IP" | Set-Content "$AGENT_INSTALLATION_PATH\ossec.conf"

# Register the agent
Start-Process -FilePath "$AGENT_INSTALLATION_PATH\agent-auth.exe" -ArgumentList "-m $WAZUH_MANAGER_IP -P $WAZUH_MANAGER_PORT -A $REGISTRATION_TOKEN" -Wait
