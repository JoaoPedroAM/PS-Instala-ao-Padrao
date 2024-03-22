# Checa se o powershell foi inicializado como admin
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # Se não, fecha a instancia e executa uma nova
    Start-Process powershell -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -admin' -f ($myinvocation.MyCommand.Definition))
    exit
}


function InstallUpdateUtility {
    param (
        [string]$brand
    )

    switch ($brand) {
        "1" {
            Write-Output "Installing Lenovo System Update..."
            winget install -e --id Lenovo.SystemUpdate --accept-source-agreements --accept-package-agreements
            
        }
        "2" {
            Write-Output "Installing Dell Command Update..."
            winget install -e --id Dell.CommandUpdate --accept-source-agreements --accept-package-agreements
            
        }
        default {
            Write-Output "Marca não listada. Pulando..."
        }
    }
}

function InstalaSoftwarePadrao{

}

# Instala o winget 
function Install-WingetIfMissing {
    # Verifica se o winget já está instalado na maquina
    if (Test-Path ~\AppData\Local\Microsoft\WindowsApps\winget.exe) {
      Write-Host "Winget já instalado, pulando instalação."
    } else {
      Write-Host "Winget não encontrado, instalando..."
      $progressPreference = 'silentlyContinue'
      Write-Information "Baixando winget e suas dependecias..."
  
      # Baixa as dependencias e pacotes de maneira silenciosa
      Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -UseBasicParsing
      Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx -UseBasicParsing
      Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx -OutFile Microsoft.UI.Xaml.2.8.x64.appx -UseBasicParsing
  
      # Instala os pacotes
      Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx -ErrorAction SilentlyContinue
      Add-AppxPackage Microsoft.UI.Xaml.2.8.x64.appx -ErrorAction SilentlyContinue
      Add-AppxPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -ErrorAction SilentlyContinue
  
      # Verifica se a instalação funcionou corretamente
      if (Test-Path ~\AppData\Local\Microsoft\WindowsApps\winget.exe) {
        Write-Host "Winget installation successful!"
      } else {
        Write-Error "Winget installation failed!"
      }
    }
  }
  
  #Chama a função de instalação do winget
  Install-WingetIfMissing

#Decide a marca da maquina
do{
    Write-Host "Escolha a marca da sua maquina:"
    Write-Host "1. Lenovo"
    Write-Host "2. Dell"
    Write-Host "3. Outros"
    $brandNumber = Read-Host "Entre com algum dos números (1, 2, 3):"
} until ($brandNumber -eq "1" -or $brandNumber -eq "2" -or $brandNumber -eq "3")

# Instala o app de update com base na marca selecionada
InstallUpdateUtility -brand $brandNumber




Write-Host("Atualizando os softwares do sistema")
winget upgrade --all --accept-source-agreements --accept-package-agreements
