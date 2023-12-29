function Get-GithubRepositoryPermissions
{
    #https://docs.github.com/en/rest/collaborators/collaborators#get-repository-permissions-for-a-user
    param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $ApiUserToken,
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $owner,
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]    
    [string]$repo,
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]    
    [string]$username)
    
    #/repos/{owner}/{repo}/collaborators/{username}/permission
    $Uri = "https://api.github.com/repos/$owner/$repo/collaborators/$username/permission"

    $results = curl.exe -X GET $Uri -H "Content-Type: application/json" -H "accept: application/json" -H "Authorization: Bearer $ApiUserToken" | ConvertFrom-Json

    return $results
}

function Get-GithubUserRepositories
{
    #https://docs.github.com/en/rest/collaborators/collaborators#get-repository-permissions-for-a-user
    param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $ApiUserToken,
    [Parameter(Mandatory)]    
    [string]$username)
    
    #/repos/{owner}/{repo}/collaborators/{username}/permission
    $Uri = "https://api.github.com/user/repos"

    $results = curl.exe -X GET $Uri -H "Content-Type: application/json" -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $ApiUserToken" | ConvertFrom-Json

    return $results
}

function Get-GithubBranches
{
  
    param (    
    [Parameter(Mandatory)]
    [string] $ApiUserToken,
    [Parameter(Mandatory)]    
    [string]$OWNER,
    [Parameter(Mandatory)]    
    [string]$REPO,
    [int]$sleepTime = 500,
    [int]$PAGE = 0)

    $Responses = New-Object "System.Collections.Generic.List[PSObject]"
    $bDiscontinue = $false
    $headers = @{ 
      'Authorization' = "Authorization: Bearer " + $ApiUserToken
      'Content-Type'  = 'application/json'
      'Accept'  = 'application/vnd.github+json'
      'X-GitHub-Api-Version' = '2022-11-28'
    }

    do 
    {
      $PAGE++

      #Using Max Page settings
      $URL = "https://api.github.com/repos/" + $OWNER + "/" + $REPO + "/branches?per_page=100&page=" + $PAGE      
      Write-Host "Calling $URL"
      $response = Invoke-WebRequest -UseBasicParsing -Uri $URL -Headers $headers

      #hard coded limit (you may need top adjust if you have more than 1000 branches)
      #also, you may hit api rate limits if there are many branches, may add a sleep statement to reduce the calls
      if ($PAGE -le 10) 
      {
        try
        {        
          if ($response.StatusCode -eq 200)
          {
            $Responses.Add(($response.Content | ConvertFrom-Json))

            if (!$response.Headers.Item('Link').ToString().Contains('next'))
            {
              $bDiscontinue  = $true #No More Pages
              Write-Host "Paging Complete"
            }
          }
          else
          {
            $bDiscontinue  = $true
          }
  
        }
        catch
        {
          Write-Host "Stopping" -ForegroundColor Red
          $bDiscontinue = $true
        }
      }
      else
      {
        $bDiscontinue = $true
      }

      [System.Threading.Thread]::Sleep($SleepTime)
    }
    Until($bDiscontinue)

    #$Responses | ForEach-Object { Write-Host $_ }

    return $Responses

}


function Get-GitHubUserOrganizations
{
    #https://docs.github.com/en/rest/orgs/orgs?apiVersion=2022-11-28#list-organizations-for-the-authenticated-user
    param (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string] $ApiUserToken,
        [Parameter(Mandatory)]    
        [string]$username)

    $headers = @{ 
            'Authorization' = "Authorization: Bearer " + $ApiUserToken
            'Content-Type'  = 'application/json'
            'Accept'  = 'application/vnd.github+json'
            'X-GitHub-Api-Version' = '2022-11-28'
    }

    $Uri = "https://api.github.com/user/orgs"

    $results = curl.exe -X GET $Uri -H "Content-Type: application/json" -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $ApiUserToken" | ConvertFrom-Json
    
    return $results
}

function Get-GitHubOrganization
{
  #https://docs.github.com/en/rest/orgs/orgs?apiVersion=2022-11-28#list-organizations-for-the-authenticated-user
  param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $ApiUserToken,
    [Parameter(Mandatory)]    
    [string]$Organization)

  $headers = @{ 
    'Authorization'        = 'Authorization: Bearer ' + $ApiUserToken
    'Content-Type'         = 'application/json'
    'Accept'               = 'application/vnd.github+json'
    'X-GitHub-Api-Version' = '2022-11-28'
  }

  $Uri = 'https://api.github.com/orgs/' + $Organization

  $results = curl.exe -X GET $Uri -H 'Content-Type: application/json' -H 'Accept: application/vnd.github+json' -H "Authorization: Bearer $ApiUserToken" | ConvertFrom-Json
    
  return $results
}
function Get-GitHubOrganizationRoles
{
  #https://docs.github.com/en/rest/orgs/orgs?apiVersion=2022-11-28#list-organizations-for-the-authenticated-user
  param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $ApiUserToken,
    [Parameter(Mandatory)]    
    [string]$Organization)

  $headers = @{ 
    'Authorization'        = 'Authorization: Bearer ' + $ApiUserToken
    'Content-Type'         = 'application/json'
    'Accept'               = 'application/vnd.github+json'
    'X-GitHub-Api-Version' = '2022-11-28'
  }

  $Uri = 'https://api.github.com/orgs/' + $Organization + '/organization-roles'

  $results = curl.exe -X GET $Uri -H 'Content-Type: application/json' -H 'Accept: application/vnd.github+json' -H "Authorization: Bearer $ApiUserToken" | ConvertFrom-Json
    
  return $results
}


function Get-GitHubOrganizationMembers
{
  #https://docs.github.com/en/rest/orgs/orgs?apiVersion=2022-11-28#list-organizations-for-the-authenticated-user
  param (
    [Parameter(Mandatory)]
    [ValidateNotNullOrEmpty()]
    [string] $ApiUserToken,
    [Parameter(Mandatory)]    
    [string]$Organization)

  $headers = @{ 
    'Authorization'        = 'Authorization: Bearer ' + $ApiUserToken
    'Content-Type'         = 'application/json'
    'Accept'               = 'application/vnd.github+json'
    'X-GitHub-Api-Version' = '2022-11-28'
  }

  $Uri = 'https://api.github.com/orgs/' + $Organization + '/members'

  $results = curl.exe -X GET $Uri -H 'Content-Type: application/json' -H 'Accept: application/vnd.github+json' -H "Authorization: Bearer $ApiUserToken" | ConvertFrom-Json
    
  return $results
}

Get-GitHubOrganizationRoles -ApiUserToken $env:myazdevops001 -Organization 'GHORG001'
$orgList = Get-GithubOrganizations -ApiUserToken $env:myazdevops001 -username myazdevops001
$orgDetailedList = $orgList | ForEach-Object { Get-GitHubOrganization -ApiUserToken $env:myazdevops001 -Organization $orgList.login }
$orgMembers = $orgDetailedList | ForEach-Object { Get-GitHubOrganizationMembers -ApiUserToken $env:myazdevops001 -Organization $orgList.login }
$orgMembers | Select-Object -Property login, type, site_admin | FT -AutoSize -Wrap