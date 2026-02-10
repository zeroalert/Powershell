schedules:
  - cron: "0 */3 * * *"
    displayName: Every 3 Hours Everyday
    branches:
      include:
        - main
    always: true

resources:
  repositories:
    - repository: HelpDeskEmailFiles
      type: git
      name: DCS - System Engineers - Projects/HelpDeskEmailFiles
      ref: main
    - repository: self

stages:
  - stage: ONCallSync
    displayName: Sync Sharepoint On Call
    jobs:
      - job: 'Sync'
        displayName: Sync Sharepoint On Call
        pool:
          name: 'General Windows Workers GMSA'
        steps:
          - checkout: HelpDeskEmailFiles
          - checkout: self

          - task: PowerShell@2
            displayName: 'Sync On-Call Rotation'
            inputs:
              filePath: '$(System.DefaultWorkingDirectory)\SharePoint Utilities\Sharepoint_OnCall_Change.ps1'
              arguments: '-LogLocation "$(Build.ArtifactStagingDirectory)" -PfxPassword "$(PfxPassword)"'
              pwsh: true

          - task: PublishBuildArtifacts@1
            inputs:
              PathtoPublish: '$(Build.ArtifactStagingDirectory)'
              ArtifactName: 'Logfile'
              publishLocation: 'Container'
