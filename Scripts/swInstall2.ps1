Set-ExecutionPolicy Bypass -Scope Process -Force;
choco feature enable -n=allowGlobalConfirmation;
choco install openjdk -y;
choco install azcopy10 -y;
.\MoveAJmeter.ps1