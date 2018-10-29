param([string]$alias = (Get-Date).tostring("yyyyMMddhhmmss"))
sfdx force:org:create -f config/project-scratch-def.json --setalias $alias --setdefaultusername
sfdx force:source:push
sfdx force:user:permset:assign --permsetname FieldProfile