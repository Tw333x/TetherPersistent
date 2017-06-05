unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, IPPeerClient,
  IPPeerServer, FMX.StdCtrls, FMX.Layouts, FMX.Controls.Presentation, System.Generics.Collections,
  FMX.ScrollBox, FMX.Memo, System.Tether.Manager, System.Tether.AppProfile;

type
  TForm1 = class(TForm)
    TetheringManager1: TTetheringManager;
    Profile1: TTetheringAppProfile;
    memoMyStuff: TMemo;
    layButtons: TLayout;
    btnJoin: TButton;
    procedure TetheringManager1PairedFromLocal(const Sender: TObject; const AManagerInfo: TTetheringManagerInfo);
    procedure TetheringManager1PairedToRemote(const Sender: TObject; const AManagerInfo: TTetheringManagerInfo);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure memoMyStuffExit(Sender: TObject);
    procedure btnJoinClick(Sender: TObject);
    procedure TetheringManager1UnPairManager(const Sender: TObject; const AManagerInfo: TTetheringManagerInfo);
    function PublishResource(name: string): TLocalResource;
    function SubscribeToResource(name: string): TLocalResource;
    procedure ProfileResourceReceived(const Sender: TObject; const AResource: TRemoteResource);
  private
    { Private declarations }
    tethered: TDictionary<string, TMemo>;
    tempMemo: TMemo;
    MyPublishedInfo: TLocalResource;
    procedure setTempMemo(id: string);
    function shortId(id: string) : string;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.btnJoinClick(Sender: TObject);
begin
  TetheringManager1.AutoConnect;

  memoMyStuff.Text := shortId(TetheringManager1.Identifier) + ' ' + memoMyStuff.Text;
  MyPublishedInfo.Value := memomystuff.Text;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  tethered := TDictionary<string, TMemo>.create;
  btnJoin.Text := 'Join as ' + shortId(TetheringManager1.Identifier);
  Self.Caption := shortId(TetheringManager1.Identifier);
  MyPublishedInfo := PublishResource(TetheringManager1.Identifier);
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  tethered.Free;
end;

procedure TForm1.setTempMemo(id: string);
begin
  if tethered.ContainsKey(id) then
    tempMemo := tethered.Items[id]
  else
  begin
    tempMemo := TMemo.Create(self);
    tempMemo.Parent := Self;
    tempMemo.Align := TAlignLayout.Top;
    tethered.Add(id, tempMemo);
  end;
end;

function TForm1.shortId(id: string): string;
begin
  Result := id.Substring(1,6);
end;

procedure TForm1.memoMyStuffExit(Sender: TObject);
begin
  TetheringManager1.Text := memoMyStuff.Text;
  if Assigned(MyPublishedInfo) then
    MyPublishedInfo.Value := memomystuff.Text;
end;

procedure TForm1.ProfileResourceReceived(const Sender: TObject; const AResource: TRemoteResource);
begin
  if tethered.ContainsKey(AResource.name) then
  begin
    setTempMemo(AResource.name);
    tempMemo.Text := 'Resource @' + FormatDateTime('hh:mm:ss', Now) + #13#10 + shortId (AResource.name) + '>>' + AResource.Value.AsString;
  end
  else
  begin
    ShowMessage('Not found: ' + AResource.Profile.Manager.Identifier);
  end;

end;

function TForm1.PublishResource(name: string): TLocalResource;
var
  res: TLocalResource;
begin
  res := TLocalResource.Create(Profile1.Resources);
  res.IsPublic := True;
  res.Kind := TTetheringRemoteKind.Shared;
  res.Name := name;
  res.ResType := TRemoteResourceType.Data;
  result := res;

end;

function TForm1.SubscribeToResource(name: string): TLocalResource;
var
  res: TLocalResource;
begin
  res := TLocalResource.Create(Profile1.Resources);
  res.IsPublic := True;
  res.Kind := TTetheringRemoteKind.Mirror;
  res.Name := name;
  res.ResType := TRemoteResourceType.Data;
  res.OnResourceReceived := ProfileResourceReceived;
  result := res;
end;

procedure TForm1.TetheringManager1PairedFromLocal(const Sender: TObject; const AManagerInfo: TTetheringManagerInfo);
begin
  setTempMemo(AManagerInfo.ManagerIdentifier);
  tempMemo.Text := 'FromLocal @' + FormatDateTime('hh:mm:ss', Now) + #13#10 + shortId(AManagerInfo.ManagerIdentifier) + AManagerInfo.ManagerText;
  SubscribeToResource(AManagerInfo.ManagerIdentifier);
end;

procedure TForm1.TetheringManager1PairedToRemote(const Sender: TObject; const AManagerInfo: TTetheringManagerInfo);
begin
  setTempMemo(AManagerInfo.ManagerIdentifier);
  tempMemo.Text := 'ToRemote @ ' + FormatDateTime('hh:mm:ss', Now) + #13#10 + shortId (AManagerInfo.ManagerIdentifier) + AManagerInfo.ManagerText;
  SubscribeToResource(AManagerInfo.ManagerIdentifier);
end;

procedure TForm1.TetheringManager1UnPairManager(const Sender: TObject; const AManagerInfo: TTetheringManagerInfo);
begin
  if tethered.ContainsKey(AManagerInfo.ManagerIdentifier) then
  begin
    tethered.Items[AManagerInfo.ManagerIdentifier].Text := 'Unpaired'#13#10 + tethered.Items[AManagerInfo.ManagerIdentifier].Text;
    tethered.Items[AManagerInfo.ManagerIdentifier].Align := TAlignLayout.Bottom;
  end
  else
  begin
    ShowMessage('Can not find ' + AManagerInfo.ManagerIdentifier);
  end;
end;

end.

