unit BE.ContextMenu;

interface

uses
  ToolsAPI,
  Vcl.Menus,
  BE.Constants,
  BE.Commands.Interfaces,
  BE.Wizard.Forms,
  System.Classes,
  System.SysUtils;

type
  TBEContextMenuWizard = class(TNotifierObject, IOTAProjectMenuItemCreatorNotifier)
  protected
    procedure AddMenu(const Project: IOTAProject;
                      const IdentList: TStrings;
                      const ProjectManagerMenuList: IInterfaceList;
                            IsMultiSelect: Boolean);

  public
    class function New: IOTAProjectMenuItemCreatorNotifier;
  end;

  TBEContextMenu = class(TNotifierObject, IOTALocalMenu, IOTAProjectManagerMenu)
  private
    FCaption: String;
    FIsMultiSelectable: Boolean;
    FChecked: Boolean;
    FEnabled: Boolean;
    FHelpContext: Integer;
    FName: string;
    FParent: string;
    FPosition: Integer;
    FVerb: string;

  protected
    FProject: IOTAProject;
    FBossCommand: IBECommands;

    procedure DoRefreshProject;

    procedure VerifyBoss;

    function GetCaption: string;
    function GetChecked: Boolean;
    function GetEnabled: Boolean;
    function GetHelpContext: Integer;
    function GetName: string;
    function GetParent: string;
    function GetPosition: Integer;
    function GetVerb: string;
    procedure SetCaption(const Value: string);
    procedure SetChecked(Value: Boolean);
    procedure SetEnabled(Value: Boolean);
    procedure SetHelpContext(Value: Integer);
    procedure SetName(const Value: string);
    procedure SetParent(const Value: string);
    procedure SetPosition(Value: Integer);
    procedure SetVerb(const Value: string);
    function GetIsMultiSelectable: Boolean;
    procedure SetIsMultiSelectable(Value: Boolean);
    procedure Execute(const MenuContextList: IInterfaceList); virtual;
    function PreExecute(const MenuContextList: IInterfaceList): Boolean;
    function PostExecute(const MenuContextList: IInterfaceList): Boolean;

    constructor create(Project: IOTAProject); virtual;
    class function New(Project: IOTAProject): IOTAProjectManagerMenu;
  end;

  TBEContextMenuBoss = class(TBEContextMenu, IOTALocalMenu, IOTAProjectManagerMenu)
  public
    constructor create(Project: IOTAProject); override;
  end;

  TBEContextMenuBossInit = class(TBEContextMenu, IOTALocalMenu, IOTAProjectManagerMenu)
  protected
    procedure Execute(const MenuContextList: IInterfaceList); override;

  public
    constructor create(Project: IOTAProject); override;
  end;

  TBEContextMenuInstall = class(TBEContextMenu, IOTALocalMenu, IOTAProjectManagerMenu)
  protected
    procedure Execute(const MenuContextList: IInterfaceList); override;

  public
    constructor create(Project: IOTAProject); override;
  end;

  TBEContextMenuUpdate = class(TBEContextMenu, IOTALocalMenu, IOTAProjectManagerMenu)
  protected
    procedure Execute(const MenuContextList: IInterfaceList); override;

  public
    constructor create(Project: IOTAProject); override;
  end;

  TBEContextMenuUninstall = class(TBEContextMenu, IOTALocalMenu, IOTAProjectManagerMenu)
  protected
    procedure Execute(const MenuContextList: IInterfaceList); override;

  public
    constructor create(Project: IOTAProject); override;
  end;

  TBEContextMenuDependencies = class(TBEContextMenu, IOTALocalMenu, IOTAProjectManagerMenu)
  protected
    procedure Execute(const MenuContextList: IInterfaceList); override;

  public
    constructor create(Project: IOTAProject); override;
  end;

  TBEContextMenuCacheRemove = class(TBEContextMenu, IOTALocalMenu, IOTAProjectManagerMenu)
  protected
    procedure Execute(const MenuContextList: IInterfaceList); override;

  public
    constructor create(Project: IOTAProject); override;
  end;

  TBEContextMenuSeparator = class(TBEContextMenu, IOTALocalMenu, IOTAProjectManagerMenu)
  public
    constructor create(Project: IOTAProject; Position: Integer); reintroduce;
    class function New(Project: IOTAProject; Position: Integer): IOTAProjectManagerMenu;
  end;

var
  IndexContextMenuBoss: Integer = -1;

procedure RegisterContextMenu;

implementation

procedure RegisterContextMenu;
begin
  IndexContextMenuBoss := (BorlandIDEServices as IOTAProjectManager)
    .AddMenuItemCreatorNotifier(TBEContextMenuWizard.New);
end;

{ TBEContextMenuWizard }

procedure TBEContextMenuWizard.AddMenu(const Project: IOTAProject;
                                       const IdentList: TStrings;
                                       const ProjectManagerMenuList: IInterfaceList;
                                             IsMultiSelect: Boolean);
begin
  if (IdentList.IndexOf(sProjectContainer) < 0) or
     (not Assigned(ProjectManagerMenuList))
  then
    Exit;

  ProjectManagerMenuList.Add(TBEContextMenuBoss.New(Project));
  ProjectManagerMenuList.Add(TBEContextMenuBossInit.New(Project));
  ProjectManagerMenuList.Add(TBEContextMenuSeparator.New(Project, BOSS_INSTALL_SEPARATOR_POSITION));
  ProjectManagerMenuList.Add(TBEContextMenuInstall.New(Project));
  ProjectManagerMenuList.Add(TBEContextMenuUpdate.New(Project));
  ProjectManagerMenuList.Add(TBEContextMenuUninstall.New(Project));
  ProjectManagerMenuList.Add(TBEContextMenuSeparator.New(Project, BOSS_DEPENDENCIES_SEPARATOR_POSITION));
  ProjectManagerMenuList.Add(TBEContextMenuDependencies.New(Project));
  ProjectManagerMenuList.Add(TBEContextMenuSeparator.New(Project, BOSS_CACHE_SEPARATOR_POSITION));
  ProjectManagerMenuList.Add(TBEContextMenuCacheRemove.New(Project));
end;

class function TBEContextMenuWizard.New: IOTAProjectMenuItemCreatorNotifier;
begin
  result := Self.Create;
end;

{ TBEContextMenuBoss }

constructor TBEContextMenuBoss.create(Project: IOTAProject);
begin
  inherited create(Project);
  FPosition := BOSS_POSITION;
  FCaption  := BOSS_CAPTION;
  FVerb     := BOSS_CAPTION;
end;

{ TBEContextMenu }

constructor TBEContextMenu.create(Project: IOTAProject);
begin
  FProject := Project;
  FBossCommand := CreateBossCommand(ExtractFilePath(FProject.FileName));
  FEnabled := True;
  FChecked := False;
  FIsMultiSelectable := False;
end;

procedure TBEContextMenu.DoRefreshProject;
begin
  FProject.Refresh(True);
end;

procedure TBEContextMenu.Execute(const MenuContextList: IInterfaceList);
begin
end;

function TBEContextMenu.GetCaption: string;
begin
  result := FCaption;
end;

function TBEContextMenu.GetChecked: Boolean;
begin
  result := FChecked;
end;

function TBEContextMenu.GetEnabled: Boolean;
begin
  result := FEnabled;
end;

function TBEContextMenu.GetHelpContext: Integer;
begin
  result := FHelpContext;
end;

function TBEContextMenu.GetIsMultiSelectable: Boolean;
begin
  Result := FIsMultiSelectable;
end;

function TBEContextMenu.GetName: string;
begin
  result := FName;
end;

function TBEContextMenu.GetParent: string;
begin
  result := FParent;
end;

function TBEContextMenu.GetPosition: Integer;
begin
  result := FPosition;
end;

function TBEContextMenu.GetVerb: string;
begin
  result := FVerb;
end;

class function TBEContextMenu.New(Project: IOTAProject): IOTAProjectManagerMenu;
begin
  result := Self.create(Project);
end;

function TBEContextMenu.PostExecute(const MenuContextList: IInterfaceList): Boolean;
begin
  result := True;
end;

function TBEContextMenu.PreExecute(const MenuContextList: IInterfaceList): Boolean;
begin
  result := True;
end;

procedure TBEContextMenu.SetCaption(const Value: string);
begin
  FCaption := Value;
end;

procedure TBEContextMenu.SetChecked(Value: Boolean);
begin
  FChecked := Value;
end;

procedure TBEContextMenu.SetEnabled(Value: Boolean);
begin
  FEnabled := Value;
end;

procedure TBEContextMenu.SetHelpContext(Value: Integer);
begin
  FHelpContext := Value;
end;

procedure TBEContextMenu.SetIsMultiSelectable(Value: Boolean);
begin
  FIsMultiSelectable := Value;
end;

procedure TBEContextMenu.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TBEContextMenu.SetParent(const Value: string);
begin
  FParent := Value;
end;

procedure TBEContextMenu.SetPosition(Value: Integer);
begin
  FPosition := Value;
end;

procedure TBEContextMenu.SetVerb(const Value: string);
begin
  FVerb := Value;
end;

procedure TBEContextMenu.VerifyBoss;
begin
  if not FBossCommand.BossInstalled then
    raise Exception.Create('Boss is not installed. Use Boss Init...');
end;

{ TBEContextMenuInstall }

constructor TBEContextMenuInstall.create(Project: IOTAProject);
begin
  inherited create(Project);
  FPosition := BOSS_INSTALL_POSITION;
  FCaption := BOSS_INSTALL_CAPTION;
  FVerb := BOSS_INSTALL_CAPTION;
  FParent := BOSS_CAPTION;
end;

procedure TBEContextMenuInstall.Execute(const MenuContextList: IInterfaceList);
begin
  VerifyBoss;
  FBossCommand.Install(Self.DoRefreshProject);
end;

{ TBEContextMenuBossInit }

constructor TBEContextMenuBossInit.create(Project: IOTAProject);
begin
  inherited create(Project);
  FCaption := BOSS_INIT_CAPTION;
  FPosition:= BOSS_INIT_POSITION;
  FVerb := BOSS_INIT_CAPTION;
  FParent := BOSS_CAPTION;

  FChecked := FBossCommand.BossInstalled;
end;

procedure TBEContextMenuBossInit.Execute(const MenuContextList: IInterfaceList);
begin
  if FBossCommand.BossInstalled then
    raise Exception.CreateFmt('Boss already installed.', []);
  FBossCommand.Init;
end;

{ TBEContextMenuUninstall }

constructor TBEContextMenuUninstall.create(Project: IOTAProject);
begin
  inherited create(Project);
  FCaption := BOSS_UNINSTALL_CAPTION;
  FPosition:= BOSS_UNINSTALL_POSITION;
  FVerb := BOSS_UNINSTALL_CAPTION;
  FParent := BOSS_CAPTION;

end;

procedure TBEContextMenuUninstall.Execute(const MenuContextList: IInterfaceList);
begin
  VerifyBoss;
  FBossCommand.Uninstall(Self.DoRefreshProject);
end;

{ TBEContextMenuUpdate }

constructor TBEContextMenuUpdate.create(Project: IOTAProject);
begin
  inherited create(Project);
  FCaption := BOSS_UPDATE_CAPTION;
  FPosition:= BOSS_UPDATE_POSITION;
  FVerb := BOSS_UPDATE_CAPTION;
  FParent := BOSS_CAPTION;
end;

procedure TBEContextMenuUpdate.Execute(const MenuContextList: IInterfaceList);
begin
  VerifyBoss;
  FBossCommand.Update(Self.DoRefreshProject);
end;

{ TBEContextMenuDependencies }

constructor TBEContextMenuDependencies.create(Project: IOTAProject);
begin
  inherited create(Project);
  FCaption := BOSS_DEPENDENCIES_CAPTION;
  FVerb := BOSS_DEPENDENCIES_CAPTION;
  FPosition := BOSS_DEPENDENCIES_POSITION;
  FParent := BOSS_CAPTION;
end;

procedure TBEContextMenuDependencies.Execute(const MenuContextList: IInterfaceList);
begin
  VerifyBoss;
  BEWizardForms := TBEWizardForms.create(nil, FBossCommand, FProject);
  try
    BEWizardForms.ShowModal;
  finally
    BEWizardForms.Free;
  end;
end;

{ TBEContextMenuSeparator }

constructor TBEContextMenuSeparator.create(Project: IOTAProject; Position: Integer);
begin
  inherited create(Project);
  FPosition := Position;
  FCaption := '-';
  FVerb := '-';
  FParent := BOSS_CAPTION;
end;

class function TBEContextMenuSeparator.New(Project: IOTAProject; Position: Integer): IOTAProjectManagerMenu;
begin
  result := Self.create(Project, Position);
end;

{ TBEContextMenuCacheRemove }

constructor TBEContextMenuCacheRemove.create(Project: IOTAProject);
begin
  inherited create(Project);
  FCaption := BOSS_REMOVE_CACHE_CAPTION;
  FVerb := BOSS_REMOVE_CACHE_CAPTION;
  FPosition := BOSS_REMOVE_CACHE_POSITION;
  FParent := BOSS_CAPTION;
end;

procedure TBEContextMenuCacheRemove.Execute(const MenuContextList: IInterfaceList);
begin
  VerifyBoss;
  FBossCommand.RemoveCache(Self.DoRefreshProject);
end;

initialization

finalization
  if IndexContextMenuBoss >= 0 then
    (BorlandIDEServices as IOTAProjectManager)
      .RemoveMenuItemCreatorNotifier(IndexContextMenuBoss);

end.
