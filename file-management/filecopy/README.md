# Copy-Script

A Powershell script wrapper around robocopy. Can be used to define copy jobs that are then processed one after the other.

## Konfiguration

Die Konfiguration besteht aus zwei Bereichen: General und JobList
Der Bereich General sieht wie folgt aus und enthält Einstellungen welche für das gesammte Script gültig sind:

```
<General>
    <LogPath>C:\Users\anbaumel\Desktop\Logs</LogPath>
    <RoboArgs>/r:5 /v /fp /ts /e /w:1 /NP</RoboArgs>
    <PrefixRemoveRegex>([\d]{2}.[\d]{2}.[\d]{2}_)|([\d]{2}.[\d]{2}.[\d]{2}.[\d]{2})|(_{0,1}[\d]{1,3}.[\d]{2}.[\d]{2}.[\d]{2})</PrefixRemoveRegex>
    <IgnoreFoldersList>Archiv;archiv</IgnoreFoldersList>
</General>
```

- **LogPath** gibt an wohin die Logs geschrieben werden. 
- **RoboArgs** gibt an mit welchen Argumenten Robocopy aufgerufen wird. Hier bitte nur etwas ändern wenn du dir ganz sicher bist.
- **PrefixRemoveRegex** enthält eine regular Expression welche verwendet wird um den Präfix von Ordern zu entfernen (z.B. aus 01.00.02 – Wartungsverträge würde dann Wartungsverträge werden)
- **IgnoreFoldersList** kann eine ; separierte Liste von Ordnernamen enthalten welche beim Kopieren ignoriert werden

Um das Script zu verwenden muss du im conf file einen oder mehrere Jobs in einer JobList erfassen:

```
<JobList>
    <Job>
        <SourcePath>\\btcstg1b\BTC-Data\03 - Sales\03.01 - Accounts\03.00.01 - IGS - IG Sozialversicherungen</SourcePath>
        <DestinationPath>G:\Sync\BTC (Schweiz) AG\IGS - IGS Dokumente\01 Sales</DestinationPath>
        <CleanPrefix>0</CleanPrefix>
        <UseIgnoreFolders>1</UseIgnoreFolders>
        <Name>IGS_Sales</Name>
    </Job>
    <Job>
        <SourcePath>\\btcstg1b\BTC-Data\03 - Sales\03.01 - Accounts\03.00.01 - IGS - IG Sozialversicherungen</SourcePath>
        <DestinationPath>G:\Sync\BTC (Schweiz) AG\IGS - IGS Dokumente\01 Sales</DestinationPath>
        <CleanPrefix>0</CleanPrefix>
        <UseIgnoreFolders>0</UseIgnoreFolders>
        <Name>IGS_Projekte</Name>
    </Job>
 </JobList>
```

- **SourcePath** gibt an von wo die Files kopiert werden
- **DestinationPath** gibt an wohin die Files kopiert werden
- **CleanPrefix** gibt an ob die Präfix der Ordner auf der Obersten Ebene bereinigt werden sollen oder nicht. Es wird dazu die Regular Expression verwendet welche 
in der Konfig im Abschnitt General unter PrefixRemoveRegex angegeben wird. 0 = nicht entfernen, 1 = Entfernen.
- **UseIgnoreFolders** gibt an ob die IgnoreFoldersList für diesen Job verwendet werden soll. 0 = Liste nicht verwenden, 1 = Liste verwenden
- **Name** erlaubt es einen Namen für diesen Job zu vergeben. Dadurch lassen sich die Jobs in den Logfiles leichter unterscheiden.

Die Jobs werden von oben nach unten abgearbeitet. Jeder Job bekommt ein eigenes Logfile. Die Files werden vom angegebenen Source Path rekursiv kopiert.

## Script Aufruf

Das Script wird in Powershell aufgerufen. Beispielaufruf unten:

`PS C:\Users\anbaumel> .\copyfiles.ps1 -config .\conf.xml -dryrun $false`

| Argument | Werte | Funktion |
| ------ | ------ |------ |
| -config | string | gibt den Pfad zum Konfigurations XML an|
| -dryrun | boolean | gibt an ob die files wirklich kopiert werden sollen oder ob nur eine Liste aller Files erstellt werden soll welche kopiert würden. -dryrun $true (oder keine Angabe) kopiert die files nicht -dryrun $false kopiert die files |
| -dbg    | boolean | gibt an ob Debug Infos in Log geschrieben werden |

## Log Files

Das Script schreibt ein allgemeines Logfile in den Pfad welcher in der Konfiguration angeben wurde und ein Logfile für jeden Job. Im Allgemeinen Log kann man verfolgen wie weit die Verarbeitung schon fortgeschritten ist. Im Job Log kann man prüfen welche Files dieser Job kopiert hat.
