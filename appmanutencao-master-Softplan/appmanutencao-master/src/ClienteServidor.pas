unit ClienteServidor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Datasnap.DBClient, Data.DB, SyncObjs;

type
  TServidor = class
  private
    FID: Integer;
    FPath: AnsiString;
  public
    constructor Create;
    //Tipo do parâmetro não pode ser alterado
    function SalvarArquivos(AData: OleVariant): Boolean;
  end;

  TfClienteServidor = class(TForm)
    ProgressBar: TProgressBar;
    btEnviarSemErros: TButton;
    btEnviarComErros: TButton;
    btEnviarParalelo: TButton;
    procedure FormCreate(Sender: TObject);
    procedure btEnviarSemErrosClick(Sender: TObject);
    procedure btEnviarComErrosClick(Sender: TObject);
    procedure btEnviarParaleloClick(Sender: TObject);
  private
    FPath: AnsiString;
    FServidor: TServidor;

    function InitDataset: TClientDataset;
    procedure EnviarArquivo;
    procedure EnviarSemErros;
  public
  end;
type
  TEnvioThread = class(TThread)
    private
      FQtdIteracao: Integer;
      FLock: TCriticalSection;
    constructor Create(iQtdIteracao: Integer; ALock: TCriticalSection);
    protected
      procedure Execute; override;
    public

  end;
var
  fClienteServidor: TfClienteServidor;

const  QTD_ARQUIVOS_ENVIAR = 100;

implementation

uses
  IOUtils;

{$R *.dfm}

{TTesteThread}
constructor TEnvioThread.Create(iQtdIteracao: Integer; ALock: TCriticalSection);
begin
  FQtdIteracao := iQtdIteracao;
  FLock        := ALock;
  inherited Create;
end;

procedure TEnvioThread.Execute;
var i : Integer;
begin

  for i := 0 to FQtdIteracao-1 do
  begin
    fClienteServidor.ProgressBar.Position := fClienteServidor.ProgressBar.Position + 1;

    fClienteServidor.EnviarArquivo;
  end;

end;

procedure TfClienteServidor.btEnviarSemErrosClick(Sender: TObject);
begin
  EnviarSemErros;
end;

procedure TfClienteServidor.EnviarSemErros;
var
  i: Integer;
begin
  ProgressBar.Max      := QTD_ARQUIVOS_ENVIAR;
  ProgressBar.Position := 0;
  FServidor.FID        := 0;

  for i := 0 to QTD_ARQUIVOS_ENVIAR-1 do
  begin
    ProgressBar.Position := ProgressBar.Position + 1;

    EnviarArquivo;
  end;
end;

procedure TfClienteServidor.btEnviarComErrosClick(Sender: TObject);
var
  i       : Integer;
  FileName: String;
begin
  try
    ProgressBar.Max      := QTD_ARQUIVOS_ENVIAR;
    ProgressBar.Position := 0;
    FServidor.FID        := 0;

    for i := 0 to QTD_ARQUIVOS_ENVIAR-1 do
    begin
      ProgressBar.Position := ProgressBar.Position + 1;

      EnviarArquivo;

      {$REGION Simulação de erro, não alterar}
      if i = (QTD_ARQUIVOS_ENVIAR/2) then
        FServidor.SalvarArquivos(NULL);
      {$ENDREGION}
    end;
  except
    begin
      for i := QTD_ARQUIVOS_ENVIAR-1 downto 0 do
      begin
        FileName := IncludeTrailingPathDelimiter(ExtractFilePath(String(FServidor.FPath))) + IntToStr(i) + '.pdf';
        if FileExists(FileName) then
        begin
          DeleteFile(FileName);
          ProgressBar.Position := ProgressBar.Position - 1;
        end;
      end;
    end;

    raise;
  end;

end;

procedure TfClienteServidor.btEnviarParaleloClick(Sender: TObject);
var
  iTotal, iIteracao: Integer;
  Threads : array [0..3] of TEnvioThread;
  Lock: TCriticalSection;
begin
  // Não sei se era exatamente essa a espectativa:
  // Implementei o envio em 4 Threads se houver mais que 10 arquivos a enviar.
  iTotal := QTD_ARQUIVOS_ENVIAR;
  if (iTotal > 10 ) then
  begin
    ProgressBar.Max      := QTD_ARQUIVOS_ENVIAR;
    ProgressBar.Position := 0;
    FServidor.FID        := 0;

    Lock := TCriticalSection.Create;

    // Distribui as interações entre as Threads
    iIteracao := Trunc(iTotal / 4);
    iTotal    := iTotal - (iIteracao * 3);

    Threads[0] := TEnvioThread.Create(iIteracao, Lock);
    Threads[1] := TEnvioThread.Create(iIteracao, Lock);
    Threads[2] := TEnvioThread.Create(iIteracao, Lock);
    Threads[3] := TEnvioThread.Create(iTotal, Lock);

    WaitForMultipleObjects(4, @Threads, True, INFINITE);
    Application.ProcessMessages;

    Threads[0].Free;
    Threads[1].Free;
    Threads[2].Free;
    Threads[3].Free;

    Lock.Free;

    // Idem comentário da threads
    fClienteServidor.ProgressBar.Position := fClienteServidor.ProgressBar.Max;
  end
  else
    EnviarSemErros;

end;

procedure TfClienteServidor.EnviarArquivo;
var
  cds: TClientDataset;
begin
  cds := InitDataset;
  cds.Append;
  TBlobField(cds.FieldByName('Arquivo')).LoadFromFile(String(FPath));
  cds.Post;
  FServidor.SalvarArquivos(cds.Data);
  cds.Close;
  cds.Free;
end;

procedure TfClienteServidor.FormCreate(Sender: TObject);
begin
  inherited;
  FPath      := AnsiString(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'pdf.pdf');
  FServidor  := TServidor.Create;
end;

function TfClienteServidor.InitDataset: TClientDataset;
begin
  Result := TClientDataset.Create(nil);
  Result.FieldDefs.Add('Arquivo', ftBlob);
  Result.CreateDataSet;
end;

{ TServidor }

constructor TServidor.Create;
begin
  FPath := AnsiString(ExtractFilePath(ParamStr(0)) + 'Servidor\');
  FID   := 0;
end;

function TServidor.SalvarArquivos(AData: OleVariant): Boolean;
var
  cds: TClientDataSet;
  FileName: string;
begin
  try
    Result := False;

    cds := TClientDataset.Create(nil);
    cds.Data := AData;

    {$REGION Simulação de erro, não alterar}
    if cds.RecordCount = 0 then
      Exit;
    {$ENDREGION}

    cds.First;

    while not cds.Eof do
    begin
      Inc(FID);
      FileName := String(FPath) + IntToStr(FID) + '.pdf';
      if TFile.Exists(FileName) then
        TFile.Delete(FileName);

      TBlobField(cds.FieldByName('Arquivo')).SaveToFile(FileName);
      cds.Next;
    end;

    cds.Close;
    cds.Free;
    Result := True;
  except

    raise;
  end;
end;

end.
