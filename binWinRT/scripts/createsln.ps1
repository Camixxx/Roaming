<#
Copyright © Microsoft Open Technologies, Inc.
All Rights Reserved        
Licensed under the Apache License, Version 2.0 (the "License"); 
you may not use this file except in compliance with the License. 

You may obtain a copy of the License at 
http://www.apache.org/licenses/LICENSE-2.0 
 
THIS CODE IS PROVIDED ON AN *AS IS* BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, 
EITHER EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION ANY IMPLIED WARRANTIES OR CONDITIONS OF TITLE, 
FITNESS FOR A PARTICULAR PURPOSE, MERCHANTABLITY OR NON-INFRINGEMENT. 
 
See the Apache 2 License for the specific language governing permissions and limitations under the License.
#>

Function CreateSolution()
{
    $solution = New-Module -AsCustomObject -ScriptBlock {
        . ".\scripts\converterutils.ps1"

        #use MSBuild namespace
        $ms = 'http://schemas.microsoft.com/developer/msbuild/2003'
        $ns = @{ ms = $ms }

        $projects = @()
        $solutionDir = ""


        Function AddProject($path) {
            $globals = GetProjectGlobals $path $ns
            $guid = $globals.Node.ProjectGuid
            $relativePath = Get-RelativePath $this.solutionDir $path
            $project = New-Object –TypeName PSObject
            $project | Add-Member –MemberType NoteProperty –Name guid –Value $globals.Node.ProjectGuid
            $project | Add-Member –MemberType NoteProperty –Name path –Value $relativePath
            if($globals.Node.ProjectName)
            {
                $project | Add-Member –MemberType NoteProperty –Name name –Value $globals.Node.ProjectName
            }
            else
            {
               $project | Add-Member –MemberType NoteProperty –Name name –Value $globals.Node.RootNamespace
            }

            $this.projects += $project
        }

        Function Save($path, $platform) {
            $output = New-Item $path -type file -force

            if($platform -eq "winrt")
            {
                $template = join-path $PSScriptRoot "templates\winrt_sln_header_template.txt"
            }
            elseif($platform -eq "wp8")
            {
                $template = join-path $PSScriptRoot "templates\wp8_sln_header_template.txt"
            }            
            elseif($platform -eq "wp8_1")
            {
                $template = join-path $PSScriptRoot "templates\wp8_1_sln_header_template.txt"
            }
            else
            {
                throw "Unknown platform argument (winrt, wp8 or wp8_1)"
            }

            (Get-Content $template) | 
            Add-Content $path

            foreach($project in $this.projects)
            {
                $line = 'Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "' + $project.name + '", "' + $project.path + '", "' + $project.guid + '"'
                #Add-Content $path 'Project("{8BC9CEB8-8B4A-11D0-8D11-00A0C91BC942}") = "opencv_core", "opencv_core.vcxproj", "{8F928FE0-8A06-4F93-99FE-53B9C7A006CA}"'
                Add-Content $path $line
                Add-Content $path 'EndProject'
            }

            $template = join-path $PSScriptRoot "templates\global_start_template.txt"
            (Get-Content $template) | 
            Add-Content $path

            $template = join-path $PSScriptRoot "templates\globalsection_template.txt"
            foreach($project in $this.projects)
            {
                (Get-Content $template) | 
                Foreach-Object {$_ -replace "REPLACE_GUID", $project.guid} |
                Add-Content $path
            }

            $template = join-path $PSScriptRoot "templates\global_end_template.txt"
            (Get-Content $template) | 
            Add-Content $path
        }

        Export-ModuleMember -Variable * -Function *
    }
    return $solution
}

<#
$solutionDir = join-path $WorkingDir ".\modules\core"
$path = join-path $solutionDir "opencv_core.vcxproj"
$output = join-path $solutionDir "opencv_core2.sln"


$solution = CreateSolution
$solution.solutionDir = $solutionDir
$solution.AddProject($path)

$path = join-path $WorkingDir ".\3rdparty\zlib\zlib.vcxproj"
$solution.AddProject($path)

$solution.Save($output)
notepad $output
#>


# SIG # Begin signature block
# MIIasQYJKoZIhvcNAQcCoIIaojCCGp4CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUOtqEv614/LhRzF1HwauJxmWt
# 6JegghWMMIIEwzCCA6ugAwIBAgITMwAAAEyh6E3MtHR7OwAAAAAATDANBgkqhkiG
# 9w0BAQUFADB3MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
# A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSEw
# HwYDVQQDExhNaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EwHhcNMTMxMTExMjIxMTMx
# WhcNMTUwMjExMjIxMTMxWjCBszELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
# bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
# b3JhdGlvbjENMAsGA1UECxMETU9QUjEnMCUGA1UECxMebkNpcGhlciBEU0UgRVNO
# OkMwRjQtMzA4Ni1ERUY4MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBT
# ZXJ2aWNlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAsdj6GwYrd6jk
# lF18D+Z6ppLuilQdpPmEdYWXzMtcltDXdS3ZCPtb0u4tJcY3PvWrfhpT5Ve+a+i/
# ypYK3EbxWh4+AtKy4CaOAGR7vjyT+FgyeYfSGl0jvJxRxA8Q+gRYtRZ2buy8xuW+
# /K2swUHbqs559RyymUGneiUr/6t4DVg6sV5Q3mRM4MoVKt+m6f6kZi9bEAkJJiHU
# Pw0vbdL4d5ADbN4UEqWM5zYf9IelsEEXb+NNdGbC/aJxRjVRzGsXUWP6FZSSml9L
# KLrmFkVJ6Sy1/ouHr/ylbUPcpjD6KSjvmw0sXIPeEo1qtNtx71wUWiojKP+BcFfx
# jAeaE9gqUwIDAQABo4IBCTCCAQUwHQYDVR0OBBYEFLkNrbNN9NqfGrInJlUNIETY
# mOL0MB8GA1UdIwQYMBaAFCM0+NlSRnAK7UD7dvuzK7DDNbMPMFQGA1UdHwRNMEsw
# SaBHoEWGQ2h0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3Rz
# L01pY3Jvc29mdFRpbWVTdGFtcFBDQS5jcmwwWAYIKwYBBQUHAQEETDBKMEgGCCsG
# AQUFBzAChjxodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY3Jv
# c29mdFRpbWVTdGFtcFBDQS5jcnQwEwYDVR0lBAwwCgYIKwYBBQUHAwgwDQYJKoZI
# hvcNAQEFBQADggEBAAmKTgav6O2Czx0HftcqpyQLLa+aWyR/lHEMVYgkGlIVY+KQ
# TQVKmEqc++GnbWhVgrkp6mmpstXjDNrR1nolN3hnHAz72ylaGpc4KjlWRvs1gbnk
# PUZajuT8dTdYWUmLTts8FZ1zUkvreww6wi3Bs5tSLeA1xbnBV7PoPaE8RPIjFh4K
# qlk3J9CVUl6ofz9U8IHh3Jq9ZdV49vdMObvd4NY3DpGah4xz53FkUvc+A9jGzXK4
# NDSYW4zT9Qim63jGUaANDm/0azxAGmAWLKkGUp0cE5DObwIe6nucs/b4l2DyZdHR
# H4c6wXXwQo167Yxysnv7LIq0kUdU4i5pzBZUGlkwggT2MIID3qADAgECAhMzAAAA
# sYcLAdKYyt7cAAEAAACxMA0GCSqGSIb3DQEBBQUAMHkxCzAJBgNVBAYTAlVTMRMw
# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN
# aWNyb3NvZnQgQ29ycG9yYXRpb24xIzAhBgNVBAMTGk1pY3Jvc29mdCBDb2RlIFNp
# Z25pbmcgUENBMB4XDTEzMDEyNDIyMzM0MFoXDTE0MDQyNDIyMzM0MFowgY0xCzAJ
# BgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25k
# MR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xDTALBgNVBAsTBE1PUFIx
# KDAmBgNVBAMTH01pY3Jvc29mdCBPcGVuIFRlY2hub2xvZ2llcyBJbmMwggEiMA0G
# CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCkVodaEkoE75vSJ4V7ym0w54qQCXrL
# 886QuQjJG+Qmn2TW/1CeMnFdRHKR0N7wGDVts9WoKxRABHiJo8onaAUg75S0JSc+
# Rv37fMaQ5Vf6OgH7XGZc+yMzcNUA2ucufmq5CXLezxcPEGZE1rRVmvuMzupXOJmM
# XkSRJ+k16CE2Z49jTNTw2xHt/eGszOPxU2AAzehCc5ZFNS8sm42egnxniQxVck37
# MK/tqZx1RS8VjukL01H4PYr35nKkWU3UHUo4nv8M8QR4kQUfDMH1xnkNP64oG6rq
# 5lo45kEWP9esz9uWHlycdNyCaMunpyUDSC3Sq8vEi93mTfci/j6wrop1AgMBAAGj
# ggFgMIIBXDATBgNVHSUEDDAKBggrBgEFBQcDAzAdBgNVHQ4EFgQUpgtP/aOj5EBJ
# 6d/gwZxEexA2fyMwUQYDVR0RBEowSKRGMEQxDTALBgNVBAsTBE1PUFIxMzAxBgNV
# BAUTKjMxNjA0K2I3NDk1MTMxLTQ2NWMtNGM0Yy1hMmRhLTcxN2FkMWM0NGY5YzAf
# BgNVHSMEGDAWgBTLEejK0rQWWAHJNy4zFha5TJoKHzBWBgNVHR8ETzBNMEugSaBH
# hkVodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWND
# b2RTaWdQQ0FfMDgtMzEtMjAxMC5jcmwwWgYIKwYBBQUHAQEETjBMMEoGCCsGAQUF
# BzAChj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY0NvZFNp
# Z1BDQV8wOC0zMS0yMDEwLmNydDANBgkqhkiG9w0BAQUFAAOCAQEAaYnhEYD4B2Vt
# /JyTUb6Uq6aX88HEndmVgx5l7aBEL4w+xhRqXPllaoXkrEV4RrN1ShOuiD1kTbOe
# XEMniPZXEJJDu30sTMHTrkqIoKvZ6Jx7Vg0ery18dFL/32E+Ar78zp/FN7gxHeBl
# 9MVsg8uortjzcSgG8AgCoyfo8DN8cvLo6l4DdXCAROqb+DkAXJCj8BnDouG/eNBZ
# lp3ujhH9SDzqoe6TScf3WYBuGVkANNXlY03NT2r0VUo6MZ9588KCLO4aRkY0hlEB
# 4L7I/m9rk5zD9JPproTNQifg2hoXi/F+sTS0miax+cygdj0g2ixs+1qt/PdxRsRf
# eKIMdi9anzCCBbwwggOkoAMCAQICCmEzJhoAAAAAADEwDQYJKoZIhvcNAQEFBQAw
# XzETMBEGCgmSJomT8ixkARkWA2NvbTEZMBcGCgmSJomT8ixkARkWCW1pY3Jvc29m
# dDEtMCsGA1UEAxMkTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5
# MB4XDTEwMDgzMTIyMTkzMloXDTIwMDgzMTIyMjkzMloweTELMAkGA1UEBhMCVVMx
# EzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoT
# FU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEjMCEGA1UEAxMaTWljcm9zb2Z0IENvZGUg
# U2lnbmluZyBQQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCycllc
# GTBkvx2aYCAgQpl2U2w+G9ZvzMvx6mv+lxYQ4N86dIMaty+gMuz/3sJCTiPVcgDb
# NVcKicquIEn08GisTUuNpb15S3GbRwfa/SXfnXWIz6pzRH/XgdvzvfI2pMlcRdyv
# rT3gKGiXGqelcnNW8ReU5P01lHKg1nZfHndFg4U4FtBzWwW6Z1KNpbJpL9oZC/6S
# dCnidi9U3RQwWfjSjWL9y8lfRjFQuScT5EAwz3IpECgixzdOPaAyPZDNoTgGhVxO
# VoIoKgUyt0vXT2Pn0i1i8UU956wIAPZGoZ7RW4wmU+h6qkryRs83PDietHdcpRee
# jcsRj1Y8wawJXwPTAgMBAAGjggFeMIIBWjAPBgNVHRMBAf8EBTADAQH/MB0GA1Ud
# DgQWBBTLEejK0rQWWAHJNy4zFha5TJoKHzALBgNVHQ8EBAMCAYYwEgYJKwYBBAGC
# NxUBBAUCAwEAATAjBgkrBgEEAYI3FQIEFgQU/dExTtMmipXhmGA7qDFvpjy82C0w
# GQYJKwYBBAGCNxQCBAweCgBTAHUAYgBDAEEwHwYDVR0jBBgwFoAUDqyCYEBWJ5fl
# JRP8KuEKU5VZ5KQwUAYDVR0fBEkwRzBFoEOgQYY/aHR0cDovL2NybC5taWNyb3Nv
# ZnQuY29tL3BraS9jcmwvcHJvZHVjdHMvbWljcm9zb2Z0cm9vdGNlcnQuY3JsMFQG
# CCsGAQUFBwEBBEgwRjBEBggrBgEFBQcwAoY4aHR0cDovL3d3dy5taWNyb3NvZnQu
# Y29tL3BraS9jZXJ0cy9NaWNyb3NvZnRSb290Q2VydC5jcnQwDQYJKoZIhvcNAQEF
# BQADggIBAFk5Pn8mRq/rb0CxMrVq6w4vbqhJ9+tfde1MOy3XQ60L/svpLTGjI8x8
# UJiAIV2sPS9MuqKoVpzjcLu4tPh5tUly9z7qQX/K4QwXaculnCAt+gtQxFbNLeNK
# 0rxw56gNogOlVuC4iktX8pVCnPHz7+7jhh80PLhWmvBTI4UqpIIck+KUBx3y4k74
# jKHK6BOlkU7IG9KPcpUqcW2bGvgc8FPWZ8wi/1wdzaKMvSeyeWNWRKJRzfnpo1hW
# 3ZsCRUQvX/TartSCMm78pJUT5Otp56miLL7IKxAOZY6Z2/Wi+hImCWU4lPF6H0q7
# 0eFW6NB4lhhcyTUWX92THUmOLb6tNEQc7hAVGgBd3TVbIc6YxwnuhQ6MT20OE049
# fClInHLR82zKwexwo1eSV32UjaAbSANa98+jZwp0pTbtLS8XyOZyNxL0b7E8Z4L5
# UrKNMxZlHg6K3RDeZPRvzkbU0xfpecQEtNP7LN8fip6sCvsTJ0Ct5PnhqX9Guwdg
# R2VgQE6wQuxO7bN2edgKNAltHIAxH+IOVN3lofvlRxCtZJj/UBYufL8FIXrilUEn
# acOTj5XJjdibIa4NXJzwoq6GaIMMai27dmsAHZat8hZ79haDJLmIz2qoRzEvmtzj
# cT3XAH5iR9HOiMm4GPoOco3Boz2vAkBq/2mbluIQqBC0N1AI1sM9MIIGBzCCA++g
# AwIBAgIKYRZoNAAAAAAAHDANBgkqhkiG9w0BAQUFADBfMRMwEQYKCZImiZPyLGQB
# GRYDY29tMRkwFwYKCZImiZPyLGQBGRYJbWljcm9zb2Z0MS0wKwYDVQQDEyRNaWNy
# b3NvZnQgUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkwHhcNMDcwNDAzMTI1MzA5
# WhcNMjEwNDAzMTMwMzA5WjB3MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
# Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
# cmF0aW9uMSEwHwYDVQQDExhNaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EwggEiMA0G
# CSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCfoWyx39tIkip8ay4Z4b3i48WZUSNQ
# rc7dGE4kD+7Rp9FMrXQwIBHrB9VUlRVJlBtCkq6YXDAm2gBr6Hu97IkHD/cOBJjw
# icwfyzMkh53y9GccLPx754gd6udOo6HBI1PKjfpFzwnQXq/QsEIEovmmbJNn1yjc
# RlOwhtDlKEYuJ6yGT1VSDOQDLPtqkJAwbofzWTCd+n7Wl7PoIZd++NIT8wi3U21S
# tEWQn0gASkdmEScpZqiX5NMGgUqi+YSnEUcUCYKfhO1VeP4Bmh1QCIUAEDBG7bfe
# I0a7xC1Un68eeEExd8yb3zuDk6FhArUdDbH895uyAc4iS1T/+QXDwiALAgMBAAGj
# ggGrMIIBpzAPBgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBQjNPjZUkZwCu1A+3b7
# syuwwzWzDzALBgNVHQ8EBAMCAYYwEAYJKwYBBAGCNxUBBAMCAQAwgZgGA1UdIwSB
# kDCBjYAUDqyCYEBWJ5flJRP8KuEKU5VZ5KShY6RhMF8xEzARBgoJkiaJk/IsZAEZ
# FgNjb20xGTAXBgoJkiaJk/IsZAEZFgltaWNyb3NvZnQxLTArBgNVBAMTJE1pY3Jv
# c29mdCBSb290IENlcnRpZmljYXRlIEF1dGhvcml0eYIQea0WoUqgpa1Mc1j0BxMu
# ZTBQBgNVHR8ESTBHMEWgQ6BBhj9odHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtp
# L2NybC9wcm9kdWN0cy9taWNyb3NvZnRyb290Y2VydC5jcmwwVAYIKwYBBQUHAQEE
# SDBGMEQGCCsGAQUFBzAChjhodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2Nl
# cnRzL01pY3Jvc29mdFJvb3RDZXJ0LmNydDATBgNVHSUEDDAKBggrBgEFBQcDCDAN
# BgkqhkiG9w0BAQUFAAOCAgEAEJeKw1wDRDbd6bStd9vOeVFNAbEudHFbbQwTq86+
# e4+4LtQSooxtYrhXAstOIBNQmd16QOJXu69YmhzhHQGGrLt48ovQ7DsB7uK+jwoF
# yI1I4vBTFd1Pq5Lk541q1YDB5pTyBi+FA+mRKiQicPv2/OR4mS4N9wficLwYTp2O
# awpylbihOZxnLcVRDupiXD8WmIsgP+IHGjL5zDFKdjE9K3ILyOpwPf+FChPfwgph
# jvDXuBfrTot/xTUrXqO/67x9C0J71FNyIe4wyrt4ZVxbARcKFA7S2hSY9Ty5Zliz
# LS/n+YWGzFFW6J1wlGysOUzU9nm/qhh6YinvopspNAZ3GmLJPR5tH4LwC8csu89D
# s+X57H2146SodDW4TsVxIxImdgs8UoxxWkZDFLyzs7BNZ8ifQv+AeSGAnhUwZuhC
# El4ayJ4iIdBD6Svpu/RIzCzU2DKATCYqSCRfWupW76bemZ3KOm+9gSd0BhHudiG/
# m4LBJ1S2sWo9iaF2YbRuoROmv6pH8BJv/YoybLL+31HIjCPJZr2dHYcSZAI9La9Z
# j7jkIeW1sMpjtHhUBdRBLlCslLCleKuzoJZ1GtmShxN1Ii8yqAhuoFuMJb+g74TK
# IdbrHk/Jmu5J4PcBZW+JC33Iacjmbuqnl84xKf8OxVtc2E0bodj6L54/LlUWa8kT
# o/0xggSPMIIEiwIBATCBkDB5MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGlu
# Z3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBv
# cmF0aW9uMSMwIQYDVQQDExpNaWNyb3NvZnQgQ29kZSBTaWduaW5nIFBDQQITMwAA
# ALGHCwHSmMre3AABAAAAsTAJBgUrDgMCGgUAoIGoMBkGCSqGSIb3DQEJAzEMBgor
# BgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3
# DQEJBDEWBBSolfJdOj8/4bokG1JzvnR1EQYDaTBIBgorBgEEAYI3AgEMMTowOKAO
# gAwATwBwAGUAbgBDAFahJoAkaHR0cHM6Ly9naXRodWIuY29tL01TT3BlblRlY2gv
# b3BlbmN2MA0GCSqGSIb3DQEBAQUABIIBABGBemg8MNkWyJBgBS9KUr/8wZssISOr
# V7859S26ta7UdNiKZ+M4B2auke1J+y8NiCwOB9jiaEBq/4mh67QfxB1e8MPxB/q6
# YXh0q1I2uTy1MqnjbQiigBz+r0Ksth3h+Nyg73WfvjCdX447iG0mjpn0b8i9jfhz
# l/g2S86lCWMI/fenKZfRfLfqxyTbJOzjIQLeQeN0IBrB7sHMCr/JXxd2po5yO92B
# qgb+0MOYJBSaEuuJo7ZFTZwk+y+W5BN8I5RR45t/HrppFK96ztQqEtCk5XHWiBNU
# DEtRclwXVU0Oz32cNirmmX79DonzMzIAScuGmtpeiAJJsktZOpygvY2hggIoMIIC
# JAYJKoZIhvcNAQkGMYICFTCCAhECAQEwgY4wdzELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEhMB8GA1UEAxMYTWljcm9zb2Z0IFRpbWUtU3RhbXAg
# UENBAhMzAAAATKHoTcy0dHs7AAAAAABMMAkGBSsOAwIaBQCgXTAYBgkqhkiG9w0B
# CQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0xNDAzMTkxNjQ5NTFaMCMG
# CSqGSIb3DQEJBDEWBBSJY5ZhNFTmxtbQSQs1ZHehKt5WkTANBgkqhkiG9w0BAQUF
# AASCAQBR1tu8zC1F3ML5g+w8nXP8t1IBnMO3LTohFx9/J1/p7FKKTrKYmHjgfP6t
# rXID7CIoKNsmHYiBT6tiaSQDGRKqUpKXSD5IQO6N97iW7pGKZRf5p2a59sc8Lze5
# jNn3Y8vKtRRRTQSxgutGKAWvBCAXRfvC7/dQe5p+ieZBl3wGKwQ1X2olUCBXrdTl
# uaJ272BMrjV++j2JAvkWZQ3vCSB+Pb+TIbNtKZ1epkPegJR5/aevHaW1nrhePaSg
# pmFajriPg2x1qIMhlLFbMr/ZU9BoQ/vcjvQtvs8QCaEgIVfXxIsLu5wCNK8vuXxU
# x9EQuxij4XnN3p9jwYXiI/5wLkIh
# SIG # End signature block
