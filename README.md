# System.Net.Ftp.Commands

Dieses Powershell Modul stellt eine Reihe von Klassen, Enumerationen und Methoden zur Verfügung, um mit der PowerShell Dateien von einem Ftp-Server herunter- oder hochzuladen bzw. zu erstellen oder zu löschen. Dabei wird Wert auf ein einfaches Design gelegt, und deshalb werden auch keine weiteren Funktionen unterstützt. Ebenso soll keine Verwaltung vom FTP-Server stattfinden, sondern es wird sich ausschließlich auf die Clientseite beschränkt.

## Detaillierte Beschreibung

Es wird die .Net Framework 4.8 Klasse System.Net.FtpWebRequest verwendet, um die entsprechende Anfragen an den FTP-Server zu senden. Getestet wurde das PowerShell Module mit einem Windows 10 Client mit der PowerShell Version 5 & 6 und IIS-FTP-Server auf einem Windows Server 2016 sowie Windows 10.

Die Verwendung von .Net Framework 4.8 und den dort bereits hinterlegten Klassen, erlaubte eine einfache Programmierung des PowerShell Modules und sorgt für eine reibungslose Nutzung.

## Verwendung

Laden Sie das Modul in die PowerShell Sitzung und starten Sie mit dem Abrufen vorhandener Dateien und Ordner, oder Erstellen Sie eine neue Datei Ersetzen, Umbenennen oder Löschen diese.

```PowerShell
# Laden des Modules
Import-Module System.Net.Ftp.Commands

# Dateien und Verzeichnisse abrufen
Get-FtpDirectory -uri "ftp://192.168.178.100/"
```
