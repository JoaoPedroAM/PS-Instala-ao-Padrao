# Checa se o powershell foi inicializado como administrador
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
  # Se não, fecha a instância e executa uma nova como administrador
  Start-Process powershell -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -admin' -f ($myinvocation.MyCommand.Definition))
  exit
}

# Função principal
function Main {

  perguntaWinget  # Adiciona a pergunta sobre o Winget
  InstalaWinget           # Instala o Winget, um gerenciador de pacotes
  EscolheMarca            # Permite ao usuário escolher a marca da máquina
  InstalaCentroUpdate -brand $brandNumber   # Instala o software de atualização com base na marca selecionada
  InstalaSoftwarePadrao   # Instala uma lista de softwares padrão
  AtualizaSoftwares       # Atualiza todos os softwares do sistema
}

# Função para perguntar sobre o Winget
function perguntaWinget {
  $resposta = Read-Host "Você está enfrentando problemas com o Winget? Responda com '1' para Sim ou '2' para Não"

  if ($resposta -eq "1") {
      Write-Host "Consertando Winget..."
      ConsertaWingetWin11
  } elseif ($resposta -eq "2") {
      Write-Host "Prosseguindo sem corrigir o Winget..."
  } else {
      Write-Host "Resposta inválida. Prosseguindo sem corrigir o Winget..."
  }
}

function ConsertaWingetWin11 {

Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile winget.msixbundle
Add-AppxPackage winget.msixbundle -ForceApplicationShutdown
Remove-Item winget.msixbundle
Clear-Host 
  
}
# Função para permitir ao usuário escolher a marca da máquina
function EscolheMarca {
  do {
      Write-Host "Escolha a marca da sua maquina:"
      Write-Host "1. Lenovo"
      Write-Host "2. Dell"
      Write-Host "3. Outros"
      $global:brandNumber = Read-Host "Entre com algum dos numeros (1, 2, 3):"
  } until ($global:brandNumber -eq "1" -or $global:brandNumber -eq "2" -or $global:brandNumber -eq "3")
}

# Função para instalar o software de atualização com base na marca selecionada
function InstalaCentroUpdate {
  param (
      [string]$brand
  )

  switch ($brand) {
      "1" {
          Write-Output "Instalando Lenovo System Update..."
          winget install -e --id Lenovo.SystemUpdate --accept-source-agreements --accept-package-agreements
          
      }
      "2" {
          Write-Output "Instalando Dell Command Update..."
          winget install -e --id Dell.CommandUpdate --accept-source-agreements --accept-package-agreements
          
      }
      default {
          Write-Output "Marca nao listada. Pulando..."
      }
  }
}

# Função para instalar softwares padrão
function InstalaSoftwarePadrao {
  Write-Host "Instalando 7zip..."
  winget install -e --id 7zip.7zip
  Write-Host "Instalando Adobe Acrobat..."
  winget install -e --id Adobe.Acrobat.Reader.64-bit
  Write-Host "Instalando Mozilla Firefox ESR..."
  winget install -e --id Mozilla.Firefox.ESR
  Write-Host "Instalando Teams.."
  winget install -e --id Microsoft.Teams
  Write-Host "Instalando Java.."
  winget install -e --id Oracle.JavaRuntimeEnvironment
  Write-Host "Instalando Notepad++.."
  winget install -e --id Notepad++.Notepad++
}

# Função para instalar o Winget
function InstalaWinget {
  # Verifica se o Winget já está instalado na máquina
  if (Test-Path ~\AppData\Local\Microsoft\WindowsApps\winget.exe) {
      Write-Host "Winget ja instalado, pulando instalacao."
  } else {
      Write-Host "Winget nao encontrado, instalando..."
      $progressPreference = 'silentlyContinue'
      Write-Information "Baixando Winget e suas dependências..."

      # Baixa as dependências e pacotes de maneira silenciosa
      Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -UseBasicParsing
      Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx -UseBasicParsing
      Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx -OutFile Microsoft.UI.Xaml.2.8.x64.appx -UseBasicParsing

      # Instala os pacotes
      Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx -ErrorAction SilentlyContinue
      Add-AppxPackage Microsoft.UI.Xaml.2.8.x64.appx -ErrorAction SilentlyContinue
      Add-AppxPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -ErrorAction SilentlyContinue

      # Verifica se a instalação funcionou corretamente
      if (Test-Path ~\AppData\Local\Microsoft\WindowsApps\winget.exe) {
          Write-Host "Instalação do winget concluida!"
      } else {
          Write-Error "Falha na instalação do winget!"
      }
  }
}

# Função para atualizar os softwares do sistema
function AtualizaSoftwares {
  Write-Host("Atualizando os softwares do sistema")
  winget upgrade --all --accept-source-agreements --accept-package-agreements
}

# Chama a função principal
Main



