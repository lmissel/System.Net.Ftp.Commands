<#

Kapitel 16: Komplexebeispiele
Seite: 1074 - 1082
Titel: R16.3 Ein einfacher FTP-Client

#>

# Upload File
function New-FtpFile
{
    param(
        [String] $fileName,
        [uri] $uri,

        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential, 
        
        [Switch]$EnableSsl = $False,
		[Switch]$KeepAlive = $False,
		[Switch]$UseBinary = $False,
		[Switch]$UsePassive = $False
    )

    Begin
    {
        [System.IO.Stream] $Stream = $null
        [System.IO.FileStream] $FileStream = $null
        [System.Net.FtpWebResponse] $FtpWebResponse = $null
    }

    Process
    {
        try
        {
            # Request erzeugen
            [System.Net.FtpWebRequest] $FtpWebRequest = [System.Net.FtpWebRequest][System.Net.WebRequest]::Create($uri)
            
            # Ausf�hrende Aktion festlegen
            $FtpWebRequest.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile

            if ($Credentials)
            {
                $FtpWebRequest.Credentials = $Credentials
            }

            $FtpWebRequest.EnableSsl = $EnableSsl
            $FtpWebRequest.KeepAlive = $Credentials
            $FtpWebRequest.UseBinary = $UseBinary
            $FtpWebRequest.UsePassive = $UsePassive

            # UploadFile wird nicht von einem Http-Proxy unterst�tzt, 
            # daher deaktivieren wir den Proxy f�r diese Anfrage.
            $FtpWebRequest.Proxy = $null

            $Stream = $FtpWebRequest.GetRequestStream()
            
            # Inhalt aus Datei kopieren
            [byte[]] $buffer = [byte[]]::new(2048)
            [int] $bytesRead
            $FileStream = [System.IO.File]::Open($fileName, [System.IO.FileMode]::Open)

            # Quelldatei einlesen
            while ($true)
            {
                $bytesRead = $FileStream.Read($buffer, 0, $buffer.Length)
                if ($bytesRead -eq 0)
                {
                    break
                }
                $Stream.Write($buffer, 0, $bytesRead)
            }

            # Antwort holen
            $Stream.Close()
            $FtpWebResponse = [System.Net.FtpWebResponse]$FtpWebRequest.GetResponse()
            Write-Host "Upload complete."
        }
        catch [System.UriFormatException]
        {
            # Fehlermeldung ausgeben
        }
        catch [System.IO.IOException]
        {
            # Fehlermeldung ausgeben
        }
        catch [System.Net.WebException]
        {
            # Fehlermeldung ausgeben
        }
        finally
        {
            # Alles schlie�en
            if ($FtpWebResponse)
            {
                $FtpWebResponse.Close()
            }

            if ($FileStream)
            {
                $FileStream.Close()
            }

            if ($Stream)
            {
                $Stream.Close()
            }
        }
    }

    End
    {
    }
}

# List Directory
function Get-FtpDirectory
{
    param(
        [String] $uri,

        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential, 
        
        [Switch]$EnableSsl = $False,
		[Switch]$KeepAlive = $False,
		[Switch]$UseBinary = $False,
		[Switch]$UsePassive = $False
    )

    Begin
    {
        [System.IO.StreamReader] $StreamReader = $null
    }

    Process
    {
        try
        {
            # Request erzeugen
            [System.Net.FtpWebRequest] $FtpWebRequest = [System.Net.FtpWebRequest][System.Net.WebRequest]::Create($uri)

            if ($Credentials)
            {
                $FtpWebRequest.Credentials = $Credentials
            }

            $FtpWebRequest.EnableSsl = $EnableSsl
            $FtpWebRequest.KeepAlive = $Credentials
            $FtpWebRequest.UseBinary = $UseBinary
            $FtpWebRequest.UsePassive = $UsePassive

            # Ausf�hrende Aktion festlegen
            $FtpWebRequest.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectory
            [System.Net.FtpWebResponse] $FtpWebResponse = [System.Net.FtpWebResponse]$FtpWebRequest.GetResponse()
            $StreamReader = [System.IO.StreamReader]::new($FtpWebResponse.GetResponseStream())
            $StreamReader.ReadToEnd()

            #Ausgabe abschlie�en
            Write-Host "List complete."

        }
        catch [System.UriFormatException]
        {
            # Fehlermeldung ausgeben
        }
        catch [System.Net.WebException]
        {
            # Fehlermeldung ausgeben
        }
        finally
        {
            if ($StreamReader)
            {
                $StreamReader.Close()
            }
        }
    }

    End
    {
    }
}

# Download File
function Get-FtpFile
{
    param(
        [uri] $uri,

        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential, 
        
        [Switch]$EnableSsl = $False,
		[Switch]$KeepAlive = $False,
		[Switch]$UseBinary = $False,
		[Switch]$UsePassive = $False
    )
}

# Remove File
function Remove-FtpFile
{
    param(
        [uri] $uri,

        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential, 
        
        [Switch]$EnableSsl = $False,
		[Switch]$KeepAlive = $False,
		[Switch]$UseBinary = $False,
		[Switch]$UsePassive = $False
    )
}