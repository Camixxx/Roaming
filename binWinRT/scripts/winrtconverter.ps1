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

. ".\scripts\converterutils.ps1"

#use MSBuild namespace
$ms = 'http://schemas.microsoft.com/developer/msbuild/2003'
$ns = @{ ms = $ms }




Function ConvertAdditionalIncludesToRelativePaths($paths, $folder)
{
    $result = ""
    $tokens = $paths.replace(' ','').split(';')
    foreach($token in $tokens)
    {
        if($token -ne "%(AdditionalIncludeDirectories)")
        {
            $result += (Get-RelativePath $folder $token)  + ';' 
        }
        else
        {
            $result += "%(AdditionalIncludeDirectories);"
        }

    }
    return $result
}




Function WinrtConverter($inFile, $outFile, $platform)
{
    $InputDirPath = Split-Path -parent $inFile
    $InputDir =  [System.IO.Path]::GetFileNameWithoutExtension($InputDirPath)
    $fileName = [System.IO.Path]::GetFileNameWithoutExtension($inFile)
    $OutDir = Split-Path -parent $outFile

    #create output dir
    New-Item -ItemType Directory -Force -Path $OutDir

    <# 
        Try to load the output file.
        If successful, copy the guid out of the globals section
    #>

    $guid =$null

    try
    {
        $xml = New-Object -TypeName XML
        $xml.Load($outFile)
        $globals = Select-XML -Xml $xml -XPath '//ms:PropertyGroup[@Label="Globals"]' -Namespace $ns
        $guid = $globals.Node.ProjectGuid
    }
    catch
    {
        $guid = '{' + [guid]::NewGuid().toString().ToUpper() + '}'
    }

    # load input file into an XML object:
    $xml_win32 = New-Object -TypeName XML
    $xml_win32.Load($inFile)

    $configs = Select-XML -Xml $xml_win32 -XPath '//ms:PropertyGroup[@Label="Configuration"]' -Namespace $ns

    $Template = $null

    if($platform -eq "winrt")
    {
        if($configs[0].Node.ConfigurationType -eq "DynamicLibrary")
        {
            $Template = join-path $PSScriptRoot "templates\winrt_dll_template.vcxproj"
        }
        elseif($configs[0].Node.ConfigurationType -eq "StaticLibrary")
        {
            $Template = join-path $PSScriptRoot "templates\winrt_lib_template.vcxproj"
        }
        else
        {
            throw "Unknown vcxproj type"
        }
    }
    elseif($platform -eq "wp8")
    {
        if($configs[0].Node.ConfigurationType -eq "DynamicLibrary")
        {
            $Template = join-path $PSScriptRoot "templates\wp8_dll_template.vcxproj"
        }
        elseif($configs[0].Node.ConfigurationType -eq "StaticLibrary")
        {
            $Template = join-path $PSScriptRoot "templates\wp8_lib_template.vcxproj"
        }
        else
        {
            throw "Unknown vcxproj type"
        }
    }
    elseif($platform -eq "wp8_1")
    {
        if($configs[0].Node.ConfigurationType -eq "DynamicLibrary")
        {
            $Template = join-path $PSScriptRoot "templates\wp8_1_dll_template.vcxproj"
        }
        elseif($configs[0].Node.ConfigurationType -eq "StaticLibrary")
        {
            $Template = join-path $PSScriptRoot "templates\wp8_1_lib_template.vcxproj"
        }
        else
        {
            throw "Unknown vcxproj type"
        }
    }
    else
    {
        throw "Unknown platform argument -p (winrt, wp8 or wp8_1)"
    }

    $xml_template = New-Object -TypeName XML
    $xml_template.Load($Template)


    #Update Project Guid and Name
    $win32_globals = Select-XML -Xml $xml_win32 -XPath '//ms:PropertyGroup[@Label="Globals"]' -Namespace $ns

    $winrt_globals = Select-XML -Xml $xml_template -XPath '//ms:PropertyGroup[@Label="Globals"]' -Namespace $ns
    $winrt_globals.Node.ProjectGuid = $guid


    if($win32_globals.Node.ProjectName)
    {
        $winrt_globals.Node.RootNamespace = $win32_globals.Node.ProjectName
 
        if($winrt_globals.Node.ProjectName)
        {
            $winrt_globals.Node.ProjectName = $win32_globals.Node.ProjectName
        }
    }



    if($win32_globals.Node.RootNamespace)
    {
        $winrt_globals.Node.RootNamespace = $win32_globals.Node.RootNamespace
    }

    $project = Select-XML -Xml $xml_template -XPath '//ms:Project' -Namespace $ns



    foreach($item in (Select-XML -Xml $xml_win32 -XPath '//ms:ItemGroup' -Namespace $ns))
    {
        if ($item.node.ClInclude -or $item.node.ClCompile)
        {
            $newNode = $xml_template.ImportNode($item.Node, $true)
            $project.Node.AppendChild($newNode)
        }
    }


    #Copy ItemDefinitionGroup properties
    $debug_properties = $null
    $release_properties = $null


    foreach($item in (Select-XML -Xml $xml_win32 -XPath '//ms:ItemDefinitionGroup' -Namespace $ns))
    {
        if($item.node.Condition -match "debug")
        {
            $debug_properties = $item
        }
        else
        {
            $release_properties = $item
        }
    }

    $debug_includes = ConvertAdditionalIncludesToRelativePaths $debug_properties.Node.ClCompile.AdditionalIncludeDirectories $OutDir 
    $release_includes = ConvertAdditionalIncludesToRelativePaths $release_properties.Node.ClCompile.AdditionalIncludeDirectories $OutDir
    
    #hack to fix include paths
    $debug_includes = $debug_includes.replace("bin", $includehack)
    $release_includes = $release_includes.replace("bin", $includehack)

    foreach($item in (Select-XML -Xml $xml_template -XPath '//ms:ItemDefinitionGroup' -Namespace $ns))
    {
        $includes = $release_includes;
        $properties = $release_properties

        if($item.node.Condition -match "debug")
        {
            $includes = $debug_includes;
            $properties = $debug_properties
        }

        AddElement $xml_template $item.Node.ClCompile 'AdditionalIncludeDirectories'  $includes $ms
        AddElement $xml_template $item.Node.ClCompile 'PreprocessorDefinitions'  $properties.Node.ClCompile.PreprocessorDefinitions $ms
        if($properties.Node.ClCompile.PrecompiledHeader)
        {
           $item.Node.ClCompile.PrecompiledHeader = $properties.Node.ClCompile.PrecompiledHeader
        }

        if($properties.Node.ClCompile.PrecompiledHeaderFile)
        {
            AddElement $xml_template $item.Node.ClCompile 'PrecompiledHeaderFile'  "precomp.hpp" $ms
        }



        if($properties.Node.ClCompile.ForcedIncludeFiles)
        {
            AddElement $xml_template $item.Node.ClCompile 'ForcedIncludeFiles'  "precomp.hpp" $ms
         }


        if($properties.Node.ClCompile.DisableSpecificWarnings)
        {
            AddElement $xml_template $item.Node.ClCompile 'DisableSpecificWarnings'  $properties.Node.ClCompile.DisableSpecificWarnings $ms
        }
    }


    #save output file
    $xml_template.Save($outFile)




    foreach($item in (Select-XML -Xml $xml_template -XPath '//ms:Project//ms:ItemGroup//ms:ClCompile//ms:PrecompiledHeader' -Namespace $ns))
    {
        $newNode = $xml_template.ImportNode($item.Node, $true)
        $newNode.Condition = $newNode.Condition.replace("Win32", "ARM")
        $item.Node.parentNode.AppendChild($newNode)
        $newNode = $xml_template.ImportNode($item.Node, $true)
        $newNode.Condition = $newNode.Condition.replace("Win32", "x64")
        $item.Node.parentNode.AppendChild($newNode)
    }

    foreach($item in (Select-XML -Xml $xml_template -XPath '//ms:Project//ms:ItemGroup//ms:ClCompile//ms:PrecompiledHeaderFile' -Namespace $ns))
    {
        $item.Node."#text" = "precomp.hpp"
        $newNode = $xml_template.ImportNode($item.Node, $true)
        $newNode.Condition = $newNode.Condition.replace("Win32", "ARM")
        $item.Node.parentNode.AppendChild($newNode)
        $newNode = $xml_template.ImportNode($item.Node, $true)
        $newNode.Condition = $newNode.Condition.replace("Win32", "x64")
        $item.Node.parentNode.AppendChild($newNode)
    }

    $xml_template.selectNodes('//data/value[contains(.,"precomp.hpp")]')|
    ForEach-Object{
        $_.'#text' = 'precomp.hpp'
    }

    $xml_template.Save($outFile)


    #copy .filters file
    try
    {
        $filters = $inFile + ".filters"
        $xml_filters = New-Object -TypeName XML    
        $xml_filters.Load($filters)
        $xml_filters.Save($outFile + ".filters")
    }
    catch
    {
        Write-Host "No .filters file"
    }
}




# SIG # Begin signature block
# MIIasQYJKoZIhvcNAQcCoIIaojCCGp4CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUdP9zgkdVUGKANrCfDxt9BbhO
# lVugghWMMIIEwzCCA6ugAwIBAgITMwAAADQkMUDJoMF5jQAAAAAANDANBgkqhkiG
# 9w0BAQUFADB3MQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G
# A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMSEw
# HwYDVQQDExhNaWNyb3NvZnQgVGltZS1TdGFtcCBQQ0EwHhcNMTMwMzI3MjAwODI1
# WhcNMTQwNjI3MjAwODI1WjCBszELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hp
# bmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jw
# b3JhdGlvbjENMAsGA1UECxMETU9QUjEnMCUGA1UECxMebkNpcGhlciBEU0UgRVNO
# OkI4RUMtMzBBNC03MTQ0MSUwIwYDVQQDExxNaWNyb3NvZnQgVGltZS1TdGFtcCBT
# ZXJ2aWNlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA5RoHrQqWLNS2
# NGTLNCDyvARYgou1CdxS1HCf4lws5/VqpPW2LrGBhlkB7ElsKQQe9TiLVxj1wDIN
# 7TSQ7MZF5buKCiWq76F7h9jxcGdKzWrc5q8FkT3tBXDrQc+rsSVmu6uitxj5eBN4
# dc2LM1x97WfE7QP9KKxYYMF7vYCNM5NhYgixj1ESZY9BfsTVJektZkHTQzT6l4H4
# /Ieh7TlSH/jpPv9egMkGNgfb27lqxzfPhrUaS0rUJfLHyI2vYWeK2lMv80wegyxj
# yqAQUhG6gVhzQoTjNLLu6pO+TILQfZYLT38vzxBdGkVmqwLxXyQARsHBVdKDckIi
# hjqkvpNQAQIDAQABo4IBCTCCAQUwHQYDVR0OBBYEFF9LQt4MuTig1GY2jVb7dFlJ
# ZoErMB8GA1UdIwQYMBaAFCM0+NlSRnAK7UD7dvuzK7DDNbMPMFQGA1UdHwRNMEsw
# SaBHoEWGQ2h0dHA6Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3Rz
# L01pY3Jvc29mdFRpbWVTdGFtcFBDQS5jcmwwWAYIKwYBBQUHAQEETDBKMEgGCCsG
# AQUFBzAChjxodHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY3Jv
# c29mdFRpbWVTdGFtcFBDQS5jcnQwEwYDVR0lBAwwCgYIKwYBBQUHAwgwDQYJKoZI
# hvcNAQEFBQADggEBAA9CUKDVHq0XPx8Kpis3imdYLbEwTzvvwldp7GXTTMVQcvJz
# JfbkhALFdRxxWEOr8cmqjt/Kb1g8iecvzXo17GbX1V66jp9XhpQQoOtRN61X9id7
# I08Z2OBtdgQlMGESraWOoya2SOVT8kVOxbiJJxCdqePPI+l5bK6TaDoa8xPEFLZ6
# Op5B2plWntDT4BaWkHJMrwH3JAb7GSuYslXMep/okjprMXuA8w6eV4u35gW2OSWa
# l4IpNos4rq6LGqzu5+wuv0supQc1gfMTIOq0SpOev5yDVn+tFS9cKXELlGc4/DC/
# Zef1Od7qIu2HjKuyO7UBwq3g/I4lFQwivp8M7R0wggT2MIID3qADAgECAhMzAAAA
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
# DQEJBDEWBBTp99P291/3h1DRrs4IPKtfSXQ1VTBIBgorBgEEAYI3AgEMMTowOKAO
# gAwATwBwAGUAbgBDAFahJoAkaHR0cHM6Ly9naXRodWIuY29tL01TT3BlblRlY2gv
# b3BlbmN2MA0GCSqGSIb3DQEBAQUABIIBAEYkMqN0a2GF2oGCnG+uVXJmqHA4S2vH
# o5FfKJ9TniyDwyQJMi6iPybNYApswcaJ1qSuxCq+8knl665OX0xD3Hn4X77C6k03
# maWDWBPCKSyglBd5MZTP9/zuHGcTlOW9UHmwq0ftx7hhZoyA5YP6QZBjBGyBsT99
# ilfEXGgboXShoydVVsLysXmSAGRh4z4Xq35NDFvhWmm5fkih8tLGqSP8Uu5LnGkp
# 4z/NvzkmxVjfMnfhTZXA98ENsexhJ9AYorLZMB7/1Lb6R0ARCrLnOoGjomca7nxV
# zuLkQdYe5y01plZ6EhRtMiRoQunlY01K0U1AAFj16bI12R1nLJ/XgLqhggIoMIIC
# JAYJKoZIhvcNAQkGMYICFTCCAhECAQEwgY4wdzELMAkGA1UEBhMCVVMxEzARBgNV
# BAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jv
# c29mdCBDb3Jwb3JhdGlvbjEhMB8GA1UEAxMYTWljcm9zb2Z0IFRpbWUtU3RhbXAg
# UENBAhMzAAAANCQxQMmgwXmNAAAAAAA0MAkGBSsOAwIaBQCgXTAYBgkqhkiG9w0B
# CQMxCwYJKoZIhvcNAQcBMBwGCSqGSIb3DQEJBTEPFw0xNDAzMTkxNjQ5NTFaMCMG
# CSqGSIb3DQEJBDEWBBQ62frFLIRuACUT6QJ6SSAr+cWU+TANBgkqhkiG9w0BAQUF
# AASCAQAUg735Rs7dwyUCpatgRX8+B15pZjEjcQ6Igcihm7vEQ8XQ9cNjHTXvP4ck
# CeRL66ml6x4hY2URX8XYnyBFafIAK6UGWce96MqP6QcNM4u+UuCgbCTz2n1nAZDv
# Wkeewoz4liZzOoMYQ31+DZJJFtTQXP4dq1OYs6lgxlqihP9LYVOKRQWVoPsIom1B
# q/uZjVAJtgK2uWSUIQed83GGrP376F51yUACggFAqzGck1hmR/RvfLRoxTsSeoAj
# uYI741h9ZbGJdpqLwt05zQ+xOOnjBIcxdF/0C8RX8AYwnbq6EnsLxmuEEeFeGO7J
# gpnhYbOOdLTPZlCuR94zUMq6+rSd
# SIG # End signature block
