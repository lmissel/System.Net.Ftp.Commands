# Microsoft.FtpClient.Commands

Dieses Powershell Modul stellt eine Reihe von Klassen, Enumerationen und Methoden zur Verfügung, um mit der PowerShell Dateien von einem Ftp-Server herunter- oder hochzuladen bzw. zu erstellen oder zu löschen. Dabei wird Wert auf ein Simple Design gelegt, und deshalb auch keine weiteren Funktionen unterstützt. Ebenso soll keine Verwaltung vom FTP-Server stattfinden sondern es wird sich ausschließlich auf die Clientseite beschränkt.

## Detaillierte Beschreibung

Es wird die .Net Framework 4.8 Klasse System.Net.FtpWebRequest verwendet, um die entsprechende Anfragen an den FTP-Server zu senden. Getestet wurde das PowerShell Module mit einem Windows 10 Client mit der PowerShell Version 5 und IIS-FTP-Server auf einem Windows Server 2016.

Die Verwendung von .Net Framework 4.8 und den dort bereits hinterlegten Klassen, erlaubte eine einfache Programmierung des PowerShell Modules und sorgt für eine reibungslose Nutzung.

## Verwendung

Laden Sie das Modul in die PowerShell Sitzung und starten Sie mit dem Herstellen einer Verbidnung zum FTP-Server. Anschließend können Sie die vorhanden Dateien und Ordner abrufen, oder eine neue Datei erstellen bzw. eine vorhandene ersetzen, umbenennen bzw. löschen.

```PowerShell
# Laden des Modules
Import-Module Microsoft.FtpClient.Commands

# Verbindung herstellen
$session = New-FtpSession -Uri "ftp://FtpServer.internal"

# Dateien abrufen
Get-FtpItem -Session $session
```
