# Import the Active Directory module
Import-Module ActiveDirectory

# Read the CSV file
$csvData = Import-Csv -Path ".\exportUserRegistrationDetails_2024-5-28.csv"

# Loop through each row in the CSV
foreach ($row in $csvData) {
    # Get the UPN from the current row
    $upn = $row.userPrincipalName

    # Check if the UPN is an external user
    if ($upn -like "*onmicrosoft*") {
        $division = "External User"
        $department = "External User"
        $jobTitle = "External User"
    } else {
        # Try to fetch the user from AD
        $user = Get-ADUser -Filter "UserPrincipalName -eq '$upn'" -Properties Division, Department, Title -ErrorAction SilentlyContinue

        # Check if the user was found
        if ($user) {
            $division = $user.Division
            $department = $user.Department
            $jobTitle = $user.Title
        } else {
            $division = "No Division Found"
            $department = "No Department Found"
            $jobTitle = "No Job Title Found"
        }
    }

    # Add the division, department, and job title to the current row
    $row | Add-Member -MemberType NoteProperty -Name "Division" -Value $division
    $row | Add-Member -MemberType NoteProperty -Name "Department" -Value $department
    $row | Add-Member -MemberType NoteProperty -Name "Job Title" -Value $jobTitle
}

# Export the updated CSV data to a new file
$csvData | Export-Csv -Path ".\updated_csv_file.csv" -NoTypeInformation
