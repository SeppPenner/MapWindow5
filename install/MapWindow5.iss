; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

#define ExeBinPath "..\bin\x86\Release"
#define SamplePath "D:\dev\MapWindow-v5\GIT\install\testdata"
#define CPU "Win32"
#define vcredist "vcredist_x86-2013.exe"
#define SystemFlag "32bit"
#define MyAppName "MapWindow5"
#define MyAppPublisher "MapWindow Open Source GIS Community"
#define MyAppURL "http://www.mapwindow.org/documentation/mapwindow5/"
#define ReleaseNotes ExeBinPath + "\..\..\..\src\SolutionItems\ReleaseNotes.rtf"

#define x64BitVersion true

#ifdef x64BitVersion
  #define CPU "x64"
  #define vcredist "vcredist_x64_2013.exe"
  #define ExeBinPath "..\bin\x64\Release"
  #define SystemFlag "64bit"
#endif
#define MyAppVersion GetFileVersion(ExeBinPath + '\MapWindow.exe')

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
;; x86:
;;AppId={{EB12FA54-F2EE-4536-9A3E-3477A6049798}
;; x64:
AppId={{AF7BDDC6-2263-47B0-9AA2-DA03CA6E8DC6}

AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={pf}\MapWindow5
DisableProgramGroupPage=no
DefaultGroupName={#MyAppName}
LicenseFile={#ExeBinPath}\..\..\..\licenses\MapWindow5License.rtf
OutputDir=Output
OutputBaseFilename=MapWindow-v{#MyAppVersion}-{#CPU}
SetupIconFile=..\src\MW5\MW5.ico
UninstallDisplayIcon={uninstallexe}
Compression=lzma
SolidCompression=yes
WizardImageFile=WizImage-MW.bmp
WizardSmallImageFile=WizSmallImage-MW.bmp
AppCopyright={#MyAppPublisher}
PrivilegesRequired=none
MinVersion=0,6.0
ChangesEnvironment=no
AlwaysShowDirOnReadyPage=True
AlwaysShowGroupOnReadyPage=true
EnableDirDoesntExistWarning=True
;; UninstallDisplayName=MapWindow5 GIS uninstall
CompressionThreads=2
LZMANumBlockThreads=2
AppComments=This package will install {#MyAppName} {#MyAppVersion}
AppContact=Paul Meems (info@mapwindow.nl)
VersionInfoCompany=MapWindow Open Source GIS Team [www.mapwindow.org]
VersionInfoCopyright=Mozilla Public License (MPL) 1.1
VersionInfoDescription=MapWindow Open Source GIS [www.mapwindow.org]
VersionInfoProductName={#MyAppName}
VersionInfoProductVersion={#MyAppVersion}
AlwaysShowComponentsList=false
#ifdef x64BitVersion
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
#endif
ChangesAssociations=True
UsePreviousAppDir=False

[Components]
Name: "MapWindow"; Description: "MapWindow5 files"; Types: full custom compact; Flags: fixed
Name: "USASampleData"; Description: "USA Sample data"; Types: full

[Files]
;; MapWinGIS
Source: "{#ExeBinPath}\MapWinGIS\*.*"; DestDir: "{app}\MapWinGIS"; Flags: ignoreversion recursesubdirs createallsubdirs {#SystemFlag}; Components: MapWindow
;; MapWindow5 dlls
Source: "{#ExeBinPath}\*.dll"; DestDir: "{app}"; Flags: ignoreversion {#SystemFlag}; Components: MapWindow
Source: "{#ExeBinPath}\MapWindow.exe"; DestDir: "{app}"; Flags: ignoreversion {#SystemFlag}; Components: MapWindow
;; Manifest files:
Source: "{#ExeBinPath}\*.manifest"; DestDir: "{app}"; Flags: ignoreversion {#SystemFlag}; Components: MapWindow
;; Projections sub folder
Source: "{#ExeBinPath}\Projections\*"; DestDir: "{app}\Projections"; Flags: ignoreversion recursesubdirs createallsubdirs {#SystemFlag}; Components: MapWindow
;; Manuals sub folder
Source: "{#ExeBinPath}\Manuals\*"; DestDir: "{app}\Manuals"; Flags: ignoreversion recursesubdirs createallsubdirs {#SystemFlag}; Components: MapWindow
;; Plugins subfolder
Source: "{#ExeBinPath}\Plugins\*.dll"; DestDir: "{app}\Plugins"; Flags: ignoreversion {#SystemFlag}; Components: MapWindow; Excludes: "Interop.MapWinGIS.dll,MW5.TemplatePlugin.dll"
;; Styles subfolder
Source: "{#ExeBinPath}\Styles\*"; DestDir: "{app}\Styles"; Flags: ignoreversion recursesubdirs createallsubdirs {#SystemFlag}; Components: MapWindow
;; SQLite interop:
#ifdef x64BitVersion
Source: "{#ExeBinPath}\x64\*"; DestDir: "{app}\x64"; Flags: ignoreversion {#SystemFlag}; Components: MapWindow
#else
Source: "{#ExeBinPath}\x86\*"; DestDir: "{app}\x86"; Flags: ignoreversion {#SystemFlag}; Components: MapWindow
#endif
;; Config files:
Source: "{#ExeBinPath}\MapWindow.exe.config"; DestDir: "{app}"; Flags: ignoreversion {#SystemFlag}; Components: MapWindow
;; Licenses
Source: "D:\dev\MapwinGIS\GIT\support\GDAL_SDK\licenses\*.rtf"; DestDir: "{app}\Licenses"; Flags: ignoreversion; Components: MapWindow
Source: "{#ExeBinPath}\..\..\..\licenses\*"; DestDir: "{app}\Licenses"; Flags: ignoreversion {#SystemFlag}; Components: MapWindow

;; Sample data
Source: "{#SamplePath}\USA\*"; DestDir: "{code:GetDataDir}\USA"; Flags: recursesubdirs uninsneveruninstall; Components: USASampleData

;; VC++ files
Source: "{#vcredist}"; DestDir: "{tmp}"; Flags: deleteafterinstall ignoreversion {#SystemFlag}

;; Release notes:
Source: "{#ReleaseNotes}"; DestDir: "{app}"; Flags: ignoreversion; Components: MapWindow

; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Messages]
BeveledLabel={#MyAppName}

[Run]
; Install VC++ 2013 if needed:
#ifdef x64BitVersion
Filename: "{tmp}\{#vcredist}"; Parameters: "/qb"; Flags: waituntilterminated; Check: VCRedistNeedsInstall_x64()
#else
Filename: "{tmp}\{#vcredist}"; Parameters: "/qb"; Flags: waituntilterminated; Check: VCRedistNeedsInstall_x86()
#endif
Filename: "{app}\MapWindow.exe"; Flags: shellexec runasoriginaluser postinstall nowait skipifsilent; Description: "Start MapWindow5 GIS?"
Filename: "{code:GetDataDir}"; Flags: shellexec runasoriginaluser nowait skipifsilent; Description: "Open sample data folder"; Components: USASampleData
Filename: "{app}\ReleaseNotes.rtf"; Description: View the Release Notes; Flags: postinstall shellexec skipifsilent

[Icons]
;; In start menu:
Name: "{group}\{#MyAppName}"; Filename: "{app}\MapWindow.exe"; WorkingDir: "{app}"; Comment: "Start MapWindow5 GIS"; Components: MapWindow
;; On desktop:
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\MapWindow.exe"; WorkingDir: "{app}"; Comment: "Start MapWindow5 GIS"; Components: MapWindow

[Dirs]
Name: {code:GetDataDir}; Check: not DataDirExists; Flags: uninsneveruninstall; Permissions: users-modify
Name: "{app}\Logs"; Flags: uninsalwaysuninstall; Components: MapWindow; Permissions: users-modify
Name: "{app}\Styles"; Components: MapWindow; Permissions: users-modify
Name: "{app}\Projections"; Components: MapWindow; Permissions: users-modify

[UninstallDelete]
Type: filesandordirs; Name: "{app}\Logs"; Components: MapWindow

[Registry]
;; http://www.jrsoftware.org/isfaq.php#assoc
Root: HKCR; Subkey: ".mwproj"; ValueType: string; ValueName: ""; ValueData: "MW5Project"; Flags: uninsdeletevalue
Root: HKCR; Subkey: "MW5Project"; ValueType: string; ValueName: ""; ValueData: "MW5 Project"; Flags: uninsdeletekey
Root: HKCR; Subkey: "MW5Project\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: "{app}\MAPWINDOW.EXE,0"
Root: HKCR; Subkey: "MW5Project\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\MAPWINDOW.EXE"" ""%1"""

[InstallDelete]
Type: files; Name: "{app}\Plugins\MW5.TemplatePlugin.dll"; Components: MapWindow
Type: files; Name: "{app}\Plugins\Interop.MapWinGIS.dll"; Components: MapWindow

[Code]
#IFDEF UNICODE
  #DEFINE AW "W"
#ELSE
  #DEFINE AW "A"
#ENDIF
type
  INSTALLSTATE = Longint;
const
  INSTALLSTATE_INVALIDARG = -2;  // An invalid parameter was passed to the function.
  INSTALLSTATE_UNKNOWN = -1;     // The product is neither advertised or installed.
  INSTALLSTATE_ADVERTISED = 1;   // The product is advertised but not installed.
  INSTALLSTATE_ABSENT = 2;       // The product is installed for a different user.
  INSTALLSTATE_DEFAULT = 5;      // The product is installed for the current user.

  VC_2008_REDIST_X86 = '{FF66E9F6-83E7-3A3E-AF14-8DE9A809A6A4}';
  VC_2008_REDIST_X64 = '{350AA351-21FA-3270-8B7A-835434E766AD}';
  VC_2008_REDIST_IA64 = '{2B547B43-DB50-3139-9EBE-37D419E0F5FA}';
  VC_2008_SP1_REDIST_X86 = '{9A25302D-30C0-39D9-BD6F-21E6EC160475}';
  VC_2008_SP1_REDIST_X64 = '{8220EEFE-38CD-377E-8595-13398D740ACE}';
  VC_2008_SP1_REDIST_IA64 = '{5827ECE1-AEB0-328E-B813-6FC68622C1F9}';
  VC_2008_SP1_ATL_SEC_UPD_REDIST_X86 = '{1F1C2DFC-2D24-3E06-BCB8-725134ADF989}';
  VC_2008_SP1_ATL_SEC_UPD_REDIST_X64 = '{4B6C7001-C7D6-3710-913E-5BC23FCE91E6}';
  VC_2008_SP1_ATL_SEC_UPD_REDIST_IA64 = '{977AD349-C2A8-39DD-9273-285C08987C7B}';
  VC_2008_SP1_MFC_SEC_UPD_REDIST_X86 = '{9BE518E6-ECC6-35A9-88E4-87755C07200F}';
  VC_2008_SP1_MFC_SEC_UPD_REDIST_X64 = '{5FCE6D76-F5DC-37AB-B2B8-22AB8CEDB1D4}';
  VC_2008_SP1_MFC_SEC_UPD_REDIST_IA64 = '{515643D1-4E9E-342F-A75A-D1F16448DC04}';

  VC_2010_REDIST_X86 = '{196BB40D-1578-3D01-B289-BEFC77A11A1E}';
  VC_2010_REDIST_X64 = '{DA5E371C-6333-3D8A-93A4-6FD5B20BCC6E}';
  VC_2010_REDIST_IA64 = '{C1A35166-4301-38E9-BA67-02823AD72A1B}';
  VC_2010_SP1_REDIST_X86 = '{F0C3E5D1-1ADE-321E-8167-68EF0DE699A5}';
  VC_2010_SP1_REDIST_X64 = '{1D8E6291-B0D5-35EC-8441-6616F567A0F7}';
  VC_2010_SP1_REDIST_IA64 = '{88C73C1C-2DE5-3B01-AFB8-B46EF4AB41CD}';

  // http://stackoverflow.com/questions/27582762/inno-setup-for-visual-c-redistributable-package-for-visual-studio-2013
  VC_2013_REDIST_X86 = '{13A4EE12-23EA-3371-91EE-EFB36DDFFF3E}'; //Microsoft.VS.VC_RuntimeMinimumVSU_x86,v12
  VC_2013_REDIST_X64 = '{A749D8E6-B613-3BE3-8F5F-045C84EBA29B}'; //Microsoft.VS.VC_RuntimeMinimumVSU_amd64,v12


function MsiQueryProductState(szProduct: string): INSTALLSTATE; 
  external 'MsiQueryProductState{#AW}@msi.dll stdcall';

function VCVersionInstalled(const ProductID: string): Boolean;
begin
  Result := MsiQueryProductState(ProductID) = INSTALLSTATE_DEFAULT;
end;

function VCRedistNeedsInstall_x86(): Boolean;
begin
  // here the Result must be True when you need to install your VCRedist
  // or False when you don't need to, so now it's upon you how you build
  // this statement, the following won't install your VC redist only when
  // the Visual C++ 2008 Redist (x86) and Visual C++ 2008 SP1 Redist(x86)
  // are installed for the current user
  Result := not (VCVersionInstalled(VC_2013_REDIST_X86));
end;

function VCRedistNeedsInstall_x64(): Boolean;
begin
  // here the Result must be True when you need to install your VCRedist
  // or False when you don't need to, so now it's upon you how you build
  // this statement, the following won't install your VC redist only when
  // the Visual C++ 2008 Redist (x86) and Visual C++ 2008 SP1 Redist(x86)
  // are installed for the current user
  Result := not (VCVersionInstalled(VC_2013_REDIST_X64));
end;

function NeedsAddPath(Param: string): boolean;
var
  OrigPath: string;
begin
  if not RegQueryStringValue(HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
    'Path', OrigPath)
  then begin
    Result := True;
    exit;
  end;
  // look for the path with leading and trailing semicolon
  // Pos() returns 0 if not found
  Result := Pos(';' + Param + ';', ';' + OrigPath + ';') = 0;
end;

// https://lindsaybradford.wordpress.com/2013/11/18/configurable-data-directories-via-inno-setup/
var
  DataDirPage: TInputDirWizardPage;
 
function GetDataDir(Param: String): String;
begin
  { Return the selected DataDir }
  Result := DataDirPage.Values[0];
end;
 

// custom wizard page setup, for data dir.
procedure InitializeWizard;
var
  myLocalAppData: String;
begin
  DataDirPage := CreateInputDirPage(
    wpSelectComponents,
    '{#MyAppName} Data Directory',
    '',
    'Please select a directory to install {#MyAppName} sample data to.',
    False,
    '{#MyAppName}'
  );
  DataDirPage.Add('Sample data dir');
 
  // Default data dir:
  DataDirPage.Values[0] := ExpandConstant('{userdocs}\MapWindow5');
end;

function DataDirExists(): Boolean;
begin
  { Find out if data dir already exists }
  Result := DirExists(GetDataDir(''));
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  // initialize result to not skip any page (not necessary, but safer)
  Result := False;
  // if the page that is asked to be skipped is your custom page, then...
  if PageID = DataDirPage.ID then
    // if the component is not selected, skip the page
    Result := not IsComponentSelected('USASampleData');
end;

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
;Name: "afrikaans"; MessagesFile: "compiler:Languages\Afrikaans.isl"
;Name: "albanian"; MessagesFile: "compiler:Languages\Albanian.isl"
;Name: "arabic"; MessagesFile: "compiler:Languages\Arabic.isl"
;Name: "basque"; MessagesFile: "compiler:Languages\Basque.isl"
;Name: "belarusian"; MessagesFile: "compiler:Languages\Belarusian.isl"
;Name: "bosnian"; MessagesFile: "compiler:Languages\Bosnian.isl"
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"
;Name: "bulgarian"; MessagesFile: "compiler:Languages\Bulgarian.isl"
Name: "catalan"; MessagesFile: "compiler:Languages\Catalan.isl"
;Name: "chinesesimp"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"
;Name: "chinesetrad"; MessagesFile: "compiler:Languages\ChineseTraditional.isl"
Name: "corsican"; MessagesFile: "compiler:Languages\Corsican.isl"
Name: "czech"; MessagesFile: "compiler:Languages\Czech.isl"
Name: "danish"; MessagesFile: "compiler:Languages\Danish.isl"
Name: "dutch"; MessagesFile: "compiler:Languages\Dutch.isl"
;Name: "estonian"; MessagesFile: "compiler:Languages\Estonian.isl"
Name: "finnish"; MessagesFile: "compiler:Languages\Finnish.isl"
Name: "french"; MessagesFile: "compiler:Languages\French.isl"
;Name: "galician"; MessagesFile: "compiler:Languages\Galician.isl"
Name: "german"; MessagesFile: "compiler:Languages\German.isl"
Name: "greek"; MessagesFile: "compiler:Languages\Greek.isl"
Name: "hebrew"; MessagesFile: "compiler:Languages\Hebrew.isl"
Name: "hungarian"; MessagesFile: "compiler:Languages\Hungarian.isl"
;Name: "icelandic"; MessagesFile: "compiler:Languages\Icelandic.isl"
;Name: "indonesian"; MessagesFile: "compiler:Languages\Indonesian.isl"
Name: "italian"; MessagesFile: "compiler:Languages\Italian.isl"
Name: "japanese"; MessagesFile: "compiler:Languages\Japanese.isl"
;Name: "korean"; MessagesFile: "compiler:Languages\Korean.isl"
;Name: "lithuanian"; MessagesFile: "compiler:Languages\Lithuanian.isl"
;Name: "luxemburgish"; MessagesFile: "compiler:Languages\Luxemburgish.isl"
;Name: "macedonian"; MessagesFile: "compiler:Languages\Macedonian.isl"
;Name: "malaysian"; MessagesFile: "compiler:Languages\Malaysian.isl"
;Name: "nepali"; MessagesFile: "compiler:Languages\Nepali.islu"
Name: "norwegian"; MessagesFile: "compiler:Languages\Norwegian.isl"
Name: "polish"; MessagesFile: "compiler:Languages\Polish.isl"
Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"
;Name: "romanian"; MessagesFile: "compiler:Languages\Romanian.isl"
Name: "russian"; MessagesFile: "compiler:Languages\Russian.isl"
Name: "serbiancyrillic"; MessagesFile: "compiler:Languages\SerbianCyrillic.isl"
Name: "serbianlatin"; MessagesFile: "compiler:Languages\SerbianLatin.isl"
;Name: "slovak"; MessagesFile: "compiler:Languages\Slovak.isl"
Name: "slovenian"; MessagesFile: "compiler:Languages\Slovenian.isl"
Name: "spanish"; MessagesFile: "compiler:Languages\Spanish.isl"
;Name: "swedish"; MessagesFile: "compiler:Languages\Swedish.isl"
;Name: "tatarish"; MessagesFile: "compiler:Languages\Tatar.isl"
Name: "turkish"; MessagesFile: "compiler:Languages\Turkish.isl"
Name: "ukrainian"; MessagesFile: "compiler:Languages\Ukrainian.isl"

