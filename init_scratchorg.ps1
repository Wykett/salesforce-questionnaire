param([string]$alias = (Get-Date).tostring("yyyyMMddhhmmss"))
sfdx force:org:create -f config/project-scratch-def.json --setalias $alias --setdefaultusername --wait 2
sfdx force:source:push