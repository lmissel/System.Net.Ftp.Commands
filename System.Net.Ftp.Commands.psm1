<#
.Synopsis
   Eine Datei auf einem Ftp-Server hochladen.
.DESCRIPTION
   Die Mthode benötigt als parameter den Namen der hochzuladenden Datei, die URL, unter
   welcher diese Datei auf dem Ftp-Server erreichbar sein soll, sowie ggfs. einen Benutzernamen
   und ein Passwort.
.EXAMPLE
   New-FtpFile -FileName MeineDatei.txt -URI ftp://my.intern/MeineDatei.txt
#>
function New-FtpFile
{
    [CmdletBinding(DefaultParameterSetName='Default', 
                  SupportsShouldProcess=$false, 
                  PositionalBinding=$false,
                  HelpUri = 'https://github.com/lmissel/Microsoft.FtpClient.Commands',
                  ConfirmImpact='Medium')]
    [Alias()]
    [OutputType([String])]
    param(
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Default')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [String] $fileName,

        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=1,
                   ParameterSetName='Default')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [uri] $uri,

        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=2,
                   ParameterSetName='Default')]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential, 

        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=3,
                   ParameterSetName='Default')]
        [Switch]$EnableSsl = $False,

        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=4,
                   ParameterSetName='Default')]
		[Switch]$KeepAlive = $False,

        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=5,
                   ParameterSetName='Default')]
		[Switch]$UseBinary = $False,

        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=6,
                   ParameterSetName='Default')]
		[Switch]$UsePassive = $False
    )

    Begin
    {
        [System.IO.Stream] $Stream = $null
        [System.IO.FileStream] $FileStream = $null
        [System.Net.FtpWebResponse] $FtpWebResponse = $null

        # Der Parameter serverUri sollte mit dem ftp:// scheme beginnen.
        if (-not (Test-UriSchemeFtp -uri $uri)) { throw "This is not a ftp-uri." }
    }

    Process
    {
        try
        {
            # Request erzeugen
            [System.Net.FtpWebRequest] $FtpWebRequest = [System.Net.FtpWebRequest][System.Net.WebRequest]::Create($uri)
            
            # Ausführende Aktion festlegen
            $FtpWebRequest.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile

            if ($Credentials)
            {
                $FtpWebRequest.Credentials = $Credentials
            }

            $FtpWebRequest.EnableSsl = $EnableSsl
            $FtpWebRequest.KeepAlive = $Credentials
            $FtpWebRequest.UseBinary = $UseBinary
            $FtpWebRequest.UsePassive = $UsePassive

            # UploadFile wird nicht von einem Http-Proxy unterstützt, 
            # daher deaktivieren wir den Proxy für diese Anfrage.
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
            # Alles schließen
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

<#
.Synopsis
   Diese Methode liestet die Inhaltes des angegebenen FTP-Verzeichnis auf.
.DESCRIPTION
   Der Methode werden als Parameter die URL des FTP-Verzeichnisses sowie ggfs. 
   einen Benutzernamen und ein Passwort übergeben.
.EXAMPLE
   Get-FtpDirectory -URI ftp://my.intern/
#>
function Get-FtpDirectory
{
    [CmdletBinding(DefaultParameterSetName='Default', 
                  SupportsShouldProcess=$false, 
                  PositionalBinding=$false,
                  HelpUri = 'https://github.com/lmissel/Microsoft.FtpClient.Commands',
                  ConfirmImpact='Medium')]
    [Alias()]
    param(
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Default')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [uri] $uri,

        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=1,
                   ParameterSetName='Default')]
        [System.Management.Automation.PSCredential]
        #[System.Management.Automation.Credential()]
        $Credential, 

        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=2,
                   ParameterSetName='Default')]
        [Switch]$EnableSsl = $False,

        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=3,
                   ParameterSetName='Default')]
		[Switch]$KeepAlive = $False,

        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=4,
                   ParameterSetName='Default')]
		[Switch]$UseBinary = $False,

        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=5,
                   ParameterSetName='Default')]
		[Switch]$UsePassive = $False
    )

    Begin
    {
        [System.IO.StreamReader] $StreamReader = $null

        # Der Parameter serverUri sollte mit dem ftp:// scheme beginnen.
        if (-not (Test-UriSchemeFtp -uri $uri)) { throw "This is not a ftp-uri." }
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
            else
            {
                $FtpWebRequest.Credentials = new-object System.Net.NetworkCredential("anonymous","anonymous@localhost")
            }

            $FtpWebRequest.EnableSsl = $EnableSsl
            $FtpWebRequest.KeepAlive = $KeepAlive
            $FtpWebRequest.UseBinary = $UseBinary
            $FtpWebRequest.UsePassive = $UsePassive

            # Ausf�hrende Aktion festlegen
            $FtpWebRequest.Method = [System.Net.WebRequestMethods+Ftp]::ListDirectory
            [System.Net.FtpWebResponse] $FtpWebResponse = [System.Net.FtpWebResponse]$FtpWebRequest.GetResponse()
            $StreamReader = [System.IO.StreamReader]::new($FtpWebResponse.GetResponseStream())
            $StreamReader.ReadToEnd()

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

<#
.Synopsis
   Herunterladen einer Datei per FTP.
.DESCRIPTION
   Der Methode werden als Parameter die URL der herunterzuladenden FTP-Datei sowie ggfs. 
   einen Benutzernamen und ein Passwort übergeben.
.EXAMPLE
   Get-FtpFile -URI ftp://my.intern/MeineTest.txt
#>
function Get-FtpFile
{
    [CmdletBinding(DefaultParameterSetName='Default', 
                  SupportsShouldProcess=$false, 
                  PositionalBinding=$false,
                  HelpUri = 'https://github.com/lmissel/Microsoft.FtpClient.Commands',
                  ConfirmImpact='Medium')]
    [Alias()]
    param(
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Default')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [uri] $uri,

        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=1,
                   ParameterSetName='Default')]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential, 

        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=2,
                   ParameterSetName='Default')]
        [Switch]$EnableSsl = $False,

        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=3,
                   ParameterSetName='Default')]
		[Switch]$KeepAlive = $False,

        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=4,
                   ParameterSetName='Default')]
		[Switch]$UseBinary = $False,

        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=5,
                   ParameterSetName='Default')]
		[Switch]$UsePassive = $False
    )

    Begin
    {
        [System.IO.Stream] $Stream = $null
        [System.IO.FileStream] $FileStream = $null
        [System.Net.FtpWebResponse] $FtpWebResponse = $null
        [System.Net.FtpWebRequest] $FtpWebRequest = $null

        # Der Parameter serverUri sollte mit dem ftp:// scheme beginnen.
        if (-not (Test-UriSchemeFtp -uri $uri)) { throw "This is not a ftp-uri." }
    }

    Process
    {
        try
        {
            # Request erzeugen
            $FtpWebRequest = [System.Net.FtpWebRequest]::Create($uri)

            if ($Credentials)
            {
                $FtpWebRequest.Credentials = $Credentials
            }
            else
            {
                $FtpWebRequest.Credentials = new-object System.Net.NetworkCredential("anonymous","anonymous@localhost")
            }

            $FtpWebRequest.EnableSsl = $EnableSsl
            $FtpWebRequest.KeepAlive = $KeepAlive
            $FtpWebRequest.UseBinary = $UseBinary
            $FtpWebRequest.UsePassive = $UsePassive

            # Ausführende Aktion festlegen
            $FtpWebRequest.Method = [System.Net.WebRequestMethods+Ftp]::DownloadFile
            $FtpWebResponse = [System.Net.FtpWebResponse] $FtpWebRequest.GetResponse()
            $Stream = $FtpWebResponse.GetResponseStream()

            # Dateinamen extrahieren
            $SaveFileDialog = [System.Windows.Forms.SaveFileDialog]::new()
            $SaveFileDialog.FileName = [System.IO.Path]::GetFileName($FtpWebRequest.RequestUri.LocalPath)
            if ($SaveFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::Ok)
            {
                $FileStream = [System.IO.FileStream]::new($SaveFileDialog.FileName,[IO.FileMode]::Create)
                [byte[]]$readbuffer = [byte[]]::new(1024)

                do{
                    $readlength = $Stream.Read($readbuffer,0,1024)
                    $FileStream.Write($readbuffer,0,$readlength)
                }
                while ($readlength -ne 0)
            }
        }
        catch [System.UriFormatException]
        {
            # Fehlermeldung ausgeben
        }
        catch [System.Net.WebException]
        {
            # Fehlermeldung ausgeben
        }
        catch [System.IO.IOException]
        {
            # Fehlermeldung ausgeben
        }
        finally
        {
            if ($Stream) { $Stream.Close() }
            if ($FileStream) { $FileStream.Close() }
        }
    }

    End
    {
    }
}

<#
.Synopsis
   Löschen einer Datei im FTP-Verzeichnis.
.DESCRIPTION
   Die Methode braucht als Parameter die URL der zu löschenden FTP-Datei sowie ggfs. 
   einen Benutzernamen und ein Passwort übergeben.
.EXAMPLE
   Get-FtpFile -URI ftp://my.intern/MeineTest.txt
#>
function Remove-FtpFile
{
    [CmdletBinding(DefaultParameterSetName='Default', 
                  SupportsShouldProcess=$false, 
                  PositionalBinding=$false,
                  HelpUri = 'https://github.com/lmissel/Microsoft.FtpClient.Commands',
                  ConfirmImpact='Medium')]
    [Alias()]
    param(
        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0,
                   ParameterSetName='Default')]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [uri] $uri,

        [Parameter(Mandatory=$true, 
                   ValueFromPipeline=$true,
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=1,
                   ParameterSetName='Default')]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $Credential, 

        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=2,
                   ParameterSetName='Default')]
        [Switch]$EnableSsl = $False,

        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=3,
                   ParameterSetName='Default')]
		[Switch]$KeepAlive = $False,

        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=4,
                   ParameterSetName='Default')]
		[Switch]$UseBinary = $False,

        [Parameter(Mandatory=$false, 
                   ValueFromPipeline=$false,
                   ValueFromPipelineByPropertyName=$false, 
                   ValueFromRemainingArguments=$false, 
                   Position=5,
                   ParameterSetName='Default')]
		[Switch]$UsePassive = $False
    )

    Begin
    {
        [System.Net.FtpWebResponse] $FtpWebResponse = $null
        [System.Net.FtpWebRequest] $FtpWebRequest = $null

        # Der Parameter serverUri sollte mit dem ftp:// scheme beginnen.
        if (-not (Test-UriSchemeFtp -uri $uri)) { throw "This is not a ftp-uri." }
    }

    Process
    {
        try
        {
            # Request erzeugen
            $FtpWebRequest = [System.Net.FtpWebRequest]::Create($uri)

            if ($Credentials)
            {
                $FtpWebRequest.Credentials = $Credentials
            }
            else
            {
                $FtpWebRequest.Credentials = new-object System.Net.NetworkCredential("anonymous","anonymous@localhost")
            }

            $FtpWebRequest.EnableSsl = $EnableSsl
            $FtpWebRequest.KeepAlive = $Credentials
            $FtpWebRequest.UseBinary = $UseBinary
            $FtpWebRequest.UsePassive = $UsePassive

            # Ausf�hrende Aktion festlegen
            $FtpWebRequest.Method = [System.Net.WebRequestMethods+Ftp]::DeleteFile
            $FtpWebResponse = [System.Net.FtpWebResponse] $FtpWebRequest.GetResponse()
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
            if($FtpWebResponse) { $FtpWebResponse.Close() }
        }
    }

    End
    {
    }
}

function Test-UriSchemeFtp
{
    param([Uri] $uri)

    if ($uri.Scheme -eq [Uri]::UriSchemeFtp)
    {
        return $true
    }
    else
    {
        return $false
    }
}